// A made up virtual machine

execute :: (code: [..]Instruction) -> error: string {
    push_allocator(temp);

    vm: Virtual_Machine;

    initialize_label_positions(*vm, code);

    vm.is_running = true;

    while vm.is_running {
        if vm.pc >= code.count {
            make_error(vm, "Reached the last instruction, but didn't found the program end indicated by a HALT");
        }

        instruction := code[vm.pc];
        vm.pc += 1;

        if #complete instruction.kind == {
            case .HALT;
                vm.is_running = false;
            case .PUSH;
                push_to_stack(*vm, instruction.push.value);
            case .POP;
                pop_from_stack(*vm);
            case .ADD;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);
                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number + rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else if lhs.kind == .STRING {
                    if #complete rhs.kind == {
                        case .NUMBER;
                            result := Value.{
                                kind = .STRING,
                                _string = tprint("%%", lhs._string, rhs.number),
                            };
                            push_to_stack(*vm, result);
                        case .BOOL;
                            result := Value.{
                                kind = .STRING,
                                _string = tprint("%%", lhs._string, rhs._bool),
                            };
                            push_to_stack(*vm, result);
                        case .STRING;
                            result := Value.{
                                kind = .STRING,
                                _string = tprint("%%", lhs._string, rhs._string),
                            };
                            push_to_stack(*vm, result);
                    }
                } else if rhs.kind == .STRING {
                    if #complete lhs.kind == {
                        case .NUMBER;
                            result := Value.{
                                kind = .STRING,
                                _string = tprint("%%", lhs.number, rhs._string),
                            };
                            push_to_stack(*vm, result);
                        case .BOOL;
                            result := Value.{
                                kind = .STRING,
                                _string = tprint("%%", lhs._bool, rhs._string),
                            };
                            push_to_stack(*vm, result);
                        case .STRING;
                            result := Value.{
                                kind = .STRING,
                                _string = tprint("%%", lhs._string, rhs._string),
                            };
                            push_to_stack(*vm, result);
                    }
                } else {
                    return make_error(vm, "Unsupported operands for ADD");
                }
            case .SUB;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number - rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for SUB");
                }
            case .PRINT;
                value := pop_from_stack(*vm);
                if #complete value.kind == {
                    case .NUMBER;
                        print("%", value.number);
                    case .STRING;
                        print(value._string);
                    case .BOOL;
                        print("%", value._bool);
                }
            case .PRINTLN;
                value := pop_from_stack(*vm);
                if #complete value.kind == {
                    case .NUMBER;
                        print("%\n", value.number);
                    case .STRING;
                        print("%\n", value._string);
                    case .BOOL;
                        print("%\n", value._bool);
                }
            case .MUL;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number * rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for MUL");
                }
            case .DIV;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number / rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for DIV");
                }
            case .MOD;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = cast(float64, cast(int, lhs.number) % cast(int, rhs.number)),
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for MOD");
                }
            case .EXP;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = pow(lhs.number, rhs.number),
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for EXP");
                }
            case .LT;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number < rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for LT");
                }
            case .GT;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number > rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for GT");
                }
            case .LE;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number <= rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for LE");
                }
            case .GE;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number >= rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for GE");
                }
            case .NE;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .BOOL && rhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool ^ rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for XOR");
                }
            case .LABEL;
                // Do nothing;
            case .AND;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .BOOL && rhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool && rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for AND");
                }
            case .OR;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .BOOL && rhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool || rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for OR");
                }
            case .XOR;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .BOOL && rhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool ^ rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for XOR");
                }
            case .NEG;
                value := pop_from_stack(*vm);
                if value.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = !value._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for NEG");
                }
            case .EQ;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if lhs.kind == .BOOL && rhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool == rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else if lhs.kind == .NUMBER && rhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number == rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else if lhs.kind == .STRING && rhs.kind == .STRING {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._string == rhs._string,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_error(vm, "Unsupported operands for EQ");
                }
            case .JMPZ;
                operand := pop_from_stack(*vm);
                if operand.kind != .BOOL {
                    return make_error(vm, "Expected a BOOL for the JMPZ instruction");
                }

                if operand._bool == false {
                    ok:, vm.pc = table_find(*vm.label_positions, instruction.jmpz.label_name);
                    if !ok {
                        return make_error(vm, tprint("Attempt to JMPZ to a undeclared label '%'", instruction.jmpz.label_name));
                    }
                }
            case .JMP;
                ok:, vm.pc = table_find(*vm.label_positions, instruction.jmp.label_name);
                if !ok {
                    return make_error(vm, tprint("Attempt to JMP to a undeclared label '%'", instruction.jmp.label_name));
                }
            case .STORE_GLOBAL;
                value := pop_from_stack(*vm);
                table_set(*vm.globals, instruction.store_global.name, value);
            case .LOAD_GLOBAL;
                ok, value := table_find(*vm.globals, instruction.load_global.name);
                if !ok {
                    return make_error(vm, tprint("Attempt to LOAD_GLOBAL unknown value from '%'", instruction.load_global.name));
                }

                push_to_stack(*vm, value);
            case .STORE_LOCAL;
                value := pop_from_stack(*vm);

                if instruction.store_local.slot >= vm.stack.count {
                    array_resize(*vm.stack, instruction.store_local.slot + 1);
                }

                vm.stack[instruction.store_local.slot] = value;
            case .LOAD_LOCAL;
                if instruction.load_local.slot >= vm.stack.count {
                    return make_error(vm, "Failed to LOAD_LOCAL because it's slot is bigger than the count of values in the stack");
                }

                value := vm.stack[instruction.load_local.slot];
                push_to_stack(*vm, value);
        }
    }

    return "";
}

#scope_file

Virtual_Machine :: struct {
    stack:      [..]Value;

    pc:         int; // Program counter
    sp:         int; // Stack   pointer

    label_positions: Table(string, int);

    globals: Table(string, Value);

    is_running: bool;
}

push_to_stack :: (vm: *Virtual_Machine, value: Value) {
    array_add(*vm.stack, value);
    vm.sp += 1;
}

pop_from_stack :: (vm: *Virtual_Machine) -> Value {
    value := pop(*vm.stack);
    vm.sp -= 1;

    return value;
}

make_error :: (vm: Virtual_Machine, message: string) -> string {
    return tprint("Runtime error (PC: '%'): %", vm.pc - 1, message);
}

initialize_label_positions :: (vm: *Virtual_Machine, code: [..]Instruction) {
    for instruction: code {
        if instruction.kind == .LABEL {
            table_set(*vm.label_positions, instruction.label.name, it_index);
        }
    }
}

#import "Basic";
#import "Math";
#import "Hash_Table";
#import,file "instructions.jai";
