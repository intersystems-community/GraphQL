Class GraphQL.Query.Test
{

/// do ##class(GraphQL.Query.Test).Test()
ClassMethod Test(class, prop)
{
	set result = ..Execute(class, prop)
	w result.%ToJSON()
}

/// query{sample_person{Name}}
/// query{sample_person{Name Home {City}}
ClassMethod Execute(class, prop) As %DynamicObject
{
	set data = []
	

	&sql(DECLARE C1 CURSOR FOR
		SELECT :prop(1),:prop(2)
		INTO :name, :comp
		FROM Sample.Person
	)
	
	&sql(OPEN C1)
	&sql(FETCH C1)

	While (SQLCODE = 0) {
		do data.%Push({"name":(name),"FavoriteColors":(comp)})
		&sql(FETCH C1)
	}

	&sql(CLOSE C1)
	
	
	set obj = {}
	set obj.data = data
	quit obj
}

}

