MDebug(iErr:="", iErrTitle:="", iMode:="x", iLogFile:="", iTextErrEx:="", ExConfig:={}) {
	iDebug:=ExConfig.HasOwnProp("MDebug")?ExConfig.MDebug:"x|!"
	if !iDebug
		return
	switch iDebug {
	case "All", 1: iDebug:="x|!|i"
	case 2: iDebug:="x|!"
	case 3: iDebug:="x"
	}
	DebugModeRegEx:="i)\A(" iDebug ")\z"
	if !(iMode ~= DebugModeRegEx)
		return
	t:=""
	static IsLog:=0
	static LogFile:=""
	if iLogFile {
		LogFile:=iLogFile
	} else if !LogFile {
		LogFile:=(ExConfig.HasOwnProp("Name")?ExConfig.Name:A_ScriptName) ".log"
	}
	
	if !IsLog || !FileExist(LogFile) {
		t.="=================================================="
		if ExConfig.HasOwnProp("Name")
			t.="`nApp                : " ExConfig.Name (ExConfig.HasOwnProp("Ver")?" " ExConfig.Ver:"")
		if !OSVersion:=RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "LCUVer","")
			OSVersion:=A_OSVersion ((UBR:=RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "UBR",""))?"." UBR:"")
		t.="`nOSVersion          : " OSVersion
		t.="`nIs64bitOS          : " A_Is64bitOS
		t.="`nLanguage           : " A_Language
		t.="`nInstallationType   : " RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType","")
		t.="`nEditionID          : " RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID","")
		t.="`n==================================================`n"
		try FileDelete LogFile
		IsLog:=1
	}
	t.="`n" FormatTime(A_Now, "[yyyy/MM/dd HH:mm:ss") "." A_MSec "] [" iMode "]" (iErrTitle?" [" iErrTitle "] ":" ")	
	if InStr(Type(iErr), "Error") {
		t.="`nMessage            :" iErr.Message
		t.="`nExtra              :" iErr.Extra
		t.="`nStack              :" iErr.Stack
		t.=iTextErrEx?"`n" iTextErrEx:""
	} else {
		t.=iErr
		t.=iTextErrEx?"`n" iTextErrEx:""
	}
	FileAppend t, LogFile
}