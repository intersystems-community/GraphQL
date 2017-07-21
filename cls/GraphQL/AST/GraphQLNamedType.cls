Class GraphQL.AST.GraphQLNamedType Extends GraphQLType
{

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	return $$$OK
}

Method GetValue()
{
	return ..Name.Value
}

}

