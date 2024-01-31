UserSID:=GetCurrentUserSID()
UserLocalAppData:=RegRead("HKU\" UserSID "\Volatile Environment", "LOCALAPPDATA")
SystemInfo:=GetSystemInfo()

GetSystemInfo() {
	SI:={}
	SI.InstallationType:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType")
	SI.EditionID:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID")
	SI.ProductName:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName")
	SI.DisplayVersion:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "DisplayVersion")
	SI.RegisteredOwner:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "RegisteredOwner")
	Return SI
}

RegKeyExist(RegKey) {
	sKey:=StrSplit(RegKey, "\")
	cKey:=""
	Loop (sKey.Length-1)
		cKey.=(A_Index=1?"":"\") sKey[A_Index+1]
	fKey:=sKey[1]
	RootKey:=0x80000001
	Switch fKey
	{
		Case "HKEY_CLASSES_ROOT","HKCR": RootKey:=0x80000000
		Case "HKEY_CURRENT_USER","HKCU": RootKey:=0x80000001
		Case "HKEY_LOCAL_MACHINE","HKLM": RootKey:=0x80000002
		Case "HKEY_USERS","HKU": RootKey:=0x80000003
		Case "HKEY_CURRENT_CONFIG","HKCC": RootKey:=0x80000005
	}
    exists := !DllCall("RegOpenKeyExW", "PTR", RootKey, "wstr", cKey
						, "UINT", 0, "UINT", 131097, "PTR*", &hKey:=0)
    DllCall("RegCloseKey", "PTR", hKey)
    return exists
}

HKCU2HCU(KeyName) {
	If InStr(KeyName, "HKEY_CURRENT_USER")=1
		KeyName := StrReplace(KeyName, "HKEY_CURRENT_USER", "HKU\" UserSID,,,1)
	Else If InStr(KeyName, "HKCU")=1
		KeyName := StrReplace(KeyName, "HKCU", "HKU\" UserSID,,,1)
	Return KeyName
}
GetCurrentUserSID()  {
	PID := ProcessExist()
	static PROCESS_QUERY_INFORMATION := 0x400, TOKEN_QUERY := 0x8
		, TokenUser := 1, TokenOwner := 4
	if !hProcess := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION, "UInt", false, "UInt", PID, "Ptr")
		Return Error("OpenProcess")
	if !DllCall("Advapi32\OpenProcessToken", "Ptr", hProcess, "UInt", TOKEN_QUERY, "PtrP", &hToken:=0)
		Return Error("OpenProcessToken", hProcess)
	tokenType:=TokenUser
	DllCall("Advapi32\GetTokenInformation", "Ptr", hToken, "Int", tokenType, "Ptr", 0, "Int", 0, "UIntP", &bites:=0)
	buff:=Buffer(bites)
	if !DllCall("Advapi32\GetTokenInformation", "Ptr", hToken, "Int", tokenType, "Ptr", buff, "Int", bites, "UIntP", &bites)
	  Return Error("GetTokenInformation", hToken)
	DllCall("CloseHandle", "Ptr", hProcess), DllCall("CloseHandle", "Ptr", hToken)
	DllCall("advapi32\ConvertSidToStringSid", "Ptr", NumGet(buff, "Ptr"), "UPtrP", &pString:=0)
	Return StrGet(pString)
}

WinHttp(link) {
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	whr.Open("get", link)
	whr.Send()
	whr.WaitForResponse()
	c:=whr.responseText
	whr:=""
	Return c
}

GoSafeboot() {
	RunWait "bcdedit /set {current} safeboot minimal"
	Restart()
}
ExitSafeboot() {
	RunWait "bcdedit /deletevalue {current} safeboot"
	Restart()
}
Restart() {
	Run "shutdown.exe /r /f /t 00"
}
