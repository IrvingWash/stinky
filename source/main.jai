#placeholder DEBUG;

#import "Basic"()(
    MEMORY_DEBUGGER                 = DEBUG,
    TEMP_ALLOCATOR_OVERWRITE_MEMORY = DEBUG,
);

main :: () {
    #if DEBUG {
        defer report_memory_leaks();
    }

    print("Hello, Sailor!\n");
}
