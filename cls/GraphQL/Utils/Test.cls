Class GraphQL.Utils.Test
{

/// do ##class(GraphQL.Utils.Test).GetAst()
ClassMethod GetAst(query = {##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(),"IQ").Data.Read()}) As GraphQL.AST.GraphQLDocument
{
	set lexer = ##class(GraphQL.Lexer).%New()
	set parser = ##class(GraphQL.Parser).%New(lexer)
	
	return parser.Parse(##class(GraphQL.Source).%New(query))
}

XData IQ
{
query{
  Sample_Person{
    id
    Name
	FavoriteColors
    DOB
  }
}
}

}

