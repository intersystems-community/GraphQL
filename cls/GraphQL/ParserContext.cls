Include GraphQLUtils

Class GraphQL.ParserContext Extends %RegisteredObject
{

Property CurrentToken As Token;

Property Lexer As Lexer;

Property Source As Source;

Method %OnNew(Source As Source, Lexer As Lexer) As %Status
{
	set ..Source = Source
	set ..Lexer = Lexer
	set ..CurrentToken = ..Lexer.Lex(Source)
	return $$$OK
}

Method Parse() As GraphQL.AST.GraphQLDocument [ CodeMode = expression ]
{
..ParseDocument()
}

Method ParseDocument() As GraphQL.AST.GraphQLDocument
{
	set Start = ..CurrentToken.Start
	set Definitions = ..ParseDefinitionsIfNotEOF() // done
	
	return ..CreateDocument(Start, Definitions)
}

Method ParseDefinitionsIfNotEOF() As %ListOfObjectsWithClassName
{
	set Definitions = ##class(%ListOfObjectsWithClassName).%New()
	if (..CurrentToken.Kind '= $$$EOF)
	{
		do 
		{
			do Definitions.Insert(..ParseDefinition())
		}
		while('..Skip($$$EOF))
	}
	return Definitions
}

Method CreateDocument(Start As %Integer, Definitions As %ListOfObjectsWithClassName) As GraphQL.AST.GraphQLDocument
{
	set Location = ##class(GraphQL.AST.GraphQLLocation).%New(Start,..CurrentToken.End)
	return ##class(GraphQL.AST.GraphQLDocument).%New(Location,Definitions)
}

Method ParseDefinition() As GraphQL.AST.ASTNode
{
	if (..Peek($$$BRACEL))
	{
		return ..ParseOperationDefinition() //here
	}
	if (..Peek($$$NAME))
	{
		set ParseNamedDefinition = ..ParseNamedDefinition()
		return $Get(ParseNamedDefinition)
	}
	throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Unexpected "_..CurrentToken_": "_NextChar,..Source,..CurrentToken.Start)
}

Method Peek(Kind) As %Boolean [ CodeMode = expression ]
{
$Select(..CurrentToken.Kind = Kind:$$$YES, 1:$$$NO)
}

Method ParseOperationDefinition() As GraphQL.AST.ASTNode
{
	set Start = ..CurrentToken.Start
	
	if (..Peek($$$BRACEL))
	{
		return ..CreateOperationDefinition(Start)	//here
	}
	return ..CreateOperationDefinition(Start,..ParseOperationType(), ..GetName())
}

Method CreateOperationDefinition(Start As %Integer, Operation As %Integer = {$$$NULL}, Name As GraphQL.AST.GraphQLName = {$$$NULL})
{
	set Definition = ##class(GraphQL.AST.GraphQLOperationDefinition).%New()
	
	if ((Operation '= "") && (Name '= ""))
	{
		set Definition.Operation = Operation
		set Definition.Name = Name
		set Definition.VariableDefinitions = ..ParseVariableDefinitions() //done
		set Definition.Directives = ..ParseDirectives()	
		set Definition.SelectionSet = ..ParseSelectionSet()
		set Definition.Location = ..GetLocation(Start)
	}else{
		set Definition.Operation = $$$QUERY
		set Definition.SelectionSet = ..ParseSelectionSet()
		set Definition.Location = ..GetLocation(Start)
	}
	return Definition
}

Method ParseSelectionSet() As GraphQL.AST.GraphQLSelectionSet
{
	set Start = ..CurrentToken.Start
	set Selections = ..Many($$$BRACEL, "ParseSelection", $$$BRACER) //done ParseSelection()
	set Location = ..GetLocation(Start)
	return ##class(GraphQL.AST.GraphQLSelectionSet).%New(Selections, Location)
}

// done

Method ParseSelection() As GraphQL.AST.ASTNode [ CodeMode = expression ]
{
$Select(..Peek($$$SPREAD): ..ParseFragment(), 1: ..ParseFieldSelection())
}

Method ParseFieldSelection() As GraphQL.AST.GraphQLFieldSelection
{
	set Start = ..CurrentToken.Start
	set NameOrAlias = ..ParseName()
	
	if (..Skip($$$COLON))
	{
		set Name = ..ParseName()
		set Alias = NameOrAlias
	}else{
		set Alias = $$$NULL
		set Name = NameOrAlias
	}
	return ..CreateFieldSelection(Start, Name, Alias) //done
}

Method CreateFieldSelection(Start As %Integer, Name As GraphQL.AST.GraphQLName, Alias As GraphQL.AST.GraphQLName) As GraphQL.AST.GraphQLFieldSelection
{
	set Arguments = ..ParseArguments()
	set Directives = ..ParseDirectives()
	set SelectionSet = $Select(..Peek($$$BRACEL): ..ParseSelectionSet(), 1: $$$NULL)
	set Location = ..GetLocation(Start)
	return ##class(GraphQL.AST.GraphQLFieldSelection).%New(Name, Alias, Arguments, Directives, SelectionSet, Location)
}

Method ParseFragment() As GraphQL.AST.ASTNode
{
	set Start = ..CurrentToken.Start
	do ..Expect($$$SPREAD)
	if (..Peek($$$NAME) && (..CurrentToken.Value '= "on"))
	{
		return ..CreateGraphQLFragmentSpread(Start) //done
	}
	return ..CreateInlineFragment(Start) //done
}

Method CreateGraphQLFragmentSpread(Start As %Integer) As GraphQL.AST.ASTNode
{
	set Name = ..ParseFragmentName()
	set Directives = ..ParseDirectives()
	set Location = ..GetLocation(Start)
	return ##class(GraphQL.AST.GraphQLFragmentSpread).%New(Name, Directives, Location)
}

Method CreateInlineFragment(Start As %Integer) As GraphQL.AST.ASTNode
{
	set TypeCondition = ..GetTypeCondition() //done
	set Directives = ..ParseDirectives()
	set SelectionSet = ..ParseSelectionSet()
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLInlineFragment).%New(TypeCondition, Directives, SelectionSet, Location)
}

Method GetTypeCondition() As GraphQL.AST.GraphQLNamedType
{
	if ((..CurrentToken.Value '= $$$NULL) && (..CurrentToken.Value = "on"))
	{
		do ..Advance()
		return ..ParseNamedType()
	}
	return $$$NULL
}

Method ParseDirectives() As %ListOfObjectsWithClassName
{
	set Directives = ##class(%ListOfObjectsWithClassName).%New()
	while(..Peek($$$AT))
	{
		do Directives.Insert(..ParseDirective())
	}
	return Directives
}

Method ParseDirective() As GraphQL.AST.GraphQLDirective
{
	set Start = ..CurrentToken.Start
	do ..Expect($$$AT)
	if Start = "" break
	set Directive = ##class(GraphQL.AST.GraphQLDirective).%New()
	set Directive.Name = ..ParseName()
	set Directive.Arguments = ..ParseArguments()
	set Directive.Location = ..GetLocation(Start)
	
	return Directive
}

Method ParseName() As GraphQL.AST.GraphQLName
{
	set Start = ..CurrentToken.Start
	set Value = ..CurrentToken.Value 
	
	do ..Expect($$$NAME)
	
	return ##class(GraphQL.AST.GraphQLName).%New(..GetLocation(Start), Value)
}

Method ParseArguments() As %ListOfObjectsWithClassName
{
	set Arguments = ##class(%ListOfObjectsWithClassName).%New()
	return $Select(..Peek($$$PARENL): ..Many($$$PARENL, "ParseArgument", $$$PARENR), 1: Arguments)
}

Method ParseArgument() As GraphQL.AST.GraphQLArgument [ CodeMode = expression ]
{
##class(GraphQL.AST.GraphQLArgument).%New(..ParseName(),..ExpectColonAndParseValueLiteral($$$NO),..GetLocation(..CurrentToken.Start))
}

Method ExpectColonAndParseValueLiteral(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	do ..Expect($$$COLON)
	return ..ParseValueLiteral(IsConstant)
}

Method ParseValueLiteral(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	set Case = ""
	set Case = $Case(..CurrentToken.Kind,
						$$$BRACKETL: ..ParseList(IsConstant),				//need create 1 method in this class
						$$$BRACEL: ..ParseObject(IsConstant),				//done
						$$$INT: ..ParseInt(IsConstant),						//done
						$$$FLOAT: ..ParseFloat(IsConstant),					//done
						$$$STRING: ..ParseString(IsConstant),				//done
						$$$NAME: ..ParseNameValue(IsConstant),				//done
						$$$DOLLAR: $select('IsConstant:..ParseVariable()))	//done
	return:Case'="" Case
	throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Unexpected "_..CurrentToken,..Source,..CurrentToken.Start)
}

Method ParseInt(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	set Token = ..CurrentToken
	do ..Advance()
	return ##class(GraphQL.AST.GraphQLScalarValue).%New($$$IntValue, 
														Token.Value,
														..GetLocation(Token.Start))
}

Method ParseFloat(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	set Token = ..CurrentToken
	do ..Advance()
	return ##class(GraphQL.AST.GraphQLScalarValue).%New($$$FloatValue, 
														Token.Value,
														..GetLocation(Token.Start))
}

Method ParseString(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	set Token = ..CurrentToken
	do ..Advance()
	return ##class(GraphQL.AST.GraphQLScalarValue).%New($$$StringValue, 
														Token.Value,
														..GetLocation(Token.Start))
}

Method ParseNameValue(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	if (..CurrentToken.Value = "true" || ..CurrentToken.Value = "false")
	{
		 return ..ParseBooleanValue(..CurrentToken)							//done
	}elseif((..CurrentToken.Value'="") && (..CurrentToken.Value '= "null")){
		return ..ParseEnumValue(..CurrentToken)								//done
	}
	
	throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Unexpected "_..CurrentToken, ..Source, ..CurrentToken.Start)
}

Method ParseBooleanValue(Token As Token) As GraphQL.AST.GraphQLValue
{
	do ..Advance()
	return ##class(GraphQL.AST.GraphQLScalarValue).%New($$$BooleanValue,
														 Token.Value,
														 ..GetLocation(Token.Start))
}

Method ParseEnumValue(Token As Token) As GraphQL.AST.GraphQLValue
{
	do ..Advance()
	return ##class(GraphQL.AST.GraphQLScalarValue).%New($$$EnumValue,
														 Token.Value,
														 ..GetLocation(Token.Start))
}

Method ParseVariable() As GraphQL.AST.GraphQLVariable
{
	set Start = ..CurrentToken.Start
	do ..Expect($$$DOLLAR)
	return ##class(GraphQL.AST.GraphQLVariable).%New(..GetName(), ..GetLocation(Start))
}

Method ParseObject(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue [ CodeMode = expression ]
{
##class(GraphQL.AST.GraphQLObjectValue).%New(..ParseObjectFields(IsConstant),..GetLocation(..CurrentToken.Start))
}

Method ParseObjectFields(IsConstant As %Boolean) As %ListOfObjectsWithClassName
{
	#dim Fields As %ListOfObjectsWithClassName
	do ..Expect($$$BRACEL)
	while('..Skip($$$BRACER))
	{
		do Fields.Insert(..ParseObjectField(IsConstant))
	}
	return Fields
}

Method ParseObjectField(IsConstant As %Boolean) As GraphQL.AST.GraphQLObjectField
{
	return ##class(GraphQL.AST.GraphQLObjectField).%New(..ParseName(),
											 ..ExpectColonAndParseValueLiteral(IsConstant),
											 ..GetLocation(..CurrentToken.Start))
}

Method ParseList(IsConstant As %Boolean) As GraphQL.AST.GraphQLValue
{
	set Start = ..CurrentToken.Start
	set Constant = $$$YES 	//done
	set Value = $$$NO		//done
	
	set Location = ..GetLocation(Start)
	set AstValue = $Extract(..Source.Body,Start,..CurrentToken.End - 1)
	set Values = ..Any($$$BRACKETL,"ParseValueLiteral", $$$BRACKETR, $Select(IsConstant:Constant, 1:Value))
	
	return ##class(GraphQL.AST.GraphQLListValue).%New($$$ListValue, Location, AstValue, Values)
}

Method Any(Open As %Integer, Next As %String, Close As %Integer, Arg = {$$$NULL}) As %ListOfObjectsWithClassName
{
	do ..Expect($$$COLON)
	
	set Nodes = ##class(%ListOfObjectsWithClassName).%New() 
	
	while ('..Skip(Close))
	{
		if $Data(Arg) {
			do Nodes.Insert($Method(,Next, Arg))
		}else{
			do Nodes.Insert($Method(,Next))
		}
	}
	return Nodes
}

Method ParseVariableDefinitions() As %ListOfObjectsWithClassName
{
	set VariableDefinitions = ##class(%ListOfObjectsWithClassName).%New()
	return $Select(..Peek($$$PARENL):..Many($$$PARENL,"ParseVariableDefinition",$$$PARENR), 1:VariableDefinitions)
}

Method ParseVariableDefinition() As GraphQL.AST.GraphQLVariableDefinition
{
	set Start = ..CurrentToken.Start
	set Variable = ..ParseVariable()
	set Type = ..AdvanceThroughColonAndParseType()
	set DefaultValue = ..SkipEqualsAndParseValueLiteral()
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLVariableDefinition).%New(Variable, Type, DefaultValue, Location)
}

Method SkipEqualsAndParseValueLiteral() As %RegisteredObject [ CodeMode = expression ]
{
$Select(..Skip($$$EQUALS):..ParseValueLiteral($$$YES), 1:$$$NULL)
}

Method AdvanceThroughColonAndParseType() As GraphQL.AST.GraphQLType
{
	do ..Expect($$$COLON) 
	return ..ParseType()
}

Method GetName() As GraphQL.AST.GraphQLName [ CodeMode = expression ]
{
$Select(..Peek($$$NAME): ..ParseName(), 1:$$$NULL)
}

Method GetLocation(Start As %Integer) As GraphQL.AST.GraphQLLocation [ CodeMode = expression ]
{
##class(GraphQL.AST.GraphQLLocation).%New(Start,..CurrentToken.End)
}

Method Skip(Kind) As %Boolean
{
	set IsCurrentTokenMathing = $Select(..CurrentToken.Kind = Kind:$$$YES, 1:$$$NO)
	do:IsCurrentTokenMathing ..Advance()
	return IsCurrentTokenMathing
}

Method Advance()
{
	set ..CurrentToken = ..Lexer.Lex(..Source,..CurrentToken.End)
}

Method Expect(Kind)
{
	if (..CurrentToken.Kind = Kind)
	{
		do ..Advance()
	}else{
		set ExpectedKind = ##class(Token).GetTokenKindDescription(Kind)
		set ReceivedKind = ##class(Token).GetTokenKindDescription(..CurrentToken.Kind)
		throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Expected:'"_ExpectedKind_"' Received:'"_ReceivedKind_"' Location:",..Source, ..CurrentToken.Start)
	}
}

Method ParseNamedDefinition() As GraphQL.AST.ASTNode [ CodeMode = expression ]
{
$Case(..CurrentToken.Value,

		// Note: subscription is an experimental non-spec addition.
		"query": ..ParseOperationDefinition(),
		"mutation": ..ParseOperationDefinition(),
		"subscription": ..ParseOperationDefinition(),
		
		"fragment": ..ParseFragmentDefinition(),				// done
		
		//Note: the Type System IDL is an experimental non-spec addition.
		"schema": ..ParseSchemaDefinition(),					//done
        "scalar":  ..ParseScalarTypeDefinition(),				//done
        "type":  ..ParseObjectTypeDefinition(),					//done
        "interface":  ..ParseInterfaceTypeDefinition(),			//done
        "union":  ..ParseUnionTypeDefinition(),					//done
        "enum":  ..ParseEnumTypeDefinition(),					//done
        "input":  ..ParseInputObjectTypeDefinition(),			//done
        "extend":  ..ParseTypeExtensionDefinition(),			//done
        "directive":  ..ParseDirectiveDefinition(),				//done
        :""
     )
}

Method ParseSchemaDefinition() As GraphQL.AST.GraphQLSchemaDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("schem")
	
	set Directives = ..ParseDirectives()
	set OperationTypes = ..Any($$$BRACEL, "ParseOperationTypeDefinition", $$$BRACER) //done ..ParseOperationTypeDefinition()
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLSchemaDefinition).%New(Directives, OperationTypes, Location)
}

Method ParseOperationTypeDefinition() As GraphQL.AST.GraphQLOperationTypeDefinition
{
	set Start = ..CurrentToken.Start
	set Operation = ..ParseOperationType() //done
	do ..Expect($$$COLON)
	set Type = ..ParseNamedType()
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLOperationTypeDefinition).%New(Operation,Type,Location)
}

Method ParseOperationType() As %Integer
{
	set Token = ..CurrentToken
	do ..Expect($$$NAME)
	return $Case(Token.Value,
					"query":		$$$QUERY,
					"mutation": 	$$$MUTATION,
					"subscription": $$$SUBSCRIPTON)
}

Method ParseScalarTypeDefinition() As GraphQL.AST.GraphQLScalarTypeDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("scalar")
	
	set Name = ..ParseName()
	set Directives = ..ParseDirectives()
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLScalarTypeDefinition).%New(Name, Directives, Location)
}

