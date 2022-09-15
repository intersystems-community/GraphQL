Class GraphQL.AST.GraphQLVariableDefinition Extends ASTNode
{

Property Variable As GraphQLVariable;

Property Type As GraphQLType;

Property DefaultValue As %RegisteredObject;

Method %OnNew(Variable As GraphQLVariable, Type As GraphQLType, DefaultValue As %RegisteredObject, Location As GraphQL.AST.GraphQLLocation) As %Status
{
	set ..Variable = Variable
	set ..Type = Type
	set ..DefaultValue = DefaultValue
	set ..Location = Location
	
	return $$$OK
}

}

