/// Get and set settings
Class GraphQL.Settings [ Abstract ]
{

Parameter SETTINGSGLVN = "^GraphQL.Settings";

/// scopeclass - class for SQL queries. See Form.REST.Objects for implementation details
Parameter SCOPECLASS = "GraphQL.Scope.All";

/// Get setting value by name (name is always uppercase)
/// Refer to parameters for possible settings
/// write ##class(GraphQL.Settings).GetSetting("SCOPECLASS")
ClassMethod GetSetting(name As %String) As %String [ CodeMode = expression ]
{
$get(@..#SETTINGSGLVN($zcvt(name, "U")),$Parameter(,$zcvt(name, "U")))
}

/// Set setting "name" value
/// write ##class(GraphQL.Settings).SetSetting("SCOPECLASS",123)
ClassMethod SetSetting(name As %String = "", value As %String = "") As %Status
{
	#dim sc As %Status = $$$OK
	
	set name = $zcvt(name, "U")
	quit:'##class(%Dictionary.ParameterDefinition).IDKEYExists($classname(), name) $$$ERROR($$$GeneralError, "Setting '" _ name _ "' does not exists")
	
	if name = "SCOPECLASS" {
		if '##class(%Dictionary.ClassDefinition).%ExistsId(value) {
			set sc = $$$ERROR($$$GeneralError, "Class '" _value _ "' does not exis")
		}/* elseif $$$comClassKeyGet(value, $$$cCLASSsuper) '[ $classname() {
			set sc = $$$ERROR($$$GeneralError, "Class '" _value _ "' is not a subclass of " _ $classname())
		}*/
	} 
	
	set:$$$ISOK(sc) @..#SETTINGSGLVN@(name) = value
	return sc
}

}

