;ServiceName:="DiagTrack"
;Service_Info(ServiceName)
;MsgBox Service_State(ServiceName, true)
;Service_Change_StartType(ServiceName, 2)
; Service_Start(ServiceName)
;Service_Stop(ServiceName)
;MsgBox Service_State(ServiceName, true)
;a:=Service_List(State:="Inactive")
;MsgBox a.Count
;MsgBox a["DiagTrack"]["svcType"]

;Service_Info(ServiceName)

/*
        *** Service State codes: ***

SERVICE_STOPPED (1) : The service is not running.
SERVICE_START_PENDING (2) : The service is starting.
SERVICE_STOP_PENDING (3) : The service is stopping.
SERVICE_RUNNING (4) : The service is running.
SERVICE_CONTINUE_PENDING (5) : The service continue is pending.
SERVICE_PAUSE_PENDING (6) : The service pause is pending.
SERVICE_PAUSED (7) : The service is paused.
*/
Service_State(ServiceName, textResult:=false) { ; Return Values			  
	SCM_HANDLE := OpenSCManager(0x1)
	hSvc := OpenService(SCM_HANDLE,ServiceName,0x4)
    
    If (!hSvc)
        result := 0
    Else {
        SC_STATUS := Buffer(28, 0)
		QueryServiceStatus(hSvc, SC_STATUS)
        result := NumGet(SC_STATUS,4,"UInt")
		CloseServiceHandle(hSvc)
    }
    CloseServiceHandle(SCM_HANDLE)
    
    If (textResult) {
        r := result
        result := (r=1) ? "Stopped" : (r=2) ? "Start Pending" : (r=3) ? "Stop Pending" : (r=4) ? "Running" : (r=5) ? "Continue Pending" : (r=6) ? "Pause Pending" : (r=7) ? "Paused" : "Unknown"
    }
    return result
}

Service_Info(ServiceName) {
	encoding := (!StrLen(Chr(0xFFFF))) ? "UTF-8" : "UTF-16"	
	SCM_HANDLE := OpenSCManager(0xF003F)
	hSvc := OpenService(SCM_HANDLE,ServiceName,0x0001)

	If (!hSvc) {
		result := 0
	} Else {
		QueryServiceConfig(hSvc,,,&bSize:=0)				
		QUERY_SERVICE_CONFIG := Buffer(bSize,0)
		QueryServiceConfig(hSvc,QUERY_SERVICE_CONFIG,bSize)
		
		If (bSize) {
			svcType := NumGet(QUERY_SERVICE_CONFIG,0,"UInt")
			svcStartMode := NumGet(QUERY_SERVICE_CONFIG,4,"UInt")
			svcErrCtl := NumGet(QUERY_SERVICE_CONFIG,8,"UInt")
			binPath_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 12 : 16, "UPtr")
			svcPathName := StrGet(binPath_LPSTR,encoding)
			;lpLoadOrderGroup:16:24
			;dwTagId:20:32
			depen_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 24 : 40, "UPtr")
			ServiceStartName_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 28 : 48, "UPtr")
			DispName_LPSTR := NumGet(QUERY_SERVICE_CONFIG,(A_PtrSize=4) ? 32 : 56, "UPtr")
			svcDispName := StrGet(DispName_LPSTR,encoding)
			
			offset := 0, svcDep := Map(), svcTrigger := 0, svcDelayed := false, svcDesc := ""
			While (curDep := StrGet(depen_LPSTR+offset,encoding)) {
				svcDep[curDep] := ""
				offset += (StrLen(curDep) + 1) * ((A_PtrSize=4) ? 1 : 2)
			}
			
			SERVICE_CONFIG_DESCRIPTION:=1
			QueryServiceConfig2(hSvc, SERVICE_CONFIG_DESCRIPTION,,, &bSize:=0)		
			if (bSize) {
				SERVICE_DESCRIPTION := Buffer(bSize,0)
				QueryServiceConfig2(hSvc, SERVICE_CONFIG_DESCRIPTION,SERVICE_DESCRIPTION,bSize)
				str_ptr := NumGet(SERVICE_DESCRIPTION,"UPtr")
				svcDesc := str_ptr ? StrGet(str_ptr,encoding) : ""
			}
			
			SERVICE_CONFIG_DELAYED_AUTO_START_INFO:=3
			QueryServiceConfig2(hSvc, SERVICE_CONFIG_DELAYED_AUTO_START_INFO,,, &bSize:=0)		
			if (bSize) {
				SERVICE_DELAYED_AUTO_START_INFO := Buffer(bSize,0)
				r:=QueryServiceConfig2(hSvc, SERVICE_CONFIG_DELAYED_AUTO_START_INFO,SERVICE_DELAYED_AUTO_START_INFO,bSize)
				svcDelayed := r ? NumGet(SERVICE_DELAYED_AUTO_START_INFO,"Char") : false
			}
			
			SERVICE_CONFIG_TRIGGER_INFO:=8
			QueryServiceConfig2(hSvc, SERVICE_CONFIG_TRIGGER_INFO,,, &bSize:=0)	
			If (bSize) {
				SERVICE_TRIGGER_INFO := Buffer(bSize,0)
				QueryServiceConfig2(hSvc, SERVICE_CONFIG_TRIGGER_INFO,SERVICE_TRIGGER_INFO,bSize)
				svcTrigger := NumGet(SERVICE_TRIGGER_INFO,"UInt")
			}
		}
		CloseServiceHandle(hSvc)		
		result :=  Map("svcName",ServiceName,"svcDispName",svcDispName,"svcStartMode",svcStartMode
					 ,"svcDesc",svcDesc,"svcPathName",svcPathName,"svcType",svcType,"svcDep",svcDep
					 ,"svcTrigger",svcTrigger,"svcDelayed",svcDelayed)
	}
	CloseServiceHandle(SCM_HANDLE)
	Return result
}

