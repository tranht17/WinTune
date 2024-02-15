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
		Global HKCU,USERPROFILE
		UserSID:=UserClicked
		HKCU:=GetHKCU(&USERPROFILE)
		SpaceName:="            "
		g["NavItem_UserName"].Text:=SpaceName LookupAccountSid(UserSID).Name
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

GetActiveUser() {
	wtsapi32 := DllCall("LoadLibrary", "Str", "wtsapi32.dll", "Ptr")
	DllCall("wtsapi32\WTSEnumerateSessionsEx", "Ptr", 0, "UPtr*", 1, "UPtr", 0, "Ptr*", &pSessionInfo:=0, "UPtr*", &wtsSessionCount:=0)
	UserName:=""
	cbWTS_SESSION_INFO_1:=(A_PtrSize == 8 ? 56 : 32)
	Loop wtsSessionCount {
		currSessOffset := cbWTS_SESSION_INFO_1 * (A_Index - 1)
		currSessOffset += 4, State := NumGet(pSessionInfo, currSessOffset, "UInt")
		currSessOffset += 4, SessionId := NumGet(pSessionInfo, currSessOffset, "UInt")
		If SessionId && (State == 0) {
			If nUserName:=NumGet(pSessionInfo, (currSessOffset += A_PtrSize*3), "Ptr") {
				UserName := StrGet(nUserName,, "UTF-16")
			}
			Break
		}
	}
	DllCall("wtsapi32\WTSFreeMemoryEx", "UPtr", 2, "Ptr", pSessionInfo, "UPtr", wtsSessionCount)
	DllCall("FreeLibrary", "Ptr", wtsapi32)
	Return UserName
}
LookupAccountName(UserName) {
	nSizeSID:=nSizeDomain:=256
	SID:=Buffer(nSizeSID)
	pDomain:=Buffer(nSizeDomain)
	DllCall("advapi32\LookupAccountName", "Str", "", "Str", UserName, "Ptr", SID, "PtrP", &nSizeSID, "Ptr", pDomain, "PtrP", &nSizeDomain, "PtrP", &eUser:=0)
	DllCall("advapi32\ConvertSidToStringSid", "Ptr", SID, "UPtrP", &pString:=0)
	If !pString {
		MsgBox("User '" UserName "' does not exist","Error","Iconx")
		ExitApp
	}
	Return StrGet(pString)
}
LookupAccountSid(SID) {
	r := {}
	nSizeName:=nSizeDomain:=256
	pName:=Buffer(nSizeName)
	pDomain:=Buffer(nSizeDomain)
	DllCall("advapi32\ConvertStringSidToSid", "Str", SID, "UPtr*", &pSID:=0)
	if !(DllCall("advapi32\LookupAccountSid", "Ptr", 0, "Ptr", pSID, "Ptr", pName, "UInt*", &nSizeName, "Ptr", pDomain, "UInt*", &nSizeDomain, "UInt*", &SNU:=0))
		return 0
	r.Name := StrGet(pName), r.Domain := StrGet(pDomain)
	return r
}

SetUserPic(Ctr, sUserSID) {
	pBitmap := Gdip_CreateBitmap(32, 32)
	pGraphics := Gdip_GraphicsFromImage(pBitmap)
	sFile := RegRead("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\" sUserSID, "Image32", "")
	If !(sFile && FileExist(sFile))
		sFile:=EnvGet("ProgramData") "\Microsoft\User Account Pictures\user-32.png"
	DllCall("gdiplus\GdipCreateBitmapFromFile", "UPtr", StrPtr(sFile), "UPtr*", &pBitmap2:=0)
	Gdip_SetSmoothing(pGraphics)
	pBrush:=Gdip_CreateTextureBrush(pBitmap2)
	DllCall("gdiplus\GdipFillEllipse", "UPtr", pGraphics, "UPtr", pBrush, "Float", 0, "Float", 0, "Float", 32, "Float", 32)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Ctr.Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
}
UserCount() {
	c:=0
	Loop Reg, "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", "K" {
		; If A_LoopRegName == "S-1-5-18" || A_LoopRegName == "S-1-5-19" || A_LoopRegName == "S-1-5-20"
			; Continue
		If InStr(A_LoopRegName, "S-1-5-21")=1 
			c++
	}
	Return c
}