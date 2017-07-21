Class GraphQL.AST.GraphQLLocation Extends %SerialObject
{

Property End As %Integer(MINVAL = 0);

Property Start As %Integer(MINVAL = 0);

Method %OnNew(Start As %Integer, End As %Integer) As %Status
{
	set ..Start = Start
	set ..End = End
	
	return $$$OK
}

Storage Default
{
<Data name="GraphQLLocationState">
<Value name="1">
<Value>End</Value>
</Value>
<Value name="2">
<Value>Start</Value>
</Value>
</Data>
<State>GraphQLLocationState</State>
<StreamLocation>^GraphQL.AST.GraphQLLocationS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}

