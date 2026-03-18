BtnStartupManager_Click(g, NavID) {
	static LVWidth
	CurrentTabCtrls:=[	"StartupManager_BtnDisable" ,
						"StartupManager_BtnDelete",
						"StartupManager_BtnOpenTarget",
						"StartupManager_BtnFindRegistry",
						"StartupManager_BtnSearchOnline",
						"StartupManager_LV"]
	try {
		Loop CurrentTabCtrls.Length {
			if CurrentTabCtrls[A_Index]!="StartupManager_LV"
				g[CurrentTabCtrls[A_Index]].Enabled:=False
			g[CurrentTabCtrls[A_Index]].Visible:=True
		}	
	} catch {
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
		LVStartupManager:=g.AddListView("vStartupManager_LV -Multi w" LVWidth " h" PanelH-46 " x" sXCBT+6 " y" sYCBT+40, ["","","","","Type","StatusId","UWPAppRegKey"])
		LVStartupManager.OnEvent("Click",LVStartupManager_Click)
		LVStartupManager.OnEvent("ContextMenu",LVStartupManager_ContextMenu)
		g.SetFont("s" App.MainFontSize,App.MainFont)
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
	}
	LVStartupManager:=g["StartupManager_LV"]
	
	if !App.TabLangLoaded.HasOwnProp(NavID) || !App.TabLangLoaded.%NavID% {
		m:=Map("StartupManager_BtnDisable", "Text_Disable" ,
			   "StartupManager_BtnDelete", "Text_Delete" ,
			   "StartupManager_BtnOpenTarget", "Text_OpenTarget" ,
			   "StartupManager_BtnFindRegistry", "Text_FindRegistry" ,
			   "StartupManager_BtnSearchOnline", "Text_SearchOnline"
				)
		for k, v in m {
			g[k].Text:=GetLangTextWithIcon(v)
		}
		
		LVStartupManager.ModifyCol(1, , GetLangText("Text_Name"))
		LVStartupManager.ModifyCol(2, , GetLangText("Text_Status"))
		LVStartupManager.ModifyCol(3, , GetLangText("Text_CommandLine"))
		LVStartupManager.ModifyCol(4, , GetLangText("Text_Target"))
		; LVStartupManager.ModifyCol(5, , GetLangText("Text_Type"))
		
		App.TabLangLoaded.%NavID%:=1
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
	LVStartupManager.ModifyCol(7, 0)
	
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
		{Type: "UWPApp", LongType: "UWPApp"}
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
			if A_LoopFileName="desktop.ini"
				Continue
			if A_LoopFileExt="LNK" {
				FileGetShortcut A_LoopFilePath, &rTarget, &OutDir, &rArgs, &OutDesc, &rIcon, &rIconNum, &OutRunState
				rCommandLine:=rTarget " " rArgs
				IconIndex := IL_Add(ImageListID, rIcon?rIcon:rTarget, rIconNum?rIconNum:1)
				IconIndex := IconIndex?IconIndex:2
			} else {
				rTarget:=A_LoopFilePath
				rCommandLine:=A_LoopFilePath
				IconIndex:=1
				if InStr(FileExist(rTarget), "D")
					IconIndex := 3
				else {
					IconIndex := IL_Add(ImageListID, rTarget, 1)
					IconIndex := IconIndex?IconIndex:2
				}
			}
			HexReg:=RegRead(StartupApprovedKey, A_LoopFileName, "")
			ItemStatus:=""
			if HexReg
				ItemStatus:=SubStr(HexReg, 1, 2)+0
			ItemStatusText:=""
			if ItemStatus && Mod(ItemStatus, 2)
				ItemStatusText:=GetLangText("Text_Disabled")
			else
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
			if sItem.HasOwnProp("StartupApprovedKey") && sItem.StartupApprovedKey {
				StartupApprovedKey:=sItem.StartupApprovedKey
				HexReg:=RegRead(StartupApprovedKey, A_LoopRegName, "")
				if HexReg
					ItemStatus:=SubStr(HexReg, 1, 2)+0
				else
					ItemStatus:=2
				if Mod(ItemStatus, 2)
					ItemStatusText:=GetLangText("Text_Disabled")
			}
			try {
				rTarget:=FindTarget(v, &attr:="")
			} catch Error as err {
				Debug(err,"CommandLine: " v)
			}
			
			IconIndex:=1
			if attr="D"
				IconIndex := 3
			else if attr="AE" {
				IconIndex := IL_Add(ImageListID, rTarget, 1)
				IconIndex := IconIndex?IconIndex:2
			}
			LV.Add("Icon" IconIndex, A_LoopRegName, ItemStatusText, v, rTarget, sId, ItemStatus)
		}
	}
	UWPAppLoad(LV, sId, sItem) {
		Loop Reg "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData", "K" {
			FamilyName:=A_LoopRegName
			Loop Reg A_LoopRegKey "\" A_LoopRegName, "K" {
				StartupKey:=A_LoopRegName
				Loop Reg A_LoopRegKey "\" A_LoopRegName {
					if A_LoopRegName="State" {
						State:=RegRead()
						if RegRead(A_LoopRegKey, "UserEnabledStartupOnce", 0)
							State:=2
						Packages:=PackageManager.FindPackagesByPackageFamilyName(FamilyName)
						if !Packages.Length
							return
						ItemStatusText:=GetLangText("Text_Disabled")
						if State==2
							ItemStatusText:=GetLangText("Text_Enabled")		
						IconIndex := IL_Add(ImageListID, Packages[1].Logo)
						LV.Add("Icon" IconIndex, Packages[1].DisplayName, ItemStatusText, , , sId, State, FamilyName "\" StartupKey)
					}
				}
			}
		}
	}
	FindTarget(InPath, &rFileAttr) {
		if !InPath
			return
		StartPos:=1
		tmpTarget:=""
		while (fpo:=RegexMatch(InPath, '[^" ]+|"([^"]*)"', &m, StartPos)) {
			if A_Index!=1
				tmpTarget.=' '
			tmpTarget.=m[1]?m[1]:m[]
			if InStr(tmpTarget, "%")
				tmpTarget:=ExpandEnvironmentStrings(tmpTarget)
			if InStr(FileExist(tmpTarget), "D") {
				rFileAttr:="D"
				return tmpTarget
			} else if InStr(FileExist(tmpTarget), "A") || InStr(FileExist(tmpTarget), "N") {
				SplitPath tmpTarget, &rFileName
				rFileAttr:="A"
				if SubStr(rFileName, -4)=".exe"
					rFileAttr.="E"
				return tmpTarget
			}
			StartPos := fpo + StrLen(m[])
		}
	}
	LVStartupManager_Click(GuiCtrlObj, Item) {
		if Item {
			iTarget:=GuiCtrlObj.GetText(Item , 4)
			iType:=StartupType[GuiCtrlObj.GetText(Item , 5)].Type
			g["StartupManager_BtnOpenTarget"].Enabled:=!!iTarget
			g["StartupManager_BtnFindRegistry"].Enabled:=(iType=="Registry")
			g["StartupManager_BtnSearchOnline"].Enabled:=True
			
			IsUWPApp:=(iType=="UWPApp")
			
			iStatus:=GuiCtrlObj.GetText(Item , 6)
			
			if (IsUWPApp && iStatus!=2) || (!IsUWPApp && iStatus && Mod(iStatus, 2)) {
				bStatusText:="Text_Enable"
			} else
				bStatusText:="Text_Disable"

			g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
			
			if IsUWPApp
				g["StartupManager_BtnDisable"].Enabled:=True
			else
				g["StartupManager_BtnDisable"].Enabled:=!!iStatus
			
			g["StartupManager_BtnDelete"].Enabled:=!IsUWPApp
		} else {
			DisableAllBtn()
		}
	}
	LVStartupManager_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
		if Item<=255
			DisableAllBtn()
		if Item<=0 || Item>255
			return
		
		MyMenu := Menu()
		iType:=StartupType[GuiCtrlObj.GetText(Item , 5)].Type
		IsUWPApp:=(iType=="UWPApp")
		iStatus:=GuiCtrlObj.GetText(Item , 6)
		bStatusText:=""
		if (IsUWPApp && iStatus!=2) || (!IsUWPApp && iStatus && Mod(iStatus, 2)) {
			bStatusText:="Text_Enable"
		} else
			bStatusText:="Text_Disable"
		g["StartupManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
		if IsUWPApp
			g["StartupManager_BtnDisable"].Enabled:=True
		else
			g["StartupManager_BtnDisable"].Enabled:=!!iStatus
		
		MyMenu.Add(GetLangText(bStatusText), RunItem)
		MyMenu.Add(GetLangText("Text_Properties"), RunItem)
		MyMenu.Add(GetLangText("Text_OpenTarget"), RunItem)
		MyMenu.Add(GetLangText("Text_FindRegistry"), RunItem)
		MyMenu.Add(GetLangText("Text_SearchOnline"), RunItem)
		MyMenu.Add(GetLangText("Text_Delete"), RunItem)

		if !iStatus && !IsUWPApp
			MyMenu.Disable("1&")
		iTarget:=GuiCtrlObj.GetText(Item , 4)
		if iTarget {
			g["StartupManager_BtnOpenTarget"].Enabled:=True
		} else {
			MyMenu.Disable("2&")
			MyMenu.Disable("3&")
		}
		IsRegistry:=(iType=="Registry")
		if IsRegistry {
			g["StartupManager_BtnFindRegistry"].Enabled:=True
		} else {
			MyMenu.Disable("4&")
		}
		g["StartupManager_BtnSearchOnline"].Enabled:=True
		
		if IsUWPApp {
			g["StartupManager_BtnDelete"].Enabled:=False
			MyMenu.Disable("6&")
		} else
			g["StartupManager_BtnDelete"].Enabled:=True
		MyMenu.Show
		
		RunItem(ItemName, ItemPos, MyMenu) {
			StartupManager_FnRun(ItemPos)
		}
	}
	StartupManager_FnRun(ItemPos) {
		LV:=g["StartupManager_LV"]
		i:=LV.GetNext()
		if ItemPos=1 {
			iStatus:=LV.GetText(i , 6)
			iType:=StartupType[LV.GetText(i , 5)].Type
			IsUWPApp:=(iType=="UWPApp")
			if IsUWPApp {
				RunKey:=App.HKCU "\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\" LV.GetText(i , 7)
				if iStatus!=2 {
					iStatusText:="Text_Enabled"
					bStatusText:="Text_Disable"
					iStatus:=2
				} else {
					iStatusText:="Text_Disabled"
					bStatusText:="Text_Enable"
					iStatus:=0
					RegWrite 0, "REG_DWORD", RunKey, "UserEnabledStartupOnce"
				}
				RegWrite iStatus, "REG_DWORD", RunKey, "State"
			} else {
				sHex:=""
				if iStatus && Mod(iStatus, 2) {
					if iStatus=3 {
						iStatus:=2
					} else {
						iStatus:=6
					}
					sHex.="0" iStatus "0000000000000000000000"
					iStatusText:="Text_Enabled"
					bStatusText:="Text_Disable"
				} else {
					if !iStatus || iStatus=2 {
						iStatus:=3
					} else {
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
			return
		} else if ItemPos=6 {
			iType:=StartupType[LV.GetText(i , 5)].Type
			if iType=="Registry" {
				try RegDelete StartupType[LV.GetText(i , 5)].RunKey, LV.GetText(i , 1)
			} else {
				f:=StartupType[LV.GetText(i , 5)].RunKey "\" LV.GetText(i , 1)
				if InStr(FileExist(f), "D") {
					try DirDelete f, true
				} else {
					try FileDelete f
				}
			}
			try RegDelete StartupType[LV.GetText(i , 5)].StartupApprovedKey, LV.GetText(i , 1)
			LV.Delete(i)
			DisableAllBtn()
			return
		} else if ItemPos=2 {
			runAsParam:="properties " LV.GetText(i, 4)
		} else if ItemPos=3 {
			runAsParam:="explorer.exe /select, " LV.GetText(i, 4)
		} else if ItemPos=4 {	
			RegWrite StartupType[LV.GetText(i , 5)].RunKey, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit", "LastKey"
			runAsParam:="regedit.exe"
		} else if ItemPos=5 {
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
