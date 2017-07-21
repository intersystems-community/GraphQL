Class GraphQL.AST.GraphQLListValue Extends GraphQLValue
{

Property KindField As %String;

Property AstValue As %String;

Property Values As list Of GraphQLValue;

Method %OnNew(KindField As %String, Location As %Integer, AstValue As %String, Values As %ListOfObjectsWithClassName) As %Status
{
	set ..KindField = KindField
	set ..Location = Location
	set ..AstValue = AstValue
	do ##class(GraphQL.Utils).SetCollection(..Values, Values)
	quit $$$OK
}

}

