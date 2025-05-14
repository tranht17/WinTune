CreatePopupUser(Ctr, *) {
	If UserCount()=1
		Return
	g:=Ctr.Gui
	g2:=CreateDlg(g, 0)

	NavSelectW:=245, NavSelectH:=36
	
	g2.AddPic("Hidden vNavBGHover xm")
	g2.AddPic("vNavBGActive Hidden xm")
	pToken:=Gdip_Startup()
	CreateBGNavSelect(g2["NavBGHover"], g2["NavBGActive"], NavSelectW, NavSelectH ,6)

	SpaceName:="            "
	y:=0
	Loop Reg, "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", "K" {
		If InStr(A_LoopRegName, "S-1-5-21-")!=1 || (App.UserSID=A_LoopRegName)
			Continue
		tUser:=LookupAccountSid(A_LoopRegName)
		If !tUser.HasOwnProp("Name") || !tUser.Name
			Continue
		a:=g2.AddPic("BackgroundTrans w22 h22 xm8 ym" y+8)
		SetUserPic(a, A_LoopRegName)
		NavItem:=g2.AddText("BackgroundTrans 0x200 0x100 h" NavSelectH " w" NavSelectW " xm ym" y " vNavItem_" A_LoopRegName, SpaceName tUser.Name)
		NavItem.SetFont("s" App.MainFontSize+2 )
		NavItem.OnEvent("Click", User_Click)
		y+=(NavSelectH+4)
	}
	Gdip_Shutdown(pToken)
	
	User_Click(Ctr, *) {
		UserClicked:=SubStr(Ctr.Name,9)
		App.UserSID:=UserClicked
        App.UserProfile:=GetUSERPROFILE()
		App.HKCU:=GetHKCU()
		App.User:=LookupAccountSid(App.UserSID).Name
		g["NavItem_UserName"].Text:=SpaceName App.User
		pToken:=Gdip_Startup()
		SetUserPic(g["UserPic"], App.UserSID)
		Gdip_Shutdown(pToken)
		DestroyDlg(0)
		NavItem_Click(g)
    }
    ShowDlg(g, g2, 4, Ctr)
	If WinWaitNotActive(g2)
		DestroyDlg(0)	
}