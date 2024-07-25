#Requires AutoHotkey v2
#Include ../Lib/JSON.ahk
#Include ../Inc/LangData.ahk

A_FileEncoding:="UTF-8-RAW"
g := Gui(,"Language Converter Tool")
g.AddText(, "LangData.ahk path:")
g.AddEdit("readonly w300", "..\Inc\LangData.ahk")
g.AddText(, "Json path:")
g.AddEdit("readonly w300", "..\Lang\")
g.AddButton("h30 w124", "Convert to Json files").OnEvent("Click", Convert_LangJson)
g.AddButton("yp h30 w170", "Convert back LangData.ahk").OnEvent("Click", Convert_LangDataAHK)
g.Show()

for ,param in A_Args {
	MsgBox param
}

CheckLangExistList() {
	List:={}
	For k, In LangData.en.OwnProps() {
		i:=0
		Loop Files, "..\*.ahk", "R" {
			t:=FileRead(A_LoopFilePath)
			If InStr(t, '"' k '"')
				i++
			If InStr(t, 'v' k)
				i++
		}
		List.%k%:=i
	}
	FileAppend DisplayObj(List,1), "LangExistList.txt"
	MsgBox "Done!"
}
; CheckLangExist()
CheckLangExist() {
	For k,v In LangData.OwnProps() {
		If k="en"
			Continue
		For k2, In v.OwnProps() {
			If !LangData.en.HasOwnProp(k2) {
				A_Clipboard:=k2
				MsgBox k "|" k2
			}
				
		}
	}
}
Convert_LangDataAHK(*) {
	out:="LangData:= {"
	Loop Files, "..\Lang\*.json" {
		LangDataText:=FileRead(A_LoopFilePath)
		Lang:=JSON.parse(LangDataText,,False)
		out.="`n" SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName)-5) ": " DisplayObj(Lang,1) ","
	}
	out:=RTrim(out,',')
	out.="`n}"
	tLangDataFile:="..\Inc\LangData.ahk"
	try FileMove tLangDataFile, tLangDataFile "." A_Now, 1
	FileAppend out, tLangDataFile
	MsgBox "Done!"
}
Convert_LangJson(*) {
	LangPath:="..\Lang\"
	DirCreate LangPath
	For k,v In LangData.OwnProps() {
		tFile:=LangPath k ".json"
		try FileMove tFile, tFile "." A_Now, 1
		FileAppend DisplayObj(v, 1, True), tFile
	}
	MsgBox "Done!"
}

DisplayObj(Obj, ExpandLevel:=0, JsonFormat:=False, Child:=0) {
	Quotes:=JsonFormat?'"':''
	NewLine:=(ExpandLevel>Child?'`n':'')
	out:="{"
	If Obj.HasOwnProp("Name") {
		out.=NewLine Quotes 'Name' Quotes ': "' Obj.Name '",'
		Obj.DeleteProp("Name")
	}
	If Obj.HasOwnProp("Translator") {
		out.=NewLine Quotes 'Translator' Quotes ': "' Obj.Translator '",'
		Obj.DeleteProp("Translator")
	}
	If Obj.HasOwnProp("Flag") {
		out.=NewLine Quotes 'Flag' Quotes ': "' Obj.Flag '",'
		Obj.DeleteProp("Flag")
	}
	For k,v In Obj.OwnProps() {
		out.=NewLine Quotes k Quotes ': '
		If IsObject(v) && Child<5
			out.=DisplayObj(v, ExpandLevel, JsonFormat, Child+1)
		Else
			out.='"' ES(v, (JsonFormat?"\":"``")) '"'
		out.=','
	}
	out:=RTrim(out,',')
	Return out.=NewLine '}'
}
ES(S, E:="``") {
	S := StrReplace(S, "\", E "\")
	S := StrReplace(S, "`t", E "t")
	S := StrReplace(S, "`r", E "r")
	S := StrReplace(S, "`n", E "n")
	S := StrReplace(S, "`b", E "b")
	S := StrReplace(S, "`f", E "f")
	S := StrReplace(S, "`v", E "v")
	S := StrReplace(S, '"', E '"')
	Return S
}