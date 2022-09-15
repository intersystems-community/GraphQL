/// Defining a task for End Users
/// 
/// You want to generate a standard report that the user schedules to run, allowing them the
/// flexibility to choose when it runs.
/// By assigning Properties to the Class we can make items configurable such as where the 
/// report will be directed and perhaps a heading to be displayed.
/// 
/// The System Management Portal will automatically display the properties for Printer and Heading
/// and will validate that Printer is not ""  You can add any logic you would like to any property
Class Sample.TaskExample1 Extends Sample.Task
{

/// Output printer for report
Property Printer As %String;

Property Heading As %String;

ClassMethod PrinterIsValid(Printer As %String) As %Status
{
	If Printer="" Quit $$$ERROR($$$GeneralError,"Please enter a printer")
	Quit $$$OK
}

/// Your program logic can be here in the OnTask method or in another class or a routine
/// just be sure to return a status code from the OnTask method
Method OnTask() As %Status
{
	Set Printer=..Printer
	Open ..Printer Use ..Printer
	Write ..Heading,!!
	Write "Profits up 1000%!!!!",!
	Close ..Printer
	/// Returning a status other than OK will mark the task as Suspended and send an email 
	/// if a value is defined in EmailOnError
	Quit $$$OK
}

}

