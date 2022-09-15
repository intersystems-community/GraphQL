/// This sample registered object represent the identification information for a person.  
/// This class is used to illustrate return a list of objects using XML.
Class Sample.PersonIdentification Extends (%RegisteredObject, %XML.Adaptor)
{

/// Id of Person record in the database.
Property ID As %String;

/// Person's name.
Property Name As %String [ Required ];

/// Person's Social Security number. This is validated using pattern match.
Property SSN As %String(PATTERN = "3N1""-""2N1""-""4N") [ Required ];

/// Person's Date of Birth.
Property DOB As %Date;

}

