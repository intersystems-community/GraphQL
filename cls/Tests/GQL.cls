Class Tests.GQL
{

ClassMethod test() As %ListOfObjectsWithClassName
{
	set lexer = ##class(GraphQL.Lexer).%New()
	set parser = ##class(GraphQL.Parser).%New(lexer)
	set query = "query{"_$c(10)_"user(login: ""gevorg95""){"_$c(10)_"name"_$c(10)_"}}"
	set ast = parser.Parse(##class(GraphQL.Source).%New(query))

	do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(ast,,,"biaceloqtw")
	q ast
}

}

