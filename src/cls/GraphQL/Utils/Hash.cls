Include GraphQLUtils

Class GraphQL.Utils.Hash
{

Method Hash() As %String [ CodeMode = objectgenerator, ForceGenerate ]
{
	#include %occCPTJSgen
	#dim class As %Dictionary.CompiledClass = %compiledclass
	quit:class.Name="GraphQL.Utils.Hash" $$$OK
	set properties = ""
	for i=1:1:class.Properties.Count() {
		#dim prop As %Dictionary.PropertyDefinition
		set prop = class.Properties.GetAt(i)
		if prop.Internal || prop.Calculated || prop.ReadOnly || prop.Private || prop.Identity || (prop.Description [ "@DoNotHash") continue
		set name = prop.Name
		set properties = properties _ $lb(name)
		if prop.Collection = $$$cPROPCOLLECTIONLIST {
			do %code.WriteLine($$$TAB _ "set " _ name _ " = """"")
			do %code.WriteLine($$$TAB _ "for i=1:1:.." _ name _ ".Count() {")
			
			if $$$classIsDataType(prop.Type) {
				do %code.WriteLine($$$TAB _ $$$TAB _ "set " _ name _ " = " _ name _ " _ $lb(.." _ name _ ".GetAt(i))")
			} else {
				do %code.WriteLine($$$TAB _ $$$TAB _ "set " _ name _ " = " _ name _ " _ $lb(.." _ name _ ".GetAt(i).Hash())")
			}
			do %code.WriteLine($$$TAB _ "}")
			
		} else {
			if $$$classIsDataType(prop.Type) {
				do %code.WriteLine($$$TAB _ "set " _ name _ " = .." _ name)
			} else {
				do %code.WriteLine($$$TAB _ "set " _ name _ " = $case($IsObject(.." _ name _ "), $$$YES:.." _ name _ ".Hash(), :"""")")
			}
		}
	}
	do %code.WriteLine($$$TAB _ "set hash = $system.Encryption.MD5Hash($lb(" _ $lts(properties) _ "))")
	do %code.WriteLine($$$TAB _ "set base64hash = $system.Encryption.Base64Encode(hash)")
	do %code.WriteLine($$$TAB _ "quit $tr(base64hash,""+/="")")
	quit $$$OK
}

}

