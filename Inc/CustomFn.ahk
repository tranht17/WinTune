CheckUninstallOneDrive() {
	OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
	If !FileExist(OneDriveSetup) {	
		OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
		If !FileExist(OneDriveSetup) {
			OneDriveSetup:=A_WinDir "\Sysnative\OneDriveSetup.exe"
			If !FileExist(OneDriveSetup)
				Return -1
		}
	}
	OneDriveSetupRun:=RegRead(HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "OneDriveSetup", "")
	PreInstall:=!InStr(OneDriveSetupRun, "/uninstall")
	If !(OneDriveExist:=FileExist(EnvGet2("Local AppData") "\Microsoft\OneDrive\onedrive.exe")) {
		If !(OneDriveExist:=FileExist(A_ProgramFiles "\Microsoft OneDrive\OneDrive.exe")) && A_Is64bitOS {
				OneDriveExist:=FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft OneDrive\OneDrive.exe")
		}
	}
	r:=0
	If (!OneDriveExist && !OneDriveSetupRun) || (OneDriveExist && OneDriveSetupRun && !PreInstall)
		r:=1
	Return r
}
UninstallOneDrive(s,d,silent) {
	OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
	If !FileExist(OneDriveSetup) {	
		OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
		If !FileExist(OneDriveSetup) {
			OneDriveSetup:=A_WinDir "\Sysnative\OneDriveSetup.exe"
			If !FileExist(OneDriveSetup)
				Return -1
		}
	}
	If !(IsPerMachine:=!!FileExist(A_ProgramFiles "\Microsoft OneDrive\OneDrive.exe")) && A_Is64bitOS {
		IsPerMachine:=!!FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft OneDrive\OneDrive.exe")
	}
	OneDriveSetupCMD:=OneDriveSetup (IsPerMachine?' /allusers':'') (s?' /uninstall':'') ' /silent'
	If CurrentUser=GetActiveUser() {
		If s
			ProcessClose "OneDrive.exe"
		RunWait OneDriveSetupCMD
	} Else {
		try
			RegDelete HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", "OneDriveSetup"
		try
			RegDelete HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", "OneDrive"
		RegWrite OneDriveSetupCMD, "REG_SZ", HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "OneDriveSetup"
	}
}

CheckDisableVisualStudioTelemetry() {
	If FileExist(A_Is64bitOS?EnvGet("ProgramFiles(x86)"):A_ProgramFiles "\Microsoft Visual Studio\Installer\vswhere.exe")	
		Return RegRead(HKCU  "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch",0)
	Else {
		Return -1
	}
}
DisableVisualStudioTelemetry(s,d,silent) {
	Ver:=SubStr(RunTerminal(A_Is64bitOS?EnvGet("ProgramFiles(x86)"):A_ProgramFiles "\Microsoft Visual Studio\Installer\vswhere.exe -latest -property catalog_productDisplayVersion"), 1,2)
	RegWrite s, "REG_DWORD", HKCU  "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch"
	RegWrite !s, "REG_DWORD", "HKLM\Software\WOW6432Node\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
	RegWrite !s, "REG_DWORD", HKCU "\Software\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
}

CheckDisableSystemRestore() {
	Return !RegRead("HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval",0)
}
DisableSystemRestore(s,d,silent) {
	If s {
		RegWrite '0', "REG_DWORD", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval"
		RegDelete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients", "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
		RunTerminal(A_Comspec ' /c vssadmin delete shadows /all /quiet')
	} Else {
		RegWrite '1', "REG_DWORD", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval"
		DeviceID:=""
		For CS in ComObjGet("winmgmts:").ExecQuery("SELECT DeviceID FROM Win32_Volume WHERE DriveLetter='" SubStr(A_WinDir, 1, 2) "'") {
			DeviceID:=CS.DeviceID
		}
		RegExMatch(DeviceID, "\\?\\(.*)", &SubPat)
		RegWrite Trim(SubPat[0]) ":" DriveGetLabel(SubStr(A_WinDir, 1, 2)) "(" SubStr(A_WinDir, 1, 1) "%3A)", "REG_MULTI_SZ", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients", "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
	}
}

