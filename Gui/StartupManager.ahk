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
		a:=g.AddButton("vStartupManager_BtnDisable w110 Disabled x" sXCBT+6 " y" sYCBT+6, GetLangTextWithIcon("Text_Disable"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(1))

		a:=g.AddButton("vStartupManager_BtnDelete yp w110 Disabled", GetLangTextWithIcon("Text_Delete"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(6))
		
		a:=g.AddButton("vStartupManager_BtnOpenTarget yp w190 Disabled", GetLangTextWithIcon("Text_OpenTarget"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(3))

		a:=g.AddButton("vStartupManager_BtnFindRegistry yp w160 Disabled", GetLangTextWithIcon("Text_FindRegistry"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(4))
		
		a:=g.AddButton("vStartupManager_BtnSearchOnline yp w145 Disabled", GetLangTextWithIcon("Text_SearchOnline"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(5))
		LVStartupManager:=g.AddListView("vStartupManager_LV -Multi w" PanelW-12 " h" PanelH-46 " x" sXCBT+6 " y" sYCBT+40, 
								[GetLangText("Text_Name"),GetLangText("Text_Status"),GetLangText("Text_CommandLine"),GetLangText("Text_Target"),GetLangText("Text_Type"),"StatusId"])
		LVStartupManager.SetFont("s10")
		LVStartupManager.OnEvent("Click",LVStartupManager_Click)
		LVStartupManager.OnEvent("ContextMenu",LVStartupManager_ContextMenu)
		
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
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
	StartupType:={
		Registry_HKCU_Run: {Type: "Registry", RunKey: HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"},
		Registry_HKCU_Run32: {Type: "Registry", RunKey: HKCU "\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"},
		Registry_HKLM_Run: {Type: "Registry", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"},
		Registry_HKLM_Run32: {Type: "Registry", RunKey: "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"},
		Folder_Startup: {Type: "Folder", RunKey: EnvGet2("Startup"), StartupApprovedKey: HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"},
		Folder_StartupCommon: {Type: "Folder", RunKey: A_StartupCommon, StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"},
	}
	For k , v in StartupType.OwnProps() {
		iType:=v.Type
		%iType%Load(LVStartupManager, k, v)
	}
	Return CurrentTabCtrls
	
	FolderLoad(LV, sId, sItem) {
		sPath:=sItem.RunKey
		StartupApprovedKey:=sItem.StartupApprovedKey
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
			LV.Add("Icon" IconIndex, A_LoopFileName, ItemStatusText, rCommandLine, rTarget, sId, ItemStatus)
		}
	}
	RegistryLoad(LV, sId, sItem) {
		RunKey:=sItem.RunKey
		StartupApprovedKey:=sItem.StartupApprovedKey
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
			LV.Add("Icon" IconIndex, A_LoopRegName, ItemStatusText, v, rTarget, sId, ItemStatus)
		}
	}

	FindTarget(InPath, &rFileAttr) {
		r:=""
		If !InPath
			Return r
		
		SplitPath InPath,, &dir, &ext, &name_no_ext
		sExt:=StrSplit(ext,A_Space)[1]
		InPath:=dir "\" name_no_ext "." sExt

		If InStr(InPath, "%") {
			r:=FindTarget(ExpandEnvironmentStrings(InPath), &rFileAttr)
		} Else If InStr(InPath,'"')=1 {
			r:=FindTarget(SubStr(InPath, 2 , InStr(InPath,'"',,2)-2), &rFileAttr)
		} Else If InStr(FileExist(InPath), "D") {
			rFileAttr:="D"
			r:=InPath
		} Else If InStr(FileExist(InPath), "A") || InStr(FileExist(InPath), "N") {
			SplitPath InPath, &rFileName
			rFileAttr:="A"
			If SubStr(rFileName, -4)=".exe"
				rFileAttr.="E"
			r:=InPath
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
			g["StartupManager_BtnFindRegistry"].Enabled:=(StartupType.%GuiCtrlObj.GetText(Item , 5)%.Type=="Registry")		
			g["StartupManager_BtnSearchOnline"].Enabled:=True
			
			iStatus:=GuiCtrlObj.GetText(Item , 6)
			If iStatus && Mod(iStatus, 2) {
				bStatusText:="Text_Enable"
			} Else {
				bStatusText:="Text_Disable"
			}
			g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
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
			iStatusText:="Text_Enable"
		} Else {
			iStatusText:="Text_Disable"
		}
		g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(iStatusText)
		g["StartupManager_BtnDisable"].Enabled:=True
		
		MyMenu.Add(GetLangText(iStatusText), RunItem)
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
		IsRegistry:=(StartupType.%GuiCtrlObj.GetText(Item , 5)%.Type=="Registry")
		If IsRegistry {
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
				iStatusText:="Text_Enabled"
				bStatusText:="Text_Disable"
			} Else {
				If !s || s=2 {
					sc:=3
				} Else {
					sc:=7
				}
				sHex.="0" sc "000000004012B7D233B201"
				iStatusText:="Text_Disabled"
				bStatusText:="Text_Enable"
			}
			RegWrite sHex, "REG_BINARY", StartupType.%LV.GetText(i , 5)%.StartupApprovedKey, LV.GetText(i , 1)
			g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
			LV.Modify(i,,, GetLangText(iStatusText),,,,sc)
			Return
		} Else If ItemPos=6 {
			iType:=StartupType.%LV.GetText(i , 5)%.Type
			If iType=="Registry" {
				try RegDelete StartupType.%LV.GetText(i , 5)%.RunKey, LV.GetText(i , 1)
			} Else {
				f:=StartupType.%LV.GetText(i , 5)%.RunKey "\" LV.GetText(i , 1)
				If InStr(FileExist(f), "D") {
					try DirDelete f, true
				} Else {
					try FileDelete f
				}
			}
			try RegDelete StartupType.%LV.GetText(i , 5)%.StartupApprovedKey, LV.GetText(i , 1)
			LV.Delete(i)
			DisableAllBtn()
			Return
		} Else If ItemPos=2 {
			runAsParam:="properties " LV.GetText(i, 4)
		} Else If ItemPos=3 {
			runAsParam:="explorer.exe /select, " LV.GetText(i, 4)
		} Else If ItemPos=4 {	
			RegWrite StartupType.%LV.GetText(i , 5)%.RunKey, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey"
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
