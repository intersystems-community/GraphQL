Class GraphQL.Source Extends %RegisteredObject
{

Property Name As %String;

Property Body As %String;

Method %OnNew(Body As %String, Name As %String = "GraphQL") As %Status
{
	set ..Name = Name
	if $Data(Body)
	{
		set ..Body = $Replace($Replace(Body,$c(13,10),$c(10)) ,$c(13),$c(10))
	}else{
		set ..Body = ""
	}
	return $$$OK
}

}

