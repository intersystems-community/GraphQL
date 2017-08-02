Class GraphQL.AST.GraphQLVariable Extends GraphQLValue
{

Property Name As GraphQLName;

Method %OnNew(Name As GraphQLName, Location As GraphQLLocation) As %Status
{
	set ..Name = Name
	set ..Location = Location
	return $$$OK
}

}

