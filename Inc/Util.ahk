UserSID:=GetCurrentUserInfo()[2]
UserLocalAppData:=RegRead("HKU\" UserSID "\Volatile Environment", "LOCALAPPDATA")

SystemInfo() {
	SI:={}
	SI.InstallationType:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType")
	SI.EditionID:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID")
	SI.ProductName:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductName")
	SI.DisplayVersion:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "DisplayVersion")
	SI.RegisteredOwner:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "RegisteredOwner")
	Return SI
}
FrameShadow(HGui) {
	DllCall("dwmapi\DwmIsCompositionEnabled","IntP",&_ISENABLED:=0)
	if !_ISENABLED
		DllCall("SetClassLong" (A_PtrSize=8?"Ptr":""),"UInt",HGui,"Int",-26,"Int",DllCall("GetClassLong" (A_PtrSize=8?"Ptr":""),"UInt",HGui,"Int",-26)|0x20000)
	else {
		_MARGINS:=Buffer(16,0)
		NumPut("UInt",1,_MARGINS,0)
		NumPut("UInt",1,_MARGINS,4)
		NumPut("UInt",1,_MARGINS,8)
		NumPut("UInt",1,_MARGINS,12)		
		DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", HGui, "UInt", 2, "Int*", 2, "UInt", 4)
		DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", HGui, "Ptr", _MARGINS)
	}
}

SetWindowTheme(Ctr) {
	DllCall("uxtheme\SetWindowTheme", "ptr", Ctr.hwnd, "str", Themes.%ThemeSelected%.CtrDark?"DarkMode_Explorer":"Explorer", "ptr", 0)
}

