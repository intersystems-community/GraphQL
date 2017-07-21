Class GraphQL.AST.GraphQLScalarTypeDefinition Extends GraphQLTypeDefinition
{

Property Name As GraphQLName;

Property Directives As list Of GraphQLDirective;

Method %OnNew(Name As GraphQLName, Directives As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	
	do ##class(GraphQL.Utils).SetCollection(..Directives, Directives)
	
	return $$$OK
}

}

