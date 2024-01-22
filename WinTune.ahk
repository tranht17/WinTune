;@Ahk2Exe-SetName            WinTune
;@Ahk2Exe-SetCopyright       tranht17
;@Ahk2Exe-SetVersion         1.1.0.0
;@Ahk2Exe-SetMainIcon        Img/Icon.ico
#Requires AutoHotkey 2.0
#SingleInstance Ignore
; SetRegView 64
#Warn

App:={Name: "WinTune", Ver: "1.1.0"}

full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
    try {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

#include <RunTerminal>
#include <Powrprof>
#include <SC>
#include <Hex>
#include <Gdip_All>
#Include <JSON>
#Include <ToolTipOptions>
#Include <PicSwitch>

#Include inc/Data.ahk
#Include inc/Util.ahk
#Include inc/HostEdit.ahk
#Include inc/CustomFn.ahk
#Include inc/SaveOptimizeConfig.ahk

LangCode:="en"
try {
	LangDataText:=FileRead("Lang\" LangCode ".json","UTF-8")
} Catch {
	LangDataText:='{"AUOptions":{"Desc":"Set Notify before download Windows Updates","Name":"AUOptions"},"AutoEndTasks":{"Desc":"Close frozen processes to avoid system crash","Name":"Auto End Tasks"},"BtnClearStartMenu":{"Name":"Clear StartMenu"},"BtnDeselectAll":{"Name":"Deselect All"},"BtnHostEdit":{"Name":"Host Edit"},"BtnRestartExplorer":{"Name":"Restart Explorer"},"BtnSelectAll":{"Name":"Select All"},"BtnSys_Close":{"Desc":"Close"},"BtnSys_Language":{"Desc":"Language"},"BtnSys_LoadOptimizeConfig":{"Desc":"Load optimization configurations file"},"BtnSys_Minimize":{"Desc":"Minimize"},"BtnSys_SaveImage":{"Desc":"Self-Capture and Save to Image"},"BtnSys_SaveOptimizeConfigAll":{"Desc":"Save all optimization configurations to file"},"BtnSys_SaveOptimizeConfigTab":{"Desc":"Save this tab only optimization configuration to file"},"BtnSys_Setting":{"Desc":"Setting"},"BtnSys_Theme":{"Desc":"Theme"},"ClassicContextMenu":{"Name":"Classic Context Menu"},"DiagnosticDataOff":{"Name":"Diagnostic Data Off"},"DisableAdsOnLockScreen":{"Name":"Disable Ads On Lock Screen"},"DisableAeDebug":{"Desc":"Disable the debugger to speed up error processing","Name":"Disable AeDebug"},"DisableAnimationEffectMaxMin":{"Desc":"Close animation effect when maximizing or minimizing a window to speed up the window response","Name":"Disable Animation Effect Max Min"},"DisableAppendCompletion":{"Desc":"Disable inline Auto-Complete (Append completion or Auto-fill)","Name":"Disable Append Completion"},"DisableAutoDefragIde":{"Desc":"Disable auto defrag when ide to increase working life of SSD","Name":"Disable Auto Defrag Ide"},"DisableAutoInstallationApps":{"Name":"Disable Auto Installation Apps"},"DisableAutoplay":{"Desc":"Disable the “Autoplay” feature on drives to avoid virus infection","Name":"Disable Autoplay"},"DisableAutoSuggest":{"Desc":"Disable Auto-Suggest (Auto-complete drop-down)","Name":"Disable Auto-Suggest"},"DisableAutoWindowsUpdates":{"Desc":"Disable Automatic Updates","Name":"Disable Auto Windows Updates"},"DisableBackgroundApps":{"Name":"Disable Background Apps"},"DisableBingSearchStartMenu":{"Name":"Disable BingSearch Start Menu"},"DisableBootOptimize":{"Desc":"Disable defrag system drive on boot to increase working life of SSD","Name":"Disable Boot Optimize"},"DisableCortana":{"Name":"Disable Cortana"},"DisableCortanaWindowsSearch":{"Desc":"Stops Cortana from being used as part of your Windows Search Function","Name":"Disable Cortana Windows Search"},"DisableCrashAutoReboot":{"Desc":"Disable automatical reboot when system encounters blue screen of death","Name":"Disable Crash Auto Reboot"},"DisableDiagTrack":{"Name":"Disable DiagTrack"},"DisabledVBSCodeIntegrity":{"Desc":"Disable virtualization-based protection of code integrity","Name":"Disabled VBS Code Integrity"},"DisableErrorReporting":{"Desc":"Disable screen error reporting to improve system performance","Name":"Disable Error Reporting"},"DisableFrequentFolders":{"Name":"Disable FrequentFolders"},"DisableGameBar":{"Desc":"The Game DVR feature allows you to record your gameplay in the background.\nIt is located on the Game Bar – which offers buttons to record gameplay & take screenshots using the Game DVR feature.\nBut it can slow your gaming performance by recording video in the background.","Name":"Disable Game Bar & Game DVR"},"DisableGoogleUpdateTask":{"Name":"Disable GoogleUpdateTask"},"DisableHibernate":{"Name":"Disable Hibernate"},"DisableHybridSleep":{"Name":"Disable Hybrid Sleep"},"DisableLockScreen":{"Name":"Disable Lock Screen"},"DisableLowDiskSpaceChecks":{"Desc":"Optimize disk I/O subsystem to improve system performance","Name":"Disable Low Disk Space Checks"},"Disablememorypagination":{"Desc":"Disable memory pagination and reduce disk I/O to improve application performance.\n(Option may be ignored if physical memory is <1 GB)","Name":"Disable memory pagination"},"DisableMenuShowDelay":{"Desc":"Optimized response speed of system display","Name":"Disable Menu Show Delay"},"DisableMicrosoftEdgeUpdateTask":{"Name":"Disable MicrosoftEdgeUpdateTask"},"DisableMSDefender":{"Desc":"To disable Microsoft Defender Antivirus you need to do 2 steps:\n\n- Check Disable Microsoft Defender.\n- Enter Safe Mode and check it again.\n\nTo turn Microsoft Defender back on, you just need to do the opposite.\n\n(If you enter Safe Mode using this program, you need to use this program to exit Safe Mode\n  or you can use the command line `'bcdedit /deletevalue \"{current}\" safeboot`')","Name":"Disable Microsoft Defender"},"DisableOfferSuggestions":{"Name":"Disable Offer Suggestions"},"DisablePersonalizedAdsStoreApps":{"Name":"Disable PersonalizedAds StoreApps"},"DisablePrefetchParameters":{"Desc":"Disable prefetch parameters to increase SSD working life","Name":"Disable Prefetch Parameters"},"DisablePrintSpooler":{"Name":"Disable Print Spooler"},"DisableRecentFiles":{"Name":"Disable RecentFiles"},"DisableRemoteRegAccess":{"Desc":"Disable registry modification from a remote computer","Name":"Disable Remote Reg Access"},"DisableScheduledDefrag":{"Name":"Disable Scheduled Defrag"},"DisableSettingsAppSuggestions":{"Name":"Disable Settings App Suggestions"},"DisableShortcutText":{"Name":"Disable Shortcut Text"},"DisableSleep":{"Name":"Disable Sleep"},"DisableSyncProviderNotifications":{"Name":"Disable Sync Provider Notifications"},"DisableSystemRestore":{"Name":"Disable System Restore"},"DisableTailoredExperiences":{"Name":"Disable Tailored Experiences"},"DisableTipsAndSuggestions":{"Name":"Disable Tips And Suggestions"},"DisableTurnOffDisplay":{"Name":"Disable Turn Off Display"},"DisableVisualStudioTelemetry":{"Name":"Disable VisualStudio Telemetry"},"DisableWCE":{"Desc":"Disable Windows Customer Experience Improvement\n\n- Proxy: This task collects and uploads autochk SQM data if opted-in to the Microsoft Customer Experience Improvement Program.\n- Microsoft Compatibility Appraiser: Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program.","Name":"Disable WCE Improvement"},"DisableWebSearch":{"Name":"Disable Web Search"},"DisableWebSearchStartMenu":{"Desc":"Disables Web Search in Start Menu","Name":"Disable WebSearch Start Menu"},"DisableWindowsFeedback":{"Name":"Disable Windows Feedback"},"DisableWindowsSearch":{"Name":"Disable Windows Search"},"EnableDarkMode":{"Name":"Enable Dark Mode"},"HostEdit_BtnImportFromFile":{"Name":"Import From Files"},"HostEdit_BtnImportFromLink":{"Name":"Import From Link"},"HostEdit_BtnInsertLink":{"Desc":"Insert link for Import to host","Name":"Insert Link"},"HostEdit_BtnReload":{"Name":"Reload host file"},"HostEdit_BtnResetDefault":{"Name":"Reset Default"},"HostEdit_BtnSave":{"Name":"Save"},"HostEdit_BtnSaveAs":{"Name":"Save As"},"IncreaseIconCache":{"Desc":"Increase system icon cache and speed up desktop display","Name":"Increase Icon Cache"},"IoPageLockLimit":{"Desc":"Optimize the defauit settings of memory to improve system performance","Name":"Io Page Lock Limit"},"LinkResolveIgnoreLinkInfo":{"Desc":"Do not track Shell shortcuts during roaming","Name":"Link Resolve Ignore LinkInfo"},"MouseHoverTime":{"Desc":"Speed up display speed of Taskbar Window Previews","Name":"Mouse Hover Time"},"NoInternetOpenWith":{"Desc":"Turn off Internet File Association service","Name":"No Internet OpenWith"},"NoResolveSearch":{"Desc":"Do not use the search-based method when resolving shell shortcuts","Name":"No Resolve Search"},"NumLockonStartup":{"Name":"Num Lock on Startup"},"OpenFileExplorerThisPC":{"Name":"Open File Explorer ThisPC"},"OptimizeNetworkTransfer":{"Desc":"Optimize network settings to improve transfer performance","Name":"Optimize Network Transfer"},"Optimizeprocessorperformance":{"Desc":"Optimize processor performance to make applications, games, etc. run more smoothly.","Name":"Optimize processor performance"},"OptimizeRefreshPolicy":{"Desc":"Optimize disk I/O subsystem to improve system performance","Name":"Optimize Refresh Policy"},"Optional":{"Name":"Optional"},"Privacy":{"Name":"Privacy"},"ShowExtensions":{"Name":"Show Extensions"},"ShowHidden":{"Name":"Show Hidden"},"ShowHiddenSystem":{"Name":"Show Hidden System"},"ShowThisPC":{"Name":"Show ThisPC"},"ShutdownAcceleration":{"Desc":"Reduce application idleness at shutdown to improve the shutdown process","Name":"Shutdown Acceleration"},"SnippingPrintScreen":{"Name":"Snipping PrintScreen"},"System":{"Name":"System"},"UninstallOneDrive":{"Name":"Uninstall OneDrive"},"UnpinChat":{"Name":"Chat"},"UnpinCopilot":{"Name":"Copilot"},"UnpinCortana":{"Name":"Cortana"},"UnpinEdge":{"Name":"Edge"},"UnpinFileExplorer":{"Name":"File Explorer"},"UnpinMail":{"Name":"Mail"},"UnpinNewsandInterests":{"Name":"News and Interests"},"UnpinSearch":{"Name":"Search"},"UnpinStore":{"Name":"Store"},"UnpinTaskbar":{"Name":"Unpin Taskbar"},"UnpinTaskView":{"Name":"TaskView"},"UnpinWidgets":{"Name":"Widgets"}}'
}
Lang:=JSON.parse(LangDataText,,False)

