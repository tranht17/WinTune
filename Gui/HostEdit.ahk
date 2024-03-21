BtnHostEdit_Click(g,*) {
	CurrentTabCtrls:=Array()
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
		g["HostEdit"].Value:=Host
		Loop CurrentTabCtrls.Length {
			g[CurrentTabCtrls[A_Index]].Visible:=True
		}
	} catch {
		g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW, &PanelH)
		HostEdit:=g.AddEdit("h" PanelH-12 " w450 -wrap 0x100 x" sXCBT+6 " y" sYCBT+6 " vHostEdit",Host)
		HostEdit.OnEvent("Change",HostEdit_Change)
		HostEdit_Change(*) {
			g["HostEdit_BtnSave"].Enabled:=True
		}
		
		EditLink:=g.AddEdit("yp w250 -wrap Section vHostEdit_EditLink")
		EditLink.OnEvent("Change",EditLink_Change)
		EditLink_Change(*) {
			g["HostEdit_BtnImportFromLink"].Enabled:=!!EditLink.Value
		}

		BtnInsertLink := g.AddButton("yp h24 0x200 Center vHostEdit_BtnInsertLink", "«")
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
		
		BtnImportFromLink := g.AddButton("xs w120 Disabled vHostEdit_BtnImportFromLink", GetLangName("HostEdit_BtnImportFromLink"))
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
		
		BtnImportFromFile := g.AddButton("w120 vHostEdit_BtnImportFromFile", GetLangName("HostEdit_BtnImportFromFile"))
		BtnImportFromFile.OnEvent("Click",BtnImportFromFile_Click)
		BtnImportFromFile_Click(*) {
			files := FileSelect("M3", A_WorkingDir, "Select block list to host file")
			Loop files.Length {
				Host:=FileRead(files[A_Index])
				g["HostEdit"].Value.="`n`n### " files[A_Index] "`n" Host
				ControlSend "^{End}", g["HostEdit"]
			}
		}
		
		BtnReload := g.AddButton("w120 vHostEdit_BtnReload", GetLangName("HostEdit_BtnReload"))
		BtnReload.OnEvent("Click",BtnReload_Click)
		BtnReload_Click(*) {
			Host:=FileRead(A_WinDir "\System32\drivers\etc\hosts")
			g["HostEdit"].Value:=Host
			ControlSend "^{End}", g["HostEdit"]
			g["HostEdit_BtnSave"].Enabled:=False
		}
		
		BtnResetDefault := g.AddButton("w120 vHostEdit_BtnResetDefault", GetLangName("HostEdit_BtnResetDefault"))
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
		
		BtnSaveAs := g.AddButton("w120 vHostEdit_BtnSaveAs", GetLangName("HostEdit_BtnSaveAs"))
		BtnSaveAs.OnEvent("Click",BtnSaveAs_Click)
		BtnSaveAs_Click(*) {
			sfile := FileSelect("S16", "host_" A_Now, "Save As")
			If sfile {
				try FileDelete sfile
				FileAppend g["HostEdit"].Value, sfile
			}
		}
		
		BtnSave := g.AddButton("Disabled w120 h45 vHostEdit_BtnSave", GetLangName("HostEdit_BtnSave"))
		BtnSave.OnEvent("Click",BtnSave_Click)
		BtnSave_Click(*) {
			FileAppend HostEdit.Value, A_Temp "\host_tmp"
			FileMove A_Temp "\host_tmp", A_WinDir "\System32\drivers\etc\hosts" , 1
			BtnSave.Enabled:=False
			ControlSend "^{End}", HostEdit
		}
		Loop CurrentTabCtrls.Length {
			SetCtrlTheme(g[CurrentTabCtrls[A_Index]])
		}
	}
	ControlSend "^{End}", g["HostEdit"]
	Return CurrentTabCtrls
}