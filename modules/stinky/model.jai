AST :: struct {
    statements: Statements;
    allocator:  Allocator;
}

Node :: struct {
    line_number: int;
}

Statements :: struct {
    statements: [..]Statement;
}

Statement :: union kind: Statement_Kind {
    #as using node: Node;
    .PRINT,,      print_statement:   Print_Statement;
    .PRINTLN,,    println_statement: Println_Statement;
    .IF,,         if_statement:      If_Statement;
    .ASSIGNMENT,, assignment:        Assignment;
};

Expression :: union kind: Expression_Kind {
    .INTEGER,,          integer:          Integer;
    .FLOAT,,            _float:           Float;
    .BINARY_OPERATOR,,  binary_operator:  Binary_Operator;
    .LOGICAL_OPERATOR,, logical_operator: Logical_Operator;
    .UNARY_OPERATOR,,   unary_operator:   Unary_Operator;
    .GROUPING,,         grouping:         Grouping;
    .BOOL,,             _bool:            Bool;
    .STRING,,           _string:          String;
    .IDENTIFIER,,       identifier:       Identifier;
}

Statement_Kind :: enum {
    PRINT;
    PRINTLN;
    IF;
    ASSIGNMENT;
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
    IDENTIFIER;
}

Print_Statement :: struct {
    #as using node: Node;
    value: *Expression;
}

Println_Statement :: struct {
    #as using node: Node;
    value: *Expression;
}

If_Statement :: struct {
    #as using node: Node;
    test: *Expression;
    then_statements: Statements;
    else_statements: Statements;
}

Assignment :: struct {
    #as using node: Node;
    left:  *Expression;
    right: *Expression;
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

Identifier :: struct {
    #as using node: Node;
    name: string;
}

Binary_Operator :: struct {
    #as using node: Node;
    op:        Token;
    lhs: *Expression;
    rhs: *Expression;
}

Logical_Operator :: struct {
    #as using node: Node;
    op:  Token;
    lhs: *Expression;
    rhs: *Expression;
}

Unary_Operator :: struct {
    #as using node: Node;
    op:      Token;
    operand: *Expression;
}

Grouping :: struct {
    #as using node: Node;
    value: *Expression;
}



#scope_file

#import,file "token.jai";
