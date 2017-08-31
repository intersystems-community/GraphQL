Include GraphQLUtils

Class GraphQL.LexerContext Extends %RegisteredObject
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
	
	set Char = $Extract(..Source.Body, ..CurrentIndex)

	do ..ValidateCharacterCode(Char)
	
	set Token = ..CheckForPunctuationTokens(Char)
	
	return:$IsObject(Token) Token
	
	return:Char?1(1A,1"_") ..ReadName() 
	
	return:Char?1(1N,1"-") ..ReadNumber() 
	
	return:Char="""" ..ReadString()
	
	throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Unexpected character: "_Char,..Source,..CurrentIndex)
}

Method ReadName() As Token
{
	set Start = ..CurrentIndex
	
	do
	{
		set ..CurrentIndex = ..CurrentIndex + 1
		set Char = ..GetChar()
	}
	while(..IsNotAtTheEndOfQuery() && ..IsValidNameCharacter(Char))
	
	return ..CreateNameToken(Start)
}

Method ReadNumber() As Token
{
	set IsFloat = $$$NO
	set Start = ..CurrentIndex
	set Char = $Extract(..Source.Body, Start)
	
	if (Char = "-") set Char = ..NextChar()
	set NextChar = $Select(Char = "0": ..NextChar(), 1: ..ReadDigitsFromOwnSource(Char))
	
	if (($Ascii(NextChar) >= 48) && ($Ascii(NextChar) <= 57))
	{
		throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Invalid number, unexpected digit after "_Char_": "_NextChar,..Source,..CurrentIndex)
	}
	
	set Char = NextChar
	
	if (Char = ".")
	{
		set IsFloat = 1
		set Char = ..ReadDigitsFromOwnSource(..NextChar())
	}
	
	if (Char = "E" || Char = "e")
	{
		set IsFloat = 1
		set Char = ..NextChar()
		if (Char = "+" || Char = "-") set Char = ..NextChar()
		set Char = ..ReadDigitsFromOwnSource(Char)
	}

	return $Select(IsFloat: ..CreateFloatToken(Start), 1: ..CreateIntToken(Start))
}

Method ReadString() As Token
{
	set Start = ..CurrentIndex
	Set Value = ..ProcessStringChunks()
	return ##class(Token).%New(Start,..CurrentIndex + 1, $$$STRING, Value)
}

Method ReadDigitsFromOwnSource(Char As %Char) As %Char
{
	set ..CurrentIndex = ..ReadDigits(..Source, ..CurrentIndex, Char)
	set Char = ..GetChar()
	return Char
}

Method ReadDigits(Source As Source, Start As %Integer, FirstChar As %Char) As %Integer
{
	set Body = Source.Body
	set Position = Start
	set Char = FirstChar
	
	throw:'(Char?1N) ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Invalid number, expected digit but got: "_..ResolveCharName(Char),..Source,..CurrentIndex) 
	
	do
	{
		set Position = Position + 1
		set Char = $select(Position < $Length(Body): $Extract(Body, Position), 1: $$$NULL)
	}
	while((Char?1N))
	
	return Position
}

Method ResolveCharName(Code As %Char, UnicodeString As %String = "") As %Char
{
	return:Char=$c(0) "<EOF>"
	return:'..IsNullOrWiteSpace(UnicodeString) UnicodeString
	return Char
}

/// https://stackoverflow.com/questions/4731055/whitespace-matching-regex-java
Method IsNullOrWiteSpace(UnicodeString As %String) As %Boolean
{
	return:UnicodeString="" $$$YES
	set whitespacesOrNullList = $lb(9,10,11,12,13,32,133,160,5760,6158,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288)
	//write $listfind(whitespacesOrNullList, $ascii(char))
	for i=1:1:$Length(UnicodeString)
	{
		set Char = $Extract(UnicodeString, i)
		set Code = $Ascii(Char)
		return:'$ListFind(whitespacesOrNullList,Code) $$$NO
	}
	return $$$YES
}

Method IsValidNameCharacter(Char As %Char) As %Boolean [ CodeMode = expression ]
{
$Select(Char?1(1A,1"_"):$$$YES, 1:$$$NO)
}

Method ProcessStringChunks() As %String
{
	set ..CurrentIndex = ..CurrentIndex + 1
	set ChunksStart = ..CurrentIndex
	set Char = ..GetChar()
	set Value = ""
	
	while (..IsNotAtTheEndOfQuery() && (Char '= $c(10)) && (Char '= $c(13)) && (Char '= """"))
	{
		do ..CheckForInvalidCharacters(Char)
		set Char = ..ProcessCharacter(.Value,.ChunksStart)
	}
	
	do ..CheckStringTermination(Char)
	set Value = Value_$Extract(..Source.Body, ChunksStart, ..CurrentIndex - 1)
	return Value
}

