CheckUninstallOneDrive() {
	OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
	if !FileExist(OneDriveSetup) {	
		OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
		if !FileExist(OneDriveSetup) {
			OneDriveSetup:=A_WinDir "\Sysnative\OneDriveSetup.exe"
			if !FileExist(OneDriveSetup)
				return -1
		}
	}
	OneDriveSetupRun:=RegRead(App.HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "OneDriveSetup", "")
	PreInstall:=!InStr(OneDriveSetupRun, "/uninstall")
	if !(OneDriveExist:=FileExist(EnvGet2("Local AppData") "\Microsoft\OneDrive\onedrive.exe")) {
		if !(OneDriveExist:=FileExist(A_ProgramFiles "\Microsoft OneDrive\OneDrive.exe")) && A_Is64bitOS {
				OneDriveExist:=FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft OneDrive\OneDrive.exe")
		}
	}
	r:=0
	if (!OneDriveExist && !OneDriveSetupRun) || (OneDriveExist && OneDriveSetupRun && !PreInstall)
		r:=1
	return r
}
UninstallOneDrive(s,d,silent) {
	OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
	if !FileExist(OneDriveSetup) {	
		OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
		if !FileExist(OneDriveSetup) {
			OneDriveSetup:=A_WinDir "\Sysnative\OneDriveSetup.exe"
			if !FileExist(OneDriveSetup)
				return -1
		}
	}
	if !(IsPerMachine:=!!FileExist(A_ProgramFiles "\Microsoft OneDrive\OneDrive.exe")) && A_Is64bitOS {
		IsPerMachine:=!!FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft OneDrive\OneDrive.exe")
	}
	OneDriveSetupCMD:=OneDriveSetup (IsPerMachine?' /allusers':'') (s?' /uninstall':'') ' /silent'
	if App.User=GetActiveUser() {
		if s
			ProcessClose "OneDrive.exe"
		RunWait OneDriveSetupCMD
	} else {
		try
			RegDelete App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", "OneDriveSetup"
		try
			RegDelete App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", "OneDrive"
		RegWrite OneDriveSetupCMD, "REG_SZ", App.HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce", "OneDriveSetup"
	}
}

CheckDisableVisualStudioTelemetry() {
	if FileExist(A_Is64bitOS?EnvGet("ProgramFiles(x86)"):A_ProgramFiles "\Microsoft Visual Studio\Installer\vswhere.exe")	
		return RegRead(App.HKCU "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch",0)
	else {
		return -1
	}
}
DisableVisualStudioTelemetry(s,d,silent) {
	Ver:=SubStr(RunTerminal(A_Is64bitOS?EnvGet("ProgramFiles(x86)"):A_ProgramFiles "\Microsoft Visual Studio\Installer\vswhere.exe -latest -property catalog_productDisplayVersion"), 1,2)
	RegWrite s, "REG_DWORD", App.HKCU "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch"
	RegWrite !s, "REG_DWORD", "HKLM\Software\WOW6432Node\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
	RegWrite !s, "REG_DWORD", App.HKCU "\Software\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
}

CheckDisableSystemRestore() {
	return !RegRead("HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval",0)
}
DisableSystemRestore(s,d,silent) {
	if s {
		RegWrite '0', "REG_DWORD", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval"
		RegDelete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients", "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
		RunTerminal(A_Comspec ' /c vssadmin delete shadows /all /quiet')
	} else {
		RegWrite '1', "REG_DWORD", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore", "RPSessionInterval"
		DriveLetter:=SubStr(A_WinDir, 1, 2)
		DeviceID:=""
		for CS in ComObjGet("winmgmts:").ExecQuery("SELECT DeviceID FROM Win32_Volume WHERE DriveLetter='" DriveLetter "'") {
			DeviceID:=CS.DeviceID
		}
		RegExMatch(DeviceID, "\\?\\(.*)", &SubPat)
		RegWrite Trim(SubPat[0]) ":" DriveGetLabel(DriveLetter) "(" SubStr(DriveLetter, 1, 1) "%3A)", "REG_MULTI_SZ", "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients", "{09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}"
		
	}
}

CheckDisableMSDefender(*) {
	; SafeBootMode:=SysGet(67)
	if !SysGet(67) {
		try {
			service:= ComObject("Schedule.Service")
			service.Connect()
			location:=service.GetFolder("\Microsoft\Windows\Windows Defender")		
			if location.GetTask("Windows Defender Cache Maintenance").Enabled
				return 0
			if location.GetTask("Windows Defender Cleanup").Enabled
				return 0
			if location.GetTask("Windows Defender Scheduled Scan").Enabled
				return 0
			if location.GetTask("Windows Defender Verification").Enabled
				return 0
		} catch {
			return -1
		}
	}
	try {
		if (SS:=Service_State("Sense")) && SS = 4
			return 0
		if (SS:=Service_State("WdBoot")) && SS = 4
			return 0
		if (SS:=Service_State("WdFilter")) && SS = 4
			return 0
		if (SS:=Service_State("WdNisDrv")) && SS = 4
			return 0
		if (SS:=Service_State("WdNisSvc")) && SS = 4
			return 0
		if (SS:=Service_State("WinDefend")) && SS = 4
			return 0
		return 1
	} catch {
		return -1
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
	if s {
		try {
			RegRead(regpath "Sense", "Start")
			RegWrite '4', "REG_DWORD", regpath "Sense", "Start"
		}
		RegWrite '4', "REG_DWORD", regpath "WdBoot", "Start"
		RegWrite '4', "REG_DWORD", regpath "WdFilter", "Start"
		RegWrite '4', "REG_DWORD", regpath "WdNisDrv", "Start"
		RegWrite '4', "REG_DWORD", regpath "WdNisSvc", "Start"
		RegWrite '4', "REG_DWORD", regpath "WinDefend", "Start"
	} else {
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
	if silent {
		RunDisableMSDefender%n%(s)
	} else {
		HideToolTip()
		Result := MsgBox(GetLangText("Text_DisableMSDefender" s), App.Name, "YesNo Icon?")
		if Result = "Yes" {
			RunDisableMSDefender%n%(s)
		} else {
			return !s
		}
	}
}
