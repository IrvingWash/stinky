AST :: struct {
    expressions: [..]Expression;
    root_index:  int = -1;
}

Node :: struct {
    line_number: int;
}

Expression :: union kind: Expression_Kind {
    .INTEGER,,          integer:          Integer;
    .FLOAT,,            _float:           Float;
    .BINARY_OPERATOR,,  binary_operator:  Binary_Operator;
    .LOGICAL_OPERATOR,, logical_operator: Logical_Operator;
    .UNARY_OPERATOR,,   unary_operator:   Unary_Operator;
    .GROUPING,,         grouping:         Grouping;
    .BOOL,,             _bool:            Bool;
    .STRING,,           _string:          String;
}

Expression_Kind :: enum {
    INTEGER;
    FLOAT;
    BINARY_OPERATOR;
    LOGICAL_OPERATOR;
    UNARY_OPERATOR;
    GROUPING;
    BOOL;
    STRING;
}

Integer :: struct {
    #as using node: Node;
    value: int;
}

Float :: struct {
    #as using node: Node;
    value: float64;
}

Bool :: struct {
    #as using node: Node;
    value: bool;
}

String :: struct {
    #as using node: Node;
    value: string;
}

Binary_Operator :: struct {
    #as using node: Node;
    op:        Token;
    lhs_index: int;
    rhs_index: int;
}

Logical_Operator :: struct {
    #as using node: Node;
    op:        Token;
    lhs_index: int;
    rhs_index: int;
}

Unary_Operator :: struct {
    #as using node: Node;
    op:            Token;
    operand_index: int;
}

Grouping :: struct {
    #as using node: Node;
    index: int;
}



#scope_file

#import,file "token.jai";
