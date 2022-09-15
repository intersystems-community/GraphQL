Class GraphQL.Utils.Arguments Extends %RegisteredObject
{

Property ArgsCount As %Integer [ InitialExpression = 0 ];

Method Get(ast As GraphQL.AST.GraphQLDocument, Output args) As %Status
{
	set selectionSet = ast.Definitions.GetAt(1).SelectionSet
	set args = 0
	do ..SelectionSet(selectionSet, .args)
	return args
}

Method SelectionSet(selectionSet As GraphQL.AST.GraphQLSelectionSet, Output args) As %Status
{
	set sc = $$$OK
	set sc = ..Selections(selectionSet.Selections,.args)
	quit sc
}

Method Selections(selections As %ListOfObjectsWithClassName, Output args) As %Status
{
	set sc = $$$OK
	
	for i=1:1:selections.Size
	{
		set selection = selections.GetAt(i)
		set arguments = selection.Arguments
		
		if (selection.SelectionSet '= "")
		{
			set:'arguments.%IsNull() sc = ..Arguments(arguments,.args)
			set sc = ..SelectionSet(selection.SelectionSet,.args)
		}
	}
	quit sc
}

Method Arguments(arguments As GraphQL.AST.GraphQLArgument, Output args) As %Status
{
	for i=1:1:arguments.Size
	{
		set ..ArgsCount = ..ArgsCount + 1
		set argument = arguments.GetAt(i)
	
		set args = ..ArgsCount
		set args(..ArgsCount) = argument.Value.Value
	}
	quit $$$OK
}

}

