class Thread extends Functor
{
	__New(Bind) 
	{
		this.Bind := Bind
	}
	
	__Delete() 
	{
		this.Bind := ""
		this.Destroy()
	}
	
	Call() 
	{
		this.Bind.Call()
		if (this.Period < 0)
			this.Destroy()
	}
	
	Start(Period) 
	{
		this.Period := Period
		SetTimer, % this, % Period
	}
	
	Destroy() 
	{
		SetTimer, % this, Delete
	}
}