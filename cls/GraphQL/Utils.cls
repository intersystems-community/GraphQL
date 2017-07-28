Class GraphQL.Utils
{

// set Status = ##class(GraphQL.Utils).SetCollection(Object, Collection)

ClassMethod SetCollection(Object, Collection As %ListOfObjectsWithClassName) As %Status
{
	set Status = $$$OK
   	for i=1:1:Collection.Count()
	{
		set Status = Object.Insert(Collection.GetAt(i))
	}
	return Status
}

}

