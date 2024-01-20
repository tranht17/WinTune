BtnHostEdit_Click(g,*) {
	CurrentTabCtrls:=Array()
	g["BtnSelectAll"].Visible:=False
	g["HRLine"].Visible:=False
	g["BtnSys_SaveOptimizeConfigTab"].Visible:=False
	Host:=FileRead(A_WinDir "\System32\drivers\etc\hosts")
	CurrentTabCtrls:=[	"HostEdit" ,
						"HostEdit_BtnImportFromFile",
						"HostEdit_EditLink", 
						"HostEdit_BtnImportFromLink",	
						"HostEdit_BtnSaveAs", 
						"HostEdit_BtnSave",
						"HostEdit_BtnInsertLink",
						"HostEdit_BtnResetDefault",
						"HostEdit_BtnReload"]
	try {
		g[CurrentTabCtrls[1]].Value:=Host
		Loop CurrentTabCtrls.Length {
			g[CurrentTabCtrls[A_Index]].Visible:=True
		}
	} catch {
		HostEdit:=g.AddEdit("h442 w450 -wrap 0x100 xm216 ym36 Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[1],Host)
		
		SetWindowTheme(HostEdit)
		HostEdit.OnEvent("Change",HostEdit_Change)
		HostEdit_Change(*) {
			g["HostEdit_BtnSave"].Enabled:=True
		}
		
		EditLink:=g.AddEdit("yp w250 -wrap Section Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[3])
		SetWindowTheme(EditLink)
		EditLink.OnEvent("Change",EditLink_Change)
		EditLink_Change(*) {
			g["HostEdit_BtnImportFromLink"].Enabled:=!!EditLink.Value
		}

		BtnInsertLink := g.AddButton("yp h24 0x200 Center Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[7], "«")
		SetWindowTheme(BtnInsertLink)
		BtnInsertLink.OnEvent("Click",BtnInsertLink_Click)
		
		BtnInsertLink_Click(*) {
			FileMenu := Menu()
			FileMenu.Add("Block Windows spying and tracking IPv4 (crazy-max)", (*)=>MenuHandler("https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"))
			FileMenu.Add("Block Windows spying and tracking IPv6 (crazy-max)", (*)=>MenuHandler("https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy_v6.txt"))
			FileMenu.Add("Block Windows update IPv4 (crazy-max)", (*)=>MenuHandler("https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update.txt"))
			FileMenu.Add("Block Windows update IPv6 (crazy-max)", (*)=>MenuHandler("https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update_v6.txt"))
			FileMenu.Add("Block Windows extra IPv4 (crazy-max)", (*)=>MenuHandler("https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra.txt"))
			FileMenu.Add("Block Windows extra IPv6 (crazy-max)", (*)=>MenuHandler("https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra_v6.txt"))
			FileMenu.Show()
			MenuHandler(Item) {
				EditLink.Value:=Item
				g["HostEdit_BtnImportFromLink"].Enabled:=True
			}
		}
		
		BtnImportFromLink := g.AddButton("xs w120 Disabled Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[4], GetLangName(CurrentTabCtrls[4]))
		SetWindowTheme(BtnImportFromLink)
		BtnImportFromLink.OnEvent("Click",(*)=>BtnImportFromLink_Click(g))
		BtnImportFromLink_Click(g) {
			Try
				spy:=WinHttp(g["HostEdit_EditLink"].Value)
			Catch
				Return
			g["HostEdit"].Value.="`n`n" spy
			g["HostEdit_EditLink"].Value:=""
			g["HostEdit_BtnImportFromLink"].Enabled:=False
			g["HostEdit_BtnSave"].Enabled:=True
			ControlSend "^{End}", g["HostEdit"]
		}
		
		BtnImportFromFile := g.AddButton("w120 Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[2], GetLangName(CurrentTabCtrls[2]))
		SetWindowTheme(BtnImportFromFile)
		BtnImportFromFile.OnEvent("Click",BtnImportFromFile_Click)
		BtnImportFromFile_Click(*) {
			files := FileSelect("M3", A_WorkingDir, "Select block list to host file")
			Loop files.Length {
				Host:=FileRead(files[A_Index])
				g["HostEdit"].Value.="`n`n### " files[A_Index] "`n" Host
				ControlSend "^{End}", g["HostEdit"]
			}
		}
		
		BtnReload := g.AddButton("w120 Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[9], GetLangName(CurrentTabCtrls[9]))
		SetWindowTheme(BtnReload)
		BtnReload.OnEvent("Click",BtnReload_Click)
		BtnReload_Click(*) {
			Host:=FileRead(A_WinDir "\System32\drivers\etc\hosts")
			g["HostEdit"].Value:=Host
			ControlSend "^{End}", g["HostEdit"]
			g["HostEdit_BtnSave"].Enabled:=False
		}
		
		BtnResetDefault := g.AddButton("w120 Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[8], GetLangName(CurrentTabCtrls[8]))
		SetWindowTheme(BtnResetDefault)
		BtnResetDefault.OnEvent("Click",BtnResetDefault_Click)
		BtnResetDefault_Click(*) {
			g["HostEdit"].Value:='
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
			ControlSend "^{End}", g["HostEdit"]
			g["HostEdit_BtnSave"].Enabled:=True
		}
		
		BtnSaveAs := g.AddButton("w120 Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[5], GetLangName(CurrentTabCtrls[5]))
		SetWindowTheme(BtnSaveAs)
		BtnSaveAs.OnEvent("Click",BtnSaveAs_Click)
		BtnSaveAs_Click(*) {
			sfile := FileSelect("S16", "host_" A_Now, "Save As")
			If sfile {
				try FileDelete sfile
				FileAppend g["HostEdit"].Value, sfile
			}
		}
		
		BtnSave := g.AddButton("Disabled w120 h45 Background" Themes.%ThemeSelected%.BackColorPanelRGB " v" CurrentTabCtrls[6], GetLangName(CurrentTabCtrls[6]))
		SetWindowTheme(BtnSave)
		BtnSave.OnEvent("Click",BtnSave_Click)
		BtnSave_Click(*) {
			FileAppend HostEdit.Value, A_Temp "\host_tmp"
			FileMove A_Temp "\host_tmp", A_WinDir "\System32\drivers\etc\hosts" , 1
			BtnSave.Enabled:=False
			ControlSend "^{End}", HostEdit
		}
	}
	ControlSend "^{End}", g[CurrentTabCtrls[1]]
	Return CurrentTabCtrls
}