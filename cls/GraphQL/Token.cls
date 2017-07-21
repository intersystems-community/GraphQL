Include Tokens

Class GraphQL.Token
{

Property Start As %Integer;

Property End As %Integer;

Property Value As %String;

Property Kind;

Method %OnNew(Start As %Integer, End As %Integer, Kind, Value As %String) As %Status
{
	set ..Start = Start
	set ..End = End
	set ..Kind = Kind
	set ..Value = Value
	return $$$OK
}

ClassMethod GetTokenKindDescription(TokenKind) [ CodeMode = expression ]
{
$case(TokenKind,
	$$$EOF:"EOF",
	$$$BANG:"!",
	$$$DOLLAR:"$",
	$$$PARENL:"(",
	$$$PARENR:")",
	$$$SPREAD:"...",
	$$$COLON:":",
	$$$EQUALS:"=",
	$$$AT:"@",
	$$$BRACKETL:"[",
	$$$BRACKETR:"]",
	$$$BRACEL:"{",
	$$$PIPE:"|",
	$$$BRACER:"}",
	$$$NAME:"Name",
	$$$INT:"Int",
	$$$FLOAT:"Float",
	$$$STRING:"String",
	:"")
}

Method GetKind()
{
	if ..Value '= ""
	{
		return ..GetTokenKindDescription(..Kind)_" """_..Value_""""
	}else{
		return ..GetTokenKindDescription(..Kind)
	}
}

}

