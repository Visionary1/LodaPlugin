class MsgBox
{
	static TDCBF_BUTTON 	:= { "확인": 0x01, "예": 0x02, "아니오": 0x04, "취소": 0x08, "다시 시도": 0x10, "닫기": 0x20 }
	, pnButton 						:= [ "확인", "취소",, "다시 시도",, "예", "아니오", "닫기" ]
	, TD_ICON 						:= { "WARNING": 1, "ERROR": 2, "INFO": 3, "SHIELD": 4, "BLUE": 5, "YELLOW": 6, "RED": 7, "GREEN": 8, "GRAY": 9 }
	
	__New(pszWindowTitle := "", pszMainInstruction :="", pszContent := 0, dwCommonButtons := 0, pszIcon := 0, hWndParent := 0) 
	{
		if (A_OSVersion == "WIN_XP")
			throw 	"MsgBox 모듈은 윈도우 XP를 지원하지 않습니다!"
		return 		this.Create(pszWindowTitle, pszMainInstruction, pszContent , dwCommonButtons, pszIcon, hWndParent)
	}
	
	Create(pszWindowTitle, pszMainInstruction, pszContent, dwCommonButtons, pszIcon, hWndParent) 
	{
		this.btns := 0
		if !(Abs(dwCommonButtons) == "")
			this.btns := dwCommonButtons & 0x3F
		else
			for each, Item in StrSplit(dwCommonButtons, ["|", " ", ",", "`n"])
				this.btns |= (b := this.TDCBF_BUTTON[Item]) ? b : 0
		
		this.ico								:= (each := this.TD_ICON[pszIcon]) ? 0x10000 - each : 0
		this.hWndParent				:= hWndParent
		this.hInstance					:= 0
		this.pszWindowTitle		:= pszWindowTitle != "" ? pszWindowTitle : A_ScriptName
		this.pszMainInstruction	:= pszMainInstruction
		this.pszContent				:= pszContent
		this.HRESULT					:= DllCall("comctl32\TaskDialog", "Ptr", this.hWndParent, "Ptr", this.hInstance
		, "WStr", this.pszWindowTitle, "WStr", this.pszMainInstruction, this.pszContent = 0 ? "Ptr" : "WStr", this.pszContent
		, "UInt", this.btns, "Ptr", this.ico, "IntP", HRESULT)
		return								this.pnButton[HRESULT]
	}
}