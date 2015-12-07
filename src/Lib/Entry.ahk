class Entry
{
	As(Type) {
		this.Common()
		Next := ObjBindMethod(this, Type)
		%Next%()
		VarSetCapacity(Next, 0)
	}
	
	Common() {
		ComObjError(false)
		#NoEnv
		#SingleInstance Off
		SetKeyDelay, 20, 10
		SetWinDelay, 0
		SetControlDelay, 0
		SetBatchLines, -1
		Menu, Tray, NoStandard
		ShowGa := Func("ShowGa"), Terminate := Func("Terminate")
		Menu, Tray, Add, 가가라이브 채팅, % ShowGa
		Menu, Tray, Add,
		Menu, Tray, Add, 종료하기, % Terminate
	}
	
	User() {
		#KeyHistory 0
		ListLines Off
	}
	
	Dev() {
		;#Warn
	}
}