Service_List(State:="", SvcType:="") {  
    ServiceState := (State="Active") ? 0x1 : (State="Inactive") ? 0x2 : 0x3 ; 0x3 = All
    ServiceType  := (SvcType="Driver") ? 0xB : (SvcType="All") ? 0x3B : 0x30 ; 0x30 = Services Only
    
	SCM_HANDLE := OpenSCManager(0x4)
    
	EnumServicesStatus(SCM_HANDLE, ServiceType, ServiceState,,, &bSize:=0)
    ENUM_SERVICE_STATUS := Buffer(bSize, 0)
	EnumServicesStatus(SCM_HANDLE, ServiceType, ServiceState, ENUM_SERVICE_STATUS, bSize,, &ServiceCount:=0)
	
    struct_size1 := (A_PtrSize=4) ? 36 : 48
    encoding := (!StrLen(Chr(0xFFFF))) ? "UTF-8" : "UTF-16"
    svcObjList := Map()
    
    Loop ServiceCount {   
        SvcName_LPSTR := NumGet(ENUM_SERVICE_STATUS,(A_Index-1)*struct_size1,"UPtr")
		svcName := StrGet(SvcName_LPSTR,encoding)
        svcState := NumGet(ENUM_SERVICE_STATUS, ((A_Index-1)*struct_size1)+(A_PtrSize * 2)+4,"UInt")
		
		svcObj := Service_Info(svcName)
        svcObj["svcState"]:=svcState
        svcObjList[svcName] := svcObj
    }
    CloseServiceHandle(SCM_HANDLE)
    Return svcObjList
}

Service_Start(ServiceName) {
    ;Static ERROR_ACCESS_DENIED:=5, ERROR_INVALID_HANDLE:=6, ERROR_INVALID_NAME:=123, ERROR_SERVICE_DOES_NOT_EXIST:=1060
	SCM_HANDLE := OpenSCManager(0x1) ;SC_MANAGER_CONNECT
	hSvc := OpenService(SCM_HANDLE,ServiceName,0x10) ;SC_MANAGER_QUERY_LOCK_STATUS 0x10
    result := 0
    If (hSvc) {
		result := StartService(hSvc)
		CloseServiceHandle(hSvc)
    }
    CloseServiceHandle(SCM_HANDLE)
    return result
}

