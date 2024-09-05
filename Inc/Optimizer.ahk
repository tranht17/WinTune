CheckRequires(DataItem) {
	; RequiresWinInstallationType: "Client,Server"
	If DataItem.HasOwnProp("RequiresWinInstallationType") && DataItem.RequiresWinInstallationType {
		IsPassed:=0
		Loop Parse, DataItem.RequiresWinInstallationType, "," {
			If A_LoopField=App.SystemInfo.InstallationType {
				IsPassed:=1
				Break
			}	
		}
		If !IsPassed
			Return 0
	}
	
	; RequiresWinEditionID: "Professional"
	If DataItem.HasOwnProp("RequiresWinEditionID") && DataItem.RequiresWinEditionID {
		IsPassed:=0
		Loop Parse, DataItem.RequiresWinEditionID, "," {
			If A_LoopField=App.SystemInfo.EditionID {
				IsPassed:=1
				Break
			}	
		}
		If !IsPassed
			Return 0
	}
	
	; RequiresWinVer: ">=10.0.10240,<=10.0.19045"
	; RequiresWinVer: ">=10.0.22000"
	If DataItem.HasOwnProp("RequiresWinVer") && DataItem.RequiresWinVer {
		IsPassed:=1
		Loop Parse, DataItem.RequiresWinVer, "," {
			If !VerCompare(A_OSVersion, A_LoopField) {
				IsPassed:=0
				Break
			}
		}
		If !IsPassed
			Return 0
	}
	Return 1
}
CheckStatusItem(ItemFunc, DataItem) {
	If !CheckRequires(DataItem)
		Return -1
	s:=t:=-1
	Loop DataItem.Act.Length {
		If DataItem.Act[A_Index].HasOwnProp("Check") && !DataItem.Act[A_Index].Check
			Continue
		If !CheckRequires(DataItem.Act[A_Index])
			s:=-1
		Switch DataItem.Act[A_Index].Type
		{
		Case "Custom": s:=Check%ItemFunc%()
		Case "Service": s:=(Service_State(DataItem.Act[A_Index].Name)=DataItem.Act[A_Index].State1)
		Case "ScheduleService": s:=CheckScheduleService(DataItem.Act[A_Index])
		Case "Power": s:=!Get%DataItem.Act[A_Index].Name%()
		; Case "SystemPinned": s:=!FindPinnedItemFavorites(Act[A_Index].SearchName)
		Case "RegChange": s:=RegRead(HKCU2HCU(DataItem.Act[A_Index].RegKey), DataItem.Act[A_Index].RegValueName,DataItem.Act[A_Index].RegValue0)=DataItem.Act[A_Index].RegValue1
		Case "RegDel":
			try {
				s:=RegRead(HKCU2HCU(DataItem.Act[A_Index].RegKey), DataItem.Act[A_Index].RegValueName)!=DataItem.Act[A_Index].RegValue0
			} Catch as err {
				s:=1
			}
		Case "RegAdd":
			Key:=HKCU2HCU(DataItem.Act[A_Index].RegKey)
			If DataItem.Act[A_Index].HasOwnProp("RegValue1") {
				try {
					RegValueName:=DataItem.Act[A_Index].HasOwnProp("RegValueName")?DataItem.Act[A_Index].RegValueName:unset
					RegValueDefault:=DataItem.Act[A_Index].HasOwnProp("RegValueDefault")?DataItem.Act[A_Index].RegValueDefault:unset
					s:=RegRead(Key, RegValueName?, RegValueDefault?)=DataItem.Act[A_Index].RegValue1
				} Catch {
					s:=0
				}
			} Else If DataItem.Act[A_Index].HasOwnProp("RegValueName") {
				try {
					RegRead(Key, DataItem.Act[A_Index].RegValueName)
					s:=1
				} Catch {
					s:=0
				}
			} Else {
				s:=RegKeyExist(Key)
			}
		}
		If s=0 || s=-2
			Break
		Else If s=-1 && t=1 {
			s:=t
			t:=-1
		} Else t:=s
	}
	;  1: Value 1
	;  0: Value 0
	; -1: Skip this Act Check
	; -2: Stop Act Loop	Check
	Return s
}

