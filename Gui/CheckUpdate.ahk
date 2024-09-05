CheckUpdate(g:="") {
	req := ComObject("Msxml2.XMLHTTP")
	req.open("GET", "https://api.github.com/repos/tranht17/WinTune/releases/latest", 1)
	req.onreadystatechange := Ready
	req.send()
	
	Ready() {
		if (req.readyState != 4)
			return
		if (req.status != 200) {
			;12007: No internet|The server name cannot be resolved.
			;12029: Block internet|Connection to the server failed.
			if g
				MsgBox(GetLangText("Text_ConnectionFailed"),GetLangText("Text_CheckUpdate"),"Icon!")
			return
		}
		
		try {
			LatestInfo:=JSON.parse(req.responseText)
			NewVer:=LatestInfo["tag_name"]
		} catch Error as err {
			if g
				MsgBox(GetLangText("Text_ConnectionFailed"),GetLangText("Text_CheckUpdate"),"Icon!")
			Return
		}
		
		if VerCompare(NewVer, App.Ver)==1 {
			if g {
				g2:=CreateDlg(g)
				SetPreventDestroyDlg(300)
				tWidth:=400
				g2.AddText("h22 xm0 Center w" tWidth, "~~~~~ " GetLangText("Text_CheckUpdate") " ~~~~~").SetFont("s" App.MainFontSize+1)
				g2.AddText("xm0", GetLangText("Text_CurrentVersion") ":")
				g2.AddText("yp", App.Ver)
				g2.AddText("xm0", GetLangText("Text_NewestVersion") ":")
				g2.AddText("yp c" Themes.%App.ThemeSelected%.TextColorHover, NewVer)
				g2.AddText("xm0", GetLangText("Text_WhatsNew") ":")
				
				WhatsNew:=RegExReplace(LatestInfo["body"], "sm)\r\n## Verify.*")
				WhatsNew:=RegExReplace(WhatsNew, "\r\n!\[\]\(.*\)")
				
				EditWhatsNew:=g2.AddEdit("readonly xm0 h150 w" tWidth, WhatsNew)
				SetCtrlTheme(EditWhatsNew)
				BtnUpdate:=g2.AddButton("xm40 w100", GetLangText("Text_Update"))
				BtnUpdate.OnEvent("Click",BtnUpdate_Click)
				BtnUpdate.Focus()
				SetCtrlTheme(BtnUpdate)
				
				BtnHomepage:=g2.AddButton("yp w100", GetLangText("Text_Homepage"))
				BtnHomepage.OnEvent("Click",(*)=>Run("https://github.com/tranht17/WinTune"))
				SetCtrlTheme(BtnHomepage)
				
				BtnClose:=g2.AddButton("yp w100", GetLangText("Text_Close"))
				BtnClose.OnEvent("Click",(*)=>DestroyDlg())
				SetCtrlTheme(BtnClose)
				ShowDlg(g, g2, 1)
				
				BtnUpdate_Click(*) {
					DestroyDlg()
					g2:=CreateDlg(g)
					uWidth:=300,uHeight:=20
					g2.AddText("Center 0x200 h" uHeight " w" uWidth, GetLangText("Text_Updating") "...").SetFont("s" App.MainFontSize+1)
					ShowDlg(g, g2, 1)
					
					if A_IsCompiled {
						CurrentFile:=A_ScriptFullPath
						DownloadLink:="https://github.com/tranht17/WinTune/releases/download/" NewVer "/WinTune" (A_Is64bitOS?"":"32") ".exe"
						DownloadFile:=CurrentFile ".tmp"
						Method:="GET"
						ContentType:="application/octet-stream"
					} else {
						DownloadLink:="https://codeload.github.com/tranht17/WinTune/zip/refs/tags/" NewVer
						DownloadFolder:=A_ScriptDir "\WinTune-" NewVer
						DownloadFile:=DownloadFolder ".zip"
						Method:="GET"
						ContentType:="application/zip"
						try DirDelete DownloadFolder , 1
					}	
					try FileDelete DownloadFile
					
					req:=ComObject("WinHttp.WinHttpRequest.5.1")
					req.SetTimeouts(4000, 4000, 4000, 4000)
					req.Open(Method, DownloadLink, 0)
					
					FileDownloaded:=0
					Loop 10 {
						try {
							req.Send()
							TotalSize := req.GetResponseHeader("Content-Length")
							tContentType := req.GetResponseHeader("Content-Type")
							if tContentType=ContentType {
								tResponseBody := req.ResponseBody
								pData := NumGet(ComObjValue(tResponseBody) + 8 + A_PtrSize, "UPtr")
								FileOpen(DownloadFile, "w").RawWrite(pData, TotalSize)
								FileDownloaded:=1
								Break
							}
						}
					}
					
					if FileDownloaded {
						if A_IsCompiled {
							try FileDelete CurrentFile ".bak"
							FileMove CurrentFile, CurrentFile ".bak", 1
							FileMove DownloadFile, CurrentFile, 1
						} else {
							DirCopy DownloadFile, A_ScriptDir, 1
							DirCopy DownloadFolder, A_ScriptDir, 1
							try DirDelete DownloadFolder , 1
							try FileDelete DownloadFile
						}
						Reload
					} Else {
						try FileDelete DownloadFile
						DestroyDlg()
						MsgBox(GetLangText("Text_UpdateFailed"),GetLangText("Text_CheckUpdate"),"Icon!")
					}
				}
			} else if App.HasOwnProp("HwndMain") && App.HwndMain && g:=GuiFromHwnd(App.HwndMain) {
				g["VerCtrl"].ToolTipEx:=1
				g["VerCtrl"].Text:="v" App.Ver " -> v" NewVer
				g["VerCtrl"].SetFont("c" Themes.%App.ThemeSelected%.TextColorHover)
			}
		} else if g {
			g["VerCtrl"].DeleteProp("ToolTipEx")
			g2:=CreateDlg(g)
			SetPreventDestroyDlg(300)
			a:=g2.AddText("h22 xm0 Center w300", "~~~~~ " GetLangText("Text_CheckUpdate") " ~~~~~").SetFont("s" App.MainFontSize+1)
			a:=g2.AddText("xm0 yp50 w300 h50 Center", GetLangText("Text_NoUpdate"))
			BtnOK:=g2.AddButton("xm50 w100", GetLangText("Text_OK"))
			BtnOK.OnEvent("Click",(*)=>DestroyDlg())
			SetCtrlTheme(BtnOK)
			BtnHomepage:=g2.AddButton("yp w100", GetLangText("Text_Homepage"))
			BtnHomepage.OnEvent("Click",(*)=>Run("https://github.com/tranht17/WinTune"))
			SetCtrlTheme(BtnHomepage)
			ShowDlg(g, g2, 1)
		}
	}
}
