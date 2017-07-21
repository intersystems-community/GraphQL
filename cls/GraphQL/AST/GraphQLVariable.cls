Class GraphQL.AST.GraphQLVariable Extends (%SerialObject, GraphQLValue)
{

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	return $$$OK
}

Storage Default
{
<Data name="GraphQLVariableState">
<Value name="1">
<Value>Kind</Value>
</Value>
<Value name="2">
<Value>Location</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
</Data>
<State>GraphQLVariableState</State>
<StreamLocation>^GraphQL.AST.GraphQLVariableS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}

