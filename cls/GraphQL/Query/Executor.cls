Class GraphQL.Query.Executor [ Abstract ]
{

ClassMethod Execute(ast As GraphQL.AST.GraphQLDocument) As %DynamicObject
{
	set queryClass = ..GetQueryClassname(ast)
	
	if ##class(%Dictionary.CompiledClass).%ExistsId(queryClass) && $classmethod(queryClass, "IsUpToDate") && 0{
		set result = $classmethod(queryClass, "Execute") // TODO args...
	} else {
		set sc = ##class(GraphQL.Query.GenerateClass).Generate(ast)
		if $$$ISOK(sc) {
			set result = $classmethod(queryClass, "Execute") 
		} else {
			set result = {"ERROR": ("Unable to generate query"_$system.Status.DisplayError(sc))}
		}
	}
	quit result
}

ClassMethod GetQueryClassname(ast As GraphQL.AST.GraphQLDocument) As %Dictionary.CacheClassname [ CodeMode = expression ]
{
"gqlcq.q" _ ast.Hash()
}

}

