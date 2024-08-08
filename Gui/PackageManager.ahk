BtnPackageManager_Click(g, NavIndex) {
	static LVWidth
	CurrentTabCtrls:=[	"PackageManager_BtnDisable" ,
						"PackageManager_BtnUninstallChecked",
						"PackageManager_BtnUninstall",
						"PackageManager_BtnSearchOnline",
						"PackageManager_BtnDetails",
						"PackageManager_Mode",
						"PackageManager_InstalledAllUsers",
						"PackageManager_DeprovisionPackage",
						"PackageManager_LV"]
	try {
		Loop CurrentTabCtrls.Length {
			If InStr(CurrentTabCtrls[A_Index], "PackageManager_Btn")
				g[CurrentTabCtrls[A_Index]].Enabled:=False
			g[CurrentTabCtrls[A_Index]].Visible:=True
		}	
	} Catch {
		g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
		
		xTop:=sXCBT+8
		yTop:=sYCBT+8
		a:=g.AddDDL("vPackageManager_Mode w200 Section x" xTop " y" yTop)

		a.OnEvent("Change",SwichInstalled)
		
		b:=g.AddCheckbox("vPackageManager_InstalledAllUsers yp w150")
		b.OnEvent("Click",SwichInstalled)
		
		g.AddCheckbox("vPackageManager_DeprovisionPackage yp w200")
		
		g.SetFont("s11",App.IconFont)
		a:=g.AddButton("vPackageManager_BtnUninstallChecked w150 Disabled xs")
		a.OnEvent("Click",(*)=>PackageManager_FnRun(1))
		
		a:=g.AddButton("vPackageManager_BtnUninstall yp w150 Disabled")
		a.OnEvent("Click",(*)=>PackageManager_FnRun(2))
		
		a:=g.AddButton("vPackageManager_BtnDisable yp w146 Disabled")
		a.OnEvent("Click",(*)=>PackageManager_FnRun(3))
		
		a:=g.AddButton("vPackageManager_BtnSearchOnline yp w160 Disabled")
		a.OnEvent("Click",(*)=>PackageManager_FnRun(4))
		
		a:=g.AddButton("vPackageManager_BtnDetails yp w146 Disabled")
		a.OnEvent("Click",(*)=>PackageManager_FnRun(5))
		
		g.SetFont("s" App.MainFontSize+1,App.MainFont)
		LVWidth:=PanelW-16
		LVPackageManager:=g.AddListView("vPackageManager_LV -Multi Sort Checked xs w" LVWidth " h" PanelH-66-16, ["","","","","","Id",""])
		LVPackageManager.OnEvent("Click",LVPackageManager_Click)
		LVPackageManager.OnEvent("DoubleClick",LVPackageManager_DoubleClick)
		LVPackageManager.OnEvent("ContextMenu",LVPackageManager_ContextMenu)
		LVPackageManager.OnEvent("ItemCheck",LVPackageManager_ItemCheck)
		g.SetFont("s" App.MainFontSize,App.MainFont)
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
	}
	
	If !App.TabLangLoaded.HasOwnProp(NavIndex) || !App.TabLangLoaded.%NavIndex% {
		LVPackageManager:=g["PackageManager_LV"]
		
		g["PackageManager_Mode"].Delete()
		g["PackageManager_Mode"].Add([GetLangText("Text_InstalledMode"),GetLangText("Text_NotInstalledMode")])
		g["PackageManager_Mode"].Choose(1)
		g["PackageManager_Mode"].Opt("Redraw")
		
		
		g["PackageManager_BtnUninstallChecked"].Text:=GetLangTextWithIcon("Text_Uninstall") " (0)"
		g["PackageManager_InstalledAllUsers"].Text:=GetLangName("PackageManager_InstalledAllUsers")
		g["PackageManager_DeprovisionPackage"].Text:=GetLangName("PackageManager_DeprovisionPackage")
		
		m:=Map("PackageManager_BtnUninstall", "Text_Uninstall" ,
			   "PackageManager_BtnDisable", "Text_Disable" ,
			   "PackageManager_BtnDetails", "Text_Details" ,
			   "PackageManager_BtnSearchOnline", "Text_SearchOnline")
		For k, v in m {
			g[k].Text:=GetLangTextWithIcon(v)
		}
		
		LVPackageManager.ModifyCol(1, , GetLangText("Text_Name"))
		LVPackageManager.ModifyCol(2, , GetLangText("Text_Status"))
		LVPackageManager.ModifyCol(3, , GetLangText("Text_Version"))
		LVPackageManager.ModifyCol(4, , GetLangText("Text_Architecture"))
		LVPackageManager.ModifyCol(5, , GetLangText("Text_PublisherDisplayName"))
		LVPackageManager.ModifyCol(7, , GetLangText("Text_FamilyName"))
		
		App.TabLangLoaded.%NavIndex%:=1
	}
	
	LoadLV()	
	App.CurrentTabCtrls:=CurrentTabCtrls
	
	LoadLV(*) {
		g["BtnSys_SaveOptimizeConfigTab"].Visible:=False
		
		LVPackageManager:=g["PackageManager_LV"]
		LVPackageManager.ModifyCol(1, 38/100*LVWidth)
		LVPackageManager.ModifyCol(2, 12/100*LVWidth)
		LVPackageManager.ModifyCol(3, 17/100*LVWidth)
		LVPackageManager.ModifyCol(4, 10/100*LVWidth)
		LVPackageManager.ModifyCol(5, 23/100*LVWidth-2)
		LVPackageManager.ModifyCol(6, 0)
		LVPackageManager.ModifyCol(7, 0)
		
		ImageListID := IL_Create(20)
		LVPackageManager.SetImageList(ImageListID)
		
		LVPackageManager.Delete()
		IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
		Mode:=g["PackageManager_Mode"].Value
		rList:=PackageManager.FindPackages(IsAllUsers?"All":App.UserSID)
		PackagesList(rList)
		Loop rList.Length {
			If (Mode==1 && PackageManager.CheckInstallUser(rList[A_Index].FullName, App.UserSID)
					&& !RegKeyExist("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\" App.UserSID "\" rList[A_Index].FullName))
				|| (Mode==2 && (PackageManager.CheckInstallUser(rList[A_Index].FullName, "S-1-5-18", 1) 
					|| !PackageManager.CheckInstallUser(rList[A_Index].FullName, App.UserSID))) {
				Try {
					IconIndex := IL_Add(ImageListID, rList[A_Index].Logo, 1)
					aDisplay:=DisplayArchitecture(rList[A_Index].Architecture)
					sDisplay:=DisplayStatus(rList[A_Index])
					LVPackageManager.Add("Icon" IconIndex, rList[A_Index].DisplayName, sDisplay, rList[A_Index].Version, aDisplay, rList[A_Index].PublisherDisplayName, A_Index, rList[A_Index].FamilyName)
				} Catch Error as err {
					Debug(err, "FullName :" rList[A_Index].FullName)
				}
			}
		}
	}
	SwichInstalled(Ctr, *) {
		If Ctr.Name="PackageManager_Mode" {
			If Ctr.Value==1 {
				g["PackageManager_InstalledAllUsers"].Value:=0
				g["PackageManager_InstalledAllUsers"].Enabled:=1
			} Else If Ctr.Value==2 {
				g["PackageManager_InstalledAllUsers"].Value:=1
				g["PackageManager_InstalledAllUsers"].Enabled:=0
			}
		}
		g["PackageManager_BtnUninstallChecked"].Text:=GetLangTextWithIcon("Text_Uninstall") " (0)"
		g["PackageManager_BtnUninstallChecked"].Enabled:=False
		SwichAllBtn(0)
		LoadLV()
	}
	LVPackageManager_ItemCheck(GuiCtrlObj, Item, Checked) {
		Reload_BtnCountChecked()
	}
	LVPackageManager_Click(GuiCtrlObj, Item) {
		If Item {
			LVPackageManager.Modify(Item, "Select")
			id := LVPackageManager.GetText(Item,6)
			aList:=PackagesList()
			If aList[id].Disabled {
				bStatusText:=GetLangTextWithIcon("Text_Enable")
			} Else {
				bStatusText:=GetLangTextWithIcon("Text_Disable")
			}
			g["PackageManager_BtnDisable"].Text:=bStatusText
		}
		SwichAllBtn(!!Item)
	}
	LVPackageManager_DoubleClick(GuiCtrlObj, Item) {
		If Item {
			CreateDetailDlg(Item)
		}
	}
	LVPackageManager_ContextMenu(GuiCtrlObj, Item, IsRightClick, X, Y) {
		iSelected:=g["PackageManager_LV"].GetNext()
		If iSelected {
			MyMenu := Menu()
			
			iCount:=LVCheckedCount()
			MyMenu.Add(GetLangText("Text_Uninstall") " (" iCount ")", RunItem)
			If !iCount
				MyMenu.Disable("1&")
				
			MyMenu.Add(GetLangText("Text_Uninstall"), RunItem)
			
			id := LVPackageManager.GetText(iSelected,6)
			aList:=PackagesList()
			If aList[id].Disabled {
				iStatusText:="Text_Enable"
			} Else {
				iStatusText:="Text_Disable"
			}
			g["PackageManager_BtnDisable"].Text:=GetLangTextWithIcon(iStatusText)
			
			MyMenu.Add(GetLangText(iStatusText), RunItem)
			MyMenu.Add(GetLangText("Text_SearchOnline"), RunItem)
			MyMenu.Add(GetLangText("Text_Details"), RunItem)
			MyMenu.Add(GetLangText("Text_SelectAll"), (*)=> LVPackageManager.Modify(0, "Check") Reload_BtnCountChecked())
			MyMenu.Add(GetLangText("Text_DeselectAll"), (*)=> LVPackageManager.Modify(0, "-Check") Reload_BtnCountChecked())
			
			Mode:=g["PackageManager_Mode"].Value
			If Mode=2 && App.User=A_Username {
				MyMenu.Add(GetLangText("Text_Install") " (" iCount ")", RunItem)
				If !iCount
					MyMenu.Disable("8&")
				MyMenu.Add(GetLangText("Text_Install"), RunItem)
			}			
			MyMenu.Show
		
			RunItem(ItemName, ItemPos, MyMenu) {
				PackageManager_FnRun(ItemPos)
			}
		}
		SwichAllBtn(!!iSelected)
	}
	PackageManager_FnRun(ItemPos) {
		LVPackageManager:=g["PackageManager_LV"]
		iSelected:=LVPackageManager.GetNext()
		id := LVPackageManager.GetText(iSelected,6)
		aList:=PackagesList()
		If ItemPos=1 {
			g2:=CreateWaitDlg(g)
			IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
			RowNumber := 0
			t:=""
			Loop {
				RowNumber := LVPackageManager.GetNext(RowNumber,"c")
				if not RowNumber
					break
				cid := LVPackageManager.GetText(RowNumber,6)
				r:=UninstallPackage(aList[cid], IsAllUsers, g["PackageManager_DeprovisionPackage"].Value)
				If r {
					LVPackageManager.Delete(RowNumber)
					RowNumber--
					Reload_BtnCountChecked()
				}	
			}
			SwichAllBtn(0)
			DestroyDlg()
		} Else If ItemPos=2 {
			g2:=CreateWaitDlg(g)
			IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
			r:=UninstallPackage(aList[id], IsAllUsers, g["PackageManager_DeprovisionPackage"].Value)
			If r {
				LVPackageManager.Delete(iSelected)
				Reload_BtnCountChecked()
			}
			SwichAllBtn(0)
			DestroyDlg()
		} Else If ItemPos=3 {
			iDisabled:=aList[id].Disabled
			If iDisabled {
				PackageManager.ClearPackageStatus(aList[id].FullName, 8)
				iStatusText:="Text_Enabled"
				bStatusText:="Text_Disable"
			} Else {
				PackageManager.SetPackageStatus(aList[id].FullName, 8)
				iStatusText:="Text_Disabled"
				bStatusText:="Text_Enable"
			}
			LVPackageManager.Modify(iSelected, , , GetLangText(iStatusText))
			g["PackageManager_BtnDisable"].Text:=GetLangTextWithIcon(bStatusText)
		} Else If ItemPos=4 {
			If aList[id].SignatureKind=3
				runAsParam:="https://apps.microsoft.com/search?query=" aList[id].DisplayName
			Else 
				runAsParam:="https://www.google.com/search?q=" aList[id].DisplayName
			try Run(runAsParam)
		} Else If ItemPos=5 {
			CreateDetailDlg(iSelected)
		} Else If ItemPos=8 {
			g2:=CreateWaitDlg(g)
			IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
			RowNumber := 0
			t:=""
			Loop {
				RowNumber := LVPackageManager.GetNext(RowNumber,"c")
				if not RowNumber
					break
				cid := LVPackageManager.GetText(RowNumber,6)
				
				If PackageManager.RegisterPackageByFullName(aList[cid].FullName)=1 {
					LVPackageManager.Delete(RowNumber)
					RowNumber--
					Reload_BtnCountChecked()
				}
			}
			SwichAllBtn(0)
			DestroyDlg()
		} Else If ItemPos=9 {
			g2:=CreateWaitDlg(g)
			If PackageManager.RegisterPackageByFullName(aList[id].FullName)=1 {
				LVPackageManager.Delete(iSelected)
				Reload_BtnCountChecked()
			}
			SwichAllBtn(0)
			DestroyDlg()
		}
	}
	Reload_BtnCountChecked() {
		iCount:=LVCheckedCount()
		g["PackageManager_BtnUninstallChecked"].Text:=GetLangTextWithIcon("Text_Uninstall") " (" iCount ")"
		g["PackageManager_BtnUninstallChecked"].Enabled:=!!iCount
		g["BtnSys_SaveOptimizeConfigTab"].Visible:=!!iCount
	}
	LVCheckedCount() {
		iCount:=0
		RowNumber := 0
		Loop {
			RowNumber := g["PackageManager_LV"].GetNext(RowNumber, "C")
			if not RowNumber
				break
			iCount++
		}
		Return iCount
	}
	SwichAllBtn(s) {
		g["PackageManager_BtnUninstall"].Enabled:=s
		g["PackageManager_BtnDisable"].Enabled:=s
		g["PackageManager_BtnSearchOnline"].Enabled:=s
		g["PackageManager_BtnDetails"].Enabled:=s
	}
	CreateDetailDlg(Item) {
		g2:=CreateDlg(g)
		a:=g2.AddText("w500 h22 xm0 Center", "~~~~~ " GetLangText("Text_Details") " ~~~~~").SetFont("s" App.MainFontSize+2)
		aShowList:=["DisplayName"
				, "FamilyName"
				, "FullName"
				, "PublisherDisplayName"
				, "Architecture"
				, "Version"
				, "SignatureKind"
				, "Status"
				, "InstalledPath"
				; , "MutablePath"
				, "EffectivePath"
				; , "Logo"
				; , "EffectiveExternalPath"
				; , "MachineExternalPath"
				; , "UserExternalPath"	
				]
		id := LVPackageManager.GetText(Item,6)
		aList:=PackagesList()
		g2.SetFont("s" App.MainFontSize+1)
		Loop aShowList.Length {
			tID:=aShowList[A_Index]
			a:=g2.AddText("w100 h16 xm0", GetLangText("Text_" tID))
			If tID="Status"
				s:=DisplayStatus(aList[id])
			Else If tID="Architecture" || tID="SignatureKind"
				s:=Display%tID%(aList[id].%tID%)
			Else
				s:=aList[id].%tID%
			b:=g2.AddEdit("-vscroll -E0x200 ReadOnly w400 yp Background"  Themes.%App.ThemeSelected%.BackColor, s)
		}
		btn_OK:=g2.AddButton("xm200 w100", GetLangText("Text_OK"))
		btn_OK.OnEvent("Click",(*)=>DestroyDlg())
		SetCtrlTheme(btn_OK)
		btn_OK.Focus()
		g.GetPos(&X, &Y, &W, &H)
		tWidth:=500
		g2.Show("x" X+sXCBT+(PanelW-tWidth)/2-12 " y" Y+130)
	}
	PackagesList(iArray?) {
		Static pl:=Array()
		If IsSet(iArray)
			pl:=iArray
		Return pl
	}
	DisplayStatus(item) {
		s:=""
		If item.VerifyIsOK {
			s:=GetLangText("Text_Enabled")
		} Else If item.Disabled {
			s:=GetLangText("Text_Disabled")
		}
		Return s
	}
	DisplayArchitecture(ArchitectureID) {
		Return (ArchitectureID=9)?"x64":(ArchitectureID=11)?"Neutral":(ArchitectureID=0)?"x86":ArchitectureID
	}
	DisplaySignatureKind(SignatureKindID) {
		Return (SignatureKindID=0)?"None":(SignatureKindID=1)?"Developer":(SignatureKindID=2)?"Enterprise":(SignatureKindID=3)?"Store":(SignatureKindID=4)?"System":SignatureKindID
	}
}
CreatePackageManagerPreSaveDlg(g) {
	g2:=CreateDlg(g)
	tWidth:=400
	g2.AddText("w" tWidth " h22 xm0 Center", "~~~~~ Pre-Save"  " ~~~~~").SetFont("s" App.MainFontSize+2)
	PreSaveAct:=g2.AddDDL("w200 Choose1", ["Uninstall", "Disable", "Deprovision"])
	SetCtrlTheme(PreSaveAct)
	PreSaveAct.OnEvent("Change", PreSaveAct_Change)
	PreSaveAct_Change(GuiCtrlObj, Info) {
		CB_InstalledAllUsers.Enabled:=(GuiCtrlObj.Value==1)
		CB_DeprovisionPackage.Enabled:=(GuiCtrlObj.Value!=3)
	}
	CB_InstalledAllUsers:=g2.AddCheckbox("w100 y+20 Checked" g["PackageManager_InstalledAllUsers"].Value, GetLangText("Text_InstalledAllUsers"))
	CB_DeprovisionPackage:=g2.AddCheckbox("yp w200 Checked" g["PackageManager_DeprovisionPackage"].Value, GetLangText("Text_DeprovisionPackage"))
	g2.AddText("w200 xm0 y+20", "FamilyName list:")
	Edit_PreSave:=g2.AddEdit("w" tWidth " r10 -Wrap")
	SetCtrlTheme(Edit_PreSave)
	LVPackageManager:=g["PackageManager_LV"]
	RowNumber := 0
	Loop {
		RowNumber := LVPackageManager.GetNext(RowNumber,"c")
		if not RowNumber
			break
		Edit_PreSave.Value.= LVPackageManager.GetText(RowNumber,7) '`n'
	}

	btn_Save:=g2.AddButton("xm96 w100", GetLangText("Text_Save"))
	btn_Save.OnEvent("Click",Save_Click)
	SetCtrlTheme(btn_Save)
	Save_Click(*) {
		g2.Opt("+OwnDialogs")
		SelectedFile := FileSelect("S16", App.Name "_OptimizeTabConfig_" A_Now ".json", "Save a file")
		If SelectedFile {
			Config:={}
			ObjPackageManager:={}
			ObjPackageManager.Act:=PreSaveAct.Text
			If CB_InstalledAllUsers.Enabled && CB_InstalledAllUsers.Value
				ObjPackageManager.AllUsers:=1
			If CB_DeprovisionPackage.Enabled && CB_DeprovisionPackage.Value
				ObjPackageManager.Deprovision:=1
			Items:=Array()
			Loop Parse, Edit_PreSave.Value, "`n" {
				t:=Trim(A_LoopField)
				If t
					Items.Push t
			}
			ObjPackageManager.FamilyNames := Items
			Config.PackageManager:=[ObjPackageManager]
			try
				FileDelete SelectedFile
			FileAppend JSON.stringify(Config), SelectedFile
			DestroyDlg()
		}
		g2.Opt("-OwnDialogs")
	}
	btn_Cancel:=g2.AddButton("yp w100", GetLangText("Text_Cancel"))
	btn_Cancel.OnEvent("Click",(*)=>DestroyDlg())
	SetCtrlTheme(btn_Cancel)
	
	g.GetPos(&X, &Y, &W, &H)
	g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
	g2.Show("x" X+sXCBT+(PanelW-tWidth)/2-12 " y" Y+130)
}