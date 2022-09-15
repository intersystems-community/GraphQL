/// Find any tasks which should be running but have not
/// 
/// Edit this class and change the who@somecompany.com to your email address and update the smtp server
/// in the SendMail method before scheduling
Class Sample.TaskExample3 Extends Sample.Task
{

/// list of email addresses ; delimited to notify 
Property Notify As %String(MAXLEN = "");

/// HealthCheck if set to 1 - Will notify that all jobs are completing successfully
Property NotifyOnOK As %Boolean [ InitialExpression = 0 ];

/// query the existing tasks look for tasks which are running and passed
/// the next run time.  If problems occur send email to notify.
Method OnTask() As %Status
{
	#dim task as %SYS.Task
	#define crlf $c(13,10)
	Set tOK=1,tMessage=""
	#; Check jobs which should have run up to five minutes ago
	Set dttm=$H,dttm=(+dttm*86400)+$p(dttm,",",2)-(5*60),dttm=(dttm\86400)_","_(dttm#86400)
	Set rs=##class(%ResultSet).%New()
	#; Exclude Suspended tasks by Suspended=0 or perhaps Suspended<>1 (Suspend and Leave)
	Set Status = rs.Prepare("SELECT ID,RunningJobNumber,Name FROM %SYS.Task where (daynextscheduled < ? OR (daynextscheduled = ? AND timenextscheduled < ?))") Quit:'Status Status
	Set Status = rs.Execute(+dttm,+dttm,$p(dttm,",",2)) Quit:'Status Status
	While rs.Next() {
		Set tID=rs.Get("ID")
		Set tPID=rs.Get("RunningJobNumber")
		Set tName=rs.Get("Name")
		#; determine if job is really running
		#; Set tProcess=##Class(SYS.Process).%OpenId(tPID) could be used if the task runs in %SYS
		If '$zu(67,0,tPID) Set tOK=0,tMessage=tMessage_$$$crlf_"Job ("_tID_") "_tName_" is not running" Continue
	}
	If 'tOK || ..NotifyOnOK {
		If tMessage="" Set tMessage="All tasks completing successfully"
		Set SendAttemptCount=0
		For  {
			Set Status=..SendMail(tMessage) 
			Quit:Status
			#; try to send the status message up to 15 times otherwise fail
			If 'Status Set SendAttemptCount=SendAttemptCount+1 If SendAttemptCount>15 Quit
			Hang 60
		}
	}
	#; If Status is an error the task will stop running.  If the EmailOnError is set up the user will be
	#; notified of the problem
	Quit Status
}

Method SendMail(pMessage As %String) As %Status
{
	set s=##class(%Net.SMTP).%New()
	set s.smtpserver="[yourmailserver]"
	set s.timezone="-0400"
 	set m=##class(%Net.MailMessage).%New()
 	set m.From="who@somecompany.com"
 	Set m.ReplyTo="who@somecompany.com"
 	Set Recipients=$tr(..Notify,",",";")
 	For i=1:1:$l(Recipients,",") {Set address=$p(Recipients,",",i) do:address]"" m.To.Insert(address)}
 	set m.Subject=..%ClassName(1)_" for system "_$zu(110)
	do m.TextData.Write(pMessage)
	set status=s.Send(m)
 	if $$$ISERR(status)  Set (m,s)="" Quit status
 	Set m="",s=""
 	quit $$$OK
}

/// Example showing schedule with saving custom property values (Notify, NotifyOnOK)
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
       Set taskDef=..%New()
       Set taskDef.Notify="who@somecompany.com"
       Set taskDef.NotifyOnOK=0
       Do task.AssignSettings(taskDef)

	Quit task.%Save()
}

}