ProgNow(ItemId, ItemValue, ItemData, silent:=0, Ctr:="") {
	Try {
		IsRefreshExplorer:=0
		IsRestartExplorer:=0
		Loop ItemData.Act.Length {
			If ItemData.Act[A_Index].HasOwnProp("Check") && ItemData.Act[A_Index].Check
				Continue
			If ItemData.Act[A_Index].Type="Custom" {
				r:=%ItemId%(ItemValue, ItemData.Act[A_Index],silent)
				If Ctr && (r=0 || r=1)
					Ctr.Value:=r
			} Else If ItemData.Act[A_Index].Type="RunTerminal"
				RunTerminal(ItemData.Act[A_Index].Value%ItemValue%)
			Else
				Prog%ItemData.Act[A_Index].Type%(ItemValue,ItemData.Act[A_Index],silent)
			If !IsRefreshExplorer && ItemData.Act[A_Index].HasOwnProp("RefreshExplorer")
					&& ItemData.Act[A_Index].RefreshExplorer
				IsRefreshExplorer:=1
			If !IsRestartExplorer && ItemData.Act[A_Index].HasOwnProp("RestartExplorer")
					&& (ItemData.Act[A_Index].RestartExplorer==1 || (ItemData.Act[A_Index].RestartExplorer==2 && ItemValue==1))
				IsRestartExplorer:=1
		}
		If IsRefreshExplorer
			RefreshExplorer()
	} Catch as err {
		Debug(err, "Func: " ItemId)
	}
}

