Class GraphQL.AST.GraphQLDocument Extends ASTNode
{

Property Definitions As list Of ASTNode;

Method %OnNew(Location As GraphQLLocation, Definitions As %ListOfObjectsWithClassName) As %Status
{
 	set ..Location = Location
 	return ##class(GraphQL.Utils.Collection).Set(..Definitions, Definitions)
}

}

