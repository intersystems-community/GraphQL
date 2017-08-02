Class GraphQL.AST.GraphQLInterfaceTypeDefinition Extends GraphQLTypeDefinition
{

Property Directives As list Of GraphQLDirective;

Property Fields As list Of GraphQLFieldDefinition;

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Directives As %ListOfObjectsWithClassName, Fields As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)
	do ##class(GraphQL.Utils.Collection).Set(..Fields, Fields)

	return $$$OK
}

}

