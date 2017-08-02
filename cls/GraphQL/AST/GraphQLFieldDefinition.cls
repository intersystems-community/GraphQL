Class GraphQL.AST.GraphQLFieldDefinition Extends GraphQLTypeDefinition
{

Property Name As GraphQLName;

Property Type As GraphQLType;

Property Arguments As list Of GraphQLInputValueDefinition;

Property Directives As list Of GraphQLDirective;

Method %OnNew(Name As GraphQLName, Type As GraphQLType, Arguments As %ListOfObjectsWithClassName, Directives As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Type = Type
	Set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Arguments, Arguments)
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)
	
	return $$$OK
}

}

