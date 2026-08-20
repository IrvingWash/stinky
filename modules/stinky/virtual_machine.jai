execute :: (code: [..]Instruction) -> error: string {
    push_allocator(temp);

    vm: Virtual_Machine;

    vm.is_running = true;

    while vm.is_running {
        if vm.pc >= code.count {
            make_vm_error(vm, "Reached the last instruction, but didn't found the program end indicated by a HALT");
        }

        instruction := code[vm.pc];
        vm.pc += 1;

        if #complete instruction.kind == {
            case .HALT;
                vm.is_running = false;
            case .PUSH;
                push_to_stack(*vm, instruction.push.value);
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
                    return make_vm_error(vm, "Unsupported operands for ADD");
                }
            case .SUB;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number - rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for SUB");
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

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number * rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for MUL");
                }
            case .DIV;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = lhs.number / rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for DIV");
                }
            case .MOD;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = cast(float64, cast(int, lhs.number) % cast(int, rhs.number)),
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for MOD");
                }
            case .EXP;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .NUMBER,
                        number = pow(rhs.number, lhs.number),
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for EXP");
                }
            case .LT;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number < rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for LT");
                }
            case .GT;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number > rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for GT");
                }
            case .LE;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number <= rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for LE");
                }
            case .GE;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .NUMBER && lhs.kind == .NUMBER {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs.number >= rhs.number,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for GE");
                }
            case .NE;
                return make_vm_error(vm, "Unsupported operands for NE");
            case .LABEL;
                print("Warning: Encountered a label: %\n", instruction.label.name);
            case .AND;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .BOOL && lhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool && rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for AND");
                }
            case .OR;
                rhs := pop_from_stack(*vm);
                lhs := pop_from_stack(*vm);

                if rhs.kind == .BOOL && lhs.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = lhs._bool || rhs._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for OR");
                }
            case .XOR;
                return make_vm_error(vm, "Unsupported operands for XOR");
            case .NEG;
                value := pop_from_stack(*vm);
                if value.kind == .BOOL {
                    result := Value.{
                        kind = .BOOL,
                        _bool = !value._bool,
                    };
                    push_to_stack(*vm, result);
                } else {
                    return make_vm_error(vm, "Unsupported operands for NEG");
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
                } else {
                    return make_vm_error(vm, "Unsupported operands for EQ");
                }
        }
    }

    return "";
}

#scope_file

Virtual_Machine :: struct {
    stack:      [..]Value;
    pc:         int; // Program counter
    sp:         int; // Stack   pointer
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

make_vm_error :: (vm: Virtual_Machine, message: string) -> string {
    return tprint("Runtime error (PC: '%', SP: '%': %)", vm.pc, vm.sp, message);
}

#import "Basic";
#import "Math";
#import,file "instructions.jai";