ThemeSelected:="dark"

CreateGui()

CreateGui() {
	g:=Gui("-Caption",App.Name)
	g.SetFont("s11 c" Themes.%ThemeSelected%.TextColor,"Segoe UI Semibold")
	g.BackColor:=Themes.%ThemeSelected%.BackColor
	
	ToolTipOptions.Init()
	ToolTipOptions.SetMargins(5, 5, 5, 5)
	ToolTipOptions.SetColors("0x" Themes.%ThemeSelected%.BackColor, "0x" Themes.%ThemeSelected%.TextColor)
	
	NavSelectW:=200, NavSelectH:=36
	PanelX:=NavSelectW+24, PanelY:=36, PanelW:=760, PanelH:=456
	
	IsWin11:=VerCompare(A_OSVersion, ">=10.0.22000")
	IconFont:=IsWin11?"Segoe Fluent Icons":"Segoe MDL2 Assets"
	
	BtnSysX:=PanelX

	BtnSys_SaveOptimizeConfigTab:=g.AddText('vBtnSys_SaveOptimizeConfigTab x' BtnSysX ' ym w30 h20 0x200 Center Border',Chr(0xE74E))
	BtnSys_SaveOptimizeConfigTab.SetFont("s11",IconFont)
	BtnSys_SaveOptimizeConfigTab.Opt("-Border")
	BtnSys_SaveOptimizeConfigTab.OnEvent("Click",BtnSys_SaveOptimizeConfigTab_Click)

	BtnSys_SaveOptimizeConfigAll:=g.AddText('vBtnSys_SaveOptimizeConfigAll x' (BtnSysX+=35) ' ym w30 h20 0x200 Center Border',Chr(0xEA35))
	BtnSys_SaveOptimizeConfigAll.SetFont("s11",IconFont)
	BtnSys_SaveOptimizeConfigAll.Opt("-Border")
	BtnSys_SaveOptimizeConfigAll.OnEvent("Click",BtnSys_SaveOptimizeConfigAll_Click)

	BtnSys_LoadOptimizeConfig:=g.AddText('vBtnSys_LoadOptimizeConfig x' (BtnSysX+=35) ' ym w30 h20 0x200 Center Border',Chr(0xE838))
	BtnSys_LoadOptimizeConfig.SetFont("s11",IconFont)
	BtnSys_LoadOptimizeConfig.Opt("-Border")
	BtnSys_LoadOptimizeConfig.OnEvent("Click",BtnSys_LoadOptimizeConfig_Click)
	
	g.AddText("x" (BtnSysX+=35) " ym+3 w1 h15 Background" Themes.%ThemeSelected%.HrColor)
	
	BtnSys_SaveImage:=g.AddText('vBtnSys_SaveImage x' (BtnSysX+=10) ' ym w30 h20 0x200 Center Border',Chr(0xE114))
	BtnSys_SaveImage.SetFont("s11",IconFont)
	BtnSys_SaveImage.Opt("-Border")
	BtnSys_SaveImage.OnEvent("Click",BtnSys_SaveImage_Click)

	BtnSys_Minimize:=g.AddText('vBtnSys_Minimize x' PanelX+PanelW-65 ' ym w30 h20 0x200 Center Border',Chr(0xE108))
	BtnSys_Minimize.SetFont("s11",IconFont)
	BtnSys_Minimize.Opt("-Border")
	BtnSys_Minimize.OnEvent("Click",(*)=>g.Minimize())
	
	BtnSys_Close:=g.AddText('vBtnSys_Close x' PanelX+PanelW-30 ' ym w30 h20 0x200 Center Border',Chr(0xE10A))
	BtnSys_Close.SetFont("s11",IconFont)
	BtnSys_Close.Opt("-Border")
	BtnSys_Close.OnEvent("Click",(*) => ExitApp() )
	
	g.AddPic("Hidden vNavBGHover xm y" PanelY)
	g.AddPic("vNavBGActive Hidden xm y" PanelY)
	g.AddPic('vBGPanel w' PanelW ' h' PanelH ' x' PanelX ' y' PanelY)
	
	pToken:=Gdip_Startup()
	SetBGNavSelect(g,NavSelectW,NavSelectH)
	SetBGPanel(g,PanelW,PanelH)
	hLogo:=Gdip_CreateARGBHBITMAPFromBase64('iVBORw0KGgoAAAANSUhEUgAAAKAAAABLCAYAAAD3TIxsAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGU2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDEgNzkuMTQ2Mjg5OSwgMjAyMy8wNi8yNS0yMDowMTo1NSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyNC0wMS0xNVQwOTo0ODowMyswNzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNC0wMS0xNVQwOTo0ODowMyswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjQtMDEtMTVUMDk6NDg6MDMrMDc6MDAiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MWIwOGU0ODktYmU3YS05YTRkLWI1ODItYzBhZGY3MzQxMmYwIiB4bXBNTTpEb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6YmFkYWJjNzYtYTBhOC0wMzRmLWJiZDEtYWMyY2YzZGI1ZDQ5IiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6YTE4NGQxNGMtNjY4Yy05NDQ0LTg1ZDgtYWU2NGYzZDdmMjAwIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiBkYzpmb3JtYXQ9ImltYWdlL3BuZyI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6YTE4NGQxNGMtNjY4Yy05NDQ0LTg1ZDgtYWU2NGYzZDdmMjAwIiBzdEV2dDp3aGVuPSIyMDI0LTAxLTE1VDA5OjQ4OjAzKzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMyAoV2luZG93cykiLz4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjFiMDhlNDg5LWJlN2EtOWE0ZC1iNTgyLWMwYWRmNzM0MTJmMCIgc3RFdnQ6d2hlbj0iMjAyNC0wMS0xNVQwOTo0ODowMyswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjMgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8cGhvdG9zaG9wOlRleHRMYXllcnM+IDxyZGY6QmFnPiA8cmRmOmxpIHBob3Rvc2hvcDpMYXllck5hbWU9IldpblR1bmUiIHBob3Rvc2hvcDpMYXllclRleHQ9IldpblR1bmUiLz4gPC9yZGY6QmFnPiA8L3Bob3Rvc2hvcDpUZXh0TGF5ZXJzPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Plb4la8AABa1SURBVHja7Z13fJRVvsbZez931+td3VX3ruvuulaKIIICoijNhIQQmpQAoRcBpaVPeu+VVBICoYQkkISSQhJCQJEiJYTQU0kBpKSBWNjV3eee35l5YyaZ886sGdQr7x/PZ5j3PKe955vT3vMOPQD0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')
	
	Logo:=g.AddPic('xm10 ym410 w160 h75', "HBITMAP:" hLogo)
	Logo.OnEvent("Click",(*)=>Run("https://github.com/tranht17/WinTune"))
	DeleteObject(hLogo)
	Gdip_Shutdown(pToken)
	
	g.AddText('xm95 ym422 BackgroundTrans',"v" App.Ver)
	
	SpaceName:="              "
	Loop Layout.Length {
		ItemID:=Layout[A_Index].ID
		If (ItemID = "")
			Continue
		y:=(A_Index-1)*40+24
		aIcon:=g.AddPic("BackgroundTrans h22 w22 xm12 ym" y+13)
		aIcon.Value:=(!IsWin11 && Layout[A_Index].HasOwnProp("Icon10") && Layout[A_Index].Icon10)?Layout[A_Index].Icon10:Layout[A_Index].Icon
		NavItem:=g.AddText("BackgroundTrans 0x200 0x100 h" NavSelectH " w" NavSelectW " xm ym" y+6 " vNavItem_" A_Index, SpaceName GetLangName(ItemId))
		
		If Layout[A_Index].HasOwnProp("Fn") && Layout[A_Index].Fn {
			Fn:=Layout[A_Index].Fn
			If Layout[A_Index].HasOwnProp("NotSelected") && Layout[A_Index].NotSelected
				FnClick:=%Fn%.Bind(g, A_Index)
			Else
				FnClick:=NavItem_Click.Bind(g, A_Index)
			NavItem.OnEvent("Click", FnClick)
		}
	}
	g.SetFont("s9")
	NavItem_Click(g, 1)
	g.Show
	FrameShadow(g.hWnd)
	Return g
}

