Include GraphQLUtils

Class GraphQL.Query.Validation Extends GraphQL.Scope.All
{

/// do ##class(GraphQL.Query.Validation).Valid()
ClassMethod Valid(ast As GraphQL.AST.GraphQLDocument) As %Status
{
	set sc = $$$OK
	
	if ('ast.Definitions.%IsNull())
	{
		set sc = ..Definitions(ast.Definitions.GetAt(1))
	}else{
		w "Empty query"
		quit $$$OK
	}
	quit sc
}

ClassMethod Definitions(definitions As GraphQL.AST.GraphQLOperationDefinition) As %Status
{
	set sc = $$$OK
	set:'definitions.Directives.%IsNull() sc = ..Directives(definitions.Directives)
	set:'definitions.VariableDefinitions.%IsNull() sc = ..VariableDefinitions(definitions.VariableDefinitions)
	quit:definitions.SelectionSet="" $$$ERROR($$$GeneralError,"SelectionSet is empty")
	set sc = ..SelectionSet(definitions.SelectionSet)
	
	quit sc
}

ClassMethod Directives(directives As GraphQL.AST.GraphQLDirectiveDefinition) As %Status
{
	quit $$$OK
}

ClassMethod VariableDefinitions(variable As GraphQL.AST.GraphQLVariableDefinition) As %Status
{
	quit $$$OK
}

ClassMethod SelectionSet(selectionSet As GraphQL.AST.GraphQLSelectionSet, className As %String = "") As %Status
{
	set sc = $$$OK
	quit:selectionSet.Selections.%IsNull() $$$ERROR($$$GeneralError,"Properties for class '"_className_"'not specified")
	set sc = ..Selections(selectionSet.Selections, className)
	quit sc
}

ClassMethod Selections(selections As GraphQL.AST.GraphQLFieldSelection, className As %String = "") As %Status
{
	set sc = $$$OK
	
	for i=1:1:selections.Size
	{	
		if (((selections.GetAt(i).SelectionSet '= $$$NULL) && (className = $$$NULL)))
		{
			set newClassName = selections.GetAt(i).Name.Value
			set sc = ..ValidClassName(newClassName)
			set sc = ..ArgsAliasDirectives(selections, newClassName, i)
			quit:'sc
			set sc = ..SelectionSet(selections.GetAt(i).SelectionSet, newClassName)
		}
		elseif ((selections.GetAt(i).SelectionSet '= $$$NULL) && (className '= $$$NULL)){
			set classObject = selections.GetAt(i).Name.Value
			set newClassName = className
			set sc = ..ValidClassObjectName(className, classObject, .propertyType)
			set sc = ..ArgsAliasDirectives(selections, newClassName, i)
			quit:'sc  
			set sc = ..SelectionSet(selections.GetAt(i).SelectionSet, propertyType)
		}
		elseif ((selections.GetAt(i).SelectionSet = $$$NULL) && (className '= $$$NULL)){
			set propertyName = selections.GetAt(i).Name.Value
			continue:$zcvt(propertyName, "U")="ID"
			set sc = ..ValidClassProperties(propertyName, className)
			quit:'sc 
		}else{
			return $$$ERROR($$$GeneralError,"No")
		}
	}
	quit sc
}

ClassMethod ArgsAliasDirectives(selections As GraphQL.AST.GraphQLFieldSelection, className As %String = "", i As %Integer) As %Status
{
	set sc = $$$OK
	set:selections.GetAt(i).Alias'=$$$NULL sc = ..Alias(selections.GetAt(i).Alias)
	set:'selections.GetAt(i).Arguments.%IsNull() sc = ..Arguments(selections.GetAt(i).Arguments, $Replace(className,"_","."))
	set:'selections.GetAt(i).Directives.%IsNull() sc = ..Directives(selections.GetAt(i).Directives)
	quit sc
}

ClassMethod Arguments(arguments As GraphQL.AST.GraphQLArgument, className As %String) As %Status
{
	set sc = $$$OK
	set modifier = $LB("first", "last", "after", "before")
	
	for i=1:1:arguments.Size
	{	
		set argument = arguments.GetAt(i)
		set argName = argument.Name.Value
		set argValue = argument.Value.Value
		
		if ($ListFind(modifier, argName)>0) && ($IsValidNum(argValue, 0))
		{
			continue
		}elseif ($ListFind(modifier, argName)>0) && ('$IsValidNum(argValue, 0))
		{
			return $$$ERROR($$$GeneralError,"Argument '"_argName_"' is not valid in class "_className)
		}

		continue:$zcvt(argName, "U")="ID"
		
		set propExist = ##class(%Dictionary.CompiledPropertyMethod).IDKEYExists(className_"||"_argName, "IsValid")
		return:'propExist $$$ERROR($$$GeneralError,"Property name '"_argName_"' does not exist in class "_className)
		
		if ##class(%Dictionary.CompiledPropertyMethod).IDKEYExists(className_"||"_argName, "OdbcToLogical")
		{
			set storedArgValue = $classmethod(className, argName_"OdbcToLogical", argValue)	
		}else{
			set storedArgValue = argValue
		}
		
		set sc = $classmethod(className, argName_"IsValid", storedArgValue)
		return:'sc $$$ADDSC(sc, $$$ERROR($$$GeneralError,"Argument '"_argName_"' is not valid in class "_className))
	}

	quit sc
}

ClassMethod Alias(alias As GraphQL.AST.GraphQLFieldSelection) As %Status
{
	quit $$$OK
}

ClassMethod ValidClassName(className As %String) As %Status
{
	set listOfClass = ..GetClasses()
	quit:$ListFind(listOfClass, $Replace(className,"_","."))=0 $$$ERROR($$$GeneralError,"Class '"_className_"' does not exist.")
	quit $$$OK
}

ClassMethod ValidClassObjectName(className As %String, propertyName As %String, Output propertyType) As %Status
{
	set propertyType = $$$comMemberKeyGet($Replace(className,"_","."),$$$cCLASSproperty,propertyName,$$$cPROPtype)
	quit:propertyType="" $$$ERROR($$$GeneralError,"Property '"_propertyName_"' does not exist in class '"_className_"' or class type for this property.")
	quit $$$OK
}

ClassMethod ValidClassProperties(propertyName As %String, className As %String) As %Status
{
	set listOfProperties = ..GetProperties($Replace(className,"_","."))
	quit:$ListFind(listOfProperties, $Replace(propertyName,"_","."))=0 $$$ERROR($$$GeneralError,"Property '"_propertyName_"' does not exist in class '"_className_"'.")
	quit $$$OK
}

}

