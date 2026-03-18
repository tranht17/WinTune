;================================================================================
; PicSwitch - Switch, Checkbox controls with picture
; tranht17
; 2025/11/27
;================================================================================
Class PicSwitch Extends Gui.Text {
    static __New() {
        Gui.Prototype.AddPicSwitch:=this.AddPicSwitch
    }
	static AddPicSwitch(Options:="", sText:="", iValue:=0, iPicOpt:="") {
		hPic:=iPicOpt && iPicOpt.Has("Height")?iPicOpt["Height"]:20
		wPic:=iPicOpt && iPicOpt.Has("Width")?iPicOpt["Width"]:20
		sTextOpt:=""
		sPicOpt:=""
		Loop parse, Options, A_Space A_Tab {
			if A_LoopField=""
				continue
			if SubStr(A_LoopField,1,1) = 'w' && IsNumber(n:=SubStr(A_LoopField,2)) {
				sTextOpt.=" w" n-wPic-3
			} else if SubStr(A_LoopField,1,1) = 'x' {
				sPicOpt.=" " A_LoopField
			} else if SubStr(A_LoopField,1,1) = 'y' {
				sPicOpt.=" " A_LoopField
			} else {
				sTextOpt.=" " A_LoopField
			}
		}
		ctlPic:=this.AddPic("BackgroundTrans" sPicOpt " w" wPic " h" hPic)
		ctlPic.GetPos(&X, &Y)
		ctlTxt:=this.AddText("BackgroundTrans yp 0x200" sTextOpt " h" hPic,sText)

		ctlEnabled:=ctlTxt.Enabled
		ctlVisible:=ctlTxt.Visible
		ctlPic.Enabled:=ctlEnabled
		ctlPic.Visible:=ctlVisible

        ctlTxt.base:=PicSwitch.Prototype
		ctlTxt.Pic:=ctlPic
		ctlTxt._Value:=iValue
		ctlTxt._Enabled:=ctlEnabled
		ctlTxt._Visible:=ctlVisible

		ctlTxt.OnEvent("click",ObjBindMethod(ctlTxt,"_ClickChangeValue"))
		ctlPic.OnEvent("click",ObjBindMethod(ctlTxt,"_ClickChangeValue"))
		
		ctlTxt.PicOpt:=Map()
		if iPicOpt
			ctlTxt.PicOpt:=iPicOpt
		if !ctlTxt.PicOpt.Has("Width")
			ctlTxt.PicOpt["Width"]:=wPic
		if !ctlTxt.PicOpt.Has("Height")
			ctlTxt.PicOpt["Height"]:=hPic
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
			return value
		}
    }
	Enabled	{
		get => this._Enabled
        set {
			if (this._Enabled!=value) {
				super.Enabled:=value
				this.Pic.Enabled:=value
				this._Enabled:=value
				this.RefreshStatusIcon
			}
			return value
		}
	}
	Visible	{
		get => this._Visible
        set {
			if (this._Visible!=value) {
				super.Visible:=value
				this.Pic.Visible:=value
				this._Visible:=value
			}
			return value
		}
	}
	Move(X?, Y?, W?, H?) {
		wPic:=this.PicOpt["Width"]
		hPic:=this.PicOpt["Height"]
		if IsSet(H) {
			wPic+=(H-hPic)
			this.PicOpt["Height"]:=H
			this.PicOpt["Width"]:=wPic
		}
		this.Pic.Move(X?, Y?, IsSet(H)?wPic:unset, H?)
		this.Pic.GetPos(&wX)
		super.Move((IsSet(X)||IsSet(H))?(wX+wPic+3):unset, Y?, IsSet(W)?W-wPic-3:unset, H?)
	}
	GetPos(&X?, &Y?, &W?, &H?) {
		this.Pic.GetPos(&X, &Y, &sW)
		super.GetPos(,, &tW, &H)
		W:=sW+tW+3
	}
	_ClickChangeValue(*) {
		this._Value:=!this._Value
		this.RefreshStatusIcon
	}
	RefreshStatusIcon(*) {
		this.Pic.GetPos(&sX,, &sW, &sH)
		if sW!=this.PicOpt["Width"] {
			this.Pic.Move(,, this.PicOpt["Width"])
			super.Move(sX+this.PicOpt["Width"]+3)
		}
		if sH!=this.PicOpt["Height"] {
			this.Move(,,, this.PicOpt["Height"])
		}
		nOpt:="Value" this._Value (this._Enabled?"":"Disabled") "Icon"
		this.Pic.Value:=(this.PicOpt.Has(nOpt) && this.PicOpt[nOpt])?this.PicOpt[nOpt]:""
   }
}