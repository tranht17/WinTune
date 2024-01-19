; https://github.com/buliasz/AHKv2-Gdip
; v1.61
Gdip_Startup()
{
	if (!DllCall("LoadLibrary", "str", "gdiplus", "UPtr")) {
		throw Error("Could not load GDI+ library")
	}

	si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("UInt", 1, si)
	DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken:=0, "UPtr", si.Ptr, "UPtr", 0)
	if (!pToken) {
		throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
	}

	return pToken
}

Gdip_Shutdown(pToken)
{
	DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
	hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
	if (!hModule) {
		throw Error("GDI+ library was unloaded before shutdown")
	}
	if (!DllCall("FreeLibrary", "UPtr", hModule)) {
		throw Error("Could not free GDI+ library")
	}

	return 0
}

Gdip_GraphicsFromImage(pBitmap)
{
	DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &pGraphics:=0)
	return pGraphics
}
Gdip_CreateBitmap(Width, Height, Format:=0x26200A)
{
	DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", Width, "Int", Height, "Int", 0, "Int", Format, "UPtr", 0, "UPtr*", &pBitmap:=0)
	return pBitmap
}
Gdip_CreateHBITMAPFromBitmap(pBitmap, Background:=0xffffffff)
{
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", &hbm:=0, "Int", Background)
	return hbm
}

Gdip_DeleteBrush(pBrush)
{
	return DllCall("gdiplus\GdipDeleteBrush", "UPtr", pBrush)
}

;#####################################################################################

Gdip_DisposeImage(pBitmap)
{
	return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

;#####################################################################################

Gdip_DeleteGraphics(pGraphics)
{
	return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}

DeleteObject(hObject)
{
	return DllCall("DeleteObject", "UPtr", hObject)
}
Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette:=0)
{
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap:=0)
	return pBitmap
}
Gdip_BitmapFromScreen(Screen:=0, Raster:="")
{
	hhdc := 0
	if (Screen = 0) {
		_x := DllCall( "GetSystemMetrics", "Int", 76 )
		_y := DllCall( "GetSystemMetrics", "Int", 77 )
		_w := DllCall( "GetSystemMetrics", "Int", 78 )
		_h := DllCall( "GetSystemMetrics", "Int", 79 )
	}
	else if (SubStr(Screen, 1, 5) = "hwnd:") {
		Screen := SubStr(Screen, 6)
		if !WinExist("ahk_id " Screen) {
			return -2
		}
		WinGetRect(Screen,,, &_w, &_h)
		_x := _y := 0
		hhdc := GetDCEx(Screen, 3)
	}
	else if IsInteger(Screen) {
		M := GetMonitorInfo(Screen)
		_x := M.Left, _y := M.Top, _w := M.Right-M.Left, _h := M.Bottom-M.Top
	}
	else {
		S := StrSplit(Screen, "|")
		_x := S[1], _y := S[2], _w := S[3], _h := S[4]
	}

	if (_x = "") || (_y = "") || (_w = "") || (_h = "") {
		return -1
	}

	chdc := CreateCompatibleDC()
	hbm := CreateDIBSection(_w, _h, chdc)
	obm := SelectObject(chdc, hbm)
	hhdc := hhdc ? hhdc : GetDC()
	BitBlt(chdc, 0, 0, _w, _h, hhdc, _x, _y, Raster)
	ReleaseDC(hhdc)

	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)

	SelectObject(chdc, obm)
	DeleteObject(hbm)
	DeleteDC(hhdc)
	DeleteDC(chdc)
	return pBitmap
}
Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality:=75)
{
	_p := 0

	SplitPath sOutput,,, &extension:=""
	if (!RegExMatch(extension, "^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")) {
		return -1
	}
	extension := "." extension

	DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount:=0, "uint*", &nSize:=0)
	ci := Buffer(nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "UPtr", ci.Ptr)
	if !(nCount && nSize) {
		return -2
	}

	loop nCount {
		address := NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize, "UPtr")
		sString := StrGet(address, "UTF-16")
		if !InStr(sString, "*" extension)
			continue

		pCodec := ci.Ptr+idx
		break
	}

	if !pCodec {
		return -3
	}

	if (Quality != 75) {
		Quality := (Quality < 0) ? 0 : (Quality > 100) ? 100 : Quality

		if RegExMatch(extension, "^\.(?i:JPG|JPEG|JPE|JFIF)$") {
			DllCall("gdiplus\GdipGetEncoderParameterListSize", "UPtr", pBitmap, "UPtr", pCodec, "uint*", &nSize)
			EncoderParameters := Buffer(nSize, 0)
			DllCall("gdiplus\GdipGetEncoderParameterList", "UPtr", pBitmap, "UPtr", pCodec, "UInt", nSize, "UPtr", EncoderParameters.Ptr)
			nCount := NumGet(EncoderParameters, "UInt")
			loop nCount
			{
				elem := (24+(A_PtrSize ? A_PtrSize : 4))*(A_Index-1) + 4 + (pad := A_PtrSize = 8 ? 4 : 0)
				if (NumGet(EncoderParameters, elem+16, "UInt") = 1) && (NumGet(EncoderParameters, elem+20, "UInt") = 6)
				{
					_p := elem + EncoderParameters.Ptr - pad - 4
					NumPut("UInt", Quality, NumGet(NumPut("UInt", 4, NumPut("UInt", 1, _p+0)+20), "UInt"))
					break
				}
			}
		}
	}

	_E := DllCall("gdiplus\GdipSaveImageToFile", "UPtr", pBitmap, "UPtr", StrPtr(sOutput), "UPtr", pCodec, "UInt", _p ? _p : 0)

	return _E ? -5 : 0
}

