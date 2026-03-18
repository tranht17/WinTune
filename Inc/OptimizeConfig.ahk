SaveOptimizeConfigAll(SelectedFile) {
	Config:={}
	for NavID in TabLayout.Order {
		if !TabLayout.List.%NavID%.HasOwnProp("Items")
			continue
		ItemList:=TabLayout.List.%NavID%.Items
		for ItemId in ItemList {
			s:=CheckStatusItem(ItemId, Data.%ItemId%)
			if s<=-1
				Continue
			Config.%ItemID%:=s
		}
		
		ObjStartMenu:={}
		StartMenuLayout(&ObjStartMenu)
		Config.StartMenuLayout:=ObjStartMenu	
		
		Config.HostsEdit:=LoadHostsFile()
		
	}
	try
		FileDelete SelectedFile
	FileAppend JSON.stringify(Config), SelectedFile
}
LoadOptimizeConfig(SelectedFile, g:="") {
	ConfigText:=FileRead(SelectedFile)
	Config:=JSON.parse(ConfigText,,False)
	IsRunDisableMSDefender:=0
	for ItemId, ItemValue in Config.OwnProps() {
		if ItemId="PackageManager" {
			Loop ItemValue.Length {
				if ItemValue[A_Index].Act="RemovePackage" || ItemValue[A_Index].Act="Uninstall" {
					if ItemValue[A_Index].HasOwnProp("FamilyNames") {
						FamilyNames:=ItemValue[A_Index].FamilyNames
						AllUsers:=ItemValue[A_Index].HasOwnProp("AllUsers")?ItemValue[A_Index].AllUsers:0
						Deprovision:=ItemValue[A_Index].HasOwnProp("Deprovision")?ItemValue[A_Index].Deprovision:0
						Loop FamilyNames.Length {
							Packages:=PackageManager.FindPackagesByPackageFamilyName(FamilyNames[A_Index])
							Loop Packages.Length {
								UninstallPackage(Packages[A_Index], AllUsers, Deprovision)
							}
						}
					}
				} else if ItemValue[A_Index].Act="Disable"{
					if ItemValue[A_Index].HasOwnProp("FamilyNames") {
						FamilyNames:=ItemValue[A_Index].FamilyNames
						Deprovision:=ItemValue[A_Index].HasOwnProp("Deprovision")?ItemValue[A_Index].Deprovision:0
						Loop FamilyNames.Length {
							Packages:=PackageManager.FindPackagesByPackageFamilyName(FamilyNames[A_Index])
							Loop Packages.Length {
								PackageManager.SetPackageStatus(Packages[A_Index].FullName, 8)
								; PackageManager.ClearPackageStatus(Packages[A_Index].FullName, 8)
							}
							if Deprovision
								PackageManager.DeprovisionPackageForAllUsers(FamilyNames[A_Index])
						}
					}
				} else if ItemValue[A_Index].Act="Deprovision"{
					if ItemValue[A_Index].HasOwnProp("FamilyNames") {
						FamilyNames:=ItemValue[A_Index].FamilyNames
						Loop FamilyNames.Length {
							PackageManager.DeprovisionPackageForAllUsers(FamilyNames[A_Index])
						}
					}
				}
			}
		} else if ItemId="StartMenuLayout" {
			StartMenuLayout(&ItemValue, "set")
		} else if ItemId="HostsEdit" {
			SaveHostsFile(ItemValue)
		} else {
			if !Data.HasOwnProp(ItemID)
				Continue
			s:=CheckStatusItem(ItemId, Data.%ItemId%)
			if s<=-1 || ItemValue=s
				Continue
			if ItemId="DisableMSDefender" {
				IsRunDisableMSDefender:=1
				Continue
			}
			ProgNow(ItemId, ItemValue, Data.%ItemId%, 1)
		}
	}
	
	if IsRunDisableMSDefender {
		ItemId:="DisableMSDefender"
		ProgNow(ItemId, Config.%ItemId%, Data.%ItemId%, 1)
	} 
	
	if g
		NavItem_Click(g)
}