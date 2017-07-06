Class GraphQL.Token
{

Parameter EOF = 1;

Parameter BANG = 2;

Parameter DOLLAR = 3;

Parameter PARENL = 4;

Parameter PARENR = 5;

Parameter SPREAD = 6;

Parameter COLON = 7;

Parameter EQUALS = 8;

Parameter AT = 9;

Parameter BRACKETL = 10;

Parameter BRACKETR = 11;

Parameter BRACEL = 12;

Parameter PIPE = 13;

Parameter BRACER = 14;

Parameter NAME = 15;

Parameter INT = 16;

Parameter FLOAT = 17;

Parameter STRING = 18;

Property Start As %Integer;

Property End As %Integer;

Property Value As %String;

Property TokenKind;

Method GetTokenKindDescription(TokenKind) [ CodeMode = expression ]
{
$case(TokenKind,
	..#EOF:"EOF",
	..#BANG:"!",
	..#DOLLAR:"$",
	..#PARENL:"(",
	..#PARENR:")",
	..#SPREAD:"...",
	..#COLON:":",
	..#EQUALS:"=",
	..#AT:"@",
	..#BRACKETL:"[",
	..#BRACKETR:"]",
	..#BRACEL:"{",
	..#PIPE:"|",
	..#BRACER:"}",
	..#NAME:"Name",
	..#INT:"Int",
	..#FLOAT:"Float",
	..#STRING:"String",
	:"")
}

Method GetKind()
{
	if ..Value '= ""
	{
		return ..GetTokenKindDescription(..TokenKind)_" """_..Value_""""
	}else{
		return ..GetTokenKindDescription(..TokenKind)
	}
}

}

