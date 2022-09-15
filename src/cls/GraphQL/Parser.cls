Class GraphQL.Parser Extends %RegisteredObject
{

Property Lexer As Lexer;

Method %OnNew(Lexer As Lexer = {##class(Lexer).%New()}) As %Status
{
	set ..Lexer = Lexer
	return $$$OK
}

Method Parse(Source As Source) As GraphQL.AST.GraphQLDocument
{
	set Context = ##class(ParserContext).%New(Source,..Lexer)
	return Context.Parse()
}

}

