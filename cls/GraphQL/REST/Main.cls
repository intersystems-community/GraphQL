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
	#dim %request as %CSP.Request
	set query = %request.Content.query
	set GiQLHASH = $system.Encryption.MD5Hash(query)
	
	if GiQLHASH = "ú60t·}RÌë"
	{	
		set Schema=##class(GraphQL.Utils.Schema).GetSchema().%ToJSON()
		
		set Stream = ##class(%Stream.FileCharacter).%New()
		do Stream.LinkToFile("C:\temp\GQL\schema.json")
		do Stream.Write(Schema)
		do Stream.%Save()
		
		w Schema
	}else{
		set ast = ##class(GraphQL.Utils.Test).GetAst(query)
		do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(ast,,,"bioaeqltw")
	}

	return $$$OK
}

ClassMethod GraphiQL()
{
	
	return 1
}

}

