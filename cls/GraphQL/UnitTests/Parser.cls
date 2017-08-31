/// Unit tests
/// set ^UnitTestRoot = "C:\temp\CacheQL\cls\GraphQL\UnitTests\"
/// do ##class(sc.code).export()
/// do ##class(%UnitTest.Manager).RunTest("","/loadudl/nodelete")
Class GraphQL.UnitTests.Parser Extends %UnitTest.TestCase
{

ClassMethod GetAst(query As %String = {##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(),"IQ").Data.Read()}, Output ast As GraphQL.AST.GraphQLDocument) As %Status
{
	#dim sc As %Status = $$$OK
	set parser = ##class(GraphQL.Parser).%New()
	try {	
		set ast = parser.Parse(##class(GraphQL.Source).%New(query))
	} catch ex {
		set sc = ex.AsStatus()
	}
	quit sc
}

XData IQ
{
query{
  Sample_Person{
    id
    Name
	FavoriteColors
    DOB
  }
}
}

Method TestDataTypeFields()
{
	set query = "{ hero{ name }}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Fields are supported")
}

Method TestObjectFields()
{
	set query = "{ hero{ name friends{ name }}}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Object fields are supported")
}

Method TestArguments()
{
	set query = "{ human(id: ""1000""){ name }}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Arguments are supported")
}

Method TestAliases()
{
	set query = "{empireHero: hero(episode: EMPIRE) {name}"_
				 "jediHero: hero(episode: JEDI) {name}}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Aliases are supported")
}

Method TestFragments()
{
	set query = "{"_
				   "leftComparison: hero(episode: EMPIRE) {...comparisonFields}"_
				   "rightComparison: hero(episode: JEDI){...comparisonFields}"_
				"}"

	set fragment = "fragment comparisonFields on Character{"_
						"name"_ 
						"appearsIn"_ 
						"friends{"_
				    		"name}"_
				   "}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Fragments are supported")
}

Method TestVariables()
{
	set query = "query HeroNameAndFriends($episode: Episode) {"_
 	 				"hero(episode: $episode) {"_
    					"name"_
    					"friends {"_
      						"name"_
    					"}"_
  					"}"_
				"}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Variables are supported")
}

Method TestDefaultVariables()
{
	set query = "query HeroNameAndFriends($episode: Episode = ""JEDI"") {"_
 	 				"hero(episode: $episode) {"_
    					"name"_
    					"friends {"_
      						"name"_
    					"}"_
  					"}"_
				"}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Default variables are supported")
}

Method TestDirectives()
{
	set query = "query Hero($episode: Episode, $withFriends: Boolean!) {"_
 	 				"hero(episode: $episode) {"_
    					"name"_
    					"friends @include(if: $withFriends){"_
      						"name"_
    					"}"_
  					"}"_
				"}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Directives are supported")
}

Method TestInlineFragment()
{
	set query = "query HeroForEpisode($ep: Episode!) {"_
				  "hero(episode: $ep) {"_
				    "name"_
				    "... on Droid {"_
				      "primaryFunction"_
				    "}"_
				    "... on Human {"_
				      "height"_
				    "}"_
				  "}"_
				"}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Inline fragment are supported")
}

Method TestMetaFields()
{
	set query = "{search(text: ""an"") {"_
				    "__typename"_
				    "... on Human {"_
				      "name"_
				    "}"_
				    "... on Droid {"_
				      "name"_
				    "}"_
				    "... on Starship {"_
				      "name"_
				    "}"_
				  "}"_
				"}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Meta fields are supported")
}

Method TestMutation()
{
	set query = "mutation CreateReviewForEpisode($ep: Episode!, $review: ReviewInput!) {"_
  					"createReview(episode: $ep, review: $review) {"_
    					"stars"_
    					"commentary"_
  					"}"_
				"}"
	set sc = ..GetAst(query)
	do $$$AssertStatusOK(sc,"Mutation are supported")
}

}

