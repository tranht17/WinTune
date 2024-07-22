CheckOS()
CheckOS() {
	If A_Is64bitOS && A_PtrSize==4 {
		MsgBoxError("You need the 64-bit version of the software (WinTune64) to run on 64-bit Windows.`n`nhttps://github.com/tranht17/WinTune/releases", 1, "Incompatible")
	}
}

OnExit ExitFunc
ExitFunc(ExitReason, ExitCode) {
	UnLoadHive()
}
OnError LogError
LogError(exception, mode) {
	Debug(exception)
	try DestroyDlg()
	return true
}

Init() {
	CheckAdmin()
	Global CurrentUser
	If !IsSet(CurrentUser) || !CurrentUser
		CurrentUser:=GetActiveUser()
	Global UserSID:=LookupAccountName(CurrentUser)
	Global HKCU:=GetHKCU()
	Global SystemInfo:=GetSystemInfo()
	Global LangSelected:=IniRead("config.ini", "General", "Language", "en")
}

GetSystemInfo() {
	SI:={}
	SI.InstallationType:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType")
	SI.EditionID:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID")
	; SI.ProductName:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName")
	; SI.DisplayVersion:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "DisplayVersion")
	; SI.RegisteredOwner:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "RegisteredOwner")
	Return SI
}

