Class GraphQL.AST.GraphQLFieldSelection Extends ASTNode
{

Property Name As GraphQLName;

Property Alias As GraphQLName;

Property Arguments As list Of GraphQLArgument;

Property Directives As list Of GraphQLDirective;

Property SelectionSet As GraphQLSelectionSet;

Method %OnNew(Name As GraphQLName, Alias As GraphQLName = "", Arguments As %ListOfObjectsWithClassName, Directives As %ListOfObjectsWithClassName, SelectionSet As GraphQLSelectionSet = "", Location As GraphQL.AST.GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Alias = Alias
	set ..Location = Location
	
	do ##class(GraphQL.Utils).SetCollection(..Arguments, Arguments)
	do ##class(GraphQL.Utils).SetCollection(..Directives, Directives)
	set:SelectionSet'="" ..SelectionSet = SelectionSet 
	
	return $$$OK
}

}

