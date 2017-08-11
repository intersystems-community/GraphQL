Include Tokens

Class GraphQL.Utils.Schema [ Abstract ]
{

/// set s=##class(GraphQL.Utils.Schema).GetSchema()
ClassMethod GetSchema() As %DynamicObject
{
	#dim schema As %DynamicObject = ..GetTemplate()
	#dim root As %DynamicObject = ..GetRootTemplate()
	#dim gqlTypes As %DynamicArray = ..GetGQLTypeTemplate()
	#dim typeList As %List = ""
	#dim completeList As %List = ""
	
	do schema.data."__schema".types.%Push(root)
	
	#dim rs As %SQL.ISelectResult
	set rs = ##class(%Dictionary.ClassDefinitionQuery).SubclassOfFunc("%Library.Persistent")
	while rs.%Next() 
	{
		set classname =  rs.Name
		
		continue:$e(classname)="%"
		continue:$$$defClassKeyGet(classname, $$$cCLASSsystem)'=0 // Skip system classes
		continue:'$$$comClassDefined(classname) // TODO fix for mapped classes
		
		set typeList = typeList _ $lb(classname)
		
		do schema.data."__schema".types.%Get(0).fields.%Push(..GetRootField(classname))
	}
	
	while $ll(typeList)>0 
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
	
	set iter = gqlTypes.%GetIterator()
	while iter.%GetNext(,.value ) 
	{
	    do schema.data."__schema".types.%Push(value)
	}	
	quit schema
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

ClassMethod GetClassFields(classname As %Dictionary.CacheClassname, Output relatedTypes) As %DynamicObject
{
	
	set class = ##class(%Dictionary.CompiledClass).%OpenId(classname)
	
	if (..GetKind(classname) = "SCALAR")
	{
		set scalar = ..GetScalar(class)
		return scalar
	}else{
		set object = ..GetObject(class)
		return object
	}
}

ClassMethod GetFields(class As %Dictionary.CompiledClass) As %DynamicArray
{
	#dim fields As %DynamicArray = ##class(%DynamicArray).%New()

	for i=1:1:class.Properties.Count() 
	{
		#dim property As %Dictionary.PropertyDefinition
		set property = class.Properties.GetAt(i)
		if property.Internal || property.Calculated || property.ReadOnly || property.Private || property.Identity continue
		
		set field = ..GetField(property)
		
		do fields.%Push(field)
	}
	return fields
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
	"name": (property.Name),
	"description":(..GetDescription(property.Description)),
	"args": [], 							//need make class ..GetArgs()
	"type": (..GetType(property)),
	"isDeprecated": false,
	"deprecationReason": null
}
}

ClassMethod GetObject(class As %Dictionary.CompiledClass) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind": "OBJECT",
	"name": (..GetGQLTypeNameByCacheTypeName(class.Name)),
	"description": (..GetDescription(class.Description)),
	"fields": (..GetFields(class)),
	"inputFields": null,
	"interfaces": [],
	"enumValues": null,
	"possibleTypes": null
}
}

ClassMethod GetScalar(class As %Dictionary.CompiledClass) As %DynamicObject [ CodeMode = expression ]
{
{
	"kind": "SCALAR",
	"name": (..GetGQLTypeNameByCacheTypeName(class.Name)),
	"description": (..GetDescription(class.Description)),
	"fields": [],
	"inputFields": null,
	"interfaces": [],
	"enumValues": null,
	"possibleTypes": null
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
			($$$getClassType(type) = $$$cCLASSCLASSTYPEDATATYPE):"SCALAR",
		1:"OBJECT")
}

