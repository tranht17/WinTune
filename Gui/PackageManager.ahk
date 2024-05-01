BtnPackageManager_Click(g, NavIndex) {
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
		a:=g.AddDDL("vPackageManager_Mode Choose1 x" xTop " y" yTop, [GetLangText("Text_InstalledMode"),GetLangText("Text_NotInstalledMode")])
		a.OnEvent("Change",SwichInstalled)
		
		b:=g.AddCheckbox("vPackageManager_InstalledAllUsers yp",GetLangName("PackageManager_InstalledAllUsers"))
		b.OnEvent("Click",SwichInstalled)
		
		g.AddCheckbox("vPackageManager_DeprovisionPackage yp",GetLangName("PackageManager_DeprovisionPackage"))
		
		a:=g.AddButton("vPackageManager_BtnUninstallChecked w140 Disabled x" sXCBT+6 " y" sYCBT+36, GetLangTextWithIcon("Text_Uninstall") " (0)")
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>PackageManager_FnRun(1))
		
		a:=g.AddButton("vPackageManager_BtnUninstall yp w140 Disabled", GetLangTextWithIcon("Text_Uninstall"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>PackageManager_FnRun(2))
		
		a:=g.AddButton("vPackageManager_BtnDisable yp w136 Disabled", GetLangTextWithIcon("Text_Disable"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>PackageManager_FnRun(3))
		
		a:=g.AddButton("vPackageManager_BtnSearchOnline yp w150 Disabled", GetLangTextWithIcon("Text_SearchOnline"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>PackageManager_FnRun(4))
		
		a:=g.AddButton("vPackageManager_BtnDetails yp w150 Disabled", GetLangTextWithIcon("Text_Details"))
		a.SetFont("s11",IconFont)
		a.OnEvent("Click",(*)=>PackageManager_FnRun(5))
		
		LVPackageManager:=g.AddListView("vPackageManager_LV -Multi Sort Checked w" PanelW-12 " h" PanelH-66-6 " x" sXCBT+6 " y" sYCBT+66, 
								[GetLangText("Text_Name"),GetLangText("Text_Status"),GetLangText("Text_Version"),GetLangText("Text_Architecture"),GetLangText("Text_PublisherDisplayName"),"Id",GetLangText("Text_FamilyName")])
		LVPackageManager.SetFont("s10")
		LVPackageManager.OnEvent("Click",LVPackageManager_Click)
		LVPackageManager.OnEvent("DoubleClick",LVPackageManager_DoubleClick)
		LVPackageManager.OnEvent("ContextMenu",LVPackageManager_ContextMenu)
		LVPackageManager.OnEvent("ItemCheck",LVPackageManager_ItemCheck)
		
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
	}
	LoadLV()	
	Return CurrentTabCtrls
	
	LoadLV(*) {
		g["BtnSys_SaveOptimizeConfigTab"].Visible:=False
		
		LVPackageManager:=g["PackageManager_LV"]
		LVPackageManager.ModifyCol(1, 280)
		LVPackageManager.ModifyCol(2, 80)
		LVPackageManager.ModifyCol(3, 120)
		LVPackageManager.ModifyCol(5, 170)
		LVPackageManager.ModifyCol(6, 0)
		LVPackageManager.ModifyCol(7, 0)
		
		ImageListID := IL_Create(20)
		LVPackageManager.SetImageList(ImageListID)
		
		LVPackageManager.Delete()
		IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
		Mode:=g["PackageManager_Mode"].Value
		rList:=PackageManager.FindPackages(IsAllUsers?"All":UserSID)
		PackagesList(rList)
		Loop rList.Length {
			If (Mode==1 && PackageManager.CheckInstallUser(rList[A_Index].FullName, UserSID)
					&& !RegKeyExist("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\" UserSID "\" rList[A_Index].FullName))
				|| (Mode==2 && (PackageManager.CheckInstallUser(rList[A_Index].FullName, "S-1-5-18", 1) 
					|| !PackageManager.CheckInstallUser(rList[A_Index].FullName, UserSID))) {
				i:=A_Index
				IconIndex := IL_Add(ImageListID, rList[i].Logo, 1)
				aDisplay:=DisplayArchitecture(rList[i].Architecture)
				sDisplay:=DisplayStatus(rList[i])
				LVPackageManager.Add("Icon" IconIndex, rList[i].DisplayName, sDisplay, rList[i].Version, aDisplay, rList[i].PublisherDisplayName, i, rList[i].FamilyName)
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
			If Mode=2 && CurrentUser=A_Username {
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
			DestroyDlg(g,g2)
		} Else If ItemPos=2 {
			g2:=CreateWaitDlg(g)
			IsAllUsers:=g["PackageManager_InstalledAllUsers"].Value
			r:=UninstallPackage(aList[id], IsAllUsers, g["PackageManager_DeprovisionPackage"].Value)
			If r {
				LVPackageManager.Delete(iSelected)
				Reload_BtnCountChecked()
			}
			SwichAllBtn(0)
			DestroyDlg(g,g2)
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
			DestroyDlg(g,g2)
		} Else If ItemPos=9 {
			g2:=CreateWaitDlg(g)
			If PackageManager.RegisterPackageByFullName(aList[id].FullName)=1 {
				LVPackageManager.Delete(iSelected)
				Reload_BtnCountChecked()
			}
			SwichAllBtn(0)
			DestroyDlg(g,g2)
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
		If WinExist(App.Name "_Popup")
			WinClose
		g2:=CreateDlg(g)
		a:=g2.AddText("w500 h22 xm0 Center", "~~~~~ " GetLangText("Text_Details") " ~~~~~").SetFont("s11")
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
				; , "EffectiveExternalPath"
				; , "MachineExternalPath"
				; , "UserExternalPath"	
				]
		id := LVPackageManager.GetText(Item,6)
		aList:=PackagesList()
		Loop aShowList.Length {
			tID:=aShowList[A_Index]
			a:=g2.AddText("w100 h16 xm0", GetLangText("Text_" tID))
			a.SetFont("s10")
			If tID="Status"
				s:=DisplayStatus(aList[id])
			Else If tID="Architecture" || tID="SignatureKind"
				s:=Display%tID%(aList[id].%tID%)
			Else
				s:=aList[id].%tID%
			b:=g2.AddEdit("-vscroll -E0x200 ReadOnly w400 yp Background"  Themes.%ThemeSelected%.BackColor, s)
			b.SetFont("s10")
		}
		btn_OK:=g2.AddButton("xm200 w100", GetLangText("Text_OK"))
		btn_OK.OnEvent("Click",(*)=>DestroyDlg(g,g2))
		SetCtrlTheme(btn_OK)
		btn_OK.Focus()
		g.GetPos(&X, &Y, &W, &H)
		tWidth:=500
		g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
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
UninstallPackage(Package, IsAllUsers, IsDeprovision) {
	If IsDeprovision
		PackageManager.DeprovisionPackageForAllUsers(Package.FamilyName)
	If CurrentUser=A_Username || IsAllUsers {
		r1:=PackageManager.RemovePackage(Package.FullName, IsAllUsers?0x80000:0)
		r:=(r1==1)
		If r1==3 {
			If A_LastError==0x80073cfa && !IsWin11 && IsAllUsers {
				r2:=PackageManager.RemovePackage(Package.FullName)
				If r2==3 {
					Debug("RemovePackage error code:" Format("{:#x}",A_LastError))
				}
				r:=(r2==1)
			} Else
				Debug("RemovePackage error code:" Format("{:#x}",A_LastError))
		}				
	} Else {
		If r:=PS_RemovePackage(Package.FullName, UserSID)
			Debug(r)
		r:=!r
	}
	Return r
}

