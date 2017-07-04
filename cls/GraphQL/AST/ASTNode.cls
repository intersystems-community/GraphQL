Class GraphQL.AST.ASTNode Extends %Base [ Abstract ]
{

Property Kind;

Method KindGet()
{
	#define NameKind "Name"
	#define ASTNodeKind "Node"
	
	set class = ..%ClassName(1)
	if class = "GraphQL.AST.ASTNode" {
		set result = $$$ASTNodeKind
	} else {
		set result = $piece($piece(class,".",*), "GraphQL", *)
	}
	
	q result
}

// Property Kind As %String(VALUELIST = ",Name,Document,OperationDefinition,VariableDefinition,Variable,SelectionSet,Field,Argument,FragmentSpread,InlineFragment,FragmentDefinition,IntValue,FloatValue,StringValue,BooleanValue,EnumValue,ListValue,ObjectValue,ObjectField,Directive,NamedType,ListType,NonNullType,SchemaDefinition,OperationTypeDefinition,ScalarTypeDefinition,ObjectTypeDefinition,FieldDefinition,InputValueDefinition,InterfaceTypeDefinition,UnionTypeDefinition,EnumTypeDefinition,EnumValueDefinition,InputObjectTypeDefinition,TypeExtensionDefinition,DirectiveDefinition");

Property Location As GraphQLLocation;

ClassMethod a()
{
	#define NameKind "Name"
	
	set obj = $$$NameKind
}

}

