Class GraphQL.Lexer Extends %RegisteredObject
{

ClassMethod Lex(Source As GraphQL.Source, Start As %Integer = 1) As GraphQL.Token
{
	set Context = ##class(GraphQL.LexerContext).%New(Source, Start)
	return Context.GetToken()
}

}

