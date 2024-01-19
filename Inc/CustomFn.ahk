CheckUninstallOneDrive() => !FileExist(UserLocalAppData "\Microsoft\OneDrive\onedrive.exe")
UninstallOneDrive(s,d,silent) {
	OneDriveSetup:=A_WinDir "\System32\OneDriveSetup.exe"
	If !FileExist(OneDriveSetup) {
		OneDriveSetup:=A_WinDir "\SysWOW64\OneDriveSetup.exe"
		If !FileExist(OneDriveSetup)
			Return -1
	}
	If s {
		ProcessClose "OneDrive.exe"
		RunWait OneDriveSetup ' /uninstall'
		Sleep 1000
		try
			DirDelete UserLocalAppData "\Microsoft\OneDrive", 1
	}
	Else 
		RunWait OneDriveSetup
}
CheckDisableVisualStudioTelemetry() {
	If FileExist(EnvGet("ProgramFiles(x86)") "\Microsoft Visual Studio\Installer\vswhere.exe")	
		Return RegRead("HKU\" UserSID "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch",0)
	Else {
		Return -1
	}
}
DisableVisualStudioTelemetry(s,d,silent) {
	Ver:=SubStr(RunTerminal(EnvGet("ProgramFiles(x86)") "\Microsoft Visual Studio\Installer\vswhere.exe -latest -property catalog_productDisplayVersion"), 1,2)
	RegWrite s, "REG_DWORD", "HKU\" UserSID "\Software\Microsoft\VisualStudio\Telemetry", "TurnOffSwitch"
	RegWrite !s, "REG_DWORD", "HKLM\Software\WOW6432Node\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
	RegWrite !s, "REG_DWORD", "HKU\" UserSID "\Software\Microsoft\VSCommon\" Ver ".0\SQM", "OptIn"
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
DisableMSDefender(s,d,silent){
	; SafeBootMode:=SysGet(67)
	If !SysGet(67) {
		service:= ComObject("Schedule.Service")
		service.Connect()
		location:=service.GetFolder("\Microsoft\Windows\Windows Defender")
		location.GetTask("Windows Defender Cache Maintenance").Enabled:=!s
		location.GetTask("Windows Defender Cleanup").Enabled:=!s
		location.GetTask("Windows Defender Scheduled Scan").Enabled:=!s
		location.GetTask("Windows Defender Verification").Enabled:=!s
		Sleep 1000
		If !silent {
			Result := MsgBox("You need go to Safe Mode and " (s?"":"Un") "Check it again.`nWould you like go to Safe Mode?", App.Name, "YesNo Icon?")
			if Result = "Yes" {
				RunWait "bcdedit /set {current} safeboot minimal"
				Run "shutdown.exe /r /f /t 00"
			}
		}
	} Else {
		regpath:='HKLM\SYSTEM\CurrentControlSet\Services\'
		If s {
			try {
				RegRead(regpath "\Sense", "Start")
				RegWrite '4', "REG_DWORD", regpath "Sense", "Start"
			}
			RegWrite '4', "REG_DWORD", regpath "WdBoot", "Start"
			RegWrite '4', "REG_DWORD", regpath "WdFilter", "Start"
			RegWrite '4', "REG_DWORD", regpath "WdNisDrv", "Start"
			RegWrite '4', "REG_DWORD", regpath "WdNisSvc", "Start"
			RegWrite '4', "REG_DWORD", regpath "WinDefend", "Start"
		} Else {
			try {
				RegRead(regpath "\Sense", "Start")
				RegWrite '3', "REG_DWORD", regpath "Sense", "Start"
			}
			RegWrite '0', "REG_DWORD", regpath "WdBoot", "Start"
			RegWrite '0', "REG_DWORD", regpath "WdFilter", "Start"
			RegWrite '3', "REG_DWORD", regpath "WdNisDrv", "Start"
			RegWrite '3', "REG_DWORD", regpath "WdNisSvc", "Start"
			RegWrite '2', "REG_DWORD", regpath "WinDefend", "Start"
		}
		If !silent {
			Result := MsgBox("Would you like exit Safe Mode?", App.Name, "YesNo Icon?")
			if Result = "Yes" {
				RunWait "bcdedit /deletevalue {current} safeboot"
				Run "shutdown.exe /r /f /t 00"
			}
		}
	}
}