Method ParseInterfaceTypeDefinition() As GraphQL.AST.GraphQLInterfaceTypeDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("interface")
	
	set Name = ..ParseName()
	set Directives = ..ParseDirectives()
	set Fields = ..Any($$$BRACEL, "ParseFieldDefinition", $$$BRACER)
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLInterfaceTypeDefinition).%New(Name, Directives, Fields, Location)
}

Method ParseUnionTypeDefinition() As GraphQL.AST.GraphQLUnionTypeDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("union")
	set Name = ..ParseName()
	set Directives = ..ParseDirectives()
	do ..Expect($$$EQUALS)
	set Types = ..ParseUnionMembers() //done
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLUnionTypeDefinition).%New(Name,Directives,Types,Location)
}

Method ParseUnionMembers() As %ListOfObjectsWithClassName
{
	#dim Members As List of GraphQL.AST.GraphQLNamedType
	do
	{
		do Members.Insert(..ParseNamedType())
	}
	while (1)
	return Members
}

Method ParseEnumTypeDefinition() As GraphQL.AST.GraphQLEnumTypeDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("enum")
	
	set Name = ..ParseName()
    set Directives = ..ParseDirectives()
    set Values = ..Many($$$BRACEL, "ParseEnumValueDefinition", $$$BRACER) //done ..ParseEnumValueDefinition()
    set Location = ..GetLocation(Start)
    
    return ##class(GraphQL.AST.GraphQLEnumTypeDefinition).%New(Name, Directives, Values, Location)
}

