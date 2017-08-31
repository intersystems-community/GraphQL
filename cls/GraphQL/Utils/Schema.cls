Include GraphQLUtils

Class GraphQL.Utils.Schema Extends GraphQL.Utils.SchemaTemplate [ Abstract ]
{

/// set s=##class(GraphQL.Utils.Schema).GetSchema()
ClassMethod GetSchema() As %DynamicObject
{
	#dim schema As %DynamicObject = ..GetTemplate()
	#dim gqlTypes As %DynamicArray = ..GetGQLTypeTemplate()
	#dim typeList As %List = ""
	#dim completeList As %List = ""
	
	set typeList = $classmethod(##class(GraphQL.Settings).GetSetting("SCOPECLASS"), "GetClasses")
	for i=1:1:$ll(typeList) 
	{
		set classname =  $lg(typeList, i)		
		do schema.data."__schema".types.%Get(0).fields.%Push(..GetRootField(classname))
	}
	
	while $listlength(typeList)>0 
	{
		set classname = $listget(typeList)
		set $list(typeList, 1, 1) = ""
		set completeList = completeList _ $lb(classname) 
		
		if '..SkipIfNameExistInSchema(classname)
		{
			do schema.data."__schema".types.%Push(..GetClassFields(classname))
		}
		
		do ..GetTypeList(completeList, classname, .typeList)		
	}
	
	do ..AddTypesInSchemaTypes(.schema, gqlTypes)
		
	quit schema
}

ClassMethod GetClassFields(classname As %Dictionary.CacheClassname) As %DynamicObject
{
	set class = ##class(%Dictionary.CompiledClass).%OpenId(classname)
	
	if (..GetKind(classname) = $$$SCALAR)
	{
		set scalar = ..GetScalar(class)
		return scalar
	}else{
		set object = ..GetObject(class)
		return object
	}
}

/// flag: 1 = Args, 0 = Fields
ClassMethod GetArgsOrFields(class As %Dictionary.CompiledClass, flag As %Boolean) As %DynamicArray
{
	#dim argsOrFields As %DynamicArray = ##class(%DynamicArray).%New()
	#dim property As %Dictionary.CompiledProperty
	
	if ($$$classIsPersistent(class.Name)){ 
		if (flag = $$$Args){
			do argsOrFields.%Push(..GetIDforArgs())
		}else{
			do argsOrFields.%Push(..GetIDforFields())
		}
	}
	for i=1:1:class.Properties.Count() 
	{
		set property = class.Properties.GetAt(i)
		
		if property.Internal || property.Calculated || property.ReadOnly || property.Private || property.Identity continue
		
		if ((flag = $$$Args) && (..GetKind(property.Type) = $$$SCALAR))
		{
			set arg = ..GetArg(property)
			do argsOrFields.%Push(arg)
		}
		elseif((flag = $$$Fields))
		{
			set field = ..GetField(property)
			do argsOrFields.%Push(field)
		}
	}
	return argsOrFields
}

ClassMethod GetType(property As %Dictionary.CompiledProperty) As %DynamicObject
{
	if (property.Required)
	{
		set type = ..GetRequiredOfType(property)	
	}
	elseif(property.Collection'=$$$NULL)
	{
		set type = ..GetListOfType(property)
	}else{
		set type = ..GetScalarOrObjectType(property)
	}
	return type
}

ClassMethod GetOfType(property As %Dictionary.CompiledProperty) As %DynamicObject
{
	if (property.Collection '= $$$NULL)
	{
		set ofType = ..GetRequiredListOfType(property)
	}else{
		set ofType = ..GetScalarOrObjectType(property)
	}
	return ofType
}

ClassMethod GetScalarOrObjectType(property As %Dictionary.PropertyDefinition) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind":(..GetKind(property.Type)), 
	"name":(..GetGQLTypeNameByCacheTypeName(property.Type)),
	"ofType":null
 }
}

ClassMethod GetRequiredListOfType(property As %Dictionary.CompiledProperty) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind":"LIST", 
	"name":null,
	"ofType":
	{
		"kind":"NON_NULL", 
	 	"name":null,
	 	"ofType":(..GetScalarOrObjectType(property))
	}
}
}

ClassMethod GetRequiredOfType(property As %Dictionary.CompiledProperty) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind":"NON_NULL", 
	"name":null,
	"ofType":(..GetOfType(property))
}
}

ClassMethod GetListOfType(property As %Dictionary.CompiledProperty) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind":"LIST", 
	"name":null,
	"ofType":(..GetScalarOrObjectType(property))
}
}

ClassMethod GetField(property As %Dictionary.PropertyDefinition) As %DynamicObject [ CodeMode = expression ]
{
{
	"name": ($Replace(property.Name,"%","")),
	"description":(..GetDescription(property.Description)),
	"args": ($Select(..GetKind(property.Type) = $$$OBJECT:..GetFiltersForArgs(),1: [])),
	"type": (..GetType(property)),
	"isDeprecated": false,
	"deprecationReason": null
}
}

ClassMethod GetArg(property As %Dictionary.PropertyDefinition) As %DynamicObject [ CodeMode = expression ]
{
{
	"name": ($Replace(property.Name,"%","")),
	"description":(..GetDescription(property.Description)),
	"type": (..GetType(property)),
	"defaultValue": null
}
}

ClassMethod GetObject(class As %Dictionary.CompiledClass) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind": ($$$OBJECT),
	"name": (..GetGQLTypeNameByCacheTypeName(class.Name)),
	"description": (..GetDescription(class.Description)),
	"fields": (..GetArgsOrFields(class, $$$Fields)),
	"inputFields": null,
	"interfaces": [],
	"enumValues": null,
	"possibleTypes": null
}
}

ClassMethod GetScalar(class As %Dictionary.CompiledClass) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind": ($$$SCALAR),
	"name": (..GetGQLTypeNameByCacheTypeName(class.Name)),
	"description": (..GetDescription(class.Description)),
	"fields": [],
	"inputFields": null,
	"interfaces": [],
	"enumValues": null,
	"possibleTypes": null
}
}

ClassMethod GetRootField(classname As %String) As %DynamicObject [ CodeMode = expression ]
{
{
  "name": ($Replace(classname, ".", "_")),
  "description": null,
  "args": (..GetArgsOrFields(##class(%Dictionary.CompiledClass).%OpenId(classname), $$$Args)),
  "type": {
    "kind": "LIST",
    "name": null,
    "ofType": {
      "kind": ($$$OBJECT),
      "name": ($Replace(classname, ".", "_")),
      "ofType": null
    }
  },
  "isDeprecated": false,
  "deprecationReason": null
}
}

/// zw ##class(GraphQL.Utils.Schema).GetClassRelatedTypes("Sample.Employee")
ClassMethod GetClassRelatedTypes(classname As %Dictionary.CacheClassname) As %List
{
	&sql(SELECT 
		%DLIST(Distinct Type) INTO :relatedTypes
		FROM %Dictionary.CompiledProperty where parent = :classname)
	quit relatedTypes
}

/// w ##class(GraphQL.Utils.Schema).GetKind("%Library.CacheString")
ClassMethod GetKind(type As %String) As %String [ CodeMode = expression ]
{
$Select(($$$getClassType(type) = $$$cCLASSCLASSTYPESTREAM) || 
			($$$getClassType(type) = $$$cCLASSCLASSTYPEDATATYPE):$$$SCALAR,
		1:$$$OBJECT)
}

ClassMethod GetDescription(description As %String) As %String [ CodeMode = expression ]
{
$Replace(##class(%iKnow.Source.Converter.Html).StripHTML(description),$c(13,10),"")
}

ClassMethod SkipIfNameExistInSchema(classname) As %Boolean
{
	set checkName = ..GetGQLTypeNameByCacheTypeName(classname)
	return $select((checkName = "String") || 
				   (checkName = "Float") || 
				   (checkName = "Integer") || 
				   (checkName = "Boolean") || 
				   (checkName = "CacheString"): 1,
				    1: 0)
}

ClassMethod GetGQLTypeNameByCacheTypeName(classname As %String) As %String
{
	if ($Length(classname, "%") = 2){
	 	return $case($Piece(classname, ".", *),
	 						"Integer":"Int",
	 						"CacheString":"String",
	 						:$Piece(classname, ".", *))
	}else{
		return $Replace(classname, ".", "_")
	}
}

ClassMethod GetTypeList(completeList As %List, classname As %String, Output typeList)
{
	set relatedTypes = ..GetClassRelatedTypes(classname)
	
	for i=1:1:$listlength(relatedTypes) 
	{
		set newType = $lg(relatedTypes, i)
		if (($listfind(typeList, newType)=0) && ($listfind(completeList, newType)=0)) {
			set typeList = typeList _ $lb(newType)
		}
	}
	
	return $$$OK
}

ClassMethod PushTypesInSchema(Output schema, types As %DynamicArray) As %Status
{
}

ClassMethod AddTypesInSchemaTypes(Output schema, types As %DynamicArray) As %Status
{
	set iter = types.%GetIterator()
	while iter.%GetNext(,.value ) 
	{
	    do schema.data."__schema".types.%Push(value)
	}
}

}

