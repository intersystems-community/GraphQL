Class GraphQL.AST.GraphQLObjectValue Extends GraphQLValue
{

Property Fields As list Of GraphQLObjectField;

Method %OnNew(Fileds As %ListOfObjectsWithClassName, Location As GraphQL.AST.GraphQLLocation) As %Status
{
	set ..Location = Location
	set ..Fields = Fileds
	quit $$$OK
}

}

