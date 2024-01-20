BtnSys_SaveOptimizeConfigTab_Click(Ctr, *) {
	SelectedFile := FileSelect("S16", App.Name "_OptimizeTabConfig_" A_Now ".json", "Save a file")
	If SelectedFile {
		Config:={}
		g:=Ctr.Gui
		CurrentTabCtrls:=CurrentTabCtrlArray()
		Loop CurrentTabCtrls.Length {
			ItemID:=CurrentTabCtrls[A_Index]
			If g[ItemID].Type="PicSwitch" && Data.HasOwnProp(ItemID)
				Config.%ItemID%:=g[ItemID].Value
		}
		try
			FileDelete SelectedFile
		FileAppend JSON.stringify(Config), SelectedFile
	}
}
BtnSys_SaveOptimizeConfigAll_Click(*) {
	SelectedFile := FileSelect("S16", App.Name "_OptimizeConfig_" A_Now ".json", "Save a file")
	If SelectedFile {
		Config:={}
		Loop Layout.Length {
			If (Layout[A_Index].ID = "" || !Layout[A_Index].HasOwnProp("Items"))
				Continue
			ItemList:=Layout[A_Index].Items
			Loop ItemList.Length {
				ItemId:=ItemList[A_Index]
				s:=CheckStatusItem(ItemId, Data.%ItemId%)
				If s<=-1
					Continue
				Config.%ItemID%:=s
			}
		}	
		try
			FileDelete SelectedFile
		FileAppend JSON.stringify(Config), SelectedFile
	}
}
BtnSys_LoadOptimizeConfig_Click(Ctr, *) {
	SelectedFile := FileSelect(3, , "Open a file", "Optimize Config File (*.json)")
	If SelectedFile {
		g:=Ctr.Gui
		g2:=CreateWaitDlg(g)
		ConfigText:=FileRead(SelectedFile)
		Config:=JSON.parse(ConfigText,,False)
		For ItemId, ItemValue in Config.OwnProps() {
			If !Data.HasOwnProp(ItemID)
				Continue
			s:=CheckStatusItem(ItemId, Data.%ItemId%)
			If s<=-1 || ItemValue=s
				Continue
			ProgNow(ItemId, ItemValue, Data.%ItemId%, 1)
			try {
				If g[ItemID].Type="PicSwitch" && g[ItemID].Visible=True {
					g[ItemID].Value:=ItemValue
				}
			}
		}
		DestroyDlg(g,g2)
	}
}