RegKeyExist(RegKey) {
	sKey:=StrSplit(RegKey, "\")
	cKey:=""
	Loop (sKey.Length-1)
		cKey.=(A_Index=1?"":"\") sKey[A_Index+1]
	fKey:=sKey[1]
	RootKey:=0x80000001
	Switch fKey
	{
		Case "HKEY_CLASSES_ROOT","HKCR": RootKey:=0x80000000
		Case "HKEY_CURRENT_USER","HKCU": RootKey:=0x80000001
		Case "HKEY_LOCAL_MACHINE","HKLM": RootKey:=0x80000002
		Case "HKEY_USERS","HKU": RootKey:=0x80000003
		Case "HKEY_CURRENT_CONFIG","HKCC": RootKey:=0x80000005
	}
    exists := !DllCall("RegOpenKeyExW", "PTR", RootKey, "wstr", cKey
						, "UINT", 0, "UINT", 131097, "PTR*", &hKey:=0)
    DllCall("RegCloseKey", "PTR", hKey)
    return exists
}

HKCU2HCU(KeyName) {
	If InStr(KeyName, "HKEY_CURRENT_USER")=1
		KeyName := StrReplace(KeyName, "HKEY_CURRENT_USER", "HKU\" UserSID,,,1)
	Else If InStr(KeyName, "HKCU")=1
		KeyName := StrReplace(KeyName, "HKCU", "HKU\" UserSID,,,1)
	Return KeyName
}

GetCurrentUserInfo()  {
	PID := WinGetPID("A")
	static PROCESS_QUERY_INFORMATION := 0x400, TOKEN_QUERY := 0x8
		, TokenUser := 1, TokenOwner := 4
	
	if !hProcess := DllCall("OpenProcess", "UInt", PROCESS_QUERY_INFORMATION, "UInt", false, "UInt", PID, "Ptr")
		Return Error("OpenProcess")
	if !DllCall("Advapi32\OpenProcessToken", "Ptr", hProcess, "UInt", TOKEN_QUERY, "PtrP", &hToken:=0)
		Return Error("OpenProcessToken", hProcess)
	tokenType:=TokenUser
	DllCall("Advapi32\GetTokenInformation", "Ptr", hToken, "Int", tokenType, "Ptr", 0, "Int", 0, "UIntP", &bites:=0)
	buff:=Buffer(bites)
	if !DllCall("Advapi32\GetTokenInformation", "Ptr", hToken, "Int", tokenType, "Ptr", buff, "Int", bites, "UIntP", &bites)
	  Return Error("GetTokenInformation", hProcess, hToken)
	
	MAX_NAME := MAX_DOMAINNAME := 64
	sName:=Buffer(MAX_NAME)
	sDomainName:=Buffer(MAX_DOMAINNAME)
	if !DllCall( "Advapi32\LookupAccountSid", "Ptr", 0, "Ptr", NumGet(buff, "Ptr"), "Ptr", sName, "Ptr*", &szName:=MAX_NAME
                                           , "Ptr", sDomainName, "Ptr*", &szDomainName:=MAX_DOMAINNAME, "Ptr*", &SID_NAME_USE:=0 )
		Return Error("LookupAccountSid", hProcess, hToken)
		
	DllCall("CloseHandle", "Ptr", hProcess), DllCall("CloseHandle", "Ptr", hToken)
	
	DllCall("advapi32\ConvertSidToStringSid", "Ptr", NumGet(buff, "Ptr"), "UPtrP", &pString:=0)
	sSid:=Buffer(DllCall("lstrlenW", "UPtr", pString)*2)
	DllCall("lstrcpyW", "Ptr", sSid, "UPtr", pString)
	DllCall("LocalFree", "UPtr", pString)
	
	Return [StrGet(sName),StrGet(sSid),StrGet(sDomainName)]
}
Gdip_CreateARGBHBITMAPFromBase64(base64Value) {
	pBitmap:=Gdip_BitmapFromBase64(&base64Value)
	hBitmap:=Gdip_CreateARGBHBITMAPFromBitmap(&pBitmap)
	Gdip_DisposeImage(pBitmap)
	Return hBitmap
}
Gdip_FillRoundedRectanglePath(pGraphics, X, Y, X2, Y2, R, Color) {
   DllCall("Gdiplus.dll\GdipCreatePath", "Int", 0, "UPtr*", &pPath:=0)
   PathAddRoundedRect(pPath, X, Y, X2, Y2, R)
   DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", Color, "Ptr*", &pBrush:=0)
   DllCall("Gdiplus.dll\GdipFillPath", "Ptr", pGraphics, "Ptr", pBrush, "Ptr", pPath)
   DllCall("Gdiplus.dll\GdipDeletePath", "Ptr", pPath)
   DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", pBrush)
}
PathAddRoundedRect(Path, X1, Y1, X2, Y2, R) {
	D := (R * 2), X2 -= D, Y2 -= D
	DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X1, "Float", Y1, "Float", D, "Float", D, "Float", 180, "Float", 90)
	DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X2, "Float", Y1, "Float", D, "Float", D, "Float", 270, "Float", 90)
	DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X2, "Float", Y2, "Float", D, "Float", D, "Float", 0, "Float", 90)
	DllCall("Gdiplus.dll\GdipAddPathArc", "Ptr", Path, "Float", X1, "Float", Y2, "Float", D, "Float", D, "Float", 90, "Float", 90)
	Return DllCall("Gdiplus.dll\GdipClosePathFigure", "Ptr", Path)
}
Gdip_SetSmoothing(pGraphics) {
	DllCall("Gdiplus.dll\GdipSetSmoothingMode", "Ptr", pGraphics, "UInt", 4)
	DllCall("Gdiplus.dll\GdipSetInterpolationMode", "Ptr", pGraphics, "Int", 7)
	DllCall("Gdiplus.dll\GdipSetCompositingQuality", "Ptr", pGraphics, "UInt", 4)
	DllCall("Gdiplus.dll\GdipSetRenderingOrigin", "Ptr", pGraphics, "Int", 0, "Int", 0)
	DllCall("Gdiplus.dll\GdipSetPixelOffsetMode", "Ptr", pGraphics, "UInt", 4)
	; DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", pGraphics, "Int", 0)
}

LinkUseDefaultColor(CtrlObj, Use := True) {
   LITEM := Buffer(4278, 0)                  ; 16 + (MAX_LINKID_TEXT * 2) + (L_MAX_URL_LENGTH * 2)
   NumPut("UInt", 0x03, LITEM)               ; LIF_ITEMINDEX (0x01) | LIF_STATE (0x02)
   NumPut("UInt", Use ? 0x10 : 0, LITEM, 8)  ; ? LIS_DEFAULTCOLORS : 0
   NumPut("UInt", 0x10, LITEM, 12)           ; LIS_DEFAULTCOLORS
   While DllCall("SendMessage", "Ptr", CtrlObj.Hwnd, "UInt", 0x0702, "Ptr", 0, "Ptr", LITEM, "UInt") ; LM_SETITEM
      NumPut("Int", A_Index, LITEM, 4)
   CtrlObj.Opt("+Redraw")
}

WinHttp(link) {
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	whr.Open("get", link)
	whr.Send()
	whr.WaitForResponse()
	c:=whr.responseText
	whr:=""
	Return c
}