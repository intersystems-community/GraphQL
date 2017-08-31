Class GraphQL.Scope.All Extends Abstract
{

/// This method should return a list of classes, available for GraphQL 
ClassMethod GetClasses() As %List
{
	set list = ""
	set rs = ##class(%Dictionary.ClassDefinitionQuery).SubclassOfFunc("%Library.Persistent")
	while rs.%Next() 
	{
		set classname = rs.Name
		//continue:$e(classname)="%"
		continue:$$$defClassKeyGet(classname, $$$cCLASSsystem)'=0 // Skip system classes
		continue:'$$$comClassDefined(classname) // TODO fix for mapped classes
		set list = list _ $lb(classname)
	}
	quit list
}

/// This method should return a list of class fields, available for GraphQL 
ClassMethod GetProperties(classname As %Dictionary.CacheClassname) As %List
{
}

}

