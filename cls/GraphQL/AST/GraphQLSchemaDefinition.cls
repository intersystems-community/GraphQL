Class GraphQL.AST.GraphQLSchemaDefinition Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property OperationTypes As list Of GraphQLOperationTypeDefinition;

Method %OnNew(Directives As %ListOfObjectsWithClassName, OperationTypes As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)
	do ##class(GraphQL.Utils.Collection).Set(..OperationTypes, OperationTypes)

	return $$$OK
}

}

