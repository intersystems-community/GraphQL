Class GraphQL.Location
{

Property Line As %Integer;

Property Column As %Integer;

Method Location(Source As GraphQL.Source, Position As %Integer)
{
	set LineRegex = ##class(%Regex.Matcher).%New($c(13,10)_"|["_$c(10)_$c(13)_"]")
	set ..Line = 1
	set ..Column = Position + 1
	set LineRegex.Text = Source.Body
	
	while LineRegex.Locate()
	{
		set:'$Data(FirstLengh) FirstLengh = LineRegex.End
		if (LineRegex.Start >= Position) break
		
		set ..Line = ..Line + 1
		set ..Column = Position + 1 - (LineRegex.Start + FirstLengh)
	}
}

}

