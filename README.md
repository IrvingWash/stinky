# stinky

A toy interpreted programming language made to learn how all of this works. This is an implementation of the [Pinky language](https://pinky-lang.org/)

## Usage

### With a stinky file as input
```sy
age := 17
age := age + 1

println "The value of global variable 'age' is " + age

println "Checking the age:"
if age >= 18 then
    is_cool := true
    println "Adult (" + age + ")"
else
    -- This will error because is_cool was declared in a different scope
    println "Youngster (" + age + ") and is ~" + is_cool + " cool"
    age := age - 1
end
```

```bash
stinky path_to_your_stinky_code.sy --verbose
```

### As a REPL
```bash
stinky
```

## File extension
The file extension for your stinky files is `.sy` (pronounced exactly as "sigh").
