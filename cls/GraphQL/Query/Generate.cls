Class GraphQL.Query.Generate
{

/// do ##class(GraphQL.Query.Generate).Start()
ClassMethod Start(ast As GraphQL.AST.GraphQLDocument) As %DynamicObject
{
	k ^genquerygbl
	do ..Definitions(ast.Definitions.GetAt(1))
	set result = {"data":(..GenQuery())}
	
	quit result
}

ClassMethod Definitions(definitions As GraphQL.AST.GraphQLOperationDefinition) As %Status
{
	set sc = $$$OK
	set:'definitions.Directives.%IsNull() sc = ..Directives(definitions.Directives)
	set:'definitions.VariableDefinitions.%IsNull() sc = ..VariableDefinitions(definitions.VariableDefinitions)
	set sc = ..SelectionSet(definitions.SelectionSet)
	
	return sc
}

ClassMethod Directives(directives As GraphQL.AST.GraphQLDirectiveDefinition) As %Status
{
	quit $$$OK
}

ClassMethod VariableDefinitions(variable As GraphQL.AST.GraphQLVariableDefinition) As %Status
{
	quit $$$OK
}

ClassMethod SelectionSet(selectionSet As GraphQL.AST.GraphQLSelectionSet, qnum = "") As %Status
{
	set sc = $$$OK
	set sc = ..Selections(selectionSet.Selections, qnum)
	quit sc
}

ClassMethod Selections(selections As GraphQL.AST.GraphQLFieldSelection, qnum = "") As %Status
{
	set sc = $$$OK
	
	for i=1:1:selections.Size
	{
		if (selections.GetAt(i).SelectionSet '= "")
		{
			set ^genquerygbl(i) = $Replace(selections.GetAt(i).Name.Value,"_",".")
			set sc = ..SelectionSet(selections.GetAt(i).SelectionSet, i)
		}
		elseif ((selections.GetAt(i).SelectionSet = "") && (qnum '= ""))
		{
			set ^genquerygbl(qnum, i) = selections.GetAt(i).Name.Value
		}
	}
	quit sc
}

ClassMethod Arguments(arguments As GraphQL.AST.GraphQLArgument) As %Status
{
	quit $$$OK
}

ClassMethod Alias(alias As GraphQL.AST.GraphQLFieldSelection) As %Status
{
	quit $$$OK
}

/// do ##class(GraphQL.Query.Generate).GenQuery()
ClassMethod GenQuery() As %DynamicArray
{
	#dim result As %DynamicObject = {}
	set key = $Order(^genquerygbl(""))
	while (key '= "")
	{
		merge classAndProperties = ^genquerygbl(key)
		set class = classAndProperties
		set properties = ..GetProperties(.classAndProperties)
		set query = "select top 10 "_properties_" from "_class
		set $Property(result, class) = ..GetQueryResult(query)
		set key = $Order(^genquerygbl(key))
		kill classAndProperties
	}
	quit result
}

ClassMethod GetProperties(properties) As %String
{
	set result = ""
	set key = $Order(properties(""))
	while (key '= "")
	{
		set result = result_properties(key)_","
		set key = $Order(properties(key))
	}
	quit $e(result,1,*-1)
}

ClassMethod GetQueryResult(query) As %DynamicArray
{
	#dim status As %status = $$$OK
	#dim result As %DynamicArray = []
	#dim rs As %SQL.StatementResult = ##class(%SQL.Statement).%ExecDirect(,query)
	return:rs.%SQLCODE'=0 $$$ERROR($$$SQLError, rs.%SQLCODE, rs.%Message)

	set colCount = rs.%ResultColumnCount
	
	#dim metadata As %SQL.StatementMetadata = rs.%GetMetadata() 
	for i = 1:1:colCount {
		set colTypes(i) = metadata.columns.GetAt(i).clientType
		set colName(i) = metadata.columns.GetAt(i).colName
	}

	while rs.%Next(.status)
	{ 
		set fields = {}
		quit:$$$ISERR(status)
		for i = 1:1:colCount 
		{
			if (colTypes(i) = 2) {
				set $Property(fields, colName(i)) = $ZDate(rs.%GetData(i), 3)
			}
			elseif (($ListValid(rs.%GetData(i)) = $$$YES) && (rs.%GetData(i) '="")){
				 set $Property(fields, colName(i)) = $ListToString(rs.%GetData(i),",")
			}else {
				set $Property(fields, colName(i)) = rs.%GetData(i)
			}
		}
		do result.%Push(fields)
	}
	quit result
}

}

