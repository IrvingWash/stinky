Expression :: union kind: Expression_Kind {
    .INTEGER,,         integer:         Integer;
    .FLOAT,,           _float:          Float;
    .BINARY_OPERATOR,, binary_operator: Binary_Operator;
    .UNARY_OPERATOR,,  unary_operator:  Unary_Operator;
    .GROUPING,,        grouping:        Grouping;
}

Expression_Kind :: enum {
    INTEGER;
    FLOAT;
    BINARY_OPERATOR;
    UNARY_OPERATOR;
    GROUPING;
}

Integer :: struct {
    value: int;
}

Float :: struct {
    value: float;
}

Binary_Operator :: struct {
    op:        Token;
    lhs_index: int;
    rhs_index: int;
}

Unary_Operator :: struct {
    op:            Token;
    operand_index: int;
}

Grouping :: struct {
    index: int;
}



#scope_file

#import,file "token.jai";
