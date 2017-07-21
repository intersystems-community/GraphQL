Class GraphQL.AST.GraphQLInputValueDefinition Extends GraphQL.AST.GraphQLTypeDefinition
{

Property DefaultValue As GraphQLValue;

Property Directives As list Of GraphQLDirective;

Property Name As GraphQLName;

Property Type As GraphQLType;

Method %OnNew(Name As GraphQLName, Type As GraphQLType, DefaultValue As GraphQLValue, Directives As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Type = Type
	set ..DefaultValue = DefaultValue
	set ..Location = Location
	
	do ##class(GraphQL.Utils).SetCollection(..Directives, Directives)

	return $$$OK
}

}