ProgReg(s, ItemData, silent) {
	If (s && ItemData.Type="RegDel") || (!s && ItemData.Type="RegAdd") {
		If ItemData.HasOwnProp("LvlKeyDel") && ItemData.LvlKeyDel {
			sKey:=StrSplit(HKCU2HCU(ItemData.RegKey), "\")
			cKey:=""
			Loop (sKey.Length-ItemData.LvlKeyDel+1)
				cKey.=(A_Index=1?"":"\") sKey[A_Index]
			try RegDeleteKey cKey
		}
		Else {
			try RegDelete HKCU2HCU(ItemData.RegKey), ItemData.RegValueName
		}
	}
	Else If !ItemData.HasOwnProp("RegValueName") && ItemData.HasOwnProp("RegValue" s)
		RegWrite ItemData.RegValue%s%, ItemData.RegType, HKCU2HCU(ItemData.RegKey)
	Else If !ItemData.HasOwnProp("RegValueName")
		RegCreateKey HKCU2HCU(ItemData.RegKey)
	Else
		RegWrite ItemData.RegValue%s%, ItemData.RegType, HKCU2HCU(ItemData.RegKey), ItemData.RegValueName
}
ProgRegAdd(s, ItemData, silent) {
	ProgReg(s, ItemData, silent)
}
ProgRegChange(s, ItemData, silent) {
	ProgReg(s, ItemData, silent)
}
ProgRegDel(s, ItemData, silent) {
	ProgReg(s, ItemData, silent)
}

ProgService(s, ItemData, silent) {
	If ItemData.HasOwnProp("StartType" s)
		Service_Change_StartType(ItemData.Name, ItemData.StartType%s%)
	If ItemData.HasOwnProp("State" s) {
		If ItemData.State%s%=1
			Service_Stop(ItemData.Name)
		Else ItemData.State%s%=4
			Service_Start(ItemData.Name)
	}
}

ScheduleServiceConnect() {
	static service:= ComObject("Schedule.Service")
	service.Connect()
	Return service
}
CheckScheduleService(ItemData) {
	; SafeBootMode:=SysGet(67)
	If SysGet(67) {
		Return -1
	}
	Try {
		service:=ScheduleServiceConnect()
		r:=!service.GetFolder(ItemData.Location).GetTask(ItemData.TaskName).Enabled
		Return r
	} Catch {
		Return -1
	}
}
ProgScheduleService(s, ItemData, silent) {
	Try {
		service:=ScheduleServiceConnect()
		service.GetFolder(ItemData.Location).GetTask(ItemData.TaskName).Enabled:=!s
	} Catch {
		Return -1
	}
}

ProgPower(s, ItemData, silent) {
	Set%ItemData.Name%(ItemData.Value%s%)
}
StartMenuLayout(&item, Type:="get", silent:=1) {
	s:=0
	If VerCompare(A_OSVersion,">=10.0.22000") {
		LocalStatePath:=EnvGet2("Local AppData") "\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState"
		StartBinPath:=""
		If DirExist(LocalStatePath) {
			If FileExist(LocalStatePath "\start.bin") {
				StartBinPath:=LocalStatePath "\start.bin"
			} Else If FileExist(LocalStatePath "\start2.bin") {
				StartBinPath:=LocalStatePath "\start2.bin"
			}
		}
		
		If Type="get" {
			item.VisiblePlaces:=RegRead(App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Start", "VisiblePlaces", "")
			If StartBinPath {
				f := FileRead(StartBinPath, "RAW")
				item.StartBin:=Bin2Hex(f, f.Size)
				s:=1
			}
		} Else If Type="set" {
			If item.HasOwnProp("VisiblePlaces") {
				RegWrite item.VisiblePlaces, "REG_BINARY", App.HKCU "\Software\Microsoft\Windows\CurrentVersion\Start", "VisiblePlaces"
				s:=1
			}
			If StartBinPath && item.HasOwnProp("StartBin") {
				bin:=Hex2Bin(item.StartBin)
				FileDelete StartBinPath
				FileAppend bin, StartBinPath,"cp0"
				s:=1
			}
		}
	} Else If VerCompare(A_OSVersion,">=10.0.16299") {
		Loop Reg, App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount", "K" {
			If InStr(A_LoopRegName, "$start.suggestions$windows.data.curatedtilecollection.tilecollection") {
				If Type="get" {
					sData:=RegRead(App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data", "")
					If sData
						item.Suggestions:=sData
					s:=1
				} Else If Type="set" && item.HasOwnProp("Suggestions") {
					RegWrite item.Suggestions, "REG_BINARY", App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data"
					s:=1
				}
			} Else If InStr(A_LoopRegName, "$start.tilegrid$windows.data.curatedtilecollection.tilecollection") {
				If Type="get" {
					sData:=RegRead(App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data", "")
					If sData
						item.TileGrid:=sData
					s:=1
				} Else If Type="set" && item.HasOwnProp("TileGrid") {
					RegWrite item.TileGrid, "REG_BINARY", App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data"
					s:=1
				}
			} Else If InStr(A_LoopRegName, "$windows.data.unifiedtile.startglobalproperties") {
				If Type="get" {
					sData:=RegRead(App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data", "")
					If sData
						item.StartGlobalProperties:=sData
					s:=1
				} Else If Type="set" && item.HasOwnProp("StartGlobalProperties") {
					RegWrite item.StartGlobalProperties, "REG_BINARY", App.HKCU "\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" A_LoopRegName "\Current", "Data"
					s:=1
				}
			}
		}
	}
	
	If Type="set" && s {
		If VerCompare(A_OSVersion, ">=10.0.18362") {
			PID:=ProcessClose("StartMenuExperienceHost.exe")
			If !ProcessWaitClose(PID , 5000) && !silent
				TrayTip GetLangText("Text_ClearStartMenu_Done"), App.Name
		} Else
			ProcessClose "explorer.exe"
	}
		
	Return s
}