Service_Stop(ServiceName) {
	SCM_HANDLE := OpenSCManager(0x1) ;SC_MANAGER_CONNECT
	hSvc := OpenService(SCM_HANDLE,ServiceName,0x0020) ;SERVICE_STOP (0x0020)
    result := 0
    If (!hSvc)
        LastErr := 0
    Else {
        SERVICE_STATUS := Buffer((A_PtrSize=4)?28:32,0)
		result := ControlService(hSvc, SERVICE_STATUS)
        LastErr := A_LastError
        SERVICE_STATUS := ""
		CloseServiceHandle(hSvc)
    }
    CloseServiceHandle(SCM_HANDLE)
    A_LastError := LastErr
    return result
}

; StartType: [Auto/AutoMatic], [Demand/OnDemand], Disabled 
Service_Add(ServiceName, BinaryPath, StartType:="", DisplayName:="") {
    if !A_IsAdmin
        Return False
   
	SCM_HANDLE := OpenSCManager(0x2)
    StartType := (StartType="Auto" Or StartType="Automatic") ? 0x2 : (StartType="Demand" Or StartType="OnDemand") ? 0x3 : 0x4 ; 0x4 = Disabled   
	SC_HANDLE := CreateService(SCM_HANDLE, ServiceName, DisplayName, 0xF01FF, 0x110, StartType, 0x1, BinaryPath) 	
    result := A_LastError ? SC_HANDLE "," A_LastError : 1
	CloseServiceHandle(SC_HANDLE)
    CloseServiceHandle(SCM_HANDLE)
    Return result
}

Service_Delete(ServiceName) {
    if !A_IsAdmin ;Requires Administrator rights
        Return False
    
	SCM_HANDLE := OpenSCManager(0x1)
    result := 0
	hSvc := OpenService(SCM_HANDLE,ServiceName,0xF01FF) ;SERVICE_ALL_ACCESS (0xF01FF)
    If !hSvc
        result := -4 ;Service Not Found

    if !result
        result := DeleteService(hSvc)
	CloseServiceHandle(SCM_HANDLE)
    Return result    
}

Service_Change_StartType(ServiceName, sStartType) {
	if !A_IsAdmin ;Requires Administrator rights
        Return False
	SCM_HANDLE := OpenSCManager(0xF003F)
	hSvc := OpenService(SCM_HANDLE,ServiceName,0x0002)

	If (!hSvc) {
		result := 0
	} Else {
		result := ChangeServiceConfig(hSvc,,sStartType)
		CloseServiceHandle(hSvc)
	}
	CloseServiceHandle(SCM_HANDLE)
	Return result
}

