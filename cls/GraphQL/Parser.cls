Class GraphQL.Parser
{

Property Lexer As Lexer;

Method %OnNew(Lexer As Lexer)
{
	set ..Lexer = Lexer
}

Method Parse(Source As Source) As GraphQL.AST.GraphQLDocument
{
	set Context = ##class(ParserContext).%New(Source,..Lexer)
	return Context.Parse()
}

}

