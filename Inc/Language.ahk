CreatePopupLang(Ctr, *) {
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)

	g2:=Gui("-Caption" ,"Popup")
	FrameShadow(g2.hWnd)
	g2.SetFont("c" Themes.%ThemeSelected%.TextColor, "Segoe UI Semibold")
	g2.BackColor:=Themes.%ThemeSelected%.BackColor
	
	NavSelectW:=200, NavSelectH:=30
	
	g2.AddPic("Hidden vNavBGHover xm")
	g2.AddPic("vNavBGActive Hidden xm")
	pToken:=Gdip_Startup()
	CreateBGNavSelect(g2["NavBGHover"], g2["NavBGActive"], NavSelectW, NavSelectH ,6)
	
    IsWin11:=VerCompare(A_OSVersion, ">=10.0.22000")
	IconFont:=IsWin11?"Segoe Fluent Icons":"Segoe MDL2 Assets"
	
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
	
	g2["NavItem_" LangSelected].GetPos(&xNavItem, &yNavItem)
	g2["NavBGActive"].Move(xNavItem, yNavItem)
	g2["NavBGActive"].Visible:=True
	
    Lang_Code_Click(Ctr, *) {
		LangClicked:=SubStr(Ctr.Name,9)
		Global LangSelected
		If LangClicked=LangSelected {
			g2.Destroy()
			Return
		}
		LangSelected:=LangClicked
		Lang:=LangData.%LangSelected%
		SpaceName:="              "
		For , GuiCtrlObj in g {
			If GuiCtrlObj.Name="BtnSelectAll" {
				vis:=GuiCtrlObj.Visible
				GuiCtrlObj.Text:='<a id="1">' GetLangName("BtnSelectAll") '</a>   <a id="0">' GetLangName("BtnDeselectAll") '</a>'
				LinkUseDefaultColor(GuiCtrlObj)
				GuiCtrlObj.Visible:=vis
			} Else If InStr(GuiCtrlObj.Name,"NavItem_") {
				NavItemID:=SubStr(GuiCtrlObj.Name,9)
				GuiCtrlObj.Text:=SpaceName GetLangName(Layout[NavItemID].ID)
			} Else If GuiCtrlObj.Name && Lang.HasOwnProp(GuiCtrlObj.Name) 
					&& Lang.%GuiCtrlObj.Name%.HasOwnProp("Name") && Lang.%GuiCtrlObj.Name%.Name {
				GuiCtrlObj.Text:=GetLangName(GuiCtrlObj.Name)
			}
		}
		pToken:=Gdip_Startup()
		hFlag:=Gdip_CreateARGBHBITMAPFromBase64(LangData.%LangSelected%.Flag)
		g["BtnSys_Language"].Value:="HBITMAP:" hFlag
		DeleteObject(hFlag)
		Gdip_Shutdown(pToken)
		IniWrite LangClicked, "config.ini", "General", "Language"
		g2.Destroy()
    }
    tX:=xG+xCtr-(NavSelectW+12-wCtr)/2
	tY:=yG+yCtr+hCtr+6
	g2.Show("x" tX " y" tY)
	If WinWaitNotActive(g2)
		g2.Destroy()
}
GetLangName(ItemId) {
	Lang:=LangData.%LangSelected%
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Name") && Lang.%ItemId%.Name
		ItemId:=Lang.%ItemId%.Name
	Else {
		If LangSelected!="en" {
			Lang:=LangData.en
			If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Name") && Lang.%ItemId%.Name
				ItemId:=Lang.%ItemId%.Name
		}
	}
	Return ItemId
}
GetLangDesc(ItemId) {
	Lang:=LangData.%LangSelected%
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Desc") && Lang.%ItemId%.Desc
		Return Lang.%ItemId%.Desc
	Else {
		If LangSelected!="en" {
			Lang:=LangData.en
			If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.HasOwnProp("Desc") && Lang.%ItemId%.Desc
				Return Lang.%ItemId%.Desc	
		}
	}
}
GetLangText(ItemId) {
	Lang:=LangData.%LangSelected%
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%
		ItemId:=Lang.%ItemId%
	Else {
		If LangSelected!="en"
			Lang:=LangData.en
			If Lang.HasOwnProp(ItemId) && Lang.%ItemId%
				ItemId:=Lang.%ItemId%
	}
	Return ItemId
}