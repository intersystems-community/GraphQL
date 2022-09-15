Class GraphQL.Utils.Collection
{

/// set Status = ##class(GraphQL.Utils.Collection).Set(Object, Collection)
ClassMethod Set(Object, Collection As %ListOfObjectsWithClassName) As %Status
{
	set Status = $$$OK
   	for i=1:1:Collection.Count()
	{
		set Status = Object.Insert(Collection.GetAt(i))
	}
	return Status
}

}

