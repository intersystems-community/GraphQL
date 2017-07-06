Class GraphQL.Source
{

Property Name As %String;

Property Body As %String;

Method Source(Body As %String, Name As %String = "GraphQL")
{
	set ..Name = Name
	if $Data(Body)
	{
		set ..Body = $Replace($Replace(Body,$c(13,10),$c(10)),$c(13), $c(10))
	}else{
		set ..Body = ""
	}
}

}

