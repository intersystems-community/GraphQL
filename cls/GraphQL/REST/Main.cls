Include GraphQLUtils

Class GraphQL.REST.Main Extends AbstractREST
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE As %String = "application/json";

XData UrlMap
{
<Routes>
   <Route Url="/graphql" Method="POST" Call="GraphQL"/>
   <Route Url="/graphql" Method="GET" Call="GraphiQL"/>
</Routes>
}

ClassMethod GraphQL()
{
	set sc = $$$OK
	#dim %request as %CSP.Request
	set query = %request.Content.query
	set GiQLHASH = $system.Encryption.Base64Encode($system.Encryption.MD5Hash(query))
	if GiQLHASH = "ABURmBQ3tap6wGcPz3hLSw=="
	{	
		try{
			w ##class(GraphQL.Utils.Schema).GetSchema().%ToJSON()
		}catch ex{
			set sc = ex.AsStatus()
		}
	}else{
		try{
			set parser = ##class(GraphQL.Parser).%New()
			#dim ast As GraphQL.AST.ASTNode = parser.Parse(##class(GraphQL.Source).%New(query))
			set sc = ##class(GraphQL.Query.Validation).Valid(ast)
			if ($$$ISOK(sc))
			{
				w ##class(GraphQL.Query.Executor).Execute(ast).%ToJSON()
			}
		}catch ex{
			set sc = ex.AsStatus()
		}
		//do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(ast,,,"bioaeqltw")
		//zw ast.Definitions.GetAt(1).SelectionSet.Selections.GetAt(1).Arguments.GetAt(1).Kind
	}

	return sc
}

ClassMethod GraphiQL()
{
	return 1
}

}

