Include GraphQLUtils

Class GraphQL.Query.GenerateClass Extends %RegisteredObject
{

Property Select As %String;

Property From As %String;

Property Row As %String;

Property Class As %Dictionary.ClassDefinition;

Property QueryName As %String;

Property ClassList As list Of %Dictionary.CacheClassname;

Property QueryCount As %Integer [ InitialExpression = 0 ];

Property FieldCount As list Of %Integer;

Property IsFirstField As %Boolean [ InitialExpression = {$$$YES} ];

Method %OnNew(classname As %Dictionary.CacheClassname) As %Status [ Private, ServerOnly = 1 ]
{
	set ..Class = ..GenerateClass(classname)
	quit $$$OK
}

ClassMethod GenerateClass(classname As %Dictionary.CacheClassname) As %Dictionary.ClassDefinition
{
	do ##class(%Dictionary.ClassDefinition).%DeleteId(classname)
	set class = ##class(%Dictionary.ClassDefinition).%New(classname)
	
	set method = ##class(%Dictionary.MethodDefinition).%New()
	set method.Name = "Execute"
	set method.ClassMethod = $$$YES
	set method.ReturnType = "%DynamicObject"
	
	do method.Implementation.WriteLine($$$TAB _ "set result = {""data"":{}}")
	
	do class.Methods.Insert(method)	
	quit class
}

Method GenerateQueryCode()
{
	#dim method As %Dictionary.MethodDefinition
	set method = ..Class.Methods.GetAt(1)
	
	#dim code As %Stream.TmpCharacter
	set code = method.Implementation
	do code.WriteLine($$$TAB _ "set query" _ ..QueryCount _" = []")	
	do code.WriteLine($$$TAB _ "&sql(DECLARE C" _ ..QueryCount _" CURSOR FOR")
	do code.WriteLine($$$TAB _ $$$TAB _" SELECT TOP 10 " _ ..Select)
	
	do code.Write($$$TAB _ $$$TAB _ " INTO ")
	for i = 1:1:..FieldCount.GetAt(..QueryCount) {	
		do code.Write($select(i>1:"," ,1:"") _ ":f" _ i)
	}
	do code.WriteLine()
	
	do code.WriteLine($$$TAB _$$$TAB _ " FROM " _ ..From _ ")")
	do code.WriteLine($$$TAB _ "&sql(OPEN C" _ ..QueryCount _ ")")
	do code.WriteLine($$$TAB _ "&sql(FETCH C" _ ..QueryCount _ ")")
	do code.WriteLine($$$TAB _ "While (SQLCODE = 0) {")
	do code.WriteLine($$$TAB _ $$$TAB _ "do query"_..QueryCount _ ".%Push(" _ ..Row _ ")")
	do code.WriteLine($$$TAB _ $$$TAB _ "&sql(FETCH C" _ ..QueryCount _ ")")
	do code.WriteLine($$$TAB _ "}")
	do code.WriteLine($$$TAB _ "&sql(CLOSE C" _ ..QueryCount _ ")")
	do code.WriteLine($$$TAB _ "set result.data.""" _ ..QueryName _ """ = query" _ ..QueryCount)
	do code.WriteLine()
}

Method GenerateFinalCode()
{
	do ..Class.Methods.GetAt(1).Implementation.WriteLine($$$TAB _ "quit result")
	
	set method = ##class(%Dictionary.MethodDefinition).%New()
	set method.Name = "IsUpToDate"
	set method.ClassMethod = $$$YES
	set method.ReturnType = "%Boolean"
	
	#dim code As %Stream.TmpCharacter
	set code = method.Implementation
	
	for i=1:1:..ClassList.Count() {
		set classname = ..ClassList.GetAt(i)
		do code.WriteLine($$$TAB _ "quit:$$$comClassKeyGet(""" _ classname _ """,$$$cCLASShash)'=""" _ $$$comClassKeyGet(classname,$$$cCLASShash) _""" $$$NO")
	}
	do code.WriteLine($$$TAB _ "quit $$$YES")
	
	do ..Class.Methods.Insert(method)
}

/// w ##class(GraphQL.Query.GenerateClass).Generate(ast)
ClassMethod Generate(ast As GraphQL.AST.GraphQLDocument) As %Status
{
	set classname = ##class(GraphQL.Query.Executor).GetQueryClassname(ast)
	set generator = ..%New(classname)
	set sc = generator.Definitions(ast.Definitions.GetAt(1))
	quit:$$$ISERR(sc) sc
	
	do generator.GenerateFinalCode()
	set sc = generator.Class.%Save()
	quit:$$$ISERR(sc) sc
	
	kill generator
	
	set sc = $system.OBJ.Compile(classname, "cuks /checkuptodate=expandedonly /displaylog=0 /displayerror=0")	
	quit sc
}

Method Definitions(definitions As GraphQL.AST.GraphQLOperationDefinition) As %Status
{
	set sc = $$$OK
	set:'definitions.Directives.%IsNull() sc = ..Directives(definitions.Directives)
	set:'definitions.VariableDefinitions.%IsNull() sc = ..VariableDefinitions(definitions.VariableDefinitions)
	set sc = ..SelectionSet(definitions.SelectionSet)
	
	return sc
}

Method Directives(directives As GraphQL.AST.GraphQLDirectiveDefinition) As %Status
{
	quit $$$OK
}

Method VariableDefinitions(variable As GraphQL.AST.GraphQLVariableDefinition) As %Status
{
	quit $$$OK
}

Method SelectionSet(selectionSet As GraphQL.AST.GraphQLSelectionSet, classname = "", path = "") As %Status
{
	set sc = $$$OK
	set sc = ..Selections(selectionSet.Selections, classname, path)
	quit sc
}

Method StartQuery(queryname As %String, classname As %Dictionary.ClassDefinition)
{
	do ..ClassList.Insert(classname)
	set ..QueryName = queryname
	set ..From = ##class(%CSP.UI.Portal.SQL.Home).Quoter2($$$ClassSQLTable(classname))
	set ..Select = ""
	set ..Row = "{"
	
	set ..IsFirstField = $$$YES
	set ..QueryCount = ..QueryCount + 1
	do ..FieldCount.Insert(0)
}

Method EndQuery()
{
	set ..Row = ..Row _ "}"
	//do ..DisplayQuery()
	do ..GenerateQueryCode()
}

Method DisplayQuery()
{
	Write "SELECT: ", ..Select,!
	Write "ROW: ", ..Row,!
	Write "FROM: ",..From,!
	Write "FieldCount: ",..FieldCount.GetAt(..QueryCount),!,!
}

Method StartObject(propertyName As %String)
{
	set fieldCount = ..FieldCount.GetAt(..QueryCount)
	if fieldCount > 0 {
		set ..Row = ..Row _ ", "
	}
	set ..Row =  ..Row _ """" _ propertyName _ """:{"
	set ..IsFirstField = $$$YES
}

Method EndObject(classname As %Dictionary.ClassDefinition)
{
	set ..Row = ..Row _ "}"
	set ..IsFirstField = $$$NO
}

Method AppendField(name As %String, classname As %Dictionary.ClassDefinition, path As %String = "")
{
	set fieldCount = ..FieldCount.GetAt(..QueryCount) + 1
	if ..IsFirstField {
		set ..IsFirstField = $$$NO
	} else {
		set ..Row = ..Row _ ", "
	}
	
	if fieldCount>1 {
		set ..Select = ..Select _ ", "
	}
	set collection = $$$comMemberKeyGet(classname,$$$cCLASSproperty,name,$$$cPROPcollection)
	set type = $$$comMemberKeyGet(classname,$$$cCLASSproperty,name,$$$cPROPtype)
	
	set field = "f" _ fieldCount
	
	if collection="" {
		if type = "%Library.Date" {
			set field = " $ZDate(" _ field _ ", 3)"
		}
		
		set ..Row =  ..Row _ """" _ name _ """:(" _ field _ ")"
	} else {
		/// TODO arrays
		/// TODO lists of dates
		set ..Row =  ..Row _ """" _ name _ """:(##class(GraphQL.Utils.SQL).ListToArray(" _ field _ "))"
	}
	
	set ..Select = ..Select _ path _ $select(path'="":"_" ,1:"") _ name
	
	do ..FieldCount.SetAt(fieldCount, ..QueryCount)
}

Method Selections(selections As %ListOfObjectsWithClassName, classname = "", path As %String = "") As %Status
{
	set sc = $$$OK
	
	for i=1:1:selections.Size
	{
		set selection = selections.GetAt(i)
		if (selection.SelectionSet '= "")
		{
			if (classname = "") 
			{
				// tables
				set queryName = selection.Name.Value
				set queryClassname = $Replace(queryName,"_",".")
				do ..StartQuery(queryName, queryClassname)
				set sc = ..SelectionSet(selection.SelectionSet, queryClassname)
				do ..EndQuery()
			} else {
				// object fields
				set propertyName = selection.Name.Value
				set propertyType = $$$comMemberKeyGet(classname,$$$cCLASSproperty,propertyName,$$$cPROPtype)
				do ..StartObject(propertyName)
				set sc = ..SelectionSet(selection.SelectionSet, classname, path _ $select(path'="":"_" ,1:"") _ propertyName)
				do ..EndObject()
			}
		}
		elseif ((selection.SelectionSet = "") && (classname '= ""))
		{
			// datatype fields
			do ..AppendField(selection.Name.Value, classname, path)
		}
	}
	quit sc
}

Method Arguments(arguments As GraphQL.AST.GraphQLArgument) As %Status
{
	quit $$$OK
}

Method Alias(alias As GraphQL.AST.GraphQLFieldSelection) As %Status
{
	quit $$$OK
}

}

