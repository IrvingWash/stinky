AST :: struct {
    statements: [..]Statement;
    allocator:  Allocator;
}

Node :: struct {
    line_number: int;
}

Statement :: union kind: Statement_Kind {
    #as using node: Node;
    .PRINT,,                   print_statement:         Print_Statement;
    .PRINTLN,,                 println_statement:       Println_Statement;
    .IF,,                      if_statement:            If_Statement;
    .ASSIGNMENT,,              assignment:              Assignment;
    .WHILE,,                   while_statement:         While_Statement;
    .FOR,,                     for_statement:           For_Statement;
    .FUNCTION_DECLARATION,,    function_declaration:    Function_Declaration;
    .PARAMETER_DECLARATION,,   parameter_declaration:   Parameter_Declaration;
    .FUNCTION_CALL_STATEMENT,, function_call_statement: Function_Call_Statement;
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
    .FUNCTION_CALL,,    function_call:    Function_Call;
}

Statement_Kind :: enum {
    PRINT;
    PRINTLN;
    IF;
    ASSIGNMENT;
    WHILE;
    FOR;
    FUNCTION_DECLARATION;
    PARAMETER_DECLARATION;
    FUNCTION_CALL_STATEMENT;
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
    FUNCTION_CALL;
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
    then_statements: [..]Statement;
    else_statements: [..]Statement;
}

Assignment :: struct {
    #as using node: Node;
    left:  *Expression;
    right: *Expression;
}

While_Statement :: struct {
    #as using node: Node;
    test:       *Expression;
    statements: [..]Statement;
}

For_Statement :: struct {
    #as using node: Node;
    identifier: *Expression;
    start:      *Expression;
    end:        *Expression;
    step:       *Expression;
    statements: [..]Statement;
}

Function_Declaration :: struct {
    #as using node: Node;
    name:       string;
    parameters: [..]Statement;
    statements: [..]Statement;
}

Parameter_Declaration :: struct {
    #as using node: Node;
    name: string;
}

Function_Call :: struct {
    #as using node: Node;
    name:      string;
    arguments: [..]*Expression;
}

Function_Call_Statement :: struct {
    #as using node: Node;
    expression: *Expression;
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
    op:  Token;
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
