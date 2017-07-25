Class GraphQL.AST.GraphQLFragmentDefinition Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property SelectionSet As GraphQLSelectionSet;

Property TypeCondition As GraphQLNamedType;

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, TypeCondition As GraphQLNamedType, Directives As %ListOfObjectsWithClassName, SelectionSet As GraphQLSelectionSet, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..TypeCondition = TypeCondition
	set ..SelectionSet = SelectionSet
	set ..Location = Location
	do ##class(GraphQL.Utils).SetCollection(..Directives, Directives)
	return $$$OK
}

}

