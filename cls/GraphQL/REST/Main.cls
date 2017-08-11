Class GraphQL.REST.Main Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE As %String = "application/json";

XData UrlMap
{
<Routes>
   <Route Url="/graphql" Method="POST" Call="GraphQL"/>
   <Route Url="/graphql" Method="GET" Call="GraphQL"/>
</Routes>
}

ClassMethod GraphQL()
{
	
	set Schema=##class(GraphQL.Utils.Schema).GetSchema().%ToJSON()
	
	set Stream = ##class(%Stream.FileCharacter).%New()
	do Stream.LinkToFile("C:\temp\GQL\schema.json")
	do Stream.Write(Schema)
	do Stream.%Save()
	
	w Schema
	return $$$OK
}

}
