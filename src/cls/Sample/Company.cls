/// This sample persistent class represents a company.<br>
Class Sample.Company Extends (%Persistent, %Populate, %XML.Adaptor)
{

/// Define an index for <property>Name</property>.
Index NameIdx On Name [ Type = index ];

/// Define a unique index for <property>TaxID</property>.
Index TaxIDIdx On TaxID [ Type = index, Unique ];

/// The company's name.
Property Name As %String(MAXLEN = 80, POPSPEC = "Company()") [ Required ];

/// The company's mission statement.
Property Mission As %String(MAXLEN = 200, POPSPEC = "Mission()");

/// The unique Tax ID number for the company.
Property TaxID As %String [ Required ];

/// The last reported revenue for the company.
Property Revenue As %Integer;

/// The <class>Employee</class> objects associated with this <class>Company</class>.
Relationship Employees As Employee [ Cardinality = many, Inverse = Company ];

/// This method prints out the payroll for this company by iterating over 
/// all the <class>Employee</class> objects related to it and printing 
/// their names and salaries.<br>
/// You can try this out from the <i>Cach&eacute;</i> command line by opening 
/// an instance of <class>Company</class> object and invoking this method:
/// <example>
/// Set company = ##class(Sample.Company).%OpenId(1)
/// 
/// Do company.PrintPayroll()
/// </example>
Method PrintPayroll()
{
	Set total = 0
	Set key = ""
	
	Write !, "Payroll for ", ..Name, ":"
	
	Do {
		Set emp = ..Employees.GetNext(.key)
		If (emp '= "") {
			Set total = total + emp.Salary
			Write !, ?5, emp.Name, ?40, $J($FN(emp.Salary,","),12)
			Do ..Employees.%UnSwizzleAt(key)
		}
	} while (key '= "")
	
	Write !, "Total: ", ?40, $J($FN(total,","),12)
	Quit
}

Storage Default
{
<Data name="CompanyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Mission</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Revenue</Value>
</Value>
<Value name="5">
<Value>TaxID</Value>
</Value>
</Data>
<DataLocation>^Sample.CompanyD</DataLocation>
<DefaultData>CompanyDefaultData</DefaultData>
<ExtentSize>20</ExtentSize>
<IdLocation>^Sample.CompanyD</IdLocation>
<IndexLocation>^Sample.CompanyI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1.55</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Mission">
<AverageFieldSize>93.75</AverageFieldSize>
<Selectivity>5.0000%</Selectivity>
</Property>
<Property name="Name">
<AverageFieldSize>16.7</AverageFieldSize>
<Selectivity>5.0000%</Selectivity>
</Property>
<Property name="Revenue">
<AverageFieldSize>8.9</AverageFieldSize>
<Selectivity>5.0000%</Selectivity>
</Property>
<Property name="TaxID">
<AverageFieldSize>4.9</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="NameIdx">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="TaxIDIdx">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Sample.CompanyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

