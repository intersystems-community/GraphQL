Class GraphQL.AST.GraphQLNonNullType Extends GraphQLType
{

Property Type As GraphQLType;

Method %OnNew(Type As GraphQLType, Location As GraphQLLocation) As %Status
{
	set ..Type = Type
	set ..Location = Location
	return $$$OK
}

Method GetType() As GraphQLType
{
	Return ..Type_"!"
}

}

