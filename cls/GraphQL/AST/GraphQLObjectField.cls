Class GraphQL.AST.GraphQLObjectField Extends ASTNode
{

Property Name As GraphQLName;

Property Value As GraphQLValue;

Method %OnNew(Name As GraphQLName, Value As GraphQLValue, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Value = Value
	set ..Location = Location
	return $$$OK
}

}