Method CheckStringTermination(Char As %Char)
{
	throw:Char'="""" ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Unterminated string",..Source,..CurrentIndex)
}

Method ProcessCharacter(ByRef Value As %String, ByRef ChunksStart As %Integer) As %Char
{
	set Char = ..GetChar()
	set ..CurrentIndex = ..CurrentIndex + 1
	
	if (Char = "\")
	{
		set Value = ..AppendToValueByCode(..AppendCharactersFromLastChunk(Value, ChunksStart), ..GetChar())
		set ..CurrentIndex = ..CurrentIndex + 1
		set ChunksStart = ..CurrentIndex
	}
	
	return ..GetChar()
}

Method AppendToValueByCode(Value As %String, Char As %Char) As %String
{
	set Case = $case(Char,
		"""": Value = Value_"""",
		"/": Value = Value_"/",
		"\": Value = Value_"\",
		"b": Value = Value_$c(8),
		"f": Value = Value_$c(12),
		"n": Value = Value_$c(10),
		"r": Value = Value_$c(13),
		"t": Value = Value_$c(9),
		"u": Value = Value_..GetUnicodeChar(),
		:##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Invalid character escape sequence: "_Code,..Source,..CurrentIndex))
	throw:$IsObject(Case) Case
	return Case
}

Method GetUnicodeChar()
{
	set Expresion = $Extract(..Source.Body,..CurrentIndex,..CurrentIndex + 5)
	throw:'..OnlyHexInString(Expresion) ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Invalid character escape sequence: "_Expresion,..Source,..CurrentIndex)
	return $zcvt("\u"_..NextChar()_..NextChar()_..NextChar()_..NextChar(), "I", "JSON")
}

Method AppendCharactersFromLastChunk(Value As %String, ChunksStart As %Integer) As %String [ CodeMode = expression ]
{
Value_$Extract(..Source.Body, ChunksStart, ..CurrentIndex - ChunksStart - 1)
}

Method CheckForInvalidCharacters(Char As %Char)
{
	if (($ASCII(Char) < 20) && ($ASCII(Char) '= 9))
	{
		throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Invalid character within String: "_Code,..Source,..CurrentIndex)
	}
}

Method NextChar() As %Char
{
	set ..CurrentIndex = ..CurrentIndex + 1
	if (..IsNotAtTheEndOfQuery()){
		return $Extract(..Source.Body,..CurrentIndex)
	}else{
		return $$$NULL
	}
}

Method GetChar() As %Char
{
	if (..IsNotAtTheEndOfQuery()){
		return $Extract(..Source.Body,..CurrentIndex)
	}else{
		return $$$NULL
	}
}

Method IsNotAtTheEndOfQuery() As %Boolean [ CodeMode = expression ]
{
..CurrentIndex <= $Length(..Source.Body)
}

Method CreateEOFToken() As Token
{
	set Start = ..CurrentIndex
	set End = ..CurrentIndex
	set Kind = $$$EOF
	set Token = ##class(Token).%New(Start, End, Kind)
	return Token
}

Method GetPositionAfterWhitespace(Body As %String, Start As %Integer) As %Integer
{
	set Position = Start

	while( Position < $Length(Body))
	{
		set Char = $Extract(Body, Position)
		
		if (((Char = $c(9)) || (Char = " ") || (Char = $c(10)) || (Char = $c(13)) || (Char = ",")  || ((($Extract(Body, Position) = $c(239))) && ($Extract(Body, Position + 1) = $c(187)) && ($Extract(Body, Position + 2) = $c(191))))) 
		{
			set Position = Position + 1
		}elseif (Char = "#"){
			set position = ..WaitForEndOfComment(Body, Position, Char) 
		}else {
			return Position
		}
	}
	return Position
}

Method WaitForEndOfComment(Body As %String, Position As %Integer, Char As %Char) As %Integer
{
	while((Position < $Length(Body)) && (Char '="") && (($Ascii(Char) > 31) || (Char = $c(9))) && (Char '=$c(10)) && (Char '=$c(13)))
	{
		set Position = Position + 1
		set Char = $Extract(Body, Position)
	}
	return Position
}

Method CheckForPunctuationTokens(Char As %Char) As Token [ CodeMode = expression ]
{
$case(Char,
	"!": ..CreatePunctuationToken($$$BANG, 1),
	"$": ..CreatePunctuationToken($$$DOLLAR, 1),
	"(": ..CreatePunctuationToken($$$PARENL, 1),
	")": ..CreatePunctuationToken($$$PARENR, 1),
	".": ..CheckForSpreadOperator(),
	":": ..CreatePunctuationToken($$$COLON, 1),
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
##class(Token).%New(..CurrentIndex, ..CurrentIndex + Offset, Kind, $$$NULL)
}

Method CreateFloatToken(Start As %Integer) As Token
{
	set End = ..CurrentIndex
	set Kind = $$$FLOAT
	set Value = $Extract(..Source.Body, Start,..CurrentIndex - 2)
	return ##class(Token).%New(Start, End, Kind, Value)
}

Method CreateIntToken(Start As %Integer) As Token
{
	set End = ..CurrentIndex
	set Kind = $$$INT
	set Value = $Extract(..Source.Body, Start,..CurrentIndex - 1)
	return ##class(Token).%New(Start, End, Kind, Value)
}

Method CreateNameToken(Start As %Integer) As Token
{
	set End = ..CurrentIndex
	set Kind = $$$NAME
	set Value = $Extract(..Source.Body, Start, ..CurrentIndex - 1)
	return ##class(Token).%New(Start, End, Kind, Value)
}

Method CheckForSpreadOperator() As Token
{
	set Char1 = $Select($Length(..Source.Body) > (..CurrentIndex + 1): $Extract(..Source.Body, ..CurrentIndex + 1),1: 0)
	set Char2 = $Select($Length(..Source.Body) > (..CurrentIndex + 2): $Extract(..Source.Body, ..CurrentIndex + 2),1: 0)
	if ((Char1 = ".") && (Char2 = "."))
	{
		return ..CreatePunctuationToken($$$SPREAD, 3)
	}
	return
}

Method IfUnicodeGetString() As %String
{
	if (($Length(..Source.Body) > ..CurrentIndex + 5) && ..OnlyHexInString($Extract(..Source.Body,..CurrentIndex + 2, ..CurrentIndex + 5)))
	{
		return $Extract(..Source.Body,..CurrentIndex,..CurrentIndex + 5)
	}
	return $$$NULL
}

Method OnlyHexInString(Text As %String) As %Boolean
{
	return $Match(Text,"\A\b[0-9a-fA-F]+\b\Z")
}

Method ValidateCharacterCode(Char As %Char)
{
	set Code = $ASCII(Char)
	if ((Code < 20) && (Code '= 9) && (Code '= 10) && (Code '= 13))
	{
		throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Invalid character: "_$c(Code),..Source,..CurrentIndex)
	}
}

}

