SaveOptimizeConfigAll(SelectedFile) {
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
LoadOptimizeConfig(SelectedFile, g:="") {
	ConfigText:=FileRead(SelectedFile)
	Config:=JSON.parse(ConfigText,,False)
	IsRunDisableMSDefender:=0
	For ItemId, ItemValue in Config.OwnProps() {
		If !Data.HasOwnProp(ItemID)
			Continue
		s:=CheckStatusItem(ItemId, Data.%ItemId%)
		If s<=-1 || ItemValue=s
			Continue
		If ItemId="DisableMSDefender" {
			IsRunDisableMSDefender:=1
			Continue
		}
		ProgNow(ItemId, ItemValue, Data.%ItemId%, 1)
		try {
			If g && g[ItemID].Type="PicSwitch" && g[ItemID].Visible=True {
				g[ItemID].Value:=ItemValue
			}
		}
	}
	
	If IsRunDisableMSDefender {
		ItemId:="DisableMSDefender"
		ProgNow(ItemId, Config.%ItemId%, Data.%ItemId%, 1)
		try {
			If g && g[ItemID].Type="PicSwitch" && g[ItemID].Visible=True {
				g[ItemID].Value:=ItemValue
			}
		}
	}
}