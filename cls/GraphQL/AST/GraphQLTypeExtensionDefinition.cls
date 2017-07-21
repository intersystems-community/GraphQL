Class GraphQL.AST.GraphQLTypeExtensionDefinition Extends GraphQLTypeDefinition
{

Property Definition As GraphQLObjectTypeDefinition;

Method %OnNew(Definition As GraphQLObjectTypeDefinition, Location As GraphQLLocation) As %Status
{
	set ..Definition = Definition
	set ..Location = Location
	return $$$OK
}

}

