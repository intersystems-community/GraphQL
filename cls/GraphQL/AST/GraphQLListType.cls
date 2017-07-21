Class GraphQL.AST.GraphQLListType Extends GraphQLType
{

Property Type As GraphQLType;

Method %OnNew(Type As GraphQLType, Location As GraphQLLocation) As %Status
{
	set ..Type = Type
	set ..Location = Location
	return $$$OK
}

}

