Class GraphQL.AST.GraphQLName Extends ASTNode
{

Property Value As %String(MAXLEN = "");

Method %OnNew(Location As GraphQLLocation, Value As %String) As %Status
{
	set ..Location = Location
	set ..Value = Value
	
	return $$$OK
}

}

