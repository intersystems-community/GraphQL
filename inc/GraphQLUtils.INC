ROUTINE GraphQLUtils [Type=INC]
/// GraphQLUtils

/// Redefines $$$TAB macro
#include %occCPTJSgen

///enum TOKEN KIND
#define EOF  1
#define BANG  2
#define DOLLAR  3
#define PARENL  4
#define PARENR  5
#define SPREAD  6
#define COLON  7
#define EQUALS  8
#define AT  9
#define BRACKETL  10
#define BRACKETR  11
#define BRACEL  12
#define PIPE  13
#define BRACER  14
#define NAME  15
#define INT  16
#define FLOAT  17
#define STRING  18

///enum AST NODE KIND
#define Name 0
#define Document 1
#define OperationDefinition 2
#define VariableDefinition 3
#define Variable 4
#define SelectionSet 5
#define Field 6
#define Argument 7
#define FragmentSpread 8
#define InlineFragment 9
#define FragmentDefinition 10
#define IntValue 11
#define FloatValue 12
#define StringValue 13
#define BooleanValue 14
#define EnumValue 15
#define ListValue 16
#define ObjectValue 17
#define ObjectField 18
#define Directive 19
#define NamedType 20
#define ListType 21
#define NonNullType 22
#define SchemaDefinition 23
#define OperationTypeDefinition 24
#define ScalarTypeDefinition 25
#define ObjectTypeDefinition 26
#define FieldDefinition 27
#define InputValueDefinition 28
#define InterfaceTypeDefinition 39
#define UnionTypeDefinition 30
#define EnumTypeDefinition 31
#define EnumValueDefinition 32
#define InputObjectTypeDefinition 33
#define TypeExtensionDefinition 34
#define DirectiveDefinition 35

///enum OPERATIONS TYPE
#define QUERY "Query"
#define MUTATION "Mutation"
#define SUBSCRIPTON "Subscription"

///Other
#define NULL ""
#define Args 1
#define Fields 0
#define SCALAR "SCALAR"
#define OBJECT "OBJECT"

#define ClassSQLTable(%c)    ($$$comClassKeyGet(%c,$$$cCLASSsqlschemaname)_"."_$$$comClassKeyGet(%c,$$$cCLASSsqltablename))
