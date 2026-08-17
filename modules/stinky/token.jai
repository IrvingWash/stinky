Token :: struct {
    type:        Token_Type;
    lexeme:      string;
    line_number: u32;
}

Token_Type :: enum {
    UNKNOWN;

    PLUS;
    MINUS;
    STAR;
    L_PAREN;
    R_PAREN;
    L_CURLY;
    R_CURLY;
    L_SQUARE;
    R_SQUARE;
    DOT;
    COMMA;
    CARET;
    SLASH;
    SEMICOLON;
    QUESTION;
    MODULO;
    HASH;
    NOT;
    LESS;
    GREATER;
    COLON;
    EQUALS;

    EQUALS_EQUALS;
    NOT_EQUALS;
    LESS_EQUALS;
    GREATER_EQUALS;
    ASSIGN; // :=

    INTEGER;
    FLOAT;
    STRING;
    IDENTIFIER;

    IF;
    THEN;
    ELSE;
    TRUE;
    FALSE;
    AND;
    OR;
    WHILE;
    DO;
    FOR;
    FUNC;
    NULL;
    END;
    PRINT;
    PRINTLN;
}

Keyword :: struct {
    lexeme:     string;
    token_type: Token_Type;
}

KEYWORDS :: Keyword.[
    { "if",      .IF      },
    { "then",    .THEN    },
    { "else",    .ELSE    },
    { "true",    .TRUE    },
    { "false",   .FALSE   },
    { "and",     .AND     },
    { "or",      .OR      },
    { "while",   .WHILE   },
    { "do",      .DO      },
    { "for",     .FOR     },
    { "func",    .FUNC    },
    { "null",    .NULL    },
    { "end",     .END     },
    { "print",   .PRINT   },
    { "println", .PRINTLN },
];
