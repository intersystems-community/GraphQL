/// This class represents a U.S. ZIP (Zone Improvement Plan) 
/// Code and corresponding State and City name. The sample dataset
/// includes values for the northeastern United States.
Class Sample.USZipCode Extends (%Persistent, %XML.Adaptor) [ Final ]
{

/// This index specifies that objects are identified by the ZipCode property.
Index ZipIDX On ZipCode [ IdKey ];

/// The 5-digit ZIP Code value.
Property ZipCode As %String(MAXLEN = 5) [ Required ];

/// A 2 letter state abbreviation.
Property State As %String(MAXLEN = 2) [ Required ];

/// A city name.
Property City As %String(MAXLEN = 50) [ Required ];

Property Longitude As %Numeric(SCALE = 6);

Property Latitude As %Numeric(SCALE = 6);

Storage Default
{
<Data name="Data">
<Value name="1">
<Value>State</Value>
</Value>
<Value name="2">
<Value>City</Value>
</Value>
<Value name="3">
<Value>Longitude</Value>
</Value>
<Value name="4">
<Value>Latitude</Value>
</Value>
</Data>
<DataLocation>^ZipCodeData</DataLocation>
<DefaultData>Data</DefaultData>
<IdLocation>^ZipCodeData</IdLocation>
<IndexLocation>^ZipCodeDataIdx</IndexLocation>
<StreamLocation>^Sample.USZipCodeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

