Class GraphQL.AST.GraphQLOperationTypeDefinition Extends ASTNode
{

Property Operation As %Integer;

Property Type As GraphQLNamedType;

Method %OnNew(Operation As %String, Type As GraphQLNamedType, Location As GraphQLLocation) As %Status
{
	set ..Operation = Operation
	set ..Type = Type
	set ..Location = Location
	return $$$OK
}

}

