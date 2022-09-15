Include %occErrors

/// This class is an example of subclassing %SQL.CustomResultSet. Custom result sets are similar
/// to queries with TYPE = %Library.Query. Subclassing %SQL.CustomResultSet has a few advantages
/// over custom queries. Result sets are somewhat more efficient when interacting with the server.
/// The metadata for a result set is constructed from the class definition so there is never a need for
/// ROWSPEC. Also, result sets provide a more OO interface.
/// 
/// The result set created by this class contains rows (the number of rows specified at instantiation)
/// of randomly generated data.
/// 
/// When subclassing %SQL.CustomResultSet, there are a few steps that you must follow in order to produce
/// a working result set.
/// 
/// 	1.	Define properties that correspond to each column in the result row.
/// 	2.	Define private properties that you need to maintain the current state of the
/// 		result set.
/// 	3.	Override and implement %OpenCursor. In this method you will initialize the result
/// 		iterator and prepare the data for return. Report any errors encountered during execution
/// 			by setting %SQLCODE and %Message.
/// 	4.	Override and implement %Next. In this method you will retrieve the next row. If the end
/// 		of the result set is reached then return 0. Otherwise, set the row properties to the
/// 		appropriate value and return 1.
/// 	5.	Override and implement %CloseCursor. This is only necessary if you need to perform some
/// 		clean up.
/// 
/// 	If you wish to instantiate your custom result set class and return it to a caller then you must
/// implement an SQL routine (aka, "stored procedure"). This class includes an SQL routine 'CustomResult'.
/// 
/// Instances of %SQL.IResultSet are not meant to be "reused" meaning that a result set class
/// expects to be instantiated, the rows iterated over, and then destructed.
Class Sample.CustomResultSet Extends %SQL.CustomResultSet
{

// The first task is to define the properties that make up a row. Just define each property

// that corresponds to a column as a normal property. The property name is any valid identifier.

// All private properties that are assumed to be part of the result set state and are not part

// of the result row. SQLNAME, type, type parameters, etc. can all be defined.

//

// The following properties form a row:

Property ID As %Integer;

Property Name As %String;

Property Street As %String;

Property City As %String;

Property State As %String;

Property Spouse As Sample.Person;

// Then you can define some custom result set state properties. These properties are for your own use

// to maintain the result set state during the data retrieval cycle (%Next()). Old queries used qhandle

// to maintain the cursor status. Here we just use private properties.

Property ZCursorName As %String [ Private ];

Property ZCursorId As %Integer [ Private ];

/// This is a stored procedure that returns an instance of Sample.CustomResultSet to the caller. This procedure could
/// also declare input, input-output, output and return value parameters.
ClassMethod CustomResult(pRowcount As %Integer = 100) As %Status [ ReturnResultsets, SqlName = CustomResult, SqlProc ]
{
	#dim %sqlcontext as %Library.ProcedureContext
	try {
		if '$Isobject($Get(%sqlcontext)) { set %sqlcontext = ##class(%Library.ProcedureContext).%New() }
			#; The first argument passed to %New() is the SELECTMODE. It defaults to the current setting for
			#; the process ($system.SQL.GetSelectMode()).
		set tResult = ..%New(,pRowcount)
		do %sqlcontext.AddResultSet(tResult)
	}
	catch tException {
		if '$Isobject($Get(%sqlcontext)) { set %sqlcontext = ##class(%Library.ProcedureContext).%New() }
		if tException.%IsA("%Exception.SQL") { set ..%SQLCODE = tException.Code, ..%Message = tException.Data }
		elseif tException.%IsA("%Exception.StatusException") { if (tException.Code = $$$SQLError) || (tException.Code = $$$SQLCode) { set ..%SQLCODE = $Listget(tException.Data,1), ..%Message = $Listget(tException.Data,2) } }
		else { set %sqlcontext.%SQLCODE = -400, %sqlcontext.%Message = "Exception caught during Sample.CustomResult procedure execution: " _ tException.Name_":"_tException.Data }
	}
	quit $$$OK
}

/*
Then you must override the methods %OpenCursor() and %Next(). %CloseCursor() can be overridden if you need
to perform some post-retrieval cleanup when the result set is destructed.
*/
/// %OpenCursor() is used to initialize the cursor for iterating over the result set.
/// Define formal arguments if needed. They will be automatically managed. If you need
/// to access these argument values during the %OpenCursor/%Next/%CloseCursor cycle
/// then simply define private properties as needed.
Method %OpenCursor(rowCount As %Integer = 100) As %Library.Status
{
		#; initialize a temporary global and generate some random data
		#; Since there can be multiple instances of this class active in a give process it
		#; is necessary to add a qualifying subscript so the data we generate isn't stepped on
		#; by another instance. There are other possible qualifying subscripts that can be use.
		#; For example, the base global could be incremented and the result stored in a private
		#; property. That private property would then become the qualifier. The code to do so
		#; might look like this (assuming a private property called ZId):
		#;
		#; set ..ZId = $Increment(^||MyData)
		#; kill ^||MyData(..Zid)
		#; ...
		#;
		#; Subsequent references to ^||MyData would all have ..ZId as the first subscript.
	kill ^||MyData(+##this)
		#; build a random reference sample for the spouse property
	do ##class(%Library.PopulateUtils).BuildReferenceSample("Sample.Person",.spouses)
	for rowNumber = 1:1:rowCount {
		set Name = ##class(%PopulateUtils).Name()
		set Street = ##class(%PopulateUtils).Street()
		set City = ##class(%PopulateUtils).City()
		set State = ##class(%PopulateUtils).USState()
		set Spouse = ##class(%PopulateUtils).ArrayElement(.spouses)
			#; and place the randomly generated data into the private global
		set ^||MyData(+##this,0,rowNumber) = $listbuild(Name,Street,City,State,Spouse)
		set ^||MyData(+##this,1,$$$ucase(Name),rowNumber) = ""
	}
		#; initialize the iterator
	set ..ZCursorName = $Order(^||MyData(+##this,1,""))
	set ..ZCursorId = ""
	quit $$$OK
}

/// Advance the result set cursor to the next row. Returns 0 if the cursor is at the end of the
/// result set.
Method %Next(ByRef sc As %Library.Status) As %Library.Integer [ PlaceAfter = %Execute ]
{
		#; This sample uses two private properties to maintain the iterator.
		#; The first check is to see if we are at end, if so we quit with 0 (zero).
l0	if ..ZCursorName = "" { QUIT 0 }
l1	set ..ZCursorId = $Order(^||MyData(+##this,1,..ZCursorName,..ZCursorId))
	if ..ZCursorId = "" { set ..ZCursorName = $Order(^||MyData(+##this,1,..ZCursorName)),..ZCursorId = "" goto l0 }
	set rowList = ^||MyData(+##this,0,..ZCursorId)
		#; Set the row properties from the underlying data.
	set ..ID = ..ZCursorId, ..Name = $list(rowList,1), ..Street = $list(rowList,2), ..City = $list(rowList,3), ..State = $list(rowList,4)
		#; When the property's type class is swizzlable (subclass of %SerialObject, %Persistent, %Stream.Object, etc.) be sure to set the property
		#; using SetObject or SetObjectId.
	do ..SpouseSetObjectId($list(rowList,5))
		#; Increment ROWCOUNT- this is done automatically for SQL based result sets (thatis, subclasses of %ResultSet.SQL) but custom
		#; result sets must do this manually. You can also set SQLCODE if you wish.
	set ..%ROWCOUNT = ..%ROWCOUNT + 1
	quit 1
}

/// Clean up on destruct
Method %CloseCursor() As %Status
{
	Kill ^||MyData(+##this)
	set ..ZCursorName = "", ..ZCursorId = ""
	Quit $$$OK
}

}

