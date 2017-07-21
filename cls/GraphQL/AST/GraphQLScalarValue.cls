Class GraphQL.AST.GraphQLScalarValue Extends GraphQLValue
{

Property KindField As %Integer;

Property Value As %String;

Method %OnNew(Kind As %Integer, Value As %String, Location As GraphQLLocation) As %Status
{
	set ..KindField = Kind
	set ..Value = Value
	set ..Location = Location
	return $$$OK
}

Method GetValue()
{
	if ..KindField = "StringValue"
	{
		return """"_..Value_""""
	}
	return ..Value
}

}