NavItem_Click(g, NavIndex, *) {
	Ctr:=g["NavItem_" NavIndex]
	Ctr.GetPos(&x, &y)
	g["NavBGActive"].GetPos(&xA, &yA)
	If x=xA && y=yA
		Return
	g["NavBGHover"].Visible:=False
	g["NavBGActive"].Visible:=False
	CurrentTabCtrls:=CurrentTabCtrlArray()
	If Type(CurrentTabCtrls)="Array" && CurrentTabCtrls.Length {
		Loop CurrentTabCtrls.Length {
			g[CurrentTabCtrls[A_Index]].Visible:=False
		}
	}
	CurrentTabCtrls:=%Layout[NavIndex].Fn%(g, NavIndex)
	CurrentTabCtrlArray(CurrentTabCtrls)
	g["NavBGActive"].Move(x, y)
	g["NavBGActive"].Visible:=True
	Ctr.Focus()
}

BtnSelectAll_Click(Ctr, ID, HREF) {
	g:=Ctr.Gui
	g2:=CreateWaitDlg(g)
	CurrentTabCtrls:=CurrentTabCtrlArray()
	Loop CurrentTabCtrls.Length {
		If g[CurrentTabCtrls[A_Index]].Type="PicSwitch" && g[CurrentTabCtrls[A_Index]].Value!=ID {
			g[CurrentTabCtrls[A_Index]].Value:=ID
			ProgNowCtr(g[CurrentTabCtrls[A_Index]],Data.%CurrentTabCtrls[A_Index]%,1)
		}
	}
	DestroyDlg(g,g2)
}

