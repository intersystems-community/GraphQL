/// Defining a task using output files
/// 
/// Perhaps you would like to generate a report to a file and email the file to a group of users
/// when it is completed.
/// 
/// In an end user scenario you could have them just define the recipient list and the output directory / filename
/// and the standard report goes out to the group on schedule.
/// 
Class Sample.TaskExample2 Extends Sample.Task
{

/// Your program logic can be here in the OnTask method or in another class or a routine
/// just be sure to return a status code from the OnTask method
Method OnTask() As %Status
{
	Write "<HTML><BODY>This text will go to the output file",!
	Write "This output file will be attached when an email is sent",!
	Write "</BODY></HTML>",!
	/// Returning a status other than OK will mark the task as Suspended and send an email 
	/// to a value defined in EmailOnError
	Quit $$$OK
}

/// this will schedule a task to run Once every day at 10:30 am
/// this example does not take into account any task 'Settings'
/// In this example, if the task has not run within 18 hours and 30 minutes of the scheduled start it will
/// "Expire" and not run again until the next start time
ClassMethod ScheduleOnceDaily() As %Status
{
	#dim task as %SYS.Task
	Set task=##Class(%SYS.Task).%New()
	Set task.Name=..%ClassName(1)
	Set task.TaskClass=..%ClassName(1)  // The name of the Task Class (where OnTask is)
	Set task.NameSpace=$zu(5)  // Where namespace the task will run in
	Set task.DailyFrequency=task.DailyFrequencyDisplayToLogical("Once")
	Set task.DailyStartTime=$zth("10:30")
	Set task.OpenOutputFile=1
	Set task.OutputDirectory="c:\temp\"
	Set task.OutputFilename="TaskExample2.html"
	Set task.EmailOutput=1
	Set task.OutputFileIsBinary=0
	Do task.EmailOnError.Insert("who@somecompany.com")
	Do task.EmailOnCompletion.Insert("who@somecompany.com")
	/// also available EmailOnCompletion and EmailOnExpiration
	Quit task.%Save()
}

}