Method ParseEnumValueDefinition() As GraphQL.AST.GraphQLEnumValueDefinition [ CodeMode = expression ]
{
##class(GraphQL.AST.GraphQLEnumValueDefinition).%New(..ParseName(), ..ParseDirectives(), ..GetLocation(..CurrentToken.Start))
}

Method ParseInputObjectTypeDefinition() As GraphQL.AST.GraphQLInputObjectTypeDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("input")
	
	set Name = ..ParseName()
	set Directives = ..ParseDirectives()
	set Fields = ..Any($$$BRACEL, "ParseInputValueDef", $$$BRACER) // done ParseInputValueDef
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLInputObjectTypeDefinition).%New(Name, Directives, Fields, Location)
}

Method ParseInputValueDef() As GraphQL.AST.GraphQLInputValueDefinition
{
	set Start = ..CurrentToken.Start
	set Name = ..ParseName()
	do ..Expect($$$COLON)
	
	set Type = ..ParseType()
	set DefaultValue = ..GetDefaultConstantValue() //done
	set Directives = ..ParseDirectives()
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLInputValueDefinition).%New(Name, Type, DefaultValue, Directives, Location)
}

Method GetDefaultConstantValue() As GraphQL.AST.GraphQLValue
{
	#dim DefaultValue As GraphQL.AST.GraphQLValue
	if (..Skip($$$EQUALS))
	{
		set DefaultValue = ..ParseValueLiteral($$$YES)
	}
	return DefaultValue
}

