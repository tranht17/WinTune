BtnStartupManager_Click(g, NavIndex) {
	static LVWidth
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
		
		g.SetFont("s11",App.IconFont)
		a:=g.AddButton("vStartupManager_BtnDisable w130 Disabled x" sXCBT+6 " y" sYCBT+6)
		a.OnEvent("Click",(*)=>StartupManager_FnRun(1))

		a:=g.AddButton("vStartupManager_BtnDelete yp w130 Disabled")
		a.OnEvent("Click",(*)=>StartupManager_FnRun(6))
		
		a:=g.AddButton("vStartupManager_BtnOpenTarget yp w190 Disabled")
		a.OnEvent("Click",(*)=>StartupManager_FnRun(3))

		a:=g.AddButton("vStartupManager_BtnFindRegistry yp w160 Disabled")
		a.OnEvent("Click",(*)=>StartupManager_FnRun(4))
		
		a:=g.AddButton("vStartupManager_BtnSearchOnline yp w145 Disabled")
		a.OnEvent("Click",(*)=>StartupManager_FnRun(5))
		LVWidth:=PanelW-12
		g.SetFont("s" App.MainFontSize+1,App.MainFont)
		LVStartupManager:=g.AddListView("vStartupManager_LV -Multi w" LVWidth " h" PanelH-46 " x" sXCBT+6 " y" sYCBT+40, ["","","","","Type","StatusId"])
		LVStartupManager.OnEvent("Click",LVStartupManager_Click)
		LVStartupManager.OnEvent("ContextMenu",LVStartupManager_ContextMenu)
		g.SetFont("s" App.MainFontSize,App.MainFont)
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
	}
	LVStartupManager:=g["StartupManager_LV"]
	
	If !App.TabLangLoaded.HasOwnProp(NavIndex) || !App.TabLangLoaded.%NavIndex% {
		m:=Map("StartupManager_BtnDisable", "Text_Disable" ,
			   "StartupManager_BtnDelete", "Text_Delete" ,
			   "StartupManager_BtnOpenTarget", "Text_OpenTarget" ,
			   "StartupManager_BtnFindRegistry", "Text_FindRegistry" ,
			   "StartupManager_BtnSearchOnline", "Text_SearchOnline"
				)
		For k, v in m {
			g[k].Text:=GetLangTextWithIcon(v)
		}
		
		LVStartupManager.ModifyCol(1, , GetLangText("Text_Name"))
		LVStartupManager.ModifyCol(2, , GetLangText("Text_Status"))
		LVStartupManager.ModifyCol(3, , GetLangText("Text_CommandLine"))
		LVStartupManager.ModifyCol(4, , GetLangText("Text_Target"))
		; LVStartupManager.ModifyCol(5, , GetLangText("Text_Type"))
		
		App.TabLangLoaded.%NavIndex%:=1
	}

	ImageListID := IL_Create(20)
	LVStartupManager.SetImageList(ImageListID)
	IL_Add(ImageListID, "imageres.dll", 3)
	IL_Add(ImageListID, "imageres.dll", 12)
	IL_Add(ImageListID, "imageres.dll", 4)

	LVStartupManager.ModifyCol(1, 28/100*LVWidth)
	LVStartupManager.ModifyCol(2, 12/100*LVWidth)
	LVStartupManager.ModifyCol(3, 60/100*LVWidth-2)
	LVStartupManager.ModifyCol(4, 0)
	LVStartupManager.ModifyCol(5, 0)
	LVStartupManager.ModifyCol(6, 0)
	
	LVStartupManager.Delete()
	
	StartupType:=[
		{Type: "Registry", LongType: "Registry_HKCU_Run", RunKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"},
		{Type: "Registry", LongType: "Registry_HKCU_RunOnce", RunKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\RunOnce"},
		{Type: "Registry", LongType: "Registry_HKCU_RunPolicies", RunKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run"},
		{Type: "Registry", LongType: "Registry_HKLM_Run", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"},
		{Type: "Registry", LongType: "Registry_HKLM_Run32", RunKey: "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run", StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"},
		{Type: "Registry", LongType: "Registry_HKLM_RunOnce", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"},
		{Type: "Registry", LongType: "Registry_HKLM_RunOnce32", RunKey: "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce"},
		{Type: "Registry", LongType: "Registry_HKLM_RunPolicies", RunKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run"},
		{Type: "Folder", LongType: "Folder_Startup", RunKey: EnvGet2("Startup"), StartupApprovedKey: App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"},
		{Type: "Folder", LongType: "Folder_StartupCommon", RunKey: A_StartupCommon, StartupApprovedKey: "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\StartupFolder"},
		{Type: "UWPApp", LongType: "Registry_HKCU_Run", FamilyName: "Microsoft.549981C3F5F10_8wekyb3d8bbwe", RunKey: "CortanaStartupId", CheckStartTerminalOnLoginTask: 1},
		{Type: "UWPApp", LongType: "Registry_HKCU_Run", FamilyName: "Microsoft.WindowsTerminal_8wekyb3d8bbwe", RunKey: "StartTerminalOnLoginTask"}
	]
	
	Loop StartupType.Length {
		iType:=StartupType[A_Index].Type
		%iType%Load(LVStartupManager, A_Index, StartupType[A_Index])
	}
	
	App.CurrentTabCtrls:=CurrentTabCtrls
	
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
		Loop Reg, RunKey {
			v:=RegRead()
			ItemStatus:=""
			ItemStatusText:=GetLangText("Text_Enabled")
			If sItem.HasOwnProp("StartupApprovedKey") && sItem.StartupApprovedKey {
				StartupApprovedKey:=sItem.StartupApprovedKey
				HexReg:=RegRead(StartupApprovedKey, A_LoopRegName, "")
				If HexReg
					ItemStatus:=SubStr(HexReg, 1, 2)+0
				Else
					ItemStatus:=2
				If Mod(ItemStatus, 2)
					ItemStatusText:=GetLangText("Text_Disabled")
			}
			try {
				rTarget:=FindTarget(v, &attr:="")
			} catch Error as err {
				Debug(err,"CommandLine: " v)
			}
			
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
	
	UWPAppLoad(LV, sId, sItem) {
		Packages:=PackageManager.FindPackagesByPackageFamilyName(sItem.FamilyName)
		If !Packages.Length
			Return

		RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" sItem.FamilyName "\" sItem.RunKey
		State:=RegRead(RunKey, "State", 0)
		
		If sItem.HasOwnProp("CheckStartTerminalOnLoginTask") && sItem.CheckStartTerminalOnLoginTask {
			If !RegRead(RunKey, "UserEnabledStartupOnce", 0)
				State:=1
		}
		
		ItemStatusText:=GetLangText("Text_Disabled")
		If State==2
			ItemStatusText:=GetLangText("Text_Enabled")
			
		IconIndex := IL_Add(ImageListID, Packages[1].Logo)
		LV.Add("Icon" IconIndex, Packages[1].DisplayName, ItemStatusText, , , sId, State)
	}

	FindTarget(InPath, &rFileAttr) {
		If !InPath
			Return
		StartPos:=1
		tmpTarget:=""
		while (fpo:=RegexMatch(InPath, '[^" ]+|"([^"]*)"', &m, StartPos)) {
			if A_Index!=1
				tmpTarget.=' '
			tmpTarget.=m[1]?m[1]:m[]
			If InStr(tmpTarget, "%")
				tmpTarget:=ExpandEnvironmentStrings(tmpTarget)
			If InStr(FileExist(tmpTarget), "D") {
				rFileAttr:="D"
				Return tmpTarget
			} Else If InStr(FileExist(tmpTarget), "A") || InStr(FileExist(tmpTarget), "N") {
				SplitPath tmpTarget, &rFileName
				rFileAttr:="A"
				If SubStr(rFileName, -4)=".exe"
					rFileAttr.="E"
				Return tmpTarget
			}
			StartPos := fpo + StrLen(m[])
		}
	}
	LVStartupManager_Click(GuiCtrlObj, Item) {
		If Item {
			iTarget:=GuiCtrlObj.GetText(Item , 4)
			iType:=StartupType[GuiCtrlObj.GetText(Item , 5)].Type
			g["StartupManager_BtnOpenTarget"].Enabled:=!!iTarget
			g["StartupManager_BtnFindRegistry"].Enabled:=(iType=="Registry")
			g["StartupManager_BtnSearchOnline"].Enabled:=True
			
			IsUWPApp:=(iType=="UWPApp")
			
			iStatus:=GuiCtrlObj.GetText(Item , 6)
			
			If (IsUWPApp && iStatus!=2) || (!IsUWPApp && iStatus && Mod(iStatus, 2)) {
				bStatusText:="Text_Enable"
			} Else
				bStatusText:="Text_Disable"

			g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
			
			If IsUWPApp
				g["StartupManager_BtnDisable"].Enabled:=True
			Else
				g["StartupManager_BtnDisable"].Enabled:=!!iStatus
			
			g["StartupManager_BtnDelete"].Enabled:=!IsUWPApp
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
		iType:=StartupType[GuiCtrlObj.GetText(Item , 5)].Type
		IsUWPApp:=(iType=="UWPApp")
		iStatus:=GuiCtrlObj.GetText(Item , 6)
		bStatusText:=""
		If (IsUWPApp && iStatus!=2) || (!IsUWPApp && iStatus && Mod(iStatus, 2)) {
			bStatusText:="Text_Enable"
		} Else
			bStatusText:="Text_Disable"
		g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
		If IsUWPApp
			g["StartupManager_BtnDisable"].Enabled:=True
		Else
			g["StartupManager_BtnDisable"].Enabled:=!!iStatus
		
		MyMenu.Add(GetLangText(bStatusText), RunItem)
		MyMenu.Add(GetLangText("Text_Properties"), RunItem)
		MyMenu.Add(GetLangText("Text_OpenTarget"), RunItem)
		MyMenu.Add(GetLangText("Text_FindRegistry"), RunItem)
		MyMenu.Add(GetLangText("Text_SearchOnline"), RunItem)
		MyMenu.Add(GetLangText("Text_Delete"), RunItem)

		If !iStatus && !IsUWPApp
			MyMenu.Disable("1&")
		iTarget:=GuiCtrlObj.GetText(Item , 4)
		If iTarget {
			g["StartupManager_BtnOpenTarget"].Enabled:=True
		} Else {
			MyMenu.Disable("2&")
			MyMenu.Disable("3&")
		}
		IsRegistry:=(iType=="Registry")
		If IsRegistry {
			g["StartupManager_BtnFindRegistry"].Enabled:=True
		} Else {
			MyMenu.Disable("4&")
		}
		g["StartupManager_BtnSearchOnline"].Enabled:=True
		
		If IsUWPApp {
			g["StartupManager_BtnDelete"].Enabled:=False
			MyMenu.Disable("6&")
		} Else
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
			iStatus:=LV.GetText(i , 6)
			iType:=StartupType[LV.GetText(i , 5)].Type
			IsUWPApp:=(iType=="UWPApp")
			If IsUWPApp {
				If iStatus!=2 {
					iStatusText:="Text_Enabled"
					bStatusText:="Text_Disable"
					iStatus:=2
					RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" StartupType[LV.GetText(i , 5)].FamilyName "\" StartupType[LV.GetText(i , 5)].RunKey
					RegWrite 1, "REG_DWORD", RunKey, "UserEnabledStartupOnce"
				} Else {
					iStatusText:="Text_Disabled"
					bStatusText:="Text_Enable"
					iStatus:=1
				}
				RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" StartupType[LV.GetText(i , 5)].FamilyName "\" StartupType[LV.GetText(i , 5)].RunKey
				RegWrite iStatus, "REG_DWORD", RunKey, "State"
			} Else {
				sHex:=""
				If iStatus && Mod(iStatus, 2) {
					If iStatus=3 {
						iStatus:=2
					} Else {
						iStatus:=6
					}
					sHex.="0" iStatus "0000000000000000000000"
					iStatusText:="Text_Enabled"
					bStatusText:="Text_Disable"
				} Else {
					If !iStatus || iStatus=2 {
						iStatus:=3
					} Else {
						iStatus:=7
					}
					sHex.="0" iStatus "000000" "004012B7D233B201"
					iStatusText:="Text_Disabled"
					bStatusText:="Text_Enable"
				}
				RegWrite sHex, "REG_BINARY", StartupType[LV.GetText(i , 5)].StartupApprovedKey, LV.GetText(i , 1)
			}
			g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
			LV.Modify(i,,, GetLangText(iStatusText),,,,iStatus)
			Return
		} Else If ItemPos=6 {
			iType:=StartupType[LV.GetText(i , 5)].Type
			If iType=="Registry" {
				try RegDelete StartupType[LV.GetText(i , 5)].RunKey, LV.GetText(i , 1)
			} Else {
				f:=StartupType[LV.GetText(i , 5)].RunKey "\" LV.GetText(i , 1)
				If InStr(FileExist(f), "D") {
					try DirDelete f, true
				} Else {
					try FileDelete f
				}
			}
			try RegDelete StartupType[LV.GetText(i , 5)].StartupApprovedKey, LV.GetText(i , 1)
			LV.Delete(i)
			DisableAllBtn()
			Return
		} Else If ItemPos=2 {
			runAsParam:="properties " LV.GetText(i, 4)
		} Else If ItemPos=3 {
			runAsParam:="explorer.exe /select, " LV.GetText(i, 4)
		} Else If ItemPos=4 {	
			RegWrite StartupType[LV.GetText(i , 5)].RunKey, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey"
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
