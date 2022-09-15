Class GraphQL.AST.GraphQLUnionTypeDefinition Extends GraphQLTypeDefinition
{

Property Name As GraphQLName;

Property Directives As list Of GraphQLDirective;

Property Types As list Of GraphQLNamedType;

Method %OnNew(Name As GraphQLName, Directives As %ListOfObjectsWithClassName, Types As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)
	do ##class(GraphQL.Utils.Collection).Set(..Types, Types)

	return $$$OK
}

}

