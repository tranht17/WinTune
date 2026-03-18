;@Ahk2Exe-SetName            WinTune
;@Ahk2Exe-SetCopyright       tranht17
;@Ahk2Exe-SetVersion         2.8.0
;@Ahk2Exe-SetMainIcon        Icon.ico
#Requires AutoHotkey 2.0
#SingleInstance Off
#Warn

App:={Name: "WinTune", Ver: "2.8.0", MDebug: 1}

SetTitleMatchMode 3
if WinExist(App.Name) {
	WinActivate
	return
}

A_IconTip:= App.Name
tray := A_TrayMenu
tray.delete
tray.Add("Exit", (*) => ExitApp())

#Include <MDebug>
#Include <RunTerminal>
#Include <Powrprof>
#Include <SC>
#Include <Hex>
#Include <JSON>
#Include <PackageManager>

#Include Inc/Data.ahk
#Include Inc/LangData.ahk
#Include Inc/Base.ahk
#Include Inc/Optimizer.ahk
#Include Inc/CustomFn.ahk
#Include Inc/OptimizeConfig.ahk

#Include <Gdip_All>
#Include <ToolTipOptions>
#Include <PicSwitch>

#Include Gui/Base.ahk
#Include Gui/Theme.ahk
#Include Gui/Language.ahk
#Include Gui/User.ahk
#Include Gui/Optimizer.ahk
#Include Gui/HostsEdit.ahk
#Include Gui/StartupManager.ahk
#Include Gui/PackageManager.ahk
#Include Gui/CheckUpdate.ahk

CheckOS
CheckAdmin
OnError LogError
OnExit ExitFunc
ArgParse
Init
ArgProcess

OnMessage 0x0111, ON_EN_SETFOCUS
CreateGui
OnMessage 0x0200, WM_MOUSEMOVE
OnMessage 0x0201, WM_LBUTTONDOWN
OnMessage 0x47, WM_WINDOWPOSCHANGED