CheckDisableMSDefender(*) {
	; SafeBootMode:=SysGet(67)
	If !SysGet(67) {
		try {
			service:= ComObject("Schedule.Service")
			service.Connect()
			location:=service.GetFolder("\Microsoft\Windows\Windows Defender")		
			If location.GetTask("Windows Defender Cache Maintenance").Enabled
				Return 0
			If location.GetTask("Windows Defender Cleanup").Enabled
				Return 0
			If location.GetTask("Windows Defender Scheduled Scan").Enabled
				Return 0
			If location.GetTask("Windows Defender Verification").Enabled
				Return 0
		} Catch {
			Return -1
		}
	}
	try {
		If (SS:=Service_State("Sense")) && SS = 4
			Return 0
		If (SS:=Service_State("WdBoot")) && SS = 4
			Return 0
		If (SS:=Service_State("WdFilter")) && SS = 4
			Return 0
		If (SS:=Service_State("WdNisDrv")) && SS = 4
			Return 0
		If (SS:=Service_State("WdNisSvc")) && SS = 4
			Return 0
		If (SS:=Service_State("WinDefend")) && SS = 4
			Return 0
		Return 1
	} Catch {
		Return -1
	}
}
DisableMSDefenderScheduleTask(s) {
	service:= ComObject("Schedule.Service")
	service.Connect()
	location:=service.GetFolder("\Microsoft\Windows\Windows Defender")
	location.GetTask("Windows Defender Cache Maintenance").Enabled:=!s
	location.GetTask("Windows Defender Cleanup").Enabled:=!s
	location.GetTask("Windows Defender Scheduled Scan").Enabled:=!s
	location.GetTask("Windows Defender Verification").Enabled:=!s
}
DisableMSDefenderService(s) {
	regpath:='HKLM\SYSTEM\CurrentControlSet\Services\'
	If s {
		try {
			RegRead(regpath "Sense", "Start")
			RegWrite '4', "REG_DWORD", regpath "Sense", "Start"
		}
		RegWrite '4', "REG_DWORD", regpath "WdBoot", "Start"
		RegWrite '4', "REG_DWORD", regpath "WdFilter", "Start"
		RegWrite '4', "REG_DWORD", regpath "WdNisDrv", "Start"
		RegWrite '4', "REG_DWORD", regpath "WdNisSvc", "Start"
		RegWrite '4', "REG_DWORD", regpath "WinDefend", "Start"
	} Else {
		try {
			RegRead(regpath "Sense", "Start")
			RegWrite '3', "REG_DWORD", regpath "Sense", "Start"
		}
		RegWrite '0', "REG_DWORD", regpath "WdBoot", "Start"
		RegWrite '0', "REG_DWORD", regpath "WdFilter", "Start"
		RegWrite '3', "REG_DWORD", regpath "WdNisDrv", "Start"
		RegWrite '3', "REG_DWORD", regpath "WdNisSvc", "Start"
		RegWrite '2', "REG_DWORD", regpath "WinDefend", "Start"
	}
	
}
RunDisableMSDefender(s) {
	DisableMSDefenderScheduleTask(s)
	RegWrite A_ScriptFullPath ' /DisableMSDefenderService=' s, "REG_SZ", "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce", "*DisableMSDefenderService"
	Sleep 1000
	GoSafeboot()
}
RunDisableMSDefenderSafeMode(s) {
	DisableMSDefenderService(s)
	RegWrite A_ScriptFullPath ' /DisableMSDefenderScheduleTask=' s, "REG_SZ", "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce", "*DisableMSDefenderScheduleTask"
	Sleep 1000
	ExitSafeboot()
}
DisableMSDefender(s,d,silent){
	SafeBootMode:=SysGet(67)
	n:=SafeBootMode?"SafeMode":""
	If silent {
		RunDisableMSDefender%n%(s)
	} Else {
		HideToolTip()
		Result := MsgBox(GetLangText("Text_DisableMSDefender" s), App.Name, "YesNo Icon?")
		if Result = "Yes" {
			RunDisableMSDefender%n%(s)
		} Else {
			Return !s
		}
	}
}
