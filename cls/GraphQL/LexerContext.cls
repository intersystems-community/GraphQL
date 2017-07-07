Include Tokens

Class GraphQL.LexerContext
{

Property CurrentIndex As %Integer;

Property Source As Source;

Method %OnNew(Source As Source, Index As %Integer) As %Status
{
	set ..Source = Source
	set ..CurrentIndex = Index
	quit $$$OK
}

Method GetToken() As Token
{
	if (..Source.Body = "") return ..CreateEOFToken()
	
	set ..CurrentIndex = ..GetPositionAfterWhitespace(..Source.Body, ..CurrentIndex)
	
	if (..CurrentIndex >= $Length(..Source.Body)) return ..CreateEOFToken()
	
	set Unicode = ..IfUnicodeGetString()
	
	set Code = $Extract(..Source.Body,..CurrentIndex)
	
	do ..ValidateCharacterCode(Code)
	
	set Token = ..CheckForPunctuationTokens(Code)
	
	return:Token'="" Token
	
	return:Code?1(1A,1"_") ..ReadName() 
	
	return:Code?1(1A,1"-") ..ReadNumber() 
	
	return:Code="""" ..ReadString()
}

Method ReadName() As Token
{
	set Start = ..CurrentIndex
	set Code = "0"
	
	do
	{
		set ..CurrentIndex = ..CurrentIndex + 1
		set Code = ..GetCode()
	}
	while(..IsNotAtTheEndOfQuery() && ..IsValidNameCharacter(Code))
	
	return ..CreateNameToken(Start)
}

Method ReadNumber() As Token
{
	set IsFloat = 0
	set Start = ..CurrentIndex
	set Code = $Extract(..Source.Body,Start)
	
	if (Code = "-") set Code = ..NextCode()
	set NextCode = $Select(Code="0":..NextCode(),1:..ReadDigitsFromOwnSource(Code))
	
	if ($Ascii(NextCode) >= 48 && $Ascii(NextCode) <= 57)
	{
		do ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Invalid number, unexpected digit after "_Code_": "_NextCode,..Source,..CurrentIndex)
	}
	
	set Code = ..NextCode()
	
	if (Code = ".")
	{
		set IsFloat = 1
		set Code = ..ReadDigitsFromOwnSource(..NextCode())
	}
	
	if (Code = "E" || Code = "e")
	{
		set IsFloat = 1
		set Code = ..NextCode()
		if (Code = "+" || Code = "-") set Code = ..NextCode()
		set Code = ..ReadDigitsFromOwnSource(Code)
	}

	return $Select(IsFloat: ..CreateFloatToken(Start), 1: ..CreateIntToken(Start))
}

Method ReadString() As Token
{
	set Start = ..CurrentIndex
	Set Value = ..ProcessStringChunks()
	return ##class(Token).%OnNew(Start,..CurrentIndex + 1, $$$STRING, Value)
}

Method ReadDigitsFromOwnSource(Code As %Char) As %Char
{
	set ..CurrentIndex = ..ReadDigits(..Source,..CurrentIndex,Code)
	set Code = ..GetCode()
	return Code
}

Method ReadDigits(Source As Source, Start As %Integer, FirstCode As %Char) As %Integer
{
	set Body = Source.Body
	set Position = Start
	set Code = FirstCode
	
	do:'Code?1N ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Invalid number, expected digit but got: "_..ResolveCharName(Code),..Source,..CurrentIndex) 
	
	do
	{
		set Code = $select(Position+1 < $Length(Body):$Extract(Body,Position),1:"0")
	}
	while(Code?1N)
	
	return Position
}

Method ResolveCharName(Code As %Char, UnicodeString As %String = "") As %Char
{
	return:Code=$c(0) "<EOF>"
	return:'..IsNullOrWiteSpace(UnicodeString) UnicodeString
	return Code
}

/// https://stackoverflow.com/questions/4731055/whitespace-matching-regex-java
Method IsNullOrWiteSpace(UnicodeString As %String) As %Boolean
{
	return:UnicodeString="" $$$YES
	set whitespacesOrNullList = $lb(9,10,11,12,13,32,133,160,5760,6158,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288)
	//write $listfind(whitespacesOrNullList, $ascii(char))
	for i=1:1:$Length(UnicodeString)
	{
		set Char = $Extract(UnicodeString,I)
		set Code = $Ascii(Char)
		return:'$ListFind(whitespacesOrNullList,Code) $$$NO
	}
	return $$$YES
}

Method IsValidNameCharacter(Code As %Char) As %Boolean
{
	return $Select(Code?1(1A,1"_"):$$$YES, 1:$$$NO)
}

Method ProcessStringChunks() As %String
{
	set ChunksStart = ..CurrentIndex + 1
	set Code = ..GetCode()
	set Value = ""
	
	while (..IfUnicodeGetString() && Code '= $c(10) && Code '= $c(13) && Code '= """")
	{
		do ..CheckForInvalidCharacters(Code)
		set Code = ..ProcessCharacter(.Value,.ChunksStart)
	}
	
	do ..CheckStringTermination(Code)
	set Value = Value_$Extract(..Source.Body, ChunksStart,..CurrentIndex - ChunksStart)
	return Value
}

Method CheckStringTermination(Code)
{
	do:Code'="""" ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Unterminated string",..Source,..CurrentIndex)
}

Method ProcessCharacter(ByRef Value As %String, ByRef ChunksStart As %Integer)
{
	set Code = ..GetCode()
	set ..CurrentIndex = ..CurrentIndex + 1
	
	if (Code = "\")
	{
		set Value = ..AppendToValueByCode(..AppendCharactersFromLastChunk(Value, ChunksStart), ..GetCode())
		set ..CurrentIndex = ..CurrentIndex + 1
		set ChunksStart = ..CurrentIndex
	}
	
	return ..GetCode()
}

Method AppendToValueByCode(Value As %String, Code As %Char) As %String [ CodeMode = expression ]
{
$case(Code,
		"""": Value = Value_"""",
		"/": Value = Value_"/",
		"\": Value = Value_"\",
		"b": Value = Value_$c(8),
		"f": Value = Value_$c(12),
		"n": Value = Value_$c(10),
		"r": Value = Value_$c(13),
		"t": Value = Value_$c(9),
		"u": Value = Value_..GetUnicodeChar(),
		:##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Invalid character escape sequence: "_Code,..Source,..CurrentIndex))
}

Method GetUnicodeChar()
{
	set Expresion = $Extract(..Source.Body,..CurrentIndex,..CurrentIndex + 5)
	do:'..OnlyHexInString(Expresion) ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Invalid character escape sequence: "_Expresion,..Source,..CurrentIndex)
	return $zcvt("\u"_..NextCode()_..NextCode()_..NextCode()_..NextCode(), "I", "JSON")
}

Method AppendCharactersFromLastChunk(Value As %String, ChunksStart As %Integer) As %String [ CodeMode = expression ]
{
Value_$Extract(..Source.Body, ChunksStart, ..CurrentIndex - ChunksStart - 1)
}

Method CheckForInvalidCharacters(Code As %Char)
{
	if ($ASCII(Code) < 20 && $ASCII(Code) '= 9)
	{
		do ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Invalid character within String: "_Code,..Source,..CurrentIndex)
	}
}

Method NextCode() As %Char
{
	set ..CurrentIndex = ..CurrentIndex + 1
	if (..IsNotAtTheEndOfQuery()){
		return $Extract(..Source.Body,..CurrentIndex)
	}else{
		return "0"
	}
}

Method GetCode() As %Char
{
	if (..IfUnicodeGetString()){
		return $Extract(..Source.Body,..CurrentIndex)
	}else{
		return "0"
	}
}

Method IsNotAtTheEndOfQuery() As %Boolean [ CodeMode = expression ]
{
..CurrentIndex < $Length(..Source.Body)
}

Method CreateEOFToken() As Token
{
	set Token = ##class(Token).%New()
	set Token.Start = ..CurrentIndex
	set Token.End = ..CurrentIndex
	set Token.Kind = $$$EOF
	return Token
}

Method GetPositionAfterWhitespace(Body As %String, Start As %Integer) As %Integer
{
	set Position = Start

	while( Position < $Length(Body))
	{
		set Char = $Extract(Body, Position)
		
		if ((Char = $c(9)) || (Char = " ") ||(Char = $c(10)) ||(Char = $c(13)) ||(Char = ",")  || (Char = $c(239,187,191))) 
		{
			set Position = Position + 1
			break
		}elseif (char = "#"){
			set position = ..WaitForEndOfComment(Body, Position, Char) 
			break
		}else {
			return Position
		}
	}
	return Position
}

Method WaitForEndOfComment(Body As %String, Position As %Integer, Code As %Char) As %Integer
{
	while((Position < $Length(Body)) && Code '=0 && ($Ascii(Code) > 31 || Code = $c(9)) && Code '=$c(10) && Code '=$c(13))
	{
		set Position = Position + 1
	}
}

Method CheckForPunctuationTokens(Code As %Char) As Token [ CodeMode = expression ]
{
$case(Code,
	"!": ..CreatePunctuationToken($$$BANG, 1),
	"$": ..CreatePunctuationToken($$$DOLLAR, 1),
	"(": ..CreatePunctuationToken($$$PARENL, 1),
	")": ..CreatePunctuationToken($$$PARENR, 1),
	".": ..CheckForSpreadOperator(),
	":": ..CreatePunctuationToken($$$SPREAD, 1),
	"=": ..CreatePunctuationToken($$$EQUALS, 1),
	"@": ..CreatePunctuationToken($$$AT, 1),
	"[": ..CreatePunctuationToken($$$BRACKETL, 1),
	"]": ..CreatePunctuationToken($$$BRACKETR, 1),
	"{": ..CreatePunctuationToken($$$BRACEL, 1),
	"|": ..CreatePunctuationToken($$$PIPE, 1),
	"}": ..CreatePunctuationToken($$$BRACER, 1),
	:"")
}

Method CreatePunctuationToken(Kind, Offset As %Integer) As Token [ CodeMode = expression ]
{
##class(Token).%New(..CurrentIndex, ..CurrentIndex + Offset, Kind, 0)
}

Method CreateFloatToken(Start As %Integer) As Token [ CodeMode = expression ]
{
##class(Token).%New(Start, ..CurrentIndex, $$$FLOAT, $Extract(..Source.Body,Start,..CurrentIndex - Start))
}

Method CreateIntToken(Start As %Integer) As Token [ CodeMode = expression ]
{
##class(Token).%New(Start, ..CurrentIndex, $$$INT, $Extract(..Source.Body,Start,..CurrentIndex - Start))
}

Method CreateNameToken(Start As %Integer) As Token [ CodeMode = expression ]
{
##class(Token).%New(Start, ..CurrentIndex, $$$NAME, $Extract(..Source.Body,Start,..CurrentIndex - Start))
}

Method CheckForSpreadOperator() As Token
{
	set Char1 = $Select($Length(..Source.Body) > ..CurrentIndex + 1: $Extract(..Source.Body,..CurrentIndex + 1),1: 0)
	set Char2 = $Select($Length(..Source.Body) > ..CurrentIndex + 2: $Extract(..Source.Body,..CurrentIndex + 2),1: 0)
	if (Char1 = "." && Char2 = ".")
	{
		return ..CreatePunctuationToken($$$SPREAD, 3)
	}
	return
}

Method IfUnicodeGetString() As %String
{
	if (($Length(..Source.Body) > ..CurrentIndex + 5) && ..OnlyHexInString($Extract(..Source.Body,..CurrentIndex + 2, ..CurrentIndex + 6)))
	{
		return $Extract(..Source.Body,..CurrentIndex,..CurrentIndex + 6)
	}
}

Method OnlyHexInString(Text As %String) As %Boolean
{
	return $Match(Text,"\A\b[0-9a-fA-F]+\b\Z")
}

Method ValidateCharacterCode(Code As %Integer)
{
	set Code = $ASCII(Code)
	if (Code < 20 && Code '= 9 && Code '= 10 && Code '= 13)
	{
		do ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).%New("Invalid character: "_$c(Code),..Source,..CurrentIndex)
	}
}

}

