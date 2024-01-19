;================================================================================
; PicSwitch - Switch, Checkbox controls with picture
; tranht17
; 2024/01/14
;================================================================================
Class PicSwitch Extends Gui.Text {
    Static __New() {
        Gui.Prototype.AddPicSwitch:=this.AddPicSwitch
    }
	Static AddPicSwitch(Options:="", sText:="", iValue:=0, SOptions:="") {
		hPic:=SOptions && SOptions.Has("SHeight")?SOptions["SHeight"]:20
		wPic:=SOptions && SOptions.Has("SWidth")?SOptions["SWidth"]:20
		TextOpt:=""
		PicOpt:=""
		Loop parse, Options, A_Space A_Tab {
			If SubStr(A_LoopField,1,1) = 'w' && IsNumber(n:=SubStr(A_LoopField,2)) {
				TextOpt.=" w" n-wPic-3
			} Else If SubStr(A_LoopField,1,1) = 'x' {
				PicOpt.=" " A_LoopField
			} Else If SubStr(A_LoopField,1,1) = 'y' {
				PicOpt.=" " A_LoopField
			} Else {
				TextOpt.=" " A_LoopField
			}
		}
		ctlPic:=this.AddPic("BackgroundTrans" PicOpt " w" wPic " h" hPic)
		ctlPic.GetPos(&X, &Y)
		ctlTxt:=this.AddText("BackgroundTrans yp 0x200" TextOpt " h" hPic,sText)

		ctlEnabled:=ctlTxt.Enabled
		ctlVisible:=ctlTxt.Visible
		ctlPic.Enabled:=ctlEnabled
		ctlPic.Visible:=ctlVisible

        ctlTxt.base:=PicSwitch.Prototype
		ctlTxt.SPic:=ctlPic
		ctlTxt._Value:=iValue
		ctlTxt._Enabled:=ctlEnabled
		ctlTxt._Visible:=ctlVisible

		ctlTxt.OnEvent("click",ObjBindMethod(ctlTxt,"_ClickChangeValue"))
		ctlPic.OnEvent("click",ObjBindMethod(ctlTxt,"_ClickChangeValue"))
		
		ctlTxt.SOpt:=Map()
		If SOptions
			ctlTxt.SOpt:=SOptions
		If !ctlTxt.SOpt.Has("SWidth")
			ctlTxt.SOpt["SWidth"]:=wPic
		If !ctlTxt.SOpt.Has("SHeight")
			ctlTxt.SOpt["SHeight"]:=hPic
		ctlTxt.RefreshStatusIcon
        return ctlTxt
    }
	Type => "PicSwitch"
	Value {
        get => this._Value
        set {
			if (this._Value!=value) {
				this._Value:=value
				this.RefreshStatusIcon
			}
			Return value
		}
    }
	Enabled	{
		get => this._Enabled
        set {
			if (this._Enabled!=value) {
				super.Enabled:=value
				this.SPic.Enabled:=value
				this._Enabled:=value
				this.RefreshStatusIcon
			}
			Return value
		}
	}
	Visible	{
		get => this._Visible
        set {
			if (this._Visible!=value) {
				super.Visible:=value
				this.SPic.Visible:=value
				this._Visible:=value
			}
			Return value
		}
	}
	Move(X?, Y?, W?, H?) {
		wSPic:=this.SOpt["SWidth"]
		hSPic:=this.SOpt["SHeight"]
		If IsSet(H) {
			wSPic+=(H-hSPic)
			this.SOpt["SHeight"]:=H
			this.SOpt["SWidth"]:=wSPic
		}
		this.SPic.Move(X?, Y?, IsSet(H)?wSPic:unset, H?)
		this.SPic.GetPos(&wX)
		super.Move((IsSet(X)||IsSet(H))?(wX+wSPic+3):unset, Y?, IsSet(W)?W-wSPic-3:unset, H?)
	}
	GetPos(&X?, &Y?, &W?, &H?) {
		this.SPic.GetPos(&X, &Y, &sW)
		super.GetPos(,, &tW, &H)
		W:=sW+tW+3
	}
	_ClickChangeValue(*) {
		this._Value:=!this._Value
		this.RefreshStatusIcon
	}
	RefreshStatusIcon(*) {
		this.SPic.GetPos(&sX,, &sW, &sH)
		If sW!=this.SOpt["SWidth"] {
			this.SPic.Move(,, this.SOpt["SWidth"])
			super.Move(sX+this.SOpt["SWidth"]+3)
		}
		If sH!=this.SOpt["SHeight"] {
			this.Move(,,, this.SOpt["SHeight"])
		}
		nOpt:="Value" this._Value (this._Enabled?"":"Disabled") "Icon"
		this.SPic.Value:=(this.SOpt.Has(nOpt) && this.SOpt[nOpt])?this.SOpt[nOpt]:""
   }
}