CB_Click(Ctr,Info) {
	g:=Ctr.Gui
	g2:=CreateWaitDlg(g)
	ProgNowCtr(Ctr,Data.%Ctr.Name%)
	DestroyDlg(g,g2)
}
CurrentTabCtrlArray(CtrlArray?) {
	Static CurrentTabCtrlArray:=Array()
	If IsSet(CtrlArray)
		CurrentTabCtrlArray:=CtrlArray
	Return CurrentTabCtrlArray
}

OptimizeTab(g, NavIndex) {
	WICB:=20,SpaceItem:=16,C:=3
	Static sWCBT,sXCBT,sYCBT
	try {
		g["BtnSelectAll"]
	} Catch {
		g["BGPanel"].GetPos(&sXCBT, &sYCBT, &PanelW)
		BtnSelectAll:=g.Add("Link","vBtnSelectAll Hidden w160 h20 x" sXCBT+(PanelW-160)/2 " y" (sYCBT+=12) " Background" Themes.%ThemeSelected%.BackColorPanelRGB, 
									'<a id="1">' GetLangName("BtnSelectAll") '</a>   <a id="0">' GetLangName("BtnDeselectAll") '</a>')
		BtnSelectAll.SetFont("s11")
		LinkUseDefaultColor(BtnSelectAll)
		BtnSelectAll.OnEvent("Click",BtnSelectAll_Click)
		g.AddText("vHRLine x" sXCBT+(PanelW-400)/2 " y" (sYCBT+=30) " w400 h1 Background" Themes.%ThemeSelected%.HrColor).Focus()
		sWCBT:=(PanelW-SpaceItem)/C-SpaceItem
		sXCBT+=SpaceItem
		sYCBT+=SpaceItem
	}

	CurrentTabCtrls:=Array()

	g["BtnSelectAll"].Visible:=True
	g["HRLine"].Visible:=True
	g["BtnSys_SaveOptimizeConfigTab"].Visible:=True
	
	x:=sXCBT
	y:=sYCBT
	i:=0,CtrlCreated:=1
	ItemList:=Layout[NavIndex].Items
	
	Loop ItemList.Length {
		ItemId:=ItemList[A_Index]
		
		If CtrlCreated {
			i++
			If i=1 {
			} Else If Mod(i,C)=1
				y+=30,x-=((C-1)*(SpaceItem+sWCBT))
			Else
				x+=(SpaceItem+sWCBT)
		}
	
		try {
			g[ItemId].Value:=CheckStatusItem(ItemId, Data.%ItemId%)
			CtrlCreated:=1
		} catch
			CtrlCreated:=CreateCB(g,ItemId, sWCBT)
		Finally {
			If CtrlCreated {
				g[ItemId].Move(x, y)
				g[ItemId].Visible:=True
				CurrentTabCtrls.Push ItemId
			}
		}
	}
	Return CurrentTabCtrls
}

