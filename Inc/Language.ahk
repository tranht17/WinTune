LanguageList:=Array()
Loop Files A_ScriptDir "\lang\*.json" {
    SplitPath A_LoopFileName, , , , &FileNameNoExt
    LanguageList.Push(FileNameNoExt)
}

CreatePopupLang(Ctr, *) {
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)

	g3:=Gui("-Caption" ,"Popup")
	FrameShadow(g3.hWnd)
	g3.SetFont("c" Themes.%ThemeSelected%.TextColor, "Segoe UI Semibold")
	g3.BackColor:="00A7EB"

    IsWin11:=VerCompare(A_OSVersion, ">=10.0.22000")
	IconFont:=IsWin11?"Segoe Fluent Icons":"Segoe MDL2 Assets"

    x:=8
    for k,v in LanguageList{
		BtnSys_SaveOptimizeConfigTab:=g3.AddText('vLang_Code_' k ' cWhite' ' x' x ' y' 6 ' w50 h30',LanguageTag.%v%)
		BtnSys_SaveOptimizeConfigTab.SetFont("s" (ThemeSelected=k?22:18),IconFont)
		BtnSys_SaveOptimizeConfigTab.OnEvent("Click", Language_Click)
		x+=58
    }
    Language_Click(Ctr, *){
        global LangCode
        LangSelected:=LanguageList[SubStr(Ctr.Name,11)]
        if (LangCode == LangSelected){
            return
		}else{
			global LangCode := LangSelected
			IniWrite LangSelected, "config.ini", "Language", "Language"
			if A_IsCompiled {
				Run '*RunAs "' A_AhkPath '" /restart'
			}
			else {
				Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
			}
		}
    }
    tX:=xG+xCtr-(x-wCtr)/2
	tY:=yG+yCtr+hCtr+6
	g3.Show("x" tX " y" tY)
	If WinWaitNotActive(g3)
		g3.Destroy()
}