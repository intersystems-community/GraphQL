Class GraphQL.UnitTests.Parser Extends %UnitTest.TestCase
{

ClassMethod GetAst(query As %String, Output ast As GraphQL.AST.GraphQLDocument) As %Status
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

Method TestDataTypeFields()
{
	set query = "{ hero{ name }}"
	set sc = ..GetAst(query)
	//do $$$AssertStatusNotOK(sc,"Fields is not supported")
	do $$$AssertStatusOK(sc,"Fields is supported")
}

Method TestObjectFields()
{
	set query = "{ hero{ name friends{ name }}}"
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Object fields is not supported")
	do $$$AssertStatusOK(sc,"Object fields is supported")
}

Method TestArguments()
{
	set query = "{ human(id: ""1000""){ name }}"
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Arguments is not supported")
	do $$$AssertStatusOK(sc,"Arguments is supported")
}

Method TestAliases()
{
	set query = "{empireHero: hero(episode: EMPIRE) {name}"_
				 "jediHero: hero(episode: JEDI) {name}}"
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Aliases is not supported")
	do $$$AssertStatusOK(sc,"Aliases is supported")
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
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query_$c(10)_fragment))
	do $$$AssertStatusNotOK(sc,"Fragments is not supported")
	do $$$AssertStatusOK(sc,"Fragments is supported")
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
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Variables is not supported")
	do $$$AssertStatusOK(sc,"Variables is supported")
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
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Default variables is not supported")
	do $$$AssertStatusOK(sc,"Default variables is supported")
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
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Directives is not supported")
	do $$$AssertStatusOK(sc,"Directives is supported")
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
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Inline fragment is not supported")
	do $$$AssertStatusOK(sc,"Inline fragment is supported")
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
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Meta fields is not supported")
	do $$$AssertStatusOK(sc,"Metaf ields is supported")
}

Method TestMutation()
{
	set query = "mutation CreateReviewForEpisode($ep: Episode!, $review: ReviewInput!) {"_
  					"createReview(episode: $ep, review: $review) {"_
    					"stars"_
    					"commentary"_
  					"}"_
				"}"
	set sc = $system.Status.DisplayError(##class(GraphQL.Utils.Test).GetAst(query))
	do $$$AssertStatusNotOK(sc,"Mutation is not supported")
	do $$$AssertStatusOK(sc,"Mutation is supported")
}

}

