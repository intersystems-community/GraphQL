/// Abstract class describing interfaces you need to implement to provide your own scope control.
/// Scoppe - list of classes and fields, available for GraphQL 
Class GraphQL.Scope.Abstract [ Abstract ]
{

/// This method should return a list of classes, available for GraphQL 
ClassMethod GetClasses() As %List
{
}

/// This method should return a list of class fields, available for GraphQL 
ClassMethod GetProperties(classname As %Dictionary.CacheClassname) As %List
{
}

}

