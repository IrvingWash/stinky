#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

#import "File";
#import "Print_Color";

stinky :: #import "stinky"()(DEBUG);

#load "config.jai";

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    setup_formatting();

    error, config := make_config_from_arguments();
    if error {
        terminate("Failed: %\n", error);
    }
    defer destroy_config(config);

    if config.repl {
        run_repl();
    } else {
        source, ok := read_entire_file(config.file_path);
        if !ok {
            terminate("Failed to read '%'\n", config.file_path);
        }
        defer free(source);

        error := stinky.run(source, config.verbose);
        if error {
            terminate("Failed: %\n", error);
        }
    }
}

run_repl :: () {
    print_color("stinky repl:\n", color = .BLUE, style = .UNDERLINE);

    while true {
        buffer: [1024]u8;

        #if OS == {
            case .LINUX;
                #import "POSIX";
                #import "String";

                print("\n");

                fgets(buffer.data, buffer.count, stdin);
                source := trim(to_string(buffer));

                error := stinky.run(source, false);
                if error {
                    print_color("Failed: %\n", error, color =  .RED, to_standard_error = true);
                }
            case;
                terminate("Stinky REPL is not supported for your OS");
        }
    }
}

terminate :: (format_string: string, args: ..Any) {
    print_color(format_string, ..args, .RED, to_standard_error = true);

    exit(1);
}

setup_formatting :: () {
    print_style := *context.print_style;

    print_style.default_format_struct.draw_type_name = true;
    print_style.default_format_struct.use_long_form_if_more_than_this_many_members = 0;
    print_style.default_format_struct.use_newlines_if_long_form = true;
}
