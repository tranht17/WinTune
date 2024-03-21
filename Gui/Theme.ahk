CreatePopupTheme(Ctr, *) {
	If WinExist(App.Name "_Popup")
		WinClose
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)
	g2:=CreateDlg(g, 0, "00A7EB")
	
	x:=8
	For k,v In Themes.OwnProps() {
		BtnSys_SaveOptimizeConfigTab:=g2.AddText('vTheme_Color_' k ' c' v.BackColor ' x' x ' y' 6 ' w30 h30',ThemeSelected=k?Chr(0xEC61):Chr(0xE91F))
		BtnSys_SaveOptimizeConfigTab.SetFont("s" (ThemeSelected=k?22:20),IconFont)
		BtnSys_SaveOptimizeConfigTab.OnEvent("Click", Theme_Color_Click)
		x+=38
	}
	Theme_Color_Click(Ctr, *) {
		ThemeClicked:=SubStr(Ctr.Name,13)
		Global ThemeSelected
		If ThemeClicked=ThemeSelected
			Return
		PrevCtr:=Ctr.Gui["Theme_Color_" ThemeSelected]
		
		ThemeSelected:=ThemeClicked
		SetTheme(g, Themes.%ThemeSelected%)
		PrevCtr.Text:=Chr(0xE91F)
		PrevCtr.SetFont("s20")
		Ctr.Text:=Chr(0xEC61)
		Ctr.SetFont("s22")
		IniWrite ThemeSelected, "config.ini", "General", "Theme"
	}
	tX:=xG+xCtr-(x-wCtr)/2
	tY:=yG+yCtr+hCtr+6
	g2.Show("x" tX " y" tY)
	If WinWaitNotActive(g2)
		g2.Destroy()
}

SetTheme(g, Theme) {
	g.BackColor:=Theme.BackColor
	g.SetFont("c" Theme.TextColor)
	ToolTipOptions.SetColors("0x" Theme.BackColor, "0x" Theme.TextColor)
	pToken:=Gdip_Startup()
	SetBGNavSelect(g)
	SetBGPanel(g)
	Gdip_Shutdown(pToken)
	SetMenuTheme()
	For Hwnd, GuiCtrlObj in g {
		SetCtrlTheme(GuiCtrlObj)
	}
}
