class WinEvents ;GeekDude XD
{
	static Table := {}
	
	Register(hWnd, Class, Prefix="Gui") 
	{
		Gui, +LabelWinEvents.
		this.Table[hWnd] := {Class: Class, Prefix: Prefix}
	}
	
	Unregister(hWnd) 
	{
		this.Table.Delete(hWnd)
	}
	
	Dispatch(hWnd, Type) 
	{
		Info := this.Table[hWnd]
		return Info.Class[Info.Prefix . Type].Call(Info.Class)
	}
	
	Close() 
	{
		return WinEvents.Dispatch(this, "Close")
	}
	
	Size() 
	{
		return WinEvents.Dispatch(this, "Size")
	}
}