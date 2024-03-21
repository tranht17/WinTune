CreatePopupUser(Ctr, *) {
	If WinExist(App.Name "_Popup")
		WinClose
	If UserCount()=1
		Return
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)
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
	
	g2["NavItem_" UserSID].GetPos(&xNavItem, &yNavItem)
	g2["NavBGActive"].Move(xNavItem, yNavItem)
	g2["NavBGActive"].Visible:=True
	
	User_Click(Ctr, *) {
		UserClicked:=SubStr(Ctr.Name,9)
		Global UserSID
		If UserClicked=UserSID {
			g2.Destroy()
			Return
		}
		Global HKCU,CurrentUser
		UserSID:=UserClicked
		HKCU:=GetHKCU()
		CurrentUser:=LookupAccountSid(UserSID).Name
		SpaceName:="            "
		g["NavItem_UserName"].Text:=SpaceName CurrentUser
		pToken:=Gdip_Startup()
		SetUserPic(g["UserPic"], UserSID)
		Gdip_Shutdown(pToken)
		g2.Destroy()
		NavItem_Click(g)
    }
	
    tX:=xG+xCtr-(NavSelectW+12-wCtr)/2-6
	tY:=yG+yCtr+hCtr+6
	g2.Show("x" tX " y" tY)
	If WinWaitNotActive(g2)
		g2.Destroy()		
}