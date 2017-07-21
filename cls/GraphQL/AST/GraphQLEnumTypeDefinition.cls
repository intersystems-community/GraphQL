Class GraphQL.AST.GraphQLEnumTypeDefinition Extends GraphQLTypeDefinition
{

Property Name As GraphQLName;

Property Directives As list Of GraphQLDirective;

Property Values As list Of GraphQLEnumValueDefinition;

Method %OnNew(Name As GraphQLName, Directives As %ListOfObjectsWithClassName, Values As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	
	do ##class(GraphQL.Utils).SetCollection(..Directives, Directives)
	do ##class(GraphQL.Utils).SetCollection(..Values, Values)
	
	return $$$OK
}

}