CreateRect(&Rect, x, y, w, h)
{
	Rect := Buffer(16)
	NumPut("UInt", x, "UInt", y, "UInt", w, "UInt", h, Rect)
}
CreateDIBSection(w, h, hdc:="", bpp:=32, &ppvBits:=0)
{
	hdc2 := hdc ? hdc : GetDC()
	bi := Buffer(40, 0)

	NumPut("UInt", 40, "UInt", w, "UInt", h, "ushort", 1, "ushort", bpp, "UInt", 0, bi)

	hbm := DllCall("CreateDIBSection"
					, "UPtr", hdc2
					, "UPtr", bi.Ptr
					, "UInt", 0
					, "UPtr*", &ppvBits
					, "UPtr", 0
					, "UInt", 0, "UPtr")

	if (!hdc) {
		ReleaseDC(hdc2)
	}
	return hbm
}
CreateCompatibleDC(hdc:=0)
{
	return DllCall("CreateCompatibleDC", "UPtr", hdc)
}
SelectObject(hdc, hgdiobj)
{
	return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
}
GetDC(hwnd:=0)
{
	return DllCall("GetDC", "UPtr", hwnd)
}
GetDCEx(hwnd, flags:=0, hrgnClip:=0)
{
	return DllCall("GetDCEx", "UPtr", hwnd, "UPtr", hrgnClip, "Int", flags)
}
ReleaseDC(hdc, hwnd:=0)
{
	return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}
DeleteDC(hdc)
{
	return DllCall("DeleteDC", "UPtr", hdc)
}

GetMonitorInfo(MonitorNum)
{
	Monitors := MDMF_Enum()
	for k,v in Monitors {
		if (v.Num = MonitorNum) {
			return v
		}
	}
}

MDMF_Enum(HMON := "") {
	static EnumProc := CallbackCreate(MDMF_EnumProc)
	static Monitors := Map()

	if (HMON = "") { 	; new enumeration
		Monitors := Map("TotalCount", 0)
		if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProc, "Ptr", ObjPtr(Monitors), "Int")
			return False
	}

	return (HMON = "") ? Monitors : Monitors.HasKey(HMON) ? Monitors[HMON] : False
}
MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
	Monitors := ObjFromPtrAddRef(ObjectAddr)

	Monitors[HMON] := MDMF_GetInfo(HMON)
	Monitors["TotalCount"]++
	if (Monitors[HMON].Primary) {
		Monitors["Primary"] := HMON
	}

	return true
}
MDMF_GetInfo(HMON) {
	MIEX := Buffer(40 + (32 << !!1))
	NumPut("UInt", MIEX.Size, MIEX)
	if DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX.Ptr, "Int") {
		return {Name:      (Name := StrGet(MIEX.Ptr + 40, 32))  ; CCHDEVICENAME = 32
		      , Num:       RegExReplace(Name, ".*(\d+)$", "$1")
		      , Left:      NumGet(MIEX, 4, "Int")    ; display rectangle
		      , Top:       NumGet(MIEX, 8, "Int")    ; "
		      , Right:     NumGet(MIEX, 12, "Int")   ; "
		      , Bottom:    NumGet(MIEX, 16, "Int")   ; "
		      , WALeft:    NumGet(MIEX, 20, "Int")   ; work area
		      , WATop:     NumGet(MIEX, 24, "Int")   ; "
		      , WARight:   NumGet(MIEX, 28, "Int")   ; "
		      , WABottom:  NumGet(MIEX, 32, "Int")   ; "
		      , Primary:   NumGet(MIEX, 36, "UInt")} ; contains a non-zero value for the primary monitor.
	}
	return False
}
; Based on WinGetClientPos by dd900 and Frosti - https://www.autohotkey.com/boards/viewtopic.php?t=484
WinGetRect( hwnd, &x:="", &y:="", &w:="", &h:="" ) {
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	CreateRect(&winRect, 0, 0, 0, 0) ;is 16 on both 32 and 64
	;VarSetCapacity( winRect, 16, 0 )	; Alternative of above two lines
	DllCall( "GetWindowRect", "Ptr", hwnd, "Ptr", winRect )
	x := NumGet(winRect,  0, "UInt")
	y := NumGet(winRect,  4, "UInt")
	w := NumGet(winRect,  8, "UInt") - x
	h := NumGet(winRect, 12, "UInt") - y
}
BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster:="")
{
	return DllCall("gdi32\BitBlt"
					, "UPtr", dDC
					, "Int", dx
					, "Int", dy
					, "Int", dw
					, "Int", dh
					, "UPtr", sDC
					, "Int", sx
					, "Int", sy
					, "UInt", Raster ? Raster : 0x00CC0020)
}

