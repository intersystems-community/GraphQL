Class GraphQL.AST.ASTNode Extends (%RegisteredObject, GraphQL.Utils.Hash)
{

Property Kind;

/// @DoNotHash
Property Location As GraphQLLocation;

Method KindGet()
{
	#define ASTNodeKind "Node"
	
	set class = ..%ClassName(1)
	if class = "GraphQL.AST.ASTNode" {
		set result = $$$ASTNodeKind
	} else {
		set result = $piece($piece(class,".",*), "GraphQL", *)
	}
	
	q result
}

}

