Class Sample.Customer Extends %SerialObject
{

Property Name As %String(TRUNCATE = 1);

Property MailingAddresses As list Of Address(JAVATYPE = "java.util.List");

Property Addresses As array Of Address(JAVATYPE = "java.util.Map");

Property MyAddress As Address;

Property Status As %String(TRUNCATE = 1);

Property TS As %TimeStamp;

/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
/// 
/// <P>If this method returns an error then the object will not be created.
Method %OnNew(initvalue As %CacheString) As %Status [ Private ]
{
	Do ..SetDefault()
	Quit $$$OK
}

Method SetDefault()
{
	Do ..MailingAddresses.Clear()
	Do ..Addresses.Clear()
	
	Set l = $listbuild("One Memorial Dr.","Cambridge","MA","02142")
	Set l1 = $listbuild(l,"Sample.Address")
	Set a = ##class(Sample.Address).%Open(l1)
	Do ..MailingAddresses.Insert(a)
	
	Set l = $listbuild("768 Beacon St.","Brookline","MA","02446")
	Set l1 = $listbuild(l,"Sample.Address")
	Set a = ##class(Sample.Address).%Open(l1)
	Do ..MailingAddresses.Insert(a)
	
	Set l = $listbuild("825 Third Ave.","New York","NY","10022")
	Set l1 = $listbuild(l,"Sample.Address")
	Set a = ##class(Sample.Address).%Open(l1)
	Do ..Addresses.SetAt(a, "Residence")
	
	Set l = $listbuild("7722 Main St.","Detroit","MI","48224")
	Set l1 = $listbuild(l,"Sample.Address")
	Set a = ##class(Sample.Address).%Open(l1)
	Do ..Addresses.SetAt(a, "Business")
	
	Set l = $listbuild("25 Glen Ave","Newton","MA","02459")
	Set l1 = $listbuild(l,"Sample.Address")
	Set a = ##class(Sample.Address).%Open(l1)
	
	Set ..MyAddress = a
	Set ..Name = "Joe Doe, Jr."
	Set ..Status = "Prospect"
}

ClassMethod ToStringWrapper(Arg1 As %Binary) As %String [ SqlProc ]
{
	Set customer = ##class(Sample.Customer).%Open(Arg1)
	Quit ..ToString(customer)
}

ClassMethod ToString(customer As %IStruct) As %String [ SqlProc ]
{
	Quit:customer="" "{}"
	Set l = customer.MailingAddresses
	Set m = customer.Addresses
	Set str = customer.Name_"Addresses: "_m.Count()_": "
	
	Set key = ""
	For  {
		Set addr = m.GetNext(.key)
		Quit:key=""
		Set str = str_"<"_key_">"
		Do ..writeAddr(.str, addr)
	}

	Set str = str_"Mailing: "_l.Count()_": "
	For i=1:1:l.Count() {
		Set addr = l.GetAt(i)
		Do ..writeAddr(.str, addr)
	}
	Set str = str_"; "_customer.Status
	
	Set str = str_". My Address: "
	Do ..writeAddr(.str,customer.MyAddress)
	
	Quit str
}

ClassMethod writeAddr(ByRef str As %String, addr As Address)
{
	Set str =str_"{"
	Set str = str_"Street: "_addr.Street
	Set str = str_"; City: "_addr.City
	Set str = str_"; State: "_addr.State
	Set str = str_"; Zip:  "_addr.Zip
	Set str =str_"}  "
	Quit
}

Storage Default
{
<Data name="CustomerState">
<Value name="1">
<Value>Addresses</Value>
</Value>
<Value name="2">
<Value>MailingAddresses</Value>
</Value>
<Value name="3">
<Value>MyAddress</Value>
</Value>
<Value name="4">
<Value>Name</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
<Value name="6">
<Value>TS</Value>
</Value>
</Data>
<State>CustomerState</State>
<StreamLocation>^Sample.CustomerS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

