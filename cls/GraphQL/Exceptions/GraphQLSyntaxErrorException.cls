Class GraphQL.Exceptions.GraphQLSyntaxErrorException
{

Method %OnNew(Description As %String, Source As GraphQL.Source, Loc As %Integer)
{
	set Location = ##class(GraphQL.Location).%New(Source, Loc)
	THROW ##class(%Exception.General).%New("Syntax Error GraphQL","1",,Description_" in line "_Location.Line_" in column "_Location.Column)
}

}