;SC_MANAGER_ALL_ACCESS := 0xF003F
OpenSCManager(AR) {
	f := (!StrLen(Chr(0xFFFF))) ? "OpenSCManagerA" : "OpenSCManagerW"
	Return DllCall("advapi32\" f, "Ptr", 0, "Ptr", 0, "UInt", AR)
}

;SERVICE_CHANGE_CONFIG (0x0002)
OpenService(SCM_HANDLE,ServiceName,AR) {
	f := (!StrLen(Chr(0xFFFF))) ? "OpenServiceA" : "OpenServiceW"
	Return DllCall("advapi32\" f, "UInt", SCM_HANDLE, "Str", ServiceName, "UInt", AR)
}

QueryServiceConfig(hService, ServiceConfig:=0, BufSize:=0, &BytesNeeded:=0) {
	f := (!StrLen(Chr(0xFFFF))) ? "QueryServiceConfigA" : "QueryServiceConfigW"
	Return DllCall("advapi32\" f, "Ptr", hService, "Ptr", (ServiceConfig?ServiceConfig.Ptr:0), "UInt", BufSize, "UInt*", &BytesNeeded)
}

QueryServiceConfig2(hService, InfoLevel:=0, Buff:=0, BufSize:=0, &BytesNeeded:=0) {
	f := (!StrLen(Chr(0xFFFF))) ? "QueryServiceConfig2A" : "QueryServiceConfig2W"
	Return DllCall("advapi32\" f,"Ptr",hService, "UInt", InfoLevel,"Ptr",(Buff?Buff.Ptr:0), "UInt", BufSize, "UInt*", &BytesNeeded)
}

ChangeServiceConfig(hService,sType:=0xFFFFFFFF,sStartType:=0xFFFFFFFF) {
	;SERVICE_BOOT_START:=0x00000000
	;SERVICE_SYSTEM_START:=0x00000001
	;SERVICE_AUTO_START:=0x00000002
	;SERVICE_DEMAND_START:=0x00000003
	;SERVICE_DISABLED:=0x00000004
	;SERVICE_NO_CHANGE:=0xFFFFFFFF
	f := (!StrLen(Chr(0xFFFF))) ? "ChangeServiceConfigA" : "ChangeServiceConfigW"
	Return DllCall("advapi32\" f, "Ptr", hService, "UInt", sType, "UInt", sStartType, "UInt", 0xFFFFFFFF, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0)
}

EnumServicesStatus(hService, sType, sState, lpServices:=0, BufSize:=0, &BytesNeeded:=0, &sCount:=0, &ResumeHandle:=0) {
	f := (!StrLen(Chr(0xFFFF))) ? "EnumServicesStatusA" : "EnumServicesStatusW"
    Return DllCall("advapi32\" f
           ,"Ptr", hService,"UInt", sType,"UInt", sState,"Ptr", (lpServices?lpServices.Ptr:0)
           ,"UInt", BufSize,"UInt*", &BytesNeeded,"UInt*", &sCount,"UInt*", ResumeHandle)
}

QueryServiceStatus(hService, SC_STATUS) {
	Return DllCall("advapi32\QueryServiceStatus", "Ptr", hService, "Ptr", SC_STATUS.ptr)
}

StartService(hService) {
	f := (!StrLen(Chr(0xFFFF))) ? "StartServiceA" : "StartServiceW"
	Return DllCall("advapi32\" f, "UPtr", hService, "UInt", 0, "Ptr", 0)
}

ControlService(hService, SERVICE_STATUS) {
	Return DllCall("advapi32\ControlService", "UPtr", hService, "UInt", 1, "Ptr", SERVICE_STATUS.ptr)
}

CreateService(SCM_HANDLE, ServiceName, DisplayName:="", dwDesiredAccess:=0xF01FF, dwServiceType:=0x00000010, dwStartType:=2, dwErrorControl:=0x00000001, lpBinaryPathName:=0) {
  funcName2 := (!StrLen(Chr(0xFFFF))) ? "CreateServiceA" : "CreateServiceW"
 
	Return DllCall("advapi32\" funcName2
                   , "Ptr", SCM_HANDLE ; UInt?
                   , "Ptr", StrPtr(ServiceName)
                   , "Ptr", (!DisplayName ? StrPtr(ServiceName) : StrPtr(DisplayName))
                   , "UInt", dwDesiredAccess ;SERVICE_ALL_ACCESS (0xF01FF)
                   , "UInt", dwServiceType ;SERVICE_WIN32_OWN_PROCESS(0x00000010) | SERVICE_INTERACTIVE_PROCESS(0x00000100)
    ;;;;;; interactable service with desktop (requires local account)
    ;;;;;; http://msdn.microsoft.com/en-us/library/ms683502(VS.85).aspx
                   , "UInt", dwStartType
                   , "UInt", dwErrorControl ;SERVICE_ERROR_NORMAL(0x00000001)
                   , "Ptr", (lpBinaryPathName?StrPtr(lpBinaryPathName):0)
                   , "Ptr",  0 ;No Group (string)
                   , "UInt", 0 ;No TagId
                   , "Ptr",  0 ;No Dependencies (string)
                   , "Int",  0 ;Use LocalSystem Account
                   , "Ptr",  0) ;(String)
}

DeleteService(hService) {
	Return DllCall("advapi32\DeleteService", "Ptr", hService)
}

CloseServiceHandle(Handle) {
	DllCall("advapi32\CloseServiceHandle", "Ptr", Handle)
}
 