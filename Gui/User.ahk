CreatePopupUser(Ctr, *) {
	If UserCount()=1
		Return
	g:=Ctr.Gui
	g2:=CreateDlg(g, 0)

	NavSelectW:=190, NavSelectH:=30
	
	g2.AddPic("Hidden vNavBGHover xm")
	g2.AddPic("vNavBGActive Hidden xm")
	pToken:=Gdip_Startup()
	CreateBGNavSelect(g2["NavBGHover"], g2["NavBGActive"], NavSelectW, NavSelectH ,6)

	SpaceName:="               "
	Loop Reg, "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", "K" {
		If InStr(A_LoopRegName, "S-1-5-21")!=1
			Continue
		y:=(A_Index-1)*34
		a:=g2.AddPic("BackgroundTrans w22 h22 xm8 ym" y+4)
		SetUserPic(a, A_LoopRegName)
		NavItem:=g2.AddText("BackgroundTrans 0x200 0x100 h" NavSelectH " w" NavSelectW " xm ym" y " vNavItem_" A_LoopRegName, SpaceName LookupAccountSid(A_LoopRegName).Name)
		NavItem.OnEvent("Click", User_Click)
	}
	Gdip_Shutdown(pToken)
	
	g2["NavItem_" App.UserSID].GetPos(&xNavItem, &yNavItem)
	g2["NavBGActive"].Move(xNavItem, yNavItem)
	g2["NavBGActive"].Visible:=True
	
	User_Click(Ctr, *) {
		UserClicked:=SubStr(Ctr.Name,9)
		If UserClicked=App.UserSID {
			DestroyDlg(0)
			Return
		}
		App.UserSID:=UserClicked
		App.HKCU:=GetHKCU()
		App.User:=LookupAccountSid(App.UserSID).Name
		SpaceName:="            "
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