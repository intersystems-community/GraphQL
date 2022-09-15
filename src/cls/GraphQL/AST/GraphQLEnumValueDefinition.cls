Class GraphQL.AST.GraphQLEnumValueDefinition Extends GraphQLTypeDefinition
{

Property Directives As list Of GraphQLDirective;

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Directives As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)

	return $$$OK
}

}

