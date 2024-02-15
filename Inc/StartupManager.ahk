BtnStartupManager_Click(g, NavIndex) {
	CurrentTabCtrls:=Array()
	CurrentTabCtrls:=[	"StartupManager_BtnDisable" ,
						"StartupManager_BtnDelete",
						"StartupManager_BtnOpenTarget",
						"StartupManager_BtnFindRegistry",
						"StartupManager_BtnSearchOnline",
						"StartupManager_LV"]
	try {
		Loop CurrentTabCtrls.Length {
			If CurrentTabCtrls[A_Index]!="StartupManager_LV"
				g[CurrentTabCtrls[A_Index]].Enabled:=False
			g[CurrentTabCtrls[A_Index]].Visible:=True
		}	
	} Catch {
		g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
		a:=g.AddButton("vStartupManager_BtnDisable w110 Background" Themes.%ThemeSelected%.BackColorPanelRGB " Disabled x" sXCBT+6 " y" sYCBT+6,Chr(0xF140) " " GetLangText("Text_Disable"))
		a.SetFont("s11",IconFont)
		SetWindowTheme(a)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(1))

		a:=g.AddButton("vStartupManager_BtnDelete yp w110 Background" Themes.%ThemeSelected%.BackColorPanelRGB " Disabled",Chr(0xEA39) " " GetLangText("Text_Delete"))
		a.SetFont("s11",IconFont)
		SetWindowTheme(a)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(6))
		
		a:=g.AddButton("vStartupManager_BtnOpenTarget yp w190 Background" Themes.%ThemeSelected%.BackColorPanelRGB " Disabled",Chr(0xED25) " " GetLangText("Text_OpenTarget"))
		a.SetFont("s11",IconFont)
		SetWindowTheme(a)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(3))

		a:=g.AddButton("vStartupManager_BtnFindRegistry yp w160 Background" Themes.%ThemeSelected%.BackColorPanelRGB " Disabled",Chr(0xE74C) " " GetLangText("Text_FindRegistry"))
		a.SetFont("s11",IconFont)
		SetWindowTheme(a)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(4))
		
		a:=g.AddButton("vStartupManager_BtnSearchOnline yp w145 Background" Themes.%ThemeSelected%.BackColorPanelRGB " Disabled",Chr(0xF6FA) " " GetLangText("Text_SearchOnline"))
		a.SetFont("s11",IconFont)
		SetWindowTheme(a)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(5))
		LVStartupManager:=g.AddListView("vStartupManager_LV -Multi w" PanelW-12 " h" PanelH-46 " Background" Themes.%ThemeSelected%.BackColorPanelRGB " x" sXCBT+6 " y" sYCBT+40, 
								[GetLangText("Text_Name"),GetLangText("Text_Status"),GetLangText("Text_CommandLine"),GetLangText("Text_Target"),GetLangText("Text_Type"),"StatusId"])
		LVStartupManager.SetFont("s10")
		LVStartupManager.OnEvent("Click",LVStartupManager_Click)
		LVStartupManager.OnEvent("ContextMenu",LVStartupManager_ContextMenu)
	}
	LVStartupManager:=g["StartupManager_LV"]

	ImageListID := IL_Create(20)
	LVStartupManager.SetImageList(ImageListID)
	IL_Add(ImageListID, "imageres.dll", 3)
	IL_Add(ImageListID, "imageres.dll", 12)
	IL_Add(ImageListID, "imageres.dll", 4)

	LVStartupManager.ModifyCol(1, 200)
	LVStartupManager.ModifyCol(2, 70)
	LVStartupManager.ModifyCol(3, 473)
	LVStartupManager.ModifyCol(4, 0)
	LVStartupManager.ModifyCol(5, 0)
	LVStartupManager.ModifyCol(6, 0)
	
	LVStartupManager.Delete()
	LV_RegLoad(LVStartupManager, "HKCU|Run", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run")
	LV_RegLoad(LVStartupManager, "HKLM|Run", "HKLM\Software\Microsoft\Windows\CurrentVersion\Run", "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run")
	LV_FolderLoad(LVStartupManager, A_Startup, "Folder|Startup", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder")
	LV_FolderLoad(LVStartupManager, A_StartupCommon, "Folder|StartupCommon", "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder")
	Return CurrentTabCtrls
	
	LV_FolderLoad(LV, sPath, RunType, StartupApprovedKey) {
		Loop Files, sPath "\*.*" {
			If A_LoopFileName="desktop.ini"
				Continue
			If A_LoopFileExt="LNK" {
				FileGetShortcut A_LoopFilePath, &rTarget, &OutDir, &rArgs, &OutDesc, &rIcon, &rIconNum, &OutRunState
				rCommandLine:=rTarget " " rArgs
				IconIndex := IL_Add(ImageListID, rIcon?rIcon:rTarget, rIconNum?rIconNum:1)
				IconIndex := IconIndex?IconIndex:2
			} Else {
				rTarget:=A_LoopFilePath
				rCommandLine:=A_LoopFilePath
				IconIndex:=1
				If InStr(FileExist(rTarget), "D")
					IconIndex := 3
				Else {
					IconIndex := IL_Add(ImageListID, rTarget, 1)
					IconIndex := IconIndex?IconIndex:2
				}
			}
			HexReg:=RegRead(StartupApprovedKey, A_LoopFileName, "")
			ItemStatus:=""
			If HexReg
				ItemStatus:=SubStr(HexReg, 1, 2)+0
			ItemStatusText:=""
			If ItemStatus && Mod(ItemStatus, 2)
				ItemStatusText:=GetLangText("Text_Disabled")
			Else
				ItemStatusText:=GetLangText("Text_Enabled")
			LV.Add("Icon" IconIndex, A_LoopFileName, ItemStatusText, rCommandLine, rTarget, RunType, ItemStatus)
		}
	}
	LV_RegLoad(LV, RunType, RunKey, StartupApprovedKey) {
		Loop Reg, RunKey {
			v:=RegRead()
			HexReg:=RegRead(StartupApprovedKey, A_LoopRegName, "")
			ItemStatus:=""
			If HexReg
				ItemStatus:=SubStr(HexReg, 1, 2)+0
			ItemStatusText:=""
			If ItemStatus && Mod(ItemStatus, 2)
				ItemStatusText:=GetLangText("Text_Disabled")
			Else
				ItemStatusText:=GetLangText("Text_Enabled")
			rTarget:=FindTarget(v, &attr:="")
			IconIndex:=1
			If attr="D"
				IconIndex := 3
			Else If attr="AE" {
				IconIndex := IL_Add(ImageListID, rTarget, 1)
				IconIndex := IconIndex?IconIndex:2
			}
			LV.Add("Icon" IconIndex, A_LoopRegName, ItemStatusText, v, rTarget, RunType, ItemStatus)
		}
	}

	FindTarget(InPath, &rFileAttr) {
		r:=""
		If !InPath
			Return r
		If InStr(InPath, "%") {
			r:=FindTarget(ExpandEnvironmentStrings(InPath), &rFileAttr)
		} Else If InStr(FileExist(InPath), "D") {
			rFileAttr:="D"
			r:=InPath
		} Else If InStr(FileExist(InPath), "A") || InStr(FileExist(InPath), "N") {
			SplitPath InPath, &rFileName
			rFileAttr:="A"
			If SubStr(rFileName, -4)=".exe"
				rFileAttr.="E"
			r:=InPath
		} Else If InStr(InPath,'"')=1 {
			r:=FindTarget(SubStr(InPath, 2 , InStr(InPath,'"',,2)-2), &rFileAttr)
		} Else If InPath {
			SplitPath InPath,, &dir, &ext, &name_no_ext
			sExt:=StrSplit(ext,A_Space)[1]
			InPath:=dir "\" name_no_ext "." sExt
			r:=FindTarget(ExpandEnvironmentStrings(InPath), &rFileAttr)
		}
		Return r
	}
	ExpandEnvironmentStrings(str) {
		rExpanded:=Buffer(2000) 
		DllCall("ExpandEnvironmentStrings", "str", str, "ptr", rExpanded, "int", 1999)
		return StrGet(rExpanded)
	}
	LVStartupManager_Click(GuiCtrlObj, Item) {
		If Item {
			iTarget:=GuiCtrlObj.GetText(Item , 4)
			g["StartupManager_BtnOpenTarget"].Enabled:=!!iTarget
			
			iType:=GuiCtrlObj.GetText(Item , 5)
			g["StartupManager_BtnFindRegistry"].Enabled:=(InStr(iType,"HK")=1)
			
			g["StartupManager_BtnSearchOnline"].Enabled:=True
			
			iStatus:=GuiCtrlObj.GetText(Item , 6)
			If iStatus && Mod(iStatus, 2) {
				iStatusText:=GetLangText("Text_Enable")
				bStatusText:=Chr(0xE001) " " iStatusText
			} Else {
				iStatusText:=GetLangText("Text_Disable")
				bStatusText:=Chr(0xF140) " " iStatusText
			}
			g["StartupManager_BtnDisable"].Text:=bStatusText
			g["StartupManager_BtnDisable"].Enabled:=True
			g["StartupManager_BtnDelete"].Enabled:=True
		} Else {
			DisableAllBtn()
		}
	}
	LVStartupManager_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
		If Item<=255
			DisableAllBtn()
		If Item<=0 || Item>255
			Return
		
		MyMenu := Menu()
		
		iStatus:=GuiCtrlObj.GetText(Item , 6)
		If iStatus && Mod(iStatus, 2) {
			iStatusText:=GetLangText("Text_Enable")
			bStatusText:=Chr(0xE001) " " iStatusText
		} Else {
			iStatusText:=GetLangText("Text_Disable")
			bStatusText:=Chr(0xF140) " " iStatusText
		}
		g["StartupManager_BtnDisable"].Text:=bStatusText
		g["StartupManager_BtnDisable"].Enabled:=True
		
		MyMenu.Add(iStatusText, RunItem)
		MyMenu.Add(GetLangText("Text_Properties"), RunItem)
		MyMenu.Add(GetLangText("Text_OpenTarget"), RunItem)
		MyMenu.Add(GetLangText("Text_FindRegistry"), RunItem)
		MyMenu.Add(GetLangText("Text_SearchOnline"), RunItem)
		MyMenu.Add(GetLangText("Text_Delete"), RunItem)
		
		iTarget:=GuiCtrlObj.GetText(Item , 4)
		If iTarget {
			g["StartupManager_BtnOpenTarget"].Enabled:=True
		} Else {
			MyMenu.Disable("2&")
			MyMenu.Disable("3&")
		}
		iType:=GuiCtrlObj.GetText(Item , 5)
		If InStr(iType,"HK")=1 {
			g["StartupManager_BtnFindRegistry"].Enabled:=True
		} Else {
			MyMenu.Disable("4&")
		}
		g["StartupManager_BtnSearchOnline"].Enabled:=True
		g["StartupManager_BtnDelete"].Enabled:=True
		MyMenu.Show
		
		RunItem(ItemName, ItemPos, MyMenu) {
			StartupManager_FnRun(ItemPos)
		}
	}
	StartupManager_FnRun(ItemPos) {
		LV:=g["StartupManager_LV"]
		i:=LV.GetNext()
		If ItemPos=1 {
			sc:=""
			sHex:=""
			s:=LV.GetText(i , 6)
			If s && Mod(s, 2) {
				If s=3 {
					sc:=2
				} Else {
					sc:=6
				}
				sHex.="0" sc "0000000000000000000000"
				iStatusText:=GetLangText("Text_Enabled")
				bStatusText:=Chr(0xF140) " " GetLangText("Text_Disable")
			} Else {
				If !s || s=2 {
					sc:=3
				} Else {
					sc:=7
				}
				sHex.="0" sc "000000004012B7D233B201"
				iStatusText:=GetLangText("Text_Disabled")
				bStatusText:=Chr(0xE001) " " GetLangText("Text_Enable")
			}
			t:=LV.GetText(i , 5)
			If t="HKCU|Run" {
				Key:="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
			} Else If t="HKLM|Run" {
				Key:="HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
			} Else If t="Folder|Startup" {
				Key:="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"
			} Else If t="Folder|StartupCommon" {
				Key:="HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"
			}
			RegWrite sHex, "REG_BINARY", Key, LV.GetText(i , 1)
			g["StartupManager_BtnDisable"].Text:=bStatusText
			LV.Modify(i,,, iStatusText,,,,sc)
			Return
		} Else If ItemPos=6 {
			t:=LV.GetText(i , 5)
			RunKey:=""
			StartupApprovedKey:=""
			If t="HKCU|Run" {
				RunKey:="HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
				StartupApprovedKey:="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
			} Else If t="HKLM|Run" {
				RunKey:="HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
				StartupApprovedKey:="HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
			} Else If t="Folder|Startup" {
				StartupApprovedKey:="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"
				FileDelete A_Startup "\" LV.GetText(i , 1)
			} Else If t="Folder|StartupCommon" {
				StartupApprovedKey:="HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"
				FileDelete A_StartupCommon "\" LV.GetText(i , 1)
			}
			If RunKey
				try RegDelete RunKey, LV.GetText(i , 1)
			If StartupApprovedKey
				try RegDelete StartupApprovedKey, LV.GetText(i , 1)
			LV.Delete(i)
			DisableAllBtn()
			Return
		} Else If ItemPos=2 {
			runAsParam:="properties " LV.GetText(i, 4)
		} Else If ItemPos=3 {
			runAsParam:="explorer.exe /select, " LV.GetText(i, 4)
		} Else If ItemPos=4 {
			Key:=""
			t:=LV.GetText(i, 5)
			If InStr(t,"HKCU|Run")=1 {
				Key:="HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
			} Else If InStr(t,"HKLM|Run")=1 {
				Key:="HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
			}
			RegWrite Key, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey"
			runAsParam:="regedit.exe"
		} Else If ItemPos=5 {
			SplitPath LV.GetText(i, 4), &rFileName
			runAsParam:="https://www.google.com/search?q=" LV.GetText(i, 1) " " rFileName
		}
		try Run(runAsParam)
	}
	DisableAllBtn() {
		g["StartupManager_BtnDisable"].Enabled:=False
		g["StartupManager_BtnDelete"].Enabled:=False
		g["StartupManager_BtnOpenTarget"].Enabled:=False
		g["StartupManager_BtnFindRegistry"].Enabled:=False
		g["StartupManager_BtnSearchOnline"].Enabled:=False
	}
}
