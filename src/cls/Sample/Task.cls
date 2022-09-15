/// Task definition is divided into two sections
/// 		- The task schedule; when it will run
/// 		- The task class; what it will do when it is running
/// 
/// Generally tasks should be scheduled using the system management portal.
/// If you need to schedule tasks programatically you can find examples at the bottom of this class.
/// 
/// A series of task classes are defined to demonstrate potential usage
/// For these examples we rely on the MailServer being set 
/// 	System Management Portal [Home]> [Configuration] > [Task Manager Settings] > [E-Mail Settings] 
/// 		The SMTP server must be defined, also any authorization which is required for the mail server
/// Sample.Task
/// 		Demonstrate what happens when a task encounters a runtime error
/// 
/// Sample.TaskExample1
/// 		Demonstrates a task which fails every other time it executes
/// Sample.TaskExample2
/// 		Using output files
/// Sample.TaskExample3
/// 		Demonstrates how to look for problems with your tasks (not running)
/// 
/// 
/// Edit this class and change the who@somecompany.com to your email address 
/// 
Class Sample.Task Extends %SYS.Task.Definition
{

/// Property to keep track of how many times this task has run
Property RunCount As %String;

/// Demonstrate what happens when a task encounters a runtime error
/// The first time the task runs, it will succeed
/// The second time the task runs
/// 	The task will be marked as suspended
/// The third time the task runs
/// 	The task will be marked as suspended
/// 		An error will be generated in the system error trap 
/// Trapping errors using %ETN is already performed, therefore you should NOT set $ETRAP="^%ETN" ($ZT) this
/// will cause the process to Halt and not clean up properly
/// Never end the method by using HALT as this will cause the same problem as using ^%ETN
/// This does not mean that you can't trap and handle your errors.  See the AlternativeOnTask method 
/// which demonstrates how you can handle expected problems
Method OnTask() As %Status
{
	Set ..RunCount=..RunCount+1
	If '(..RunCount#2) Quit $$$ERROR($$$GeneralError,"My task failed")
	If '(..RunCount#3) Write 1/0
	/// Returning a status other than OK will mark the task as Suspended
	Quit $$$OK
}

/// Assuming that you want to handle an error it is safe do the following
/// it is just unsafe to Set $ZT="^%ETN" as this ends with a Halt
Method AlternativeOnTask() As %Status
{
	Set $ZT="Error"
	Set ..RunCount=..RunCount+1
	If '(..RunCount#2) Quit $$$ERROR($$$GeneralError,"My task failed")
	// Definitely throw an error
	If '(..RunCount#3) Write 1/0
	/// Returning a status other than OK will mark the task as Suspended
	Quit $$$OK
Error	///
	Set $ZT=""
	/// Maybe handle the error and quit $$$OK or just return the error
	Quit $$$ERROR($$$CacheError,$ZE)
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
	Set task.Expires=1
	Set task.ExpiresHours=18
	Set task.ExpiresMinutes=30
	Do task.EmailOnError.Insert("who@somecompany.com")
	/// also available EmailOnCompletion and EmailOnExpiration
	Quit task.%Save()
}

/// Example code to demonstrate programatically scheduling a task to run EveryHour between 9am - 5pm
/// In this example Expires=0 and therefore the task will run every time it is scheduled, this is useful
/// for cases where reports need to be generated based on a certain time, the report needs to be run
/// after the time has passed, it can't be skipped.  In this case you would probably use ..%RunDate 
/// and ..%RunTime in the OnTask method
ClassMethod ScheduleHourly() As %Status
{
	#dim task as %SYS.Task
	Set task=##Class(%SYS.Task).%New()
	Set task.Name=..%ClassName(1)
	Set task.TaskClass=..%ClassName(1)  // The name of the Task Class (where OnTask is)
	Set task.NameSpace=$zu(5)  // Namespace the task will run in
	Set task.DailyFrequency=task.DailyFrequencyDisplayToLogical("Several")
	Set task.DailyFrequencyTime=task.DailyFrequencyTimeDisplayToLogical("Hourly")
	Set task.DailyIncrement=1  // (every 1 hour or minutes depending on DailyFrequencyTime)
	Set task.DailyStartTime=$zth("09:00")
	Set task.DailyEndTime=$zth("17:00")
	Set task.Expires=0
	Do task.EmailOnError.Insert("who@somecompany.com")
	/// also available EmailOnCompletion and EmailOnExpiration
	Quit task.%Save()
}

/// Schedule task to run weekly at 3:00 am on Wednesday between January 31, 2014 and February 15, 2014
/// In this example, if the task has not run within 5 days of the scheduled start it will
/// "Expire" and not run again until the next start time
ClassMethod ScheduleWeekly() As %Status
{
	#dim task as %SYS.Task
	Set task=##Class(%SYS.Task).%New()
	Set task.Name=..%ClassName(1)  // The name to display in the utilities
	Set task.TaskClass=..%ClassName(1)  // The name of the Task Class (where OnTask is)
	Set task.NameSpace=$zu(5)  // Where namespace the task will run in
	Set task.DailyFrequency=task.DailyFrequencyDisplayToLogical("Once")
	Set task.TimePeriod=task.TimePeriodDisplayToLogical("Weekly")
	Set task.TimePeriodEvery=1 // (every 1 week)
	Set task.TimePeriodDay=4 // (1-Sunday -> 7-Saturday and 23456 is Mon thru Fri)	
	Set task.StartDate=$zdh("2014-01-31",3)
	Set task.DailyStartTime=$zth("03:00")
	Set task.EndDate=$zdh("2014-2-15",3)
	Set task.Expires=1
	Set task.ExpiresDays=5
	Do task.EmailOnError.Insert("who@somecompany.com")
	/// also available EmailOnCompletion and EmailOnExpiration
	Quit task.%Save()
}

/// Schedule task to run monthly on the first Monday at 5:00 am 
ClassMethod ScheduleMonthly() As %Status
{
	#dim task as %SYS.Task
	Set task=##Class(%SYS.Task).%New()
	Set task.Name=..%ClassName(1)  // The name to display in the utilities
	Set task.TaskClass=..%ClassName(1)  // The name of the Task Class (where OnTask is)
	Set task.NameSpace=$zu(5)  // Where namespace the task will run in
	Set task.DailyFrequency=task.DailyFrequencyDisplayToLogical("Once")
	Set task.TimePeriod=task.TimePeriodDisplayToLogical("Monthly Special")
	Set task.TimePeriodEvery=1 // (every month)
	Set task.TimePeriodDay="1^2" // 1st ^ Monday
	Set task.StartDate=$zdh("2012-12-31",3)
	Set task.EndDate=$zdh("2014-5-15",3)
	Set task.DailyStartTime=$zth("05:00")
	Do task.EmailOnError.Insert("who@somecompany.com")
	/// also available EmailOnCompletion and EmailOnExpiration
	Quit task.%Save()

	/*
	Other similar examples
	
		Run The first day of every month
		TimePeriod=task.TimePeriodDisplayToLogical("Monthly"),TimePeriodEvery=1,TimePeriodDay=1
		
		Run the last day of every month
		TimePeriod=task.TimePeriodDisplayToLogical("Monthly"),TimePeriodEvery=1,TimePeriodDay=31
		
		Run the last day of every other month
		TimePeriod=task.TimePeriodDisplayToLogical("Monthly"),TimePeriodEvery=2,TimePeriodDay=31
		
		Run the second Saturday of every month
		TimePeriod=task.TimePeriodDisplayToLogical("Monthly Special"),TimePeriodEvery=1,TimePeriodDay=2^7
		
		Run the first Sunday of every month
		TimePeriod=task.TimePeriodDisplayToLogical("Monthly Special"),TimePeriodEvery=1,TimePeriodDay=1^1
	*/
}

/// this will schedule a task to run after another task has completed
/// since JournalSwitch happens on all systems we will use that as our trigger task
/// but any task could easily be substituted
ClassMethod ScheduleAfterAnother() As %Status
{
	#dim task as %SYS.Task
	Set taskID = 1  // we would normally use ##class(%SYS.Task).FindId(Name) but we know the ID
	Set taskGUID = ##Class(%SYS.Task).JobGUIDGetStored(taskID)
	
	#define OurName "Sample.Runafter"
	Set task=##Class(%SYS.Task).OpenId($$$OurName) /// Will find the first task with this name
	If 'task {
		Set task=##Class(%SYS.Task).%New()
		Set task.Name=$$$OurName
	}
	Set task.TaskClass=..%ClassName(1)  // The name of the Task Class (where OnTask is)
	Set task.NameSpace=$zu(5)  // Where namespace the task will run in
	Set task.RunAfterGUID=taskGUID
	Set task.TimePeriod=task.TimePeriodDisplayToLogical("Run After")
	Do task.EmailOnError.Insert("who@somecompany.com")
	/// also available EmailOnCompletion and EmailOnExpiration
	Quit task.%Save()
}

/// example programatically suspending and then resuming a task
ClassMethod SuspendAndResumeTask() As %Status
{
	Set taskID=##Class(%SYS.Task).FindId("Sample.Task")
	If 'taskID Quit $$$ERROR($$$GeneralError,"Can't find the task specified")
	Set Status=##Class(%SYS.Task).Suspend(taskID,2)  // suspend the task but reschedule 
	Quit:'Status Status // We failed to suspend it for some reason, potentially it is running
	Else  Set Status=##Class(%SYS.Task).Resume(taskID) /// resume the task
	Quit Status
}

}

