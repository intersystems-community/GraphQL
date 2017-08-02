Class GraphQL.Query.Test
{

/// do ##class(GraphQL.Query.Test).Test()
ClassMethod Test()
{
	set result = ..Execute()
	do result.$toJSON()
}

/// query{sample_person{Name}}
/// query{sample_person{Name Home {City}}
ClassMethod Execute() As %Object
{
	set data = []
	

	&sql(DECLARE C1 CURSOR FOR
		SELECT Name
		INTO :name
		FROM Sample.Person
	)

	&sql(OPEN C1)
	&sql(FETCH C1)

	While (SQLCODE = 0) {
		do data.$push({"name":name})
		&sql(FETCH C1)
	}

	&sql(CLOSE C1)
	
	
	set obj = {}
	set obj.data = data
	quit obj
}

}

