Class GraphQL.AST.GraphQLOperationDefinition Extends ASTNode
{

Property Directives As list Of GraphQLDirective;

Property VariableDefinitions As list Of GraphQLVariableDefinition;

/// @DoNotHash
Property Name As GraphQLName;

Property Operation As %String;

Property SelectionSet As GraphQLSelectionSet;

}

