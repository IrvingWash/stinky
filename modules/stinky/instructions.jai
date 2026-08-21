Instruction :: union kind: Instruction_Kind {
    .PUSH,,         push:         Push_Instruction;
    .ADD,,          add:          No_Operand_Instruction;
    .SUB,,          sub:          No_Operand_Instruction;
    .PRINT,,        print:        No_Operand_Instruction;
    .PRINTLN,,      println:      No_Operand_Instruction;
    .MUL,,          mul:          No_Operand_Instruction;
    .DIV,,          div:          No_Operand_Instruction;
    .MOD,,          mod:          No_Operand_Instruction;
    .EXP,,          exp:          No_Operand_Instruction;
    .LT,,           lt:           No_Operand_Instruction;
    .GT,,           gt:           No_Operand_Instruction;
    .LE,,           le:           No_Operand_Instruction;
    .GE,,           ge:           No_Operand_Instruction;
    .EQ,,           eq:           No_Operand_Instruction;
    .NE,,           ne:           No_Operand_Instruction;
    .LABEL,,        label:        Label_Instruction;
    .HALT,,         halt:         No_Operand_Instruction;
    .AND,,          and:          No_Operand_Instruction;
    .OR,,           or:           No_Operand_Instruction;
    .XOR,,          xor:          No_Operand_Instruction;
    .NEG,,          neg:          No_Operand_Instruction;
    .JMPZ,,         jmpz:         Jump_Instruction;
    .JMP,,          jmp:          Jump_Instruction;
    .STORE_GLOBAL,, store_global: Store_Global_Instruction;
    .LOAD_GLOBAL,,  load_global:  Load_Global_Instruction;
}

Instruction_Kind :: enum {
    PUSH;
    ADD;
    SUB;
    PRINT;
    PRINTLN;
    MUL;
    DIV;
    MOD;
    EXP;
    LT;
    GT;
    LE;
    GE;
    EQ;
    NE;
    LABEL;
    HALT;
    AND;
    OR;
    XOR;
    NEG;
    JMPZ;
    JMP;
    STORE_GLOBAL;
    LOAD_GLOBAL;
}

Push_Instruction :: struct {
    value:  Value;
}

No_Operand_Instruction :: struct {}

Label_Instruction :: struct {
    name: string;
}

Jump_Instruction :: struct {
    label_name: string;
}

Store_Global_Instruction :: struct {
    name: string;
}

Load_Global_Instruction :: struct {
    name: string;
}

Value :: union kind: Value_Type {
    .NUMBER,, number:  float64;
    .STRING,, _string: string;
    .BOOL,,   _bool:   bool;
}

Value_Type :: enum {
    NUMBER;
    STRING;
    BOOL;
}

prettify_instruction :: (instruction: Instruction, builder: *String_Builder, depth: *int) {
    apply_depth :: (builder: *String_Builder, depth: int) {
        for 1..depth {
            print(builder, "    ");
        }
    }

    if #complete instruction.kind == {
        case .PUSH;
            apply_depth(builder, depth.*);
            print(builder, "PUSH ");
            if #complete instruction.push.value.kind == {
                case .NUMBER;
                    print(builder, "%\n", instruction.push.value.number);
                case .STRING;
                    print(builder, "%\n", instruction.push.value._string);
                case .BOOL;
                    print(builder, "%\n", instruction.push.value._bool);
            }
        case .JMPZ;
            apply_depth(builder, depth.*);
            print(builder, "JMPZ %\n", instruction.jmpz.label_name);
        case .JMP;
            apply_depth(builder, depth.*);
            print(builder, "JMP %\n", instruction.jmp.label_name);
        case .ADD;
            apply_depth(builder, depth.*);
            print(builder, "ADD\n");
        case .SUB;
            apply_depth(builder, depth.*);
            print(builder, "SUB\n");
        case .PRINT;
            apply_depth(builder, depth.*);
            print(builder, "PRINT\n");
        case .PRINTLN;
            apply_depth(builder, depth.*);
            print(builder, "PRINTLN\n");
        case .MUL;
            apply_depth(builder, depth.*);
            print(builder, "MUL\n");
        case .DIV;
            apply_depth(builder, depth.*);
            print(builder, "DIV\n");
        case .MOD;
            apply_depth(builder, depth.*);
            print(builder, "MOD\n");
        case .EXP;
            apply_depth(builder, depth.*);
            print(builder, "EXP\n");
        case .LT;
            apply_depth(builder, depth.*);
            print(builder, "LT\n");
        case .GT;
            apply_depth(builder, depth.*);
            print(builder, "GT\n");
        case .LE;
            apply_depth(builder, depth.*);
            print(builder, "LE\n");
        case .GE;
            apply_depth(builder, depth.*);
            print(builder, "GE\n");
        case .EQ;
            apply_depth(builder, depth.*);
            print(builder, "EQ\n");
        case .NE;
            apply_depth(builder, depth.*);
            print(builder, "NE\n");
        case .LABEL;
            depth.* = 1;
            print(builder, "%:\n", instruction.label.name);
        case .HALT;
            apply_depth(builder, depth.*);
            print(builder, "HALT\n");
        case .OR;
            apply_depth(builder, depth.*);
            print(builder, "OR\n");
        case .AND;
            apply_depth(builder, depth.*);
            print(builder, "AND\n");
        case .XOR;
            apply_depth(builder, depth.*);
            print(builder, "XOR\n");
        case .NEG;
            apply_depth(builder, depth.*);
            print(builder, "NEG\n");
        case .STORE_GLOBAL;
            apply_depth(builder, depth.*);
            print(builder, "STORE_GLOBAL %\n", instruction.store_global.name);
        case .LOAD_GLOBAL;
            apply_depth(builder, depth.*);
            print(builder, "LOAD_GLOBAL %\n", instruction.load_global.name);
    }
}



#scope_file

#import "Basic";
