CheckUpdate(g:="") {
	try {
		LatestInfoText:=WinHttpResponseText("https://api.github.com/repos/tranht17/WinTune/releases/latest")
	} catch Error as err {
		; if g {
		; }
		Return
	}
	LatestInfo:=JSON.parse(LatestInfoText)
	NewVer:=LatestInfo["tag_name"]
	
	if VerCompare(NewVer, App.Ver)==1 {
		if g {
			g2:=CreateDlg(g)
			tWidth:=400
			g2.AddText("h22 xm0 Center w" tWidth, "~~~~~ " GetLangText("Text_CheckUpdate") " ~~~~~").SetFont("s10")
			g2.AddText("xm0", GetLangText("Text_CurrentVersion") ":")
			g2.AddText("yp", App.Ver)
			g2.AddText("xm0", GetLangText("Text_NewestVersion") ":")
			g2.AddText("yp c00A7EB", NewVer)
			g2.AddText("xm0", GetLangText("Text_WhatsNew") ":")
			
			WhatsNew:=RegExReplace(LatestInfo["body"], "\\r\\n## Verify(.*)")
			WhatsNew:=RegExReplace(WhatsNew, "\\r\\n!\[\]\((.*?)\)")
			
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
			g.GetPos(&gX, &gY, &gW, &gH)
			g2.Show("x" gX+(gW-tWidth)/2-16 " y" gY+gH/2-130)
			
			BtnUpdate_Click(*) {
				DestroyDlg()
				g2:=CreateDlg(g)
				tWidth:=200
				ProgressUpdate:=g2.AddProgress("w200 h20", 0)
				g2.Show("x" gX+(gW-tWidth)/2-16 " y" gY+gH/2)
				
				if A_IsCompiled {
					DownloadLink:="https://github.com/tranht17/WinTune/releases/download/" NewVer "/WinTune" (A_Is64bitOS?"":"32") ".exe"
					DownloadFile:=A_ScriptFullPath ".tmp"
					Method:="HEAD"
				} else {
					DownloadLink:="https://github.com/tranht17/WinTune/archive/refs/tags/" NewVer ".zip"
					DownloadFolder:=A_ScriptDir "\WinTune-" NewVer
					DownloadFile:=DownloadFolder ".zip"
					Method:="GET"
				}
				
				whr:=ComObject("WinHttp.WinHttpRequest.5.1")
				whr.Open(Method, DownloadLink)
				
				TryCount:=0
				GoSend:
				whr.Send()

				try {
					TotalSize := whr.GetResponseHeader("Content-Length")
				} catch Error as err {
					if TryCount < 10 {
						Sleep 1000
						TryCount++
						GoTo GoSend
					} else {
						Debug(err)
					}
				}
				
				ProgressUpdate.Opt("Range0-" TotalSize)
				
				SetTimer __UpdateProgressBar, 100
				Download DownloadLink, DownloadFile
				
				__UpdateProgressBar() {
					CurrentSize:=FileGetSize(DownloadFile)
					ProgressUpdate.Value := CurrentSize
					if CurrentSize==TotalSize {
						SetTimer , 0
						if A_IsCompiled {
							FileMove A_ScriptFullPath, A_ScriptFullPath ".BAK", 1
							FileMove DownloadFile, A_ScriptFullPath, 1
						} else {
							DirCopy DownloadFile, A_ScriptDir, 1
							DirCopy DownloadFolder, A_ScriptDir, 1
							DirDelete DownloadFolder , 1
							FileDelete DownloadFile
						}
						Reload
					}
				}
			}
		} else if App.HasOwnProp("HwndMain") && App.HwndMain && g:=GuiFromHwnd(App.HwndMain) {
			g["VerCtrl"].ToolTipEx:=1
			g["VerCtrl"].Text:="v" App.Ver " -> v" NewVer
			g["VerCtrl"].SetFont("c00A7EB")
		}
	} else if g {
		g["VerCtrl"].DeleteProp("ToolTipEx")
		g2:=CreateDlg(g)
		tWidth:=300
		a:=g2.AddText("h22 xm0 Center w" tWidth, "~~~~~ " GetLangText("Text_CheckUpdate") " ~~~~~").SetFont("s10")
		a:=g2.AddText("xm0 yp50 w300 h50 Center", GetLangText("Text_NoUpdate"))
		BtnOK:=g2.AddButton("xm100 w100", GetLangText("Text_OK"))
		BtnOK.OnEvent("Click",(*)=>DestroyDlg())
		SetCtrlTheme(BtnOK)
		g.GetPos(&gX, &gY, &gW, &gH)
		g2.Show("x" gX+(gW-tWidth)/2-16 " y" gY+gH/2-80)
	}
}