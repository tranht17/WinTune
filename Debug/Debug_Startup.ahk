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
	r:=""
	If !InPath
		Return r
	
	SplitPath InPath,, &dir, &ext, &name_no_ext
	sExt:=StrSplit(ext,A_Space)[1]
	InPath:=dir "\" name_no_ext "." sExt

	If InStr(InPath, "%") {
		r:=FindTarget(ExpandEnvironmentStrings(InPath), &rFileAttr)
	} Else If InStr(InPath,'"')=1 {
		r:=FindTarget(SubStr(InPath, 2 , InStr(InPath,'"',,2)-2), &rFileAttr)
	} Else If InStr(FileExist(InPath), "D") {
		rFileAttr:="D"
		r:=InPath
	} Else If InStr(FileExist(InPath), "A") || InStr(FileExist(InPath), "N") {
		SplitPath InPath, &rFileName
		rFileAttr:="A"
		If SubStr(rFileName, -4)=".exe"
			rFileAttr.="E"
		r:=InPath
	} 
	Return r
}
ExpandEnvironmentStrings(str) {
	rExpanded:=Buffer(2000) 
	DllCall("ExpandEnvironmentStrings", "str", str, "ptr", rExpanded, "int", 1999)
	return StrGet(rExpanded)
}