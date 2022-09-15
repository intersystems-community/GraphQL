Class GraphQL.Utils.SQL
{

ClassMethod ListToArray(list As %List) As %DynamicArray
{
	set array = []
	for i=1:1:$listlength(list) {
		do array.%Push($lg(list, i))
	}
	quit array
}

}

