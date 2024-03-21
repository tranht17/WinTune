for ,param in A_Args {
	If InStr(param, "/DisableMSDefenderService=")=1 {
		sparam:=SubStr(param,-1)
		DisableMSDefenderService(sparam)
		Sleep 1000
		ExitSafeboot()
		ExitApp
	} Else If InStr(param, "/DisableMSDefenderScheduleTask=")=1 {
		sparam:=SubStr(param,-1)
		DisableMSDefenderScheduleTask(sparam)
		ExitApp
	} Else If InStr(param, "/User=")=1 {
		CurrentUser:=SubStr(param,7)
	} Else If InStr(param, "/LoadConfig=")=1 {
		sparam:=SubStr(param,13)
		Init()
		LoadOptimizeConfig(sparam)
		ExitApp
	} Else If InStr(param, "/SaveConfig")=1 {
		If param="/SaveConfig"
			sparam:=App.Name "_OptimizeConfig_" A_Now ".json"
		Else If InStr(param, "/SaveConfig=")=1
			sparam:=SubStr(param,13)
		Else
			Continue
		Init()
		SaveOptimizeConfigAll(sparam)
		ExitApp
	}
}