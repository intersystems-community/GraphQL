Class GraphQL.REST.Main Extends %CSP.REST
{

XData UrlMap
{
<Routes>
   <Route Url="/graphql" Method="POST" Call="GraphQL"/>
</Routes>
}

ClassMethod GraphQL()
{
	//do ##class(%CSP.Utils).DisplayAllObjects()
	//q 1
	Set Stream = ##class(%Stream.FileCharacter).%New()
	do Stream.LinkToFile("C:\Users\gevor\Desktop\graphiql-0.11.2\example\graphql")
	do Stream.OutputToDevice()
	q 1
}

}

