/// This class contains a method to generate data for Sample package
Class Sample.Utils Extends %RegisteredObject
{

/// Invoke this method to set up the data for these classes.
/// Create one company for every five people.
ClassMethod Generate(personCount As %Integer = 100)
{
    //make sure we always have at least 1 person
    If (personCount < 1) {
        Set personCount=1
        }
        
    //never use %KillExtent() in a real application
    do ##class(Sample.Company).%KillExtent()
    do ##class(Sample.Person).%KillExtent()
    do ##class(Sample.Employee).%KillExtent()
    //do ##class(Sample.Vendor).%KillExtent() ; doesn't work with %CacheSQLStorage 
    
    Set companyCount= personCount \ 5
    If (companyCount < 1) {
        Set companyCount=1
        }

    Do ##class(Sample.Company).Populate(companyCount)
	Do ##class(Sample.Person).Populate(personCount)
	Do ##class(Sample.Employee).Populate(personCount,,,,2)
	Do ##class(Sample.Vendor).Populate(personCount)
	
	//specify values for stream properties in Sample.Employee
	//do this for the first lucky 10 employees, for reasons of space
	
	set e1=personCount+1 ; ID of the first employee
	for i=e1:1:e1+9 {
		set employee=##class(Sample.Employee).%OpenId(i)
		set firstname=$PIECE(employee.Name,",",2)
		set firstname=$PIECE(firstname," ",1)
		set text=firstname_" used to work at "_##class(%PopulateUtils).Company()
		         _" as a(n) "_##class(%PopulateUtils).Title()
		         
		do employee.Notes.Write(text)
		
		//add a stock picture (yes, all these employees look alike)
		do employee.Picture.Write($G(^EmployeePictures))
		
		do employee.%Save()
		}
}

}

