Class GraphQL.AST.GraphQLDirectiveDefinition Extends GraphQLTypeDefinition
{

Property Arguments As list Of GraphQLInputValueDefinition;

Property Definitions As list Of GraphQLInputValueDefinition;

Property Locations As list Of GraphQLName;

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Arguments As %ListOfObjectsWithClassName, Locations As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	do ##class(GraphQL.Utils.Collection).Set(..Arguments, Arguments)
	do ##class(GraphQL.Utils.Collection).Set(..Locations, Locations)
	return $$$OK
}

}