RegKeyExist(RegKey) {
	sKey:=StrSplit(RegKey, "\")
	cKey:=""
	Loop (sKey.Length-1)
		cKey.=(A_Index=1?"":"\") sKey[A_Index+1]
    exists := !DllCall("RegOpenKeyExW", "PTR", NumHK(sKey[1]), "wstr", cKey
						, "UINT", 0, "UINT", 131097, "PTR*", &hKey:=0)
    DllCall("RegCloseKey", "PTR", hKey)
    return exists
}

NumHK(RootKey) {
	NumRootKey:=0x80000001
	Switch RootKey {
		Case "HKEY_CLASSES_ROOT","HKCR": NumRootKey:=0x80000000
		Case "HKEY_CURRENT_USER","HKCU": NumRootKey:=0x80000001
		Case "HKEY_LOCAL_MACHINE","HKLM": NumRootKey:=0x80000002
		Case "HKEY_USERS","HKU": NumRootKey:=0x80000003
		Case "HKEY_CURRENT_CONFIG","HKCC": NumRootKey:=0x80000005
	}
	Return NumRootKey
}

HKCU2HCU(KeyName) {
	If InStr(KeyName, "HKEY_CURRENT_USER")=1
		KeyName := StrReplace(KeyName, "HKEY_CURRENT_USER", HKCU,,,1)
	Else If InStr(KeyName, "HKCU")=1
		KeyName := StrReplace(KeyName, "HKCU", HKCU,,,1)
	Return KeyName
}
GetHKCU() {
	UnLoadHive()
	rHKCU:="HKU\" UserSID
	ProfileImagePath := RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\" UserSID, "ProfileImagePath", "")
	If !ProfileImagePath
		MsgBoxError("'" UserSID "' does not exist", 1)
	If !RegKeyExist(rHKCU) {
		HiveFile:=ProfileImagePath "\NTUSER.DAT"
		If !FileExist(HiveFile)
			MsgBoxError("'" HiveFile "' does not exist", 1)
		RegLoadKey(HiveFile)
		rHKCU:="HKU\WinTune_Hive_tmp"
	}
	Global USERPROFILE:=ProfileImagePath
	Return rHKCU
}
UnLoadHive() {
	If RegKeyExist("HKU\WinTune_Hive_tmp")
		RegUnLoadKey()
}
RegLoadKey(HiveFile, HiveName:="WinTune_Hive_tmp", RootKey:="HKU") {
	EnablePrivilege("SeRestorePrivilege")
	EnablePrivilege("SeBackupPrivilege")
	If r:=DllCall("Advapi32.dll\RegLoadKey", "int", NumHK(RootKey), "str", HiveName, "str", HiveFile)
		MsgBoxError("(" r ")RegLoadKey: '" HiveFile "'", 1)
	Return r
}
RegUnLoadKey(HiveName:="WinTune_Hive_tmp", RootKey:="HKU") {
	If r:=DllCall("Advapi32.dll\RegUnLoadKey", "int", NumHK(RootKey), "Str", HiveName) {
		If r==5 {
			If ProcessExist("regedit.exe") {
				ProcessClose "regedit.exe"
				RegUnLoadKey(HiveName, RootKey)
			} Else {
				MsgBoxError('The key "' RootKey '\' HiveName '" is being opened by another application.`nPlease close those applications and click "OK"')
				RegUnLoadKey(HiveName, RootKey)
			}
		} Else
			Debug("RegUnLoadKey|Error: " r)
	}
	Return r
}
EnablePrivilege(Privilege) {
    hProc := DllCall("GetCurrentProcess", "UPtr")
    If DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", Privilege, "Int64P", &LUID := 0, "UInt")
    && DllCall("Advapi32.dll\OpenProcessToken", "Ptr", hProc, "UInt", 32, "PtrP", &hToken := 0, "UInt") { ; TOKEN_ADJUST_PRIVILEGES = 32
        TP:=Buffer(16) ; TOKEN_PRIVILEGES
        NumPut("UInt", 1, TP)
        NumPut("UInt64", LUID, TP, 4)
        NumPut("UInt", 2, TP, 12) ; SE_PRIVILEGE_ENABLED = 2
        DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", hToken, "UInt", 0, "Ptr", TP, "UInt", 0, "Ptr", 0, "Ptr", 0, "UInt")
    }
    LastError := A_LastError
	If LastError
		Debug("EnablePrivilege|Error: " LastError)
    If (hToken)
        DllCall("CloseHandle", "Ptr", hToken)
    Return LastError
}
EnvGet2(s) {
	r:=RegRead( HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders", s, "")
	Return r?StrReplace(r, "%USERPROFILE%", USERPROFILE):""
}
GetActiveUser() {
	wtsapi32 := DllCall("LoadLibrary", "Str", "wtsapi32.dll", "Ptr")
	DllCall("wtsapi32\WTSEnumerateSessionsEx", "Ptr", 0, "UPtr*", 1, "UPtr", 0, "Ptr*", &pSessionInfo:=0, "UPtr*", &wtsSessionCount:=0)
	UserName:=""
	cbWTS_SESSION_INFO_1:=(A_PtrSize == 8 ? 56 : 32)
	Loop wtsSessionCount {
		currSessOffset := cbWTS_SESSION_INFO_1 * (A_Index - 1)
		currSessOffset += 4, State := NumGet(pSessionInfo, currSessOffset, "UInt")
		currSessOffset += 4, SessionId := NumGet(pSessionInfo, currSessOffset, "UInt")
		If SessionId && (State == 0) {
			If nUserName:=NumGet(pSessionInfo, (currSessOffset += A_PtrSize*3), "Ptr") {
				UserName := StrGet(nUserName,, "UTF-16")
			}
			Break
		}
	}
	DllCall("wtsapi32\WTSFreeMemoryEx", "UPtr", 2, "Ptr", pSessionInfo, "UPtr", wtsSessionCount)
	DllCall("FreeLibrary", "Ptr", wtsapi32)
	Return UserName
}
LookupAccountName(UserName) {
	nSizeSID:=nSizeDomain:=256
	SID:=Buffer(nSizeSID)
	pDomain:=Buffer(nSizeDomain)
	DllCall("advapi32\LookupAccountName", "Str", "", "Str", UserName, "Ptr", SID, "PtrP", &nSizeSID, "Ptr", pDomain, "PtrP", &nSizeDomain, "PtrP", &eUser:=0)
	DllCall("advapi32\ConvertSidToStringSid", "Ptr", SID, "UPtrP", &pString:=0)
	If !pString
		MsgBoxError("User '" UserName "' does not exist", 1)
	Return StrGet(pString)
}
LookupAccountSid(SID) {
	r := {}
	nSizeName:=nSizeDomain:=256
	pName:=Buffer(nSizeName)
	pDomain:=Buffer(nSizeDomain)
	DllCall("advapi32\ConvertStringSidToSid", "Str", SID, "UPtr*", &pSID:=0)
	if !(DllCall("advapi32\LookupAccountSid", "Ptr", 0, "Ptr", pSID, "Ptr", pName, "UInt*", &nSizeName, "Ptr", pDomain, "UInt*", &nSizeDomain, "UInt*", &SNU:=0))
		return 0
	r.Name := StrGet(pName), r.Domain := StrGet(pDomain)
	return r
}

GetLangName(ItemId, LangId:="") {
	If !LangId
		LangId:=LangSelected
	Lang:=LangData.%LangId%
	
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Name") && Lang.%ItemId%.Name {
		ItemId:=Lang.%ItemId%.Name
		If InStr(ItemId, "Text_")==1
			ItemId:=GetLangText(ItemId)
	} Else If LangId!="en" {
		Return GetLangName(ItemId, "en")
	}
	Return ItemId
}
GetLangDesc(ItemId, LangId:="", Ex:="") {
	If !LangId
		LangId:=LangSelected
	Lang:=LangData.%LangId%
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Desc" Ex) && Lang.%ItemId%.Desc%Ex% {
		ItemDesc:=Lang.%ItemId%.Desc%Ex%
		If InStr(ItemDesc, "Text_")==1
			ItemDesc:=GetLangText(ItemDesc)
		Return ItemDesc
	} Else If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Desc") && Lang.%ItemId%.Desc {
		ItemDesc:=Lang.%ItemId%.Desc
		If InStr(ItemDesc, "Text_")==1
			ItemDesc:=GetLangText(ItemDesc)
		Return ItemDesc
	} Else If LangId!="en" {
		Return GetLangDesc(ItemId, "en", Ex)
	}
}
GetLangText(ItemId, LangId:="") {
	If !LangId
		LangId:=LangSelected
	Lang:=LangData.%LangId%
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%
		ItemId:=Lang.%ItemId%
	Else If LangSelected!="en" {
		Return GetLangText(ItemId, "en")
	}
	Return ItemId
}
WinHttpResponseText(Link, Method:="GET", Async:=0, WaitForResponseTimeoutInSeconds:=-2) {
	whr:=WinHttp(Link, Method, Async, WaitForResponseTimeoutInSeconds)
	c:=whr.responseText
	Return c
}

WinHttp(Link, Method:="GET", Async:=0, WaitForResponseTimeoutInSeconds:=-2) {
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	; Default value (milliseconds)
	; ResolveTimeout:=0
	; ConnectTimeout:=60000
	; SendTimeout:=30000
	; ReceiveTimeout:=30000
	; whr.SetTimeouts(ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout)
	whr.Open(Method, Link, Async)
	whr.Send()
	if Async && WaitForResponseTimeoutInSeconds>-2 {
		whr.WaitForResponse(WaitForResponseTimeoutInSeconds)
	}
	Return whr
}

GoSafeboot() {
	RunWait "bcdedit /set {current} safeboot minimal"
	Shutdown 6
}
ExitSafeboot() {
	RunWait "bcdedit /deletevalue {current} safeboot"
	Shutdown 6
}
HideToolTip() {
	SetTimer () => ToolTip(), -500
}
RefreshExplorer() { ; by teadrinker
   local Windows := ComObject("Shell.Application").Windows
   Windows.Item(ComValue(0x13, 8)).Refresh()
   for Window in Windows
      if (Window.Name != "Internet Explorer")
         Window.Refresh()
}
RestartExplorer() {
	ProcessClose "explorer.exe"
}
CheckAdmin() {
	full_command_line := DllCall("GetCommandLine", "str")
	Loop 2
		DllCall( "ChangeWindowMessageFilter", "uInt", "0x" (A_Index=1?49:233), "uint", 1)
	if !(A_IsAdmin || RegExMatch(full_command_line, " /restart(?!S)")) {	
		RunAsAdmin()
		ExitApp
	}
}
RunAsAdmin() {
	try {
		Params:=""
		Loop A_Args.Length {
			i:=A_Index
			If InStr(A_Args[i], " ")
				Params .= A_Space '"' A_Args[i] '"'
			Else
				Params .= A_Space A_Args[i]
		}
		if A_IsCompiled
			Run '*RunAs "' A_ScriptFullPath '" /restart' Params
		else
			Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"' Params
		Return 1
	}
	Return 0
}
MsgBoxError(iText, IsExitApp:=0, title:="Error") {
	MsgBox(iText,title,"Iconx")
	If IsExitApp
		ExitApp
}
Debug(iErr:="",iErrEx:="") {
	If IsSet(App)
		t:="`n================= " App.Name " v" App.Ver " ================="
	Else
		t:="`n=================================================="
	
	t.="`nTime     :" A_Now
	t.="`nOSVersion:" A_OSVersion
	t.="`nIs64bitOS:" A_Is64bitOS
	
	If Type(iErr)=="String" {
		t.="`n" iErr
		try Msg(iErr)
	} Else {
		t.="`nMessage  :" iErr.Message
		t.="`nExtra    :" iErr.Extra
		t.="`nStack    :" iErr.Stack
		try Msg(iErr.Message)
	}
	
	t.=iErrEx?"`n" iErrEx:""
	
	DebugMode:=IsSet(App)&&App.HasOwnProp("DebugMode")?App.DebugMode:1
	If DebugMode==1 {
		FileAppend t, "log.txt"
		try Run "notepad log.txt"
	} Else If DebugMode==2 {
		OutputDebug t
	}
}

/* Package Manager */
UninstallPackage(Package, IsAllUsers, IsDeprovision) {
	If IsDeprovision
		PackageManager.DeprovisionPackageForAllUsers(Package.FamilyName)
	If CurrentUser=A_Username || IsAllUsers {
		r1:=PackageManager.RemovePackage(Package.FullName, IsAllUsers?0x80000:0)
		r:=(r1==1)
		If r1==3 {
			If A_LastError==0x80073cfa && !IsWin11 && IsAllUsers {
				r2:=PackageManager.RemovePackage(Package.FullName)
				If r2==3 {
					Debug("RemovePackage error code:" Format("{:#x}",A_LastError))
				}
				r:=(r2==1)
			} Else
				Debug("RemovePackage error code:" Format("{:#x}",A_LastError))
		}				
	} Else {
		If r:=PS_RemovePackage(Package.FullName, UserSID)
			Debug(r)
		r:=!r
	}
	Return r
}
PS_RemovePackage(packageFullName, UserSID:="", removalOptions:="") {
	; -PreserveApplicationData: 
		; Specifies that the cmdlet preserves the application data during the package removal. 
		; The application data is available for later use.
		; Note that this is only applicable for apps that are under development 
		; so this option can only be specified for apps that are registered from file layout (Loose file registered).
	; -PreserveRoamableApplicationData:
		; Preserves the roamable portion of the app's data when the package is removed.
		; This parameter is incompatible with PreserveApplicationData.
	UserParam:=""
	If UserSID="All"
		UserParam:=" -AllUsers"
	Else If UserSID
		UserParam:=" -User " UserSID
	UserParam.=removalOptions?" " removalOptions:""
	Return RunTerminal('Powershell Remove-AppxPackage -Package ' packageFullName UserParam)
}

/* Hosts Edit */
SaveHostsFile(t) {
	HostsTMPPath:=A_Temp "\hosts_tmp_" A_Now
	FileAppend t, HostsTMPPath
	FileSetAttrib "-R", A_WinDir "\System32\drivers\etc\hosts"
	FileMove HostsTMPPath, A_WinDir "\System32\drivers\etc\hosts" , 1
}
LoadHostsFile() {
	Return FileRead(A_WinDir "\System32\drivers\etc\hosts")
}