Method ParseTypeExtensionDefinition() As GraphQL.AST.GraphQLTypeExtensionDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("extend")
	
	set Definition = ..ParseObjectTypeDefinition() //done
	
	return ##class(GraphQL.AST.GraphQLTypeExtensionDefinition).%New(Definition,..GetLocation(Start))
}

Method ParseObjectTypeDefinition() As GraphQL.AST.GraphQLObjectTypeDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("type")
	
	set Name = ..ParseName()
	set Interface = ..ParseImplementsInterfaces() //done
	set Directives = ..ParseDirectives()
	set Fields = ..Any($$$BRACEL, "ParseFieldDefinition", $$$BRACER) //done ParseFieldDefinition
	set Location = ..GetLocation(Start)
	
	return ##class(GraphQL.AST.GraphQLObjectTypeDefinition).%New(Name, Interface, Directives, Fields, Location)
}

Method ParseImplementsInterfaces() As %ListOfObjectsWithClassName
{
	#dim Types As List of GraphQL.AST.GraphQLNamedType
	if ((..CurrentToken.Value = "implements") = $$$YES )
	{
		do ..Advance()
		
		do
		{
			do Types.Insert(..ParseNamedType())
		}
		while (..Peek($$$NAME))
	}
	return Types
}

Method ParseFieldDefinition() As GraphQL.AST.GraphQLFieldDefinition
{
	set Start = ..CurrentToken.Start
	set Name = ..ParseName()
	set Args = ..ParseArgumentDefs()
	set Location = ..GetLocation(Start)
	do ..Expect($$$COLON)
	
	return ##class(GraphQL.AST.GraphQLFieldDefinition).%New(Name, ..ParseType(), Args, ..ParseDirectives(), Location) //done ..ParseType()
}

Method ParseType() As GraphQL.AST.GraphQLType
{
	#dim Type As GraphQL.AST.GraphQLType = $$$NULL
	set Start = ..CurrentToken.Start
	
	if (..Skip($$$BRACKETL))
	{
		set Type = ..ParseType()
		do ..Expect($$$BRACKETR)
		set Type = ##class(GraphQL.AST.GraphQLListType).%New(Type, ..GetLocation(Start))
	}else{
		set Type = ..ParseNamedType()
	}
	
	if (..Skip($$$BANG))
	{
		return ##class(GraphQL.AST.GraphQLNonNullType).%New(Type, ..GetLocation(Start))
	}
	return Type
}

Method ParseDirectiveDefinition() As GraphQL.AST.GraphQLDirectiveDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("directive")
	do ..Expect($$$AT)
	
	set Name = ..ParseName()
	set Args = ..ParseArgumentDefs() //done
	
	do ..ExpectKeyword("on")
	set Locations = ..ParseDirectiveLocations() //done
	
	return ##class(GraphQL.AST.GraphQLDirectiveDefinition).%New(Name,Args,Locations,..GetLocation(Start))
}

Method ParseArgumentDefs() As %ListOfObjectsWithClassName
{
	#dim GQLInputValueDefinition As List of GraphQL.AST.GraphQLInputValueDefinition = ##class(%ListOfObjectsWithClassName).%New()
	if ('..Peek($$$PARENL))
	{
		return GQLInputValueDefinition
	}
	return ..Many($$$PARENL, "ParseInputValueDef" , $$$PARENR) //done
}

Method Many(Open As %Integer, Next As %String, Close As %Integer) As %ListOfObjectsWithClassName
{
	do ..Expect(Open)
	#dim Nodes As %ListOfObjectsWithClassName = ##class(%ListOfObjectsWithClassName).%New()
	
	do{
		do Nodes.Insert($Method(,Next))
	}while ('..Skip(Close))

	return Nodes
}

Method ParseDirectiveLocations() As %ListOfObjectsWithClassName
{
	set Locations = ##class(%ListOfObjectsWithClassName).%New()
	
	do
	{
		do Locations.Insert(..ParseName())		
	}
	while(..Skip($$$PIPE))
	
	return Locations
}

Method ParseFragmentDefinition() As GraphQL.AST.GraphQLFragmentDefinition
{
	set Start = ..CurrentToken.Start
	do ..ExpectKeyword("fragment")
	return ##class(GraphQL.AST.GraphQLFragmentDefinition).%New(
											..ParseFragmentName(),					//done
											..ExpectOnKeywordAndParseNamedType(),	//done
											..ParseDirectives(),
											..ParseSelectionSet(),
											..GetLocation(Start))
}

Method ParseFragmentName() As GraphQL.AST.GraphQLName
{
 	if (..CurrentToken.Value = "on")
 	{
	 	throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Unexpected "_..CurrentToken, ..Source, ..CurrentToken.Start)
 	}
	return ..ParseName()
}

Method ExpectOnKeywordAndParseNamedType() As GraphQL.AST.GraphQLNamedType
{
	do ..ExpectKeyword("on")
	return ..ParseNamedType()
}

Method ExpectKeyword(Keyword As %String) As %Status
{
	if ((..CurrentToken.Kind = $$$NAME) && (..CurrentToken.Value = Keyword))
	{
		do ..Advance()
		quit
	}
	throw ##class(GraphQL.Exceptions.GraphQLSyntaxErrorException).Get("Expected "_Keyword_" found Name "_..CurrentToken.Value, ..Source, ..CurrentToken.Start)
}

Method ParseNamedType() As GraphQL.AST.GraphQLNamedType [ CodeMode = expression ]
{
##class(GraphQL.AST.GraphQLNamedType).%New(..ParseName(), ..GetLocation(..CurrentToken.Start))
}

}

