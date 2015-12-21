Class Functor
{
	__Call(Method, args*)
	{
		If IsObject(Method) || (Method == "")
			Return Method ? this.Call(Method, args*) : this.Call(args*)
	}
}
/*
class Functor ;ty coco, for demonstrating a way to encapsulate the Private methods!!
{
	__Call(Method, args*) {
		if IsObject(Method)
			return this.Call(Method, args*)
		else if (Method == "")
			return this.Call(args*)
	}
}