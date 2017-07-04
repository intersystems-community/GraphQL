Class GraphQL.AST.GraphQLOperationDefinition Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property VariableDefinitions As list Of GraphQLVariableDefinition;

Property Name As GraphQLName;

Property Operation As %String(VALUELIST = "Query,Mutation,Subscription");

Property SelectionSet As GraphQLSelectionSet;

}

