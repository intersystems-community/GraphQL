Class GraphQL.AST.GraphQLInlineFragment Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property SelectionSet As GraphQLSelectionSet;

Property TypeCondition As GraphQLNamedType;

Method %OnNew(TypeCondition As GraphQLNamedType, Directives As %ListOfObjectsWithClassName, SelectionSet As GraphQLSelectionSet, Location As GraphQL.AST.GraphQLLocation) As %Status
{
	set ..TypeCondition = TypeCondition
	set ..SelectionSet = SelectionSet
	set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)
	
	return $$$OK
}

}