; ====================================

Gdip_BitmapFromBase64(&Base64)
{
	; calculate the length of the buffer needed
	if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", 0, "UInt*", &DecLen:=0, "UPtr", 0, "UPtr", 0)) {
		return -1
	}

	Dec := Buffer(DecLen, 0)

	; decode the Base64 encoded string
	if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", Dec.Ptr, "UInt*", &DecLen, "UPtr", 0, "UPtr", 0)) {
		return -2
	}

	; create a memory stream
	if !(pStream := DllCall("shlwapi\SHCreateMemStream", "UPtr", Dec.Ptr, "UInt", DecLen, "UPtr")) {
		return -3
	}

	DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "UPtr", pStream, "Ptr*", &pBitmap:=0)
	ObjRelease(pStream)

	return pBitmap
}

Gdip_CreateARGBHBITMAPFromBitmap(&pBitmap) {
	; This version is about 25% faster than Gdip_CreateHBITMAPFromBitmap().
	; Get Bitmap width and height.
	DllCall("gdiplus\GdipGetImageWidth", "ptr", pBitmap, "uint*", &width:=0)
	DllCall("gdiplus\GdipGetImageHeight", "ptr", pBitmap, "uint*", &height:=0)

	; Convert the source pBitmap into a hBitmap manually.
	; struct BITMAPINFOHEADER - https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
	hdc := DllCall("CreateCompatibleDC", "ptr", 0, "ptr")
	bi := Buffer(40, 0)               ; sizeof(bi) = 40
	NumPut(
		"UInt",     40,  		; Size
		"UInt",    	width,  	; Width
		"Int",  	-height,	; Height - Negative so (0, 0) is top-left.
		"ushort",   1, 			; Planes
		"ushort",   32,  		; BitCount / BitsPerPixel
		bi)
	hbm := DllCall("CreateDIBSection", "ptr", hdc, "ptr", bi.Ptr, "UInt", 0, "ptr*", &pBits:=0, "ptr", 0, "UInt", 0, "ptr")
	obm := DllCall("SelectObject", "ptr", hdc, "ptr", hbm, "ptr")

	; Transfer data from source pBitmap to an hBitmap manually.
	Rect := Buffer(16, 0)              ; sizeof(Rect) = 16
	NumPut(
		"UInt",   width,	; Width
		"UInt",  height, 	; Height
		Rect, 8)
	BitmapData := Buffer(16+2*A_PtrSize, 0)     ; sizeof(BitmapData) = 24, 32
	NumPut(
		"UInt",     width, 	; Width
		"UInt",    height, 	; Height
		"Int",  4 * width, 	; Stride
		"Int",    0xE200B, 	; PixelFormat
		"ptr",      pBits, 	; Scan0
		BitmapData)
	DllCall("gdiplus\GdipBitmapLockBits"
				,    "ptr", pBitmap
				,    "ptr", Rect.Ptr
				,   "UInt", 5            ; ImageLockMode.UserInputBuffer | ImageLockMode.ReadOnly
				,    "Int", 0xE200B      ; Format32bppPArgb
				,    "ptr", BitmapData.Ptr) ; Contains the pointer (pBits) to the hbm.
	DllCall("gdiplus\GdipBitmapUnlockBits", "ptr", pBitmap, "ptr", BitmapData.Ptr)

	; Cleanup the hBitmap and device contexts.
	DllCall("SelectObject", "ptr", hdc, "ptr", obm)
	DllCall("DeleteDC",     "ptr", hdc)

	return hbm
}

Gdip_CreateHICONFromBitmap(pBitmap)
{
	DllCall("gdiplus\GdipCreateHICONFromBitmap", "UPtr", pBitmap, "UPtr*", &hIcon:=0)
	return hIcon
}