ClassMethod GetDescription(description As %String) As %String [ CodeMode = expression ]
{
$Replace(##class(%iKnow.Source.Converter.Html).StripHTML(description),$c(13,10),"")
}

ClassMethod SkipIfNameExistInSchema(classname) As %Boolean
{
	set checkName = ..GetGQLTypeNameByCacheTypeName(classname)
	return $select((checkName = "String") || (checkName = "Float") || (checkName = "Int") || (checkName = "Boolean"): 1, 1:0)
}

ClassMethod GetGQLTypeNameByCacheTypeName(classname As %String) As %String
{
	if ($Length(classname, "%") = 2){
	 	return $Case($Piece(classname, ".", *),
						"Numeric": "Float",
						"Float": "Float",
						"Double": "Float",
						"Integer": "Int",
						"CacheString": "String",
						"Char": "String",
						"Date": "String",
						"TimeStamp": "String",
						"Binary": "String",
						"GlobalCharacter":"String",
						"GlobalBinary":"String",
						: $Piece(classname, ".", *))
	}else{
		return $Replace(classname, ".", "_")
	}
}

ClassMethod GetRootField(classname As %String) As %DynamicObject [ CodeMode = expression ]
{
{
  "name": ($Replace(classname, ".", "_")),
  "description": null,
  "args": [],
  "type": {
    "kind": "LIST",
    "name": null,
    "ofType": {
      "kind": "OBJECT",
      "name": ($Replace(classname, ".", "_")),
      "ofType": null
    }
  },
  "isDeprecated": false,
  "deprecationReason": null
}
}

ClassMethod GetRootTemplate() As %DynamicObject [ CodeMode = expression ]
{
{
  "kind": "OBJECT",
  "name": "RootType",
  "description": null,
  "fields": [
  ],
  "inputFields": null,
  "interfaces": [],
  "enumValues": null,
  "possibleTypes": null
}
}

/// // set s=##class(GraphQL.Utils.Schema).GetTemplate()
ClassMethod GetTemplate() As %DynamicObject [ CodeMode = expression ]
{
{
    "data": {
        "__schema": {
            "queryType": {
                "name": "RootType"
            },
            "mutationType": null,
            "subscriptionType": null,
            "types": [],
            "directives": [{
                    "name": "include",
                    "description": "Directs the executor to include this field or fragment only when the `if` argument is true.",
                    "locations": [
                        "FIELD",
                        "FRAGMENT_SPREAD",
                        "INLINE_FRAGMENT"
                    ],
                    "args": [{
                        "name": "if",
                        "description": "Included when true.",
                        "type": {
                            "kind": "NON_NULL",
                            "name": null,
                            "ofType": {
                                "kind": "SCALAR",
                                "name": "Boolean",
                                "ofType": null
                            }
                        },
                        "defaultValue": null
                    }]
                },
                {
                    "name": "skip",
                    "description": "Directs the executor to skip this field or fragment when the `if` argument is true.",
                    "locations": [
                        "FIELD",
                        "FRAGMENT_SPREAD",
                        "INLINE_FRAGMENT"
                    ],
                    "args": [{
                        "name": "if",
                        "description": "Skipped when true.",
                        "type": {
                            "kind": "NON_NULL",
                            "name": null,
                            "ofType": {
                                "kind": "SCALAR",
                                "name": "Boolean",
                                "ofType": null
                            }
                        },
                        "defaultValue": null
                    }]
                },
                {
                    "name": "deprecated",
                    "description": "Marks an element of a GraphQL schema as no longer supported.",
                    "locations": [
                        "FIELD_DEFINITION",
                        "ENUM_VALUE"
                    ],
                    "args": [{
                        "name": "reason",
                        "description": "Explains why this element was deprecated, usually also including a suggestion for how to access supported similar data. Formatted in [Markdown](https://daringfireball.net/projects/markdown/).",
                        "type": {
                            "kind": "SCALAR",
                            "name": "String",
                            "ofType": null
                        },
                        "defaultValue": "\"No longer supported\""
                    }]
                }
            ]
        }
    }
}
}

ClassMethod GetGQLTypeTemplate() As %DynamicArray [ CodeMode = expression ]
{
[{
    "kind": "SCALAR",
    "name": "ID",
    "description": "The `ID` scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `\"4\"`) or integer (such as `4`) input value will be accepted as an ID.",
    "fields": null,
    "inputFields": null,
    "interfaces": null,
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "SCALAR",
    "name": "String",
    "description": "The `String` scalar type represents textual data, represented as UTF-8 character sequences. The String type is most often used by GraphQL to represent free-form human-readable text.",
    "fields": null,
    "inputFields": null,
    "interfaces": null,
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "OBJECT",
    "name": "__Schema",
    "description": "A GraphQL Schema defines the capabilities of a GraphQL server. It exposes all available types and directives on the server, as well as the entry points for query, mutation, and subscription operations.",
    "fields": [{
            "name": "types",
            "description": "A list of all types supported by this server.",
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "LIST",
                    "name": null,
                    "ofType": {
                        "kind": "NON_NULL",
                        "name": null,
                        "ofType": {
                            "kind": "OBJECT",
                            "name": "__Type",
                            "ofType": null
                        }
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "queryType",
            "description": "The type that query operations will be rooted at.",
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "OBJECT",
                    "name": "__Type",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "mutationType",
            "description": "If this server supports mutation, the type that mutation operations will be rooted at.",
            "args": [],
            "type": {
                "kind": "OBJECT",
                "name": "__Type",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "subscriptionType",
            "description": "If this server support subscription, the type that subscription operations will be rooted at.",
            "args": [],
            "type": {
                "kind": "OBJECT",
                "name": "__Type",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "directives",
            "description": "A list of all directives supported by this server.",
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "LIST",
                    "name": null,
                    "ofType": {
                        "kind": "NON_NULL",
                        "name": null,
                        "ofType": {
                            "kind": "OBJECT",
                            "name": "__Directive",
                            "ofType": null
                        }
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "OBJECT",
    "name": "__Type",
    "description": "The fundamental unit of any GraphQL Schema is the type. There are many kinds of types in GraphQL as represented by the `__TypeKind` enum.\n\nDepending on the kind of a type, certain fields describe information about that type. Scalar types provide no information beyond a name and description, while Enum types provide their values. Object and Interface types provide the fields they describe. Abstract types, Union and Interface, provide the Object types possible at runtime. List and NonNull types compose other types.",
    "fields": [{
            "name": "kind",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "ENUM",
                    "name": "__TypeKind",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "name",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "description",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "fields",
            "description": null,
            "args": [{
                "name": "includeDeprecated",
                "description": null,
                "type": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                },
                "defaultValue": "false"
            }],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                        "kind": "OBJECT",
                        "name": "__Field",
                        "ofType": null
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "interfaces",
            "description": null,
            "args": [],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                        "kind": "OBJECT",
                        "name": "__Type",
                        "ofType": null
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "possibleTypes",
            "description": null,
            "args": [],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                        "kind": "OBJECT",
                        "name": "__Type",
                        "ofType": null
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "enumValues",
            "description": null,
            "args": [{
                "name": "includeDeprecated",
                "description": null,
                "type": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                },
                "defaultValue": "false"
            }],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                        "kind": "OBJECT",
                        "name": "__EnumValue",
                        "ofType": null
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "inputFields",
            "description": null,
            "args": [],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                        "kind": "OBJECT",
                        "name": "__InputValue",
                        "ofType": null
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "ofType",
            "description": null,
            "args": [],
            "type": {
                "kind": "OBJECT",
                "name": "__Type",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "ENUM",
    "name": "__TypeKind",
    "description": "An enum describing what kind of type a given `__Type` is.",
    "fields": null,
    "inputFields": null,
    "interfaces": null,
    "enumValues": [{
            "name": "SCALAR",
            "description": "Indicates this type is a scalar.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "OBJECT",
            "description": "Indicates this type is an object. `fields` and `interfaces` are valid fields.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "INTERFACE",
            "description": "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "UNION",
            "description": "Indicates this type is a union. `possibleTypes` is a valid field.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "ENUM",
            "description": "Indicates this type is an enum. `enumValues` is a valid field.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "INPUT_OBJECT",
            "description": "Indicates this type is an input object. `inputFields` is a valid field.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "LIST",
            "description": "Indicates this type is a list. `ofType` is a valid field.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "NON_NULL",
            "description": "Indicates this type is a non-null. `ofType` is a valid field.",
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "possibleTypes": null
},
{
    "kind": "SCALAR",
    "name": "Boolean",
    "description": "The `Boolean` scalar type represents `true` or `false`.",
    "fields": null,
    "inputFields": null,
    "interfaces": null,
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "OBJECT",
    "name": "__Field",
    "description": "Object and Interface types are described by a list of Fields, each of which has a name, potentially a list of arguments, and a return type.",
    "fields": [{
            "name": "name",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "String",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "description",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "args",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "LIST",
                    "name": null,
                    "ofType": {
                        "kind": "NON_NULL",
                        "name": null,
                        "ofType": {
                            "kind": "OBJECT",
                            "name": "__InputValue",
                            "ofType": null
                        }
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "type",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "OBJECT",
                    "name": "__Type",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "isDeprecated",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "deprecationReason",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "OBJECT",
    "name": "__InputValue",
    "description": "Arguments provided to Fields or Directives and the input fields of an InputObject are represented as Input Values which describe their type and optionally a default value.",
    "fields": [{
            "name": "name",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "String",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "description",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "type",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "OBJECT",
                    "name": "__Type",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "defaultValue",
            "description": "A GraphQL-formatted string representing the default value for this input value.",
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "OBJECT",
    "name": "__EnumValue",
    "description": "One possible value for a given Enum. Enum values are unique values, not a placeholder for a string or numeric value. However an Enum value is returned in a JSON response as a string.",
    "fields": [{
            "name": "name",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "String",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "description",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "isDeprecated",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "deprecationReason",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "OBJECT",
    "name": "__Directive",
    "description": "A Directive provides a way to describe alternate runtime execution and type validation behavior in a GraphQL document.\n\nIn some cases, you need to provide options to alter GraphQL's execution behavior in ways field arguments will not suffice, such as conditionally including or skipping a field. Directives provide this by describing additional information to the executor.",
    "fields": [{
            "name": "name",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "String",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "description",
            "description": null,
            "args": [],
            "type": {
                "kind": "SCALAR",
                "name": "String",
                "ofType": null
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "locations",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "LIST",
                    "name": null,
                    "ofType": {
                        "kind": "NON_NULL",
                        "name": null,
                        "ofType": {
                            "kind": "ENUM",
                            "name": "__DirectiveLocation",
                            "ofType": null
                        }
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "args",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "LIST",
                    "name": null,
                    "ofType": {
                        "kind": "NON_NULL",
                        "name": null,
                        "ofType": {
                            "kind": "OBJECT",
                            "name": "__InputValue",
                            "ofType": null
                        }
                    }
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "onOperation",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                }
            },
            "isDeprecated": true,
            "deprecationReason": "Use `locations`."
        },
        {
            "name": "onFragment",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                }
            },
            "isDeprecated": true,
            "deprecationReason": "Use `locations`."
        },
        {
            "name": "onField",
            "description": null,
            "args": [],
            "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                    "kind": "SCALAR",
                    "name": "Boolean",
                    "ofType": null
                }
            },
            "isDeprecated": true,
            "deprecationReason": "Use `locations`."
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
},
{
    "kind": "ENUM",
    "name": "__DirectiveLocation",
    "description": "A Directive can be adjacent to many parts of the GraphQL language, a __DirectiveLocation describes one such possible adjacencies.",
    "fields": null,
    "inputFields": null,
    "interfaces": null,
    "enumValues": [{
            "name": "QUERY",
            "description": "Location adjacent to a query operation.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "MUTATION",
            "description": "Location adjacent to a mutation operation.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "SUBSCRIPTION",
            "description": "Location adjacent to a subscription operation.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "FIELD",
            "description": "Location adjacent to a field.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "FRAGMENT_DEFINITION",
            "description": "Location adjacent to a fragment definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "FRAGMENT_SPREAD",
            "description": "Location adjacent to a fragment spread.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "INLINE_FRAGMENT",
            "description": "Location adjacent to an inline fragment.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "SCHEMA",
            "description": "Location adjacent to a schema definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "SCALAR",
            "description": "Location adjacent to a scalar definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "OBJECT",
            "description": "Location adjacent to an object type definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "FIELD_DEFINITION",
            "description": "Location adjacent to a field definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "ARGUMENT_DEFINITION",
            "description": "Location adjacent to an argument definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "INTERFACE",
            "description": "Location adjacent to an interface definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "UNION",
            "description": "Location adjacent to a union definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "ENUM",
            "description": "Location adjacent to an enum definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "ENUM_VALUE",
            "description": "Location adjacent to an enum value definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "INPUT_OBJECT",
            "description": "Location adjacent to an input object type definition.",
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "INPUT_FIELD_DEFINITION",
            "description": "Location adjacent to an input object field definition.",
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "possibleTypes": null
}]
}

}

