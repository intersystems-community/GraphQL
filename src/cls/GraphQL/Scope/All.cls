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
		continue:$e(classname)="%"
		continue:$$$defClassKeyGet(classname,$$$cCLASSgeneratedby)'=""
		continue:$$$defClassKeyGet(classname, $$$cCLASSsystem)'=0 // Skip system classes
		continue:'$$$comClassDefined(classname) // TODO fix for mapped classes
		set list = list _ $lb(classname)
	}
	quit list
}

/// This method should return a list of class fields, available for GraphQL 
/// zw ##class(GraphQL.Scope.All).GetProperties()
ClassMethod GetProperties(classname As %Dictionary.CacheClassname) As %List
{
	if ($$$classIsPersistent(classname) || $$$classIsSerial(classname))
	{
		set list = ""
		set class = ##class(%Dictionary.CompiledClass).%OpenId(classname)
		for i=1:1:class.Properties.Count() 
		{
			set property = class.Properties.GetAt(i)
			if property.Internal || property.Calculated || property.ReadOnly || property.Private || property.Identity continue
			set type = property.Type
			//continue:$extract(property)="%"
			continue:'($$$classIsPersistent(type) || $$$classIsSerial(type) || $$$classIsStream(type) || $$$classIsDataType(type))
			continue:type="%Library.RegisteredObject"
			set list = list _ $lb(property.Name)
		}
	}else{
		quit $$$ERROR($$$GeneralError,"Class: "_classname_" must be %Persistent or %Serial")
	}
	quit list
}

}

