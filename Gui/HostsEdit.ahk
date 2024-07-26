BtnHostsEdit_Click(g, NavIndex) {
	CurrentTabCtrls:=Array()
	Hosts:=LoadHostsFile()
	CurrentTabCtrls:=[	"HostsEdit" ,
						"HostsEdit_BtnImportFromFile",
						"HostsEdit_EditLink", 
						"HostsEdit_BtnImportFromLink",	
						"HostsEdit_BtnSaveAs", 
						"HostsEdit_BtnSave",
						"HostsEdit_TxtSelectLink",
						"HostsEdit_TreeViewSelectLink",
						"HostsEdit_BtnResetDefault",
						"HostsEdit_BtnReload"]
	try {
		g["HostsEdit"].Value:=Hosts
		g["HostsEdit_BtnSave"].Enabled:=False
		Loop CurrentTabCtrls.Length {
			g[CurrentTabCtrls[A_Index]].Visible:=True
		}
	} catch {
		g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
		HostsEdit:=g.AddEdit("h" PanelH-12 " w" PanelW-320-24 " -wrap x" sXCBT+6 " y" sYCBT+6 " vHostsEdit",Hosts)
		HostsEdit.OnEvent("Change",HostsEdit_Change)
		HostsEdit_Change(*) {
			g["HostsEdit_BtnSave"].Enabled:=True
		}
		
		HostListData:=[
			{Author: "crazy-max", Source: "github.com/crazy-max/WindowsSpyBlocker", Items:[
					{Name: "Windows spying and tracking IPv4", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"},
					{Name: "Windows spying and tracking IPv6", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy_v6.txt"},
					{Name: "Windows update IPv4", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update.txt"},
					{Name: "Windows update IPv6", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update_v6.txt"},
					{Name: "Windows extra IPv4", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra.txt"},
					{Name: "Windows extra IPv6", Link: "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra_v6.txt"}
				]
			},
			{Author: "StevenBlack", Source: "github.com/StevenBlack/hosts", Items:[
					{Name: "All block lists", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"},
					{Name: "Adware + Malware", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"},
					{Name: "Adware + Malware + Fakenews", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"},
					{Name: "Fakenews Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"},
					{Name: "Adware + Malware + Gambling", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling/hosts"},
					{Name: "Gambling Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"},
					{Name: "Adware + Malware + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"},
					{Name: "Porn Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts"},
					{Name: "Adware + Malware + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social/hosts"},
					{Name: "Social Only", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social-only/hosts"},
					{Name: "Adware + Malware + Fakenews + Gambling", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts"},
					{Name: "Fakenews + Gambling", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-only/hosts"},
					{Name: "Adware + Malware + Fakenews + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn/hosts"},
					{Name: "Fakenews + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-only/hosts"},
					{Name: "Adware + Malware + Fakenews + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-social/hosts"},
					{Name: "Fakenews + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-social-only/hosts"},
					{Name: "Adware + Malware + Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts"},
					{Name: "Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-only/hosts"},
					{Name: "Adware + Malware + Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social/hosts"},
					{Name: "Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-social-only/hosts"},
					{Name: "Adware + Malware + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social/hosts"},
					{Name: "Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-social-only/hosts"},
					{Name: "Adware + Malware + Fakenews + Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"},
					{Name: "Fakenews + Gambling + Porn", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-only/hosts"},
					{Name: "Adware + Malware + Fakenews + Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts"},
					{Name: "Fakenews + Gambling + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social-only/hosts"},
					{Name: "Adware + Malware + Fakenews + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-social/hosts"},
					{Name: "Fakenews + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-porn-social-only/hosts"},
					{Name: "Adware + Malware + Gambling + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social/hosts"},
					{Name: "Gambling + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social-only/hosts"},
					{Name: "Fakenews + Gambling + Porn + Social", Link: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social-only/hosts"},
				]
			}
		]
		
		g.AddText("yp w320 Section vHostsEdit_TxtSelectLink")
		ImageListID := IL_Create(2)
		IL_Add(ImageListID, "shell32.dll", 4)
		IL_Add(ImageListID, "shell32.dll", 14)
		TV := g.AddTreeView("w320 h300 vHostsEdit_TreeViewSelectLink ImageList" ImageListID)
		TV.OnEvent("Click",TreeViewSelectLink_Click)
		TV.OnEvent("ItemExpand",TreeViewSelectLink_ItemExpand)
		ObjectF:={}
		Loop HostListData.Length {
			i:=A_Index
			P1:=TV.Add(HostListData[i].Source,,"Icon1")
			Items:=HostListData[i].Items
			Loop Items.Length {
				P1C1:=TV.Add(Items[A_Index].Name, P1,"Icon2")
				ObjectF.%P1C1%:={SourceID:i,ItemID:A_Index}
			}
		}
		TreeViewSelectLink_Click(GuiCtrlObj, Info) {
			sID:=TV.GetSelection()
			If ObjectF.HasOwnProp(sID) {
				SourceID:=ObjectF.%sID%.SourceID
				ItemID:=ObjectF.%sID%.ItemID
				EditLink.Value:=HostListData[SourceID].Items[ItemID].Link
				ControlSend "^{End}", EditLink
				g["HostsEdit_BtnImportFromLink"].Enabled:=True
			}
		}
		TreeViewSelectLink_ItemExpand(GuiCtrlObj, Item, Expanded) {
			GuiCtrlObj.Visible:=False
			GuiCtrlObj.Visible:=True
		}
		
		BtnImportFromLink := g.AddButton("xs Disabled vHostsEdit_BtnImportFromLink", "«")
		BtnImportFromLink.OnEvent("Click",(*)=>BtnImportFromLink_Click(g))
		BtnImportFromLink_Click(g) {
			Try
				spy:=WinHttpResponseText(g["HostsEdit_EditLink"].Value)
			Catch
				Return
			g["HostsEdit"].Value.="`n" spy "`n"
			g["HostsEdit_EditLink"].Value:=""
			g["HostsEdit_BtnImportFromLink"].Enabled:=False
			g["HostsEdit_BtnSave"].Enabled:=True
			ControlSend "^{End}", g["HostsEdit"]
		}
		
		EditLink:=g.AddEdit("yp w290 -wrap vHostsEdit_EditLink")
		EditLink.OnEvent("Change",EditLink_Change)
		EditLink_Change(*) {
			g["HostsEdit_BtnImportFromLink"].Enabled:=!!EditLink.Value
		}
		
		BtnImportFromFile := g.AddButton("xs y+24 w140 h40 vHostsEdit_BtnImportFromFile")
		BtnImportFromFile.OnEvent("Click",BtnImportFromFile_Click)
		BtnImportFromFile_Click(*) {
			files := FileSelect("M3", A_WorkingDir, "Select block list to hosts file")
			Loop files.Length {
				Hosts:=FileRead(files[A_Index])
				g["HostsEdit"].Value.="`n`n### " files[A_Index] "`n" Hosts
				ControlSend "^{End}", g["HostsEdit"]
			}
		}
		
		BtnSaveAs := g.AddButton("yp w140 h40 vHostsEdit_BtnSaveAs")
		BtnSaveAs.OnEvent("Click",BtnSaveAs_Click)
		BtnSaveAs_Click(*) {
			sfile := FileSelect("S16", "hosts_" A_Now, "Save As")
			If sfile {
				try FileDelete sfile
				FileAppend g["HostsEdit"].Value, sfile
			}
		}
		
		BtnReload := g.AddButton("xs w140 h40 vHostsEdit_BtnReload")
		BtnReload.OnEvent("Click",BtnReload_Click)
		BtnReload_Click(*) {
			g["HostsEdit"].Value:=LoadHostsFile()
			ControlSend "^{End}", g["HostsEdit"]
			g["HostsEdit_BtnSave"].Enabled:=False
		}
		
		BtnResetDefault := g.AddButton("yp w140 h40 vHostsEdit_BtnResetDefault")
		BtnResetDefault.OnEvent("Click",BtnResetDefault_Click)
		BtnResetDefault_Click(*) {
			g["HostsEdit"].Value:='
(
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host

# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
)'
			ControlSend "^{End}", g["HostsEdit"]
			g["HostsEdit_BtnSave"].Enabled:=True
		}
		
		BtnSave := g.AddButton("Disabled xs w140 h60 vHostsEdit_BtnSave")
		BtnSave.OnEvent("Click",BtnSave_Click)
		
		BtnSave_Click(*) {
			SaveHostsFile(HostsEdit.Value)
			BtnSave.Enabled:=False
		}
		
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
	}

	If !TabLangLoaded.HasOwnProp(NavIndex) || !TabLangLoaded.%NavIndex% {
		Loop CurrentTabCtrls.Length {
			tCtrlID:=CurrentTabCtrls[A_Index]
			If tCtrlID!="HostsEdit_BtnImportFromLink" && (g[tCtrlID].Type="Button" || g[tCtrlID].Type="Text")
				g[tCtrlID].Text:=GetLangName(tCtrlID)
		}
		TabLangLoaded.%NavIndex%:=1
	}
	
	g["BtnSys_SaveOptimizeConfigTab"].Visible:=True
	CurrentTabCtrls.Push "BtnSys_SaveOptimizeConfigTab"
	
	Return CurrentTabCtrls
}