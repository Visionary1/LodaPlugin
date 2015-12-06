class JSON ;Credits coco
{
	class Load extends Functor
	{
		Call(Self, text, reviver:="") 
		{
			this.rev := IsObject(reviver) ? reviver : false
			this.keys := this.rev ? {} : false
			
			static q := Chr(34)
			, json_value := q . "{[01234567890-tfn"
			, json_value_or_array_closing := q . "{[]01234567890-tfn"
			, object_key_or_object_closing := q . "}"
			
			key := ""
			is_key := false
			root := {}
			stack := [root]
			next := json_value
			pos := 0
			
			while ((ch := SubStr(text, ++pos, 1)) != "") {
				if InStr(" `t`r`n", ch)
					continue
				if !InStr(next, ch, 1)
					this.ParseError(next, text, pos)
				
				holder := stack[1]
				is_array := holder.IsArray
				
				if InStr(",:", ch) {
					next := (is_key := !is_array && ch == ",") ? q : json_value
					
				} else if InStr("}]", ch) {
					ObjRemoveAt(stack, 1)
					next := stack[1]==root ? "" : stack[1].IsArray ? ",]" : ",}"
					
				} else {
					if InStr("{[", ch) {
						static json_array := Func("Array").IsBuiltIn || ![].IsArray ? {IsArray: true} : 0
						
						(ch == "{")
						? ( is_key := true
						, value := {}
						, next := object_key_or_object_closing )
						: ( value := json_array ? new json_array : []
						, next := json_value_or_array_closing )
						
						ObjInsertAt(stack, 1, value)
						
						if (this.keys)
							this.keys[value] := []
						
					} else {
						if (ch == q) {
							i := pos
							while (i := InStr(text, q,, i+1)) {
								value := StrReplace(SubStr(text, pos+1, i-pos-1), "\\", "\u005c")
								
								static ss_end := A_AhkVersion<"2" ? 0 : -1
								if (SubStr(value, ss_end) != "\")
									break
							}
							
							if (!i)
								this.ParseError("'", text, pos)
							
							value := StrReplace(value,    "\/",  "/")
							, value := StrReplace(value, "\" . q,    q)
							, value := StrReplace(value,    "\b", "`b")
							, value := StrReplace(value,    "\f", "`f")
							, value := StrReplace(value,    "\n", "`n")
							, value := StrReplace(value,    "\r", "`r")
							, value := StrReplace(value,    "\t", "`t")
							
							pos := i
							
							i := 0
							while (i := InStr(value, "\",, i+1)) {
								if !(SubStr(value, i+1, 1) == "u")
									this.ParseError("\", text, pos - StrLen(SubStr(value, i+1)))
								
								uffff := Abs("0x" . SubStr(value, i+2, 4))
								if (A_IsUnicode || uffff < 0x100)
									value := SubStr(value, 1, i-1) . Chr(uffff) . SubStr(value, i+6)
							}
							
							if (is_key) {
								key := value, next := ":"
								continue
							}
							
						} else {
							value := SubStr(text, pos, i := RegExMatch(text, "[\]\},\s]|$",, pos)-pos)
							
							static number := "number", null := ""
							if value is %number%
								value += 0
							else if (value == "true" || value == "false" || value == "null")
								value := %value% + 0
							else
								this.ParseError(next, text, pos, i)
							
							pos += i-1
						}
						
						next := holder==root ? "" : is_array ? ",]" : ",}"
					}
					
					is_array? key := ObjPush(holder, value) : holder[key] := value
					
					if (this.keys && this.keys.HasKey(holder))
						this.keys[holder].Push(key)
				}
				
			}
			return this.rev ? this.Walk(root, "") : root[""]
		}
		
		ParseError(expect, text, pos, len:=1) 
		{
			static q := Chr(34)
			
			line := StrSplit(SubStr(text, 1, pos), "`n", "`r").Length()
			col := pos - InStr(text, "`n",, -(StrLen(text)-pos+1))
			msg := Format("{1}`n`nLine:`t{2}`nCol:`t{3}`nChar:`t{4}"
			,     (expect == "")      ? "Extra data"
			: (expect == "'")     ? "Unterminated string starting at"
			: (expect == "\")     ? "Invalid \escape"
			: (expect == ":")     ? "Expecting ':' delimiter"
			: (expect == q)       ? "Expecting object key enclosed in double quotes"
			: (expect == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			: (expect == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			: (expect == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			: InStr(expect, "]")  ? "Expecting JSON value or array closing ']'"
			:                       "Expecting JSON value(string, number, true, false, null, object or array)"
			, line, col, pos)
			
			static offset := A_AhkVersion<"2" ? -3 : -4
			throw Exception(msg, offset, SubStr(text, pos, len))
		}
		
		Walk(holder, key) 
		{
			value := holder[key]
			if IsObject(value)
				for i, k in this.keys[value]
					value[k] := this.Walk.Call(this, value, k) ; bypass __Call
			
			return this.rev.Call(holder, key, value)
		}
	}
	
	class Get extends Functor
	{
		Call(Self, url, Async := false) 
		{
			static foo := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			foo.Open("GET", url, Async), foo.Send(), foo.WaitForResponse()
			return foo.ResponseText
		}
	}
}