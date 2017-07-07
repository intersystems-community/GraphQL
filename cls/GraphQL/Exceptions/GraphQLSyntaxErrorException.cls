Class GraphQL.Exceptions.GraphQLSyntaxErrorException
{

ClassMethod Get(Description As %String, Source As GraphQL.Source, Loc As %Integer) As %Exception.General
{
	set Location = ##class(GraphQL.Location).%New(Source, Loc)
	return ##class(%Exception.General).%New("Syntax Error GraphQL","1",,Description_" in line "_Location.Line_" in column "_Location.Column)
}

}

