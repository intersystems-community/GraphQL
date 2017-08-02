Class GraphQL.AST.GraphQLLocation Extends %RegisteredObject
{

Property End As %Integer(MINVAL = 0);

Property Start As %Integer(MINVAL = 0);

Method %OnNew(Start As %Integer, End As %Integer) As %Status
{
	set ..Start = Start
	set ..End = End
	
	return $$$OK
}

}