CreateCB(g,ItemId, W) {
	s:=CheckStatusItem(ItemId, Data.%ItemId%)
	If s<=-1
		Return 0
	
	Static m:=Map()
	If m.Count=0 {	
		m["SWidth"]:=20
		m["SHeight"]:=20
		pToken:=Gdip_Startup()
		hValue1Icon:=Gdip_CreateARGBHBITMAPFromBase64('iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAJmWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDEgNzkuMTQ2Mjg5OSwgMjAyMy8wNi8yNS0yMDowMTo1NSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0xMS0xMVQyMDo0NjoxOCswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjMtMTEtMTFUMjA6NDY6MTgrMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjU0NzZiYzFmLWMzZjgtYWY0OS04OWM1LWIxZmE4ZTlmMGU2NyIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjRjMjliMGMyLWFlZWMtNWQ0Yy04MjJkLWI0MWE1NTBkN2YwYiIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgdGlmZjpPcmllbnRhdGlvbj0iMSIgdGlmZjpYUmVzb2x1dGlvbj0iNzIwMDAwLzEwMDAwIiB0aWZmOllSZXNvbHV0aW9uPSI3MjAwMDAvMTAwMDAiIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiIGV4aWY6Q29sb3JTcGFjZT0iNjU1MzUiIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSIzODUiIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSIzODUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgc3RFdnQ6d2hlbj0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpkNTRiYjVkMi05ZTRjLWEwNDctODc3ZS0xM2UxYjM1NWY3MGQiIHN0RXZ0OndoZW49IjIwMjMtMTEtMTFUMjA6NDY6MTgrMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY29udmVydGVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJmcm9tIGFwcGxpY2F0aW9uL3ZuZC5hZG9iZS5waG90b3Nob3AgdG8gaW1hZ2UvcG5nIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJkZXJpdmVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJjb252ZXJ0ZWQgZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6NTQ3NmJjMWYtYzNmOC1hZjQ5LTg5YzUtYjFmYThlOWYwZTY3IiBzdEV2dDp3aGVuPSIyMDIzLTExLTExVDIwOjQ2OjE4KzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMSAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOmQ1NGJiNWQyLTllNGMtYTA0Ny04NzdlLTEzZTFiMzU1ZjcwZCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpmMGVhN2VlZi1kZGZiLWM1NDctOWIyMi02MTkzN2M3OGU5ZjIiIHN0UmVmOm9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmMGVhN2VlZi1kZGZiLWM1NDctOWIyMi02MTkzN2M3OGU5ZjIiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7IaVfeAAABSUlEQVQ4EWNgWP6akVz8//9/BhgG8vuBuJaBUsOAbBsgfgfE/4HYhIFhxRtWIF4MxP9JwIlADDK4EGoQCHOBLQBKrIYqegPEt4jATUAMclknkmHSUNcyMkANe0GUV0EGQQxrQzLMFm4YkoFXSDAsG8mwUqCYDDYDb2HRiGng8tcOSIbtA4o5A/ErFHUoBsIMQ8YIw/iA+AvUsJ9AzAMUfwDWj9VAiCYRaGDPAmJHNIMPIbkuCCp+lZCBSUiaQNgVKp6FJLYdyaLzuA2ECHADsQ+S5hto4fYHiAWQgoKAgQjvNaO5FIazUCKMCBciG/oRzbD7GCmARANnoRnojpGciDIQe5q7iDV94jHwCo5csReInwOxFo7EfgKXgc/wZDU2rIZB1NzBZuAWqKEPoV4gFt+D6juIbiA3EK8jsTyEYZBjBFENpKAKwIYBVM4bDAUNomwAAAAASUVORK5CYII=')
		hValue0Icon:=Gdip_CreateARGBHBITMAPFromBase64('iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAJmWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDEgNzkuMTQ2Mjg5OSwgMjAyMy8wNi8yNS0yMDowMTo1NSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVmIyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0xMS0xMVQyMDo0MzowMCswNzowMCIgeG1wOk1vZGlmeURhdGU9IjIwMjMtMTEtMTFUMjA6NDM6MDArMDc6MDAiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmEyMWU5MDhkLWFmYmUtMTE0OC1hM2FjLWM2MzZhY2YwNzU3ZSIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOmNlNzkwYWYzLTVlM2UtNjk0NC1iMDkxLWZmZWUzYzNkYTA1OSIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgcGhvdG9zaG9wOkNvbG9yTW9kZT0iMyIgdGlmZjpPcmllbnRhdGlvbj0iMSIgdGlmZjpYUmVzb2x1dGlvbj0iNzIwMDAwLzEwMDAwIiB0aWZmOllSZXNvbHV0aW9uPSI3MjAwMDAvMTAwMDAiIHRpZmY6UmVzb2x1dGlvblVuaXQ9IjIiIGV4aWY6Q29sb3JTcGFjZT0iNjU1MzUiIGV4aWY6UGl4ZWxYRGltZW5zaW9uPSIzODUiIGV4aWY6UGl4ZWxZRGltZW5zaW9uPSIzODUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmYwZWE3ZWVmLWRkZmItYzU0Ny05YjIyLTYxOTM3Yzc4ZTlmMiIgc3RFdnQ6d2hlbj0iMjAyMy0xMS0xMVQxMDo1NToyNiswNzowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjEgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpiNWU3OGFmNC03ODczLTJkNDAtYmJmZS1jOTQ0MDAxMWMxMDgiIHN0RXZ0OndoZW49IjIwMjMtMTEtMTFUMjA6NDM6MDArMDc6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS4xIChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0iY29udmVydGVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJmcm9tIGFwcGxpY2F0aW9uL3ZuZC5hZG9iZS5waG90b3Nob3AgdG8gaW1hZ2UvcG5nIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJkZXJpdmVkIiBzdEV2dDpwYXJhbWV0ZXJzPSJjb252ZXJ0ZWQgZnJvbSBhcHBsaWNhdGlvbi92bmQuYWRvYmUucGhvdG9zaG9wIHRvIGltYWdlL3BuZyIvPiA8cmRmOmxpIHN0RXZ0OmFjdGlvbj0ic2F2ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6YTIxZTkwOGQtYWZiZS0xMTQ4LWEzYWMtYzYzNmFjZjA3NTdlIiBzdEV2dDp3aGVuPSIyMDIzLTExLTExVDIwOjQzOjAwKzA3OjAwIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjUuMSAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOmI1ZTc4YWY0LTc4NzMtMmQ0MC1iYmZlLWM5NDQwMDExYzEwOCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpmMGVhN2VlZi1kZGZiLWM1NDctOWIyMi02MTkzN2M3OGU5ZjIiIHN0UmVmOm9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmMGVhN2VlZi1kZGZiLWM1NDctOWIyMi02MTkzN2M3OGU5ZjIiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5yI4PvAAAAiUlEQVQ4y+3UPQ6DMAyGYfcMwND7LyAhgSr1BKyM/IkzMNGhVRbzWXIXb47CluHZ4jdZYmJmSomSB6k+SmjhB+xwQgOFDb70wA6jw65zvQ0GmOEB5CDnV/jaoNwyOGN/Msc5mIM5GBOUvzxFxOQvL/Cxwbe+cnNum03nOht8ajQ492HQ1VfdurEvDgp6X54Vy6cAAAAASUVORK5CYII=')
		Gdip_Shutdown(pToken)
		m["Value1Icon"]:="HBITMAP:*" hValue1Icon
		m["Value0Icon"]:="HBITMAP:*" hValue0Icon
	}
	ThisCheckBox := g.AddPicSwitch("Hidden x0 y0 0x80 w" W " v" ItemId,GetLangName(ItemId),,m)
	g[ItemId].OnEvent("Click",CB_Click)
	g[ItemId].SPic.OnEvent("Click",(*)=>CB_Click(g[ItemId],""))
	g[ItemId].Value:=s
	Return 1
}
SetBGNavSelect(g, W:=0, H:=0, R:=6) {
	Static PathX2:=W,PathY2:=H,Rounded:=R
	If W>0
		PathX2:=W
	If H>0
		PathY2:=H
	If PathX2<=0 || PathY2<=0
		Return
	
	pBitmap := Gdip_CreateBitmap(PathX2, PathY2)
	pGraphics := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothing(pGraphics)

	PathX := PathY := 0
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, "0x" Themes.%ThemeSelected%.BackColorNavSelect)
	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	g["NavBGHover"].Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap)
	
	PathX := 0, PathX2 := 3, Rounded := 2
	PathY := PathY2/4
	PathY2 := PathY+PathY2/2
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, 0xFF4CC2FF)

	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	g["NavBGActive"].Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
}
SetBGPanel(g, W:=0, H:=0, R:=6, BW:=1) {
	Static PathX2:=W,PathY2:=H,Rounded:=R,BorderWidth:=BW
	If W>0
		PathX2:=W
	If H>0
		PathY2:=H
	If PathX2<=0 || PathY2<=0
		Return
	
	pBitmap := Gdip_CreateBitmap(PathX2, PathY2)
	pGraphics := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothing(pGraphics)
	
	DllCall("Gdiplus.dll\GdipGraphicsClear", "Ptr", pGraphics, "UInt", "0xFF" Themes.%ThemeSelected%.BackColor)
	
	PathX := PathY := 0
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, "0x" Themes.%ThemeSelected%.BorderColorPanel)
	
	PathX := PathY := BorderWidth, PathX2 -= BorderWidth, PathY2 -= BorderWidth, Rounded -= BorderWidth
	Gdip_FillRoundedRectanglePath(pGraphics, PathX, PathY, PathX2, PathY2, Rounded, "0x" Themes.%ThemeSelected%.BackColorPanel)

	DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "Int", 10, "Int", 10, "uint*", &ARGB:=0)

	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	g["BGPanel"].Value:="HBITMAP:" hBitmap
	DeleteObject(hBitmap), Gdip_DeleteGraphics(pGraphics), Gdip_DisposeImage(pBitmap)
	Themes.%ThemeSelected%.BackColorPanelRGB:=Format("{:X}", ARGB & 0x00FFFFFF)
}

