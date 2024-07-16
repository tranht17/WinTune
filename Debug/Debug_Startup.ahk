#Requires AutoHotkey v2
Keys:=["HKCU\Software\Microsoft\Windows\CurrentVersion\Run",
	   "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce",
	   "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run",
	   "HKLM\Software\Microsoft\Windows\CurrentVersion\Run",
	   "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce",
	   "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run",
	   "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce",
	   "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run"
]
CheckError()
CheckError() {
	m:=""
	Loop Keys.Length {
		Loop Reg, Keys[A_Index] {
			try {
				FindTarget(RegRead(), &rFileAttr)
			} catch {
				m.=RegRead() "`n"
			}
		}
	}
	if m {
		FileAppend m, "Startup_Error.txt"
		MsgBox 'Error! Please see "Startup_Error.txt"'
	} else {
		MsgBox "No error!"
	}
}
FindTarget(InPath, &rFileAttr) {
	If !InPath
		Return
	StartPos:=1
	tmpTarget:=""
	while (fpo:=RegexMatch(InPath, '[^" ]+|"([^"]*)"', &m, StartPos)) {
		if A_Index!=1
			tmpTarget.=' '
		tmpTarget.=m[1]?m[1]:m[]
		If InStr(tmpTarget, "%")
			tmpTarget:=ExpandEnvironmentStrings(tmpTarget)
		If InStr(FileExist(tmpTarget), "D") {
			rFileAttr:="D"
			Return tmpTarget
		} Else If InStr(FileExist(tmpTarget), "A") || InStr(FileExist(tmpTarget), "N") {
			SplitPath tmpTarget, &rFileName
			rFileAttr:="A"
			If SubStr(rFileName, -4)=".exe"
				rFileAttr.="E"
			Return tmpTarget
		}
		StartPos := fpo + StrLen(m[])
	}
}
ExpandEnvironmentStrings(str) {
	rExpanded:=Buffer(2000) 
	DllCall("ExpandEnvironmentStrings", "str", str, "ptr", rExpanded, "int", 1999)
	return StrGet(rExpanded)
}