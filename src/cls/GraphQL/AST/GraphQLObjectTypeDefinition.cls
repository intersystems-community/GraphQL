Class GraphQL.AST.GraphQLObjectTypeDefinition Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property Fields As list Of GraphQLFieldDefinition;

Property Interfaces As list Of GraphQLNamedType;

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Interfaces As %ListOfObjectsWithClassName, Directives As %ListOfObjectsWithClassName, Fields As %ListOfObjectsWithClassName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	
	do ##class(GraphQL.Utils.Collection).Set(..Interfaces, Interfaces)
	do ##class(GraphQL.Utils.Collection).Set(..Directives, Directives)
	do ##class(GraphQL.Utils.Collection).Set(..Fields, Fields)

	return $$$OK
}

}

