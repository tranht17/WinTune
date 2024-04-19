;@Ahk2Exe-SetName            WinTune
;@Ahk2Exe-SetCopyright       tranht17
;@Ahk2Exe-SetVersion         2.2.1.0
;@Ahk2Exe-SetMainIcon        Img/Icon.ico
#Requires AutoHotkey 2.0
#SingleInstance Ignore
#Warn

App:={Name: "WinTune", Ver: "2.2.1"}

A_IconTip:= App.Name
tray := A_TrayMenu
tray.delete
tray.Add("Exit", (*) => ExitApp())

#include <RunTerminal>
#include <Powrprof>
#include <SC>
#include <Hex>
#Include <JSON>
#Include <PackageManager>

#Include Inc/Data.ahk
#Include Inc/LangData.ahk
#Include Inc/Base.ahk
#Include Inc/Optimizer.ahk
#Include Inc/CustomFn.ahk
#Include Inc/OptimizeConfig.ahk
#Include Inc/CommandLineParam.ahk

#include <Gdip_All>
#Include <ToolTipOptions>
#Include <PicSwitch>

#Include Gui/Base.ahk
#Include Gui/Theme.ahk
#Include Gui/Language.ahk
#Include Gui/User.ahk
#Include Gui/Optimizer.ahk
#Include Gui/HostEdit.ahk
#Include Gui/StartupManager.ahk
#Include Gui/PackageManager.ahk

OnExit ExitFunc
ExitFunc(ExitReason, ExitCode) {
	UnLoadHive()
}

OnError LogError
LogError(exception, mode) {
	Debug(, exception)
	If PopupHwnd:=WinExist(App.Name "_Popup") {
		WinClose
		g:=GuiFromHwnd(DllCall("GetParent", "uint", PopupHwnd))
		If g
			g.Opt("-Disabled")
	}
	return true
}

Init()
CreateGui()
OnMessage 0x0200, WM_MOUSEMOVE
OnMessage 0x0201, WM_LBUTTONDOWN