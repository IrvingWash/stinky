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

    source, ok := read_entire_file(config.file_path);
    if !ok {
        terminate("Failed to read '%'\n", config.file_path);
    }
    defer free(source);

    stinky.run(source, config.verbose);
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
