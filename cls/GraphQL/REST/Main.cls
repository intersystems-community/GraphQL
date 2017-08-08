Class GraphQL.REST.Main Extends %CSP.REST
{

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
	// Set Stream = ##class(%Stream.FileCharacter).%New()
	// do Stream.LinkToFile("C:\Users\gevor\Desktop\graphiql-0.11.2\example\graphql")
	// do Stream.OutputToDevice()
	set s=##class(GraphQL.Utils.Schema).GetSchema()
	w s.%ToJSON()
	
	q 1
}

}

