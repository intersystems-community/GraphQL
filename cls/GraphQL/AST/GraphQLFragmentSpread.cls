Class GraphQL.AST.GraphQLFragmentSpread Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Directives As %ListOfObjectsWithClassName, Location As GraphQL.AST.GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	do ##class(GraphQL.Utils).SetCollection(..Directives, Directives)
	return $$$OK
}

}

