CreatePopupTheme(Ctr, *) {
	Ctr.GetPos(&xCtr,&yCtr,&wCtr,&hCtr)
	g:=Ctr.Gui
	g.GetPos(&xG,&yG)
	
	g2:=Gui("-Caption" ,"Popup")
	FrameShadow(g2.hWnd)
	g2.SetFont("c" Themes.%ThemeSelected%.TextColor, "Segoe UI Semibold")
	g2.BackColor:="00A7EB"
	
	IsWin11:=VerCompare(A_OSVersion, ">=10.0.22000")
	IconFont:=IsWin11?"Segoe Fluent Icons":"Segoe MDL2 Assets"
	
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
		If GuiCtrlObj.Type="Button" || GuiCtrlObj.Type="Edit" {
			SetWindowTheme(GuiCtrlObj)
			GuiCtrlObj.Opt("Background" Theme.BackColorPanelRGB " c" Theme.TextColor)
		} Else If GuiCtrlObj.Type="Text" && InStr(GuiCtrlObj.Name, "HRText_")=1
			GuiCtrlObj.Opt("c" Theme.HrColor)
		Else If GuiCtrlObj.Type="Text" && InStr(GuiCtrlObj.Name, "HRLine_")=1
			GuiCtrlObj.Opt("Background" Theme.HrColor)
		Else If GuiCtrlObj.Type="Text" || GuiCtrlObj.Type="PicSwitch"
			GuiCtrlObj.SetFont("c" Theme.TextColor)
		Else If GuiCtrlObj.Type="ListView" || GuiCtrlObj.Type="Link"
			GuiCtrlObj.Opt("Background" Theme.BackColorPanelRGB " c" Theme.TextColor)
	}
}

SetBGNavSelect(g, W:=0, H:=0, R:=6) {
	Static sPathX:=W,sPathY:=H,sRounded:=R
	If W>0
		sPathX:=W
	If H>0
		sPathY:=H
	If sPathX<=0 || sPathY<=0
		Return
	CreateBGNavSelect(g["NavBGHover"], g["NavBGActive"], sPathX, sPathY ,sRounded)
}
CreateBGNavSelect(NavBGHover, NavBGActive, sPathX, sPathY ,sRounded) {
	pBitmap := Gdip_CreateBitmap(sPathX, sPathY)
	pGraphics := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothing(pGraphics)

	PathX := PathY := 0
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, sPathX, sPathY, sRounded, "0x" Themes.%ThemeSelected%.BackColorNavSelect)
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	NavBGHover.Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap)
	
	PathX := 0, PathX2 := 3, Rounded := 2
	PathY := sPathY/4
	PathY2 := PathY+sPathY/2
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, 0xFF4CC2FF)

	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	NavBGActive.Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
}
SetBGPanel(g, W:=0, H:=0, R:=6, BW:=1) {
	Static sPathX:=W,sPathY:=H,sRounded:=R,BorderWidth:=BW
	If W>0
		sPathX:=W
	If H>0
		sPathY:=H
	If sPathX<=0 || sPathY<=0
		Return
	
	pBitmap := Gdip_CreateBitmap(sPathX, sPathY)
	pGraphics := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothing(pGraphics)
	
	DllCall("Gdiplus.dll\GdipGraphicsClear", "Ptr", pGraphics, "UInt", "0xFF" Themes.%ThemeSelected%.BackColor)
	
	PathX := PathY := 0
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, sPathX, sPathY, sRounded, "0x" Themes.%ThemeSelected%.BorderColorPanel)
	
	PathX := PathY := BorderWidth, PathX2 := sPathX-BorderWidth, PathY2 := sPathY-BorderWidth, Rounded := sRounded-BorderWidth
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, "0x" Themes.%ThemeSelected%.BackColorPanel)

	DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "Int", 10, "Int", 10, "uint*", &ARGB:=0)

	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	g["BGPanel"].Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
	Themes.%ThemeSelected%.BackColorPanelRGB:=Format("{:X}", ARGB & 0x00FFFFFF)
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

LinkUseDefaultColor(CtrlObj, Use := True) {
   LITEM := Buffer(4278, 0)                  ; 16 + (MAX_LINKID_TEXT * 2) + (L_MAX_URL_LENGTH * 2)
   NumPut("UInt", 0x03, LITEM)               ; LIF_ITEMINDEX (0x01) | LIF_STATE (0x02)
   NumPut("UInt", Use ? 0x10 : 0, LITEM, 8)  ; ? LIS_DEFAULTCOLORS : 0
   NumPut("UInt", 0x10, LITEM, 12)           ; LIS_DEFAULTCOLORS
   While DllCall("SendMessage", "Ptr", CtrlObj.Hwnd, "UInt", 0x0702, "Ptr", 0, "Ptr", LITEM, "UInt") ; LM_SETITEM
      NumPut("Int", A_Index, LITEM, 4)
   CtrlObj.Opt("+Redraw")
}

SetMenuTheme() {
	; "Default": 0, "AllowDark": 1, "ForceDark": 2, "ForceLight": 3, "Max": 4
	uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
	SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
	FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
	DllCall(SetPreferredAppMode, "Int", Themes.%ThemeSelected%.CtrDark)
	DllCall(FlushMenuThemes)
}