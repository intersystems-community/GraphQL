Class GraphQL.Utils.AbstractClassChildren
{

// do ##class(GraphQL.Utils.AbstractClassChildren).get()

/// Class to receive all descendants of the abstract class Abstractclasschildren
ClassMethod Get(class = "GraphQL.Abstract") As %ListOfDataTypes
{
 set:class="" class = $classname()
 &sql( DECLARE C1 CURSOR FOR
   SELECT Id INTO :Id
   FROM %Dictionary.ClassDefinition 
   WHERE Super [ :class
  )

  &sql(OPEN C1)
  &sql(FETCH C1)
 
  #dim list As %ListOfDataTypes = ##class(%ListOfDataTypes).%New()
  while (SQLCODE = 0) {
   do list.%Push(Id)   
   &sql(FETCH C1)
  }

  &sql(CLOSE C1)
  return list
}

}

