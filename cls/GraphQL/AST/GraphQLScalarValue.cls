Class GraphQL.AST.GraphQLScalarValue Extends GraphQLValue
{

Property KindField As %String;

Property Value As %String;

Method GetValue()
{
	if ..KindField = "StringValue"
	{
		return """"_..Value_""""
	}
	return ..Value
}

}