CheckRequires(DataItem) {
	; RequiresWinInstallationType: "Client,Server"
	If DataItem.HasOwnProp("RequiresWinInstallationType") && DataItem.RequiresWinInstallationType {
		InstallationType:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallationType")
		IsPassed:=0
		Loop Parse, DataItem.RequiresWinInstallationType, "," {
			If A_LoopField=InstallationType {
				IsPassed:=1
				Break
			}	
		}
		If !IsPassed
			Return 0
	}
	
	; RequiresWinEditionID: "Professional"
	If DataItem.HasOwnProp("RequiresWinEditionID") && DataItem.RequiresWinEditionID {
		EditionID:=RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "EditionID")
		IsPassed:=0
		Loop Parse, DataItem.RequiresWinEditionID, "," {
			If A_LoopField=EditionID {
				IsPassed:=1
				Break
			}	
		}
		If !IsPassed
			Return 0
	}
	
	; RequiresWinVer: ">=10.0.10240+ <=10.0.19045"
	; RequiresWinVer: ">=10.0.22000"
	If DataItem.HasOwnProp("RequiresWinVer") && DataItem.RequiresWinVer {
		IsPassed:=0
		Loop Parse, DataItem.RequiresWinVer, "," {
			If VerCompare(A_OSVersion, A_LoopField) {
				IsPassed:=1
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
		sType:=DataItem.Act[A_Index].Type
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
			} Catch {
				s:=1
			}
		Case "RegAdd":
			Key:=HKCU2HCU(DataItem.Act[A_Index].RegKey)
			If DataItem.Act[A_Index].HasOwnProp("RegValueName") && DataItem.Act[A_Index].HasOwnProp("RegValue1") {
				try {
					s:=RegRead(Key, DataItem.Act[A_Index].RegValueName)=DataItem.Act[A_Index].RegValue1
				} Catch {
					s:=0
				}
			} Else If DataItem.Act[A_Index].HasOwnProp("RegValue1") {
				try {
					s:=RegRead(Key)=DataItem.Act[A_Index].RegValue1
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

ProgNowCtr(Ctr, ItemData,silent:=0) {
	ProgNow(Ctr.Name, Ctr.Value, ItemData, silent)
}

ProgNow(ItemId, ItemValue, ItemData, silent:=0) {
	Try {
		Loop ItemData.Act.Length {
			If ItemData.Act[A_Index].HasOwnProp("Check") && ItemData.Act[A_Index].Check
				Continue
			If ItemData.Act[A_Index].Type="Custom"
				%ItemId%(ItemValue, ItemData.Act[A_Index],silent)
			Else If ItemData.Act[A_Index].Type="RunTerminal"
				RunTerminal(ItemData.Act[A_Index].Value%ItemValue%)
			Else
				Prog%ItemData.Act[A_Index].Type%(ItemValue,ItemData.Act[A_Index],silent)
		}
	} Catch as err {
		FileAppend Format("`n" A_Now
				"`nFunc: {1}`nMessage:`n{2}`nStack:`n{3}", ItemId, err.Message, err.Stack), "error.txt"
	}
}

ProgReg(s, ItemData, silent) {
	If (s && ItemData.Type="RegDel") || (!s && ItemData.Type="RegAdd") {
		If ItemData.HasOwnProp("LvlKeyDel") && ItemData.LvlKeyDel {
			sKey:=StrSplit(HKCU2HCU(ItemData.RegKey), "\")
			cKey:=""
			Loop (sKey.Length-ItemData.LvlKeyDel+1)
				cKey.=(A_Index=1?"":"\") sKey[A_Index]
			RegDeleteKey cKey
		}
		Else
			RegDelete HKCU2HCU(ItemData.RegKey), ItemData.RegValueName
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

OnMessage(0x0200, On_WM_MOUSEMOVE)
On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
	static PrevHwnd:=0,HoveredBtn:=""
	CurrControl := GuiCtrlFromHwnd(Hwnd)
	
	if (Hwnd != PrevHwnd) {
		ToolTip()
		If currControl {
			thisGui := currControl.Gui
			If HoveredBtn!=currControl.Name {
				If HoveredBtn {
					If InStr(HoveredBtn, "BtnSys_")=1{
						thisGui[HoveredBtn].SetFont("c" Themes.%ThemeSelected%.TextColor)
						thisGui[HoveredBtn].Opt("-Border")
						HoveredBtn:=""
					} Else If InStr(HoveredBtn, "NavItem_")=1{
						thisGui["NavBGHover"].Visible := false
						HoveredBtn:=""
					}
				}
					
				If InStr(currControl.Name, "BtnSys_")=1 {
					currControl.SetFont("cRed")
					currControl.Opt("+Border")
					HoveredBtn:=currControl.Name
				} Else If InStr(currControl.Name, "NavItem_")=1 {
					currControl.GetPos(&x, &y)
					thisGui["NavBGHover"].Move(x, y)
					thisGui["NavBGHover"].Visible := true
					HoveredBtn:=currControl.Name
				}
				
				If !currControl.Name || !Lang.HasOwnProp(currControl.Name) || !Lang.%currControl.Name%.HasOwnProp("Desc") || !Lang.%currControl.Name%.Desc
					return
				ToolTipOptions.SetTitle(InStr(currControl.Name, "BtnSys_")=1?"":GetLangName(currControl.Name))
				SetTimer(CheckHoverControl, 50)
				SetTimer(DisplayToolTip, -600)
			}
		} else {
			thisGui := GuiFromHwnd(Hwnd)
			if (isObject(thisGui)) {			
				If HoveredBtn {
					If InStr(HoveredBtn, "BtnSys_")=1 {
						thisGui[HoveredBtn].SetFont("c" Themes.%ThemeSelected%.TextColor)
						thisGui[HoveredBtn].Opt("-Border")
						HoveredBtn:=""
					} Else If InStr(HoveredBtn, "NavItem_")=1 {
						thisGui["NavBGHover"].Visible := false
						HoveredBtn:=""
					}
				}
			}
		}
		PrevHwnd := Hwnd
	}

	CheckHoverControl(){
		If hwnd != prevHwnd {
			SetTimer(DisplayToolTip, 0), SetTimer(CheckHoverControl, 0)
		}
	}
	DisplayToolTip(){
		ToolTip(Lang.%currControl.Name%.Desc)
		SetTimer(CheckHoverControl, 0)
	}
}

OnMessage 0x0201, WM_LBUTTONDOWN
WM_LBUTTONDOWN(wParam,lParam,msg,hwnd) {
    thisGui := GuiFromHwnd(hwnd)
	If thisGui
		PostMessage 0xA1, 2
}

CreateWaitDlg(g) {
	g.GetPos(&X, &Y, &W, &H)
	g2:=CreateDlg(g)
	tWidth:=300,tHeight:=20
	g2.Add("Text","Center 0x200 h" tHeight " w" tWidth,"Please wait...").SetFont("s10")
	g2.Show("x" X+(W-tWidth)/2 " y" Y+(H-tHeight)/2)
	Return g2
}

CreateDlg(g) {
	g2:=Gui("-Caption +Owner" g.Hwnd,"Dlg")
	FrameShadow(g2.hWnd)
	g2.SetFont("c" Themes.%ThemeSelected%.TextColor, "Segoe UI Semibold")
	g2.BackColor:=Themes.%ThemeSelected%.BackColor
	g.Opt("+Disabled")
	Return g2
}

DestroyDlg(g,g2,TurnOnDisabled:=True) {	
	If TurnOnDisabled
		g.Opt("-Disabled")
	g2.Destroy()
}

GetLangName(ItemId) {
	If Lang.HasOwnProp(ItemId) && Lang.%ItemId%.Name
		ItemId:=Lang.%ItemId%.Name
	Return ItemId
}
