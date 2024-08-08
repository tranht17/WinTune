CreatePopupLang(Ctr, *) {
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)
	g2:=CreateDlg(g, 0)
	
	NavSelectW:=200, NavSelectH:=30
	
	g2.AddPic("Hidden vNavBGHover xm")
	g2.AddPic("vNavBGActive Hidden xm")
	pToken:=Gdip_Startup()
	CreateBGNavSelect(g2["NavBGHover"], g2["NavBGActive"], NavSelectW, NavSelectH ,6)

	SpaceName:="            "
    for k,v in LangData.OwnProps() {
		y:=(A_Index-1)*34
		hFlag:=Gdip_CreateARGBHBITMAPFromBase64(v.Flag)
		Flag:=g2.AddPic("BackgroundTrans h20 w20 xm8 ym" y+6, "HBITMAP:" hFlag)
		DeleteObject(hFlag)
		NavItem:=g2.AddText("BackgroundTrans 0x200 0x100 h" NavSelectH " w" NavSelectW " xm ym" y " vNavItem_" k, SpaceName v.Name)
		NavItem.OnEvent("Click", Lang_Code_Click)
    }
	Gdip_Shutdown(pToken)
	
	g2["NavItem_" App.LangSelected].GetPos(&xNavItem, &yNavItem)
	g2["NavBGActive"].Move(xNavItem, yNavItem)
	g2["NavBGActive"].Visible:=True
	
    Lang_Code_Click(Ctr, *) {
		LangClicked:=SubStr(Ctr.Name,9)
		If LangClicked=App.LangSelected {
			DestroyDlg(0)
			Return
		}
		App.LangSelected:=LangClicked
		App.TabLangLoaded:= {}	
		SetNavLangAll(g)
		pToken:=Gdip_Startup()
		hFlag:=Gdip_CreateARGBHBITMAPFromBase64(LangData.%App.LangSelected%.Flag)
		g["BtnSys_Language"].Value:="HBITMAP:" hFlag
		DeleteObject(hFlag)
		Gdip_Shutdown(pToken)
		IniWrite LangClicked, "config.ini", "General", "Language"
		DestroyDlg(0)
		NavItem_Click(g)
    }
    tX:=xG+xCtr-(NavSelectW+12-wCtr)/2
	tY:=yG+yCtr+hCtr+6
	g2.Show("x" tX " y" tY)
	If WinWaitNotActive(g2)
		DestroyDlg
}