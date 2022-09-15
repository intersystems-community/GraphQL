Include %occInclude

/// <p>Sample.ResultSets
/// </p>
/// <p>
/// This class contains several methods that show how to instantiate and interact with result sets
/// using dynamic SQL. Some of these methods can be called as stored procedures. Class methods that
/// are SQLPROCs can also be executed from the command line and if they RETURNRESULTSETS then
/// those results can be displayed by calling %sqlcontext.%Display(). In addition, the methods projected
/// as SQLPROC can be called using dynamic SQL - either from the command line or through the SQL Shell.
/// Examples of different call styles are described for each method.
/// </p>
/// <p>
/// A 'result set' is an instance of %SQL.IResultSet. A result set can be returned by executing a
/// dynamic SQL SELECT or CALL statement. There are many different result set classes but they all
/// implement the interface of %SQL.IResultSet. There are some legacy result set classes that extend
/// %Library.IResultSet. The %Library.IResultSet interface is almost completely compatible with %SQL.IResultSet.
/// The most significant difference being some subtle differences in the metadata classes.
/// </p>
/// <p>
/// The simplest way to instantiate a result set is to execute a dynamic SQL SELECT statement. All
/// dynamic SQL statements return an instance of %SQL.StatementResult. %SQL.StatementResult is the
/// output statement descriptor and it defines the result interface. If the statement result object is
/// a result set object then %ResultColumnCount is greater than zero.
/// </p>
/// <p>
/// Result sets can also be returned by executing a CALL statement. There are two ways to return result sets
/// from an SQL invoked routine (SIR). The first is referred to in the SQL standard as a "prepared cursor".
/// A prepared cursor result is returned by calling a stored procedure projected from a class query.
/// </p>
/// <p>
/// The second mechanism allows for multiple result sets to be returned from an SQL invoked routine (stored
/// procedure) that is projected by a class method that is defined to return result sets. The collection
/// of result sets returned by calling such a routine (SIR) is referred to as a "result set sequence" or "RSS".
/// When a SIR that returns a non-empty result set sequence (RSS) is called then a "procedural cursor" is
/// automatically associated with the statement result object. The initial state of this cursor is unbound,
/// meaning that it is not yet bound to the first result set from the returned RSS. If the procedural cursor is
/// referenced, either directly or indirectly, then it will be bound to the next result set in the RSS
/// and that result set is removed from the RSS.
/// </p>
/// <p>
/// The result bound to the procedural cursor can be processed directly through the statement result object.
/// When the caller is finished with the result set currently bound the next result set can be bound by calling
/// the %MoreResults() method on the statement result object. That process can continue until all result sets from
/// the RSS have been processed. When that happens, %MoreResults returns zero to indicate that there are no more
/// result sets available for binding.
/// </p>
/// <p>
/// This type of binding and processing of result sets from a RSS is referred to as "serial binding". There is another
/// way to access result sets from an RSS returned by a call statement. This binding is accomplished by calling
/// the %NextResult() method on the statement result object. If %NextResult() returns a null oref then there are no
/// more result sets available for binding. Otherwise, an oref referencing a result set object will be returned and
/// the result set is removed from the RSS, making the next result available for binding immediately and can be bound
/// by invoking %NextResult() again. This style of binding is referred to as "parallel binding". The procedural cursor
/// is not bound to a result set when using this style of binding. Instead, a local variable or some other COS target
/// is bound to the result set. Several result sets can be bound at the same timed, hence the name "parallel binding".
/// </p>
/// <p>
/// If the caller mixes calls to the procedural cursor and %MoreResults() with calls to %NextResult() then a combination
/// of serial and parallel binding occurs. If the procedural cursor is referenced, binding the next result to the procedural cursor,
/// then a subsequent call to %NextResult() will bind to the result following the serially bound result. %NextResult()
/// removes the returned result set from the RSS and subsequent requests for a serially bound result will proceed with the
/// next result set in the sequence.
/// </p>
Class Sample.ResultSets [ Abstract ]
{

/// Here is an example of a classmethod (also projected as a stored procedure) that returns a result set sequence (RSS)
/// containing two result sets. This method can be called directly as a class method and the results displayed from the
/// current procedure context:
/// 	<pre>
/// 			set return = ##class(Sample.ResultSets).PersonSets("D","NY")
/// 			do %sqlcontext.%Display()
/// </pre>
/// <br>Or by a dynamic statement:
/// <pre>
/// 			set result = ##class(%SQL.Statement).%ExecDirect(,"call Sample.PersonSets('D','NY')")
/// 			do result.%Display()
/// </pre>
/// <br>
/// This method can also be invoked through the SQL Shell:
/// <pre>
/// SAMPLES>d $system.SQL.Shell()
/// SQL Command Line Shell
/// ----------------------------------------------------
/// Enter q to quit, ? for help.
/// SAMPLES>>set selectmode = display
/// 
/// selectmode = display
/// SAMPLES>>call Sample.PersonSets('A','NY')
/// 1.	call Sample.PersonSets('A','NY')
/// 
/// Dumping result #1
/// Name	DOB	Spouse	
/// Adam,Phyllis P.	10/26/2007	109
/// Adam,Vincent A.	10/18/1945	3
/// Adams,Dave M.	02/09/1938	29
/// Adams,Elmo R.	07/17/1975	22
/// Adams,Kirsten F.	03/22/1980	9
/// Adams,Stuart M.	07/31/1987	6
/// Allen,Zoe H.	11/17/1970	35
/// Alton,Charlotte S.	02/13/1940	2
/// Alton,Nellie W.	10/21/2000	11
/// Anderson,Heloisa E.	08/05/1951	
/// Avery,Jeff J.	08/01/2005	133
/// 
/// 11 Rows(s) Affected
/// 
/// Dumping result #2
/// Name	Age	Home_City	Home_State	
/// 
/// 0 Rows(s) Affected
/// ---------------------------------------------------------------------------
/// </pre>
/// And finally, it can be called from an xDBC client:
/// 
/// 	{call Sample.PersonSets('A','NY')}
/// 
/// 	The result should be two result sets displayed (in WinSQL anyway).
ClassMethod PersonSets(name As %String = "", state As %String = "MA") As %Integer [ ReturnResultsets, SqlName = PersonSets, SqlProc ]
{
		// %sqlcontext is automatically created for a method that defines SQLPROC

		// SQL result set classes can be easily prepared using dynamic SQL. %Prepare returns a
		// status value. The statement's prepare() method can also be called directly. prepare() throws
		// an exception if something goes wrong instead of returning a status value.
	set tStatement = ##class(%SQL.Statement).%New()
	try {
		do tStatement.prepare("select name,dob,spouse from sample.person where name %STARTSWITH ? order by 1")
		set tResult = tStatement.%Execute(name)
		do %sqlcontext.AddResultSet(tResult)
		do tStatement.prepare("select name,age,home_city,home_state from sample.person where home_state = ? order by 4, 1")
		set tResult = tStatement.%Execute(state)
		do %sqlcontext.AddResultSet(tResult)
		set tReturn = 1
	}
	catch tException {
		#dim tException as %Exception.AbstractException
		set %sqlcontext.%SQLCODE = tException.AsSQLCODE(), %sqlcontext.%Message = tException.SQLMessageString()
		set tReturn = 0
	}
	quit tReturn
}

/// CustomSets() is an example of a class method, projected as an SQL-callable routine, that returns two
/// result sets.
/// 
/// 		{call Sample.CustomSets()}
/// 
/// 	If you call this method as a stored procedure from the WinSQL Query window it should
/// 		display two result sets and a message window indicating the number of rows in each set.
ClassMethod CustomSets() As %Integer [ ReturnResultsets, SqlName = CustomSets, SqlProc ]
{
		// When working with custom result sets it is important to note that result sets are not
		// executable, a result set is a result of executing some other thing. In this case, refer
		// to the Sample.CustomResult class for examples of how to implement custom result classes
		// and how to instantiate and return a custom result from a class method or an SQL invoked
		// routine. Here we will use a dynamic SQL CALL to invoke the procedure implemented in the
		// Sample.CustomResult class.
		// A different error reporting style is demonstrated by using the %SQL.Statement %Prepare method.
	set tStatement = ##class(%SQL.Statement).%New()
	set tStatus = tStatement.%Prepare("call Sample.CustomResult(?)")
		// Check for an error - if one is present then report it to the context object and quit
	if $$$ISOK(tStatus) {
			// This is also an example of executing the same statement twice, each time
			// returning a result that is assigned to a different local variable.
		set rs1 = tStatement.%Execute(5)
			// Since this is the result of a call statement, it is a context object and not a simple result.
			// We will use AddContext to include this result in the result set sequence of our context
			// object.
		do %sqlcontext.AddContext(rs1)
		set rs2 = tStatement.%Execute(10)
		do %sqlcontext.AddContext(rs2)
	}
	else { set %sqlcontext.%SQLCODE = -400, %sqlcontext.%Message = "Error encountered while preparing CALL statement" }
		// Successful - you can test this method from a command prompt by executing these commands:
		//		do ##class(Sample.ResultSets).CustomSets()
		//		do %sqlcontext.%Display()
	quit 1
}

}

