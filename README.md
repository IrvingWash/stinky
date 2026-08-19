# stinky

A toy interpreted programming language made to learn how all of this works. This is an implementation of the [Pinky language](https://pinky-lang.org/)

## Usage

```sy
-- This set is big, so the font size of the terminal should be descreased to view it appropriately

left_edge      := -520
right_edge     := 300
top_edge       := 300
bottom_edge    := -300
x_step         := 3
y_step         := 7
max_iterations := 200

func make_mandelbrot() 
    println "Mandelbrot Set"

    for y0 := top_edge, bottom_edge, -y_step do
        for x0 := left_edge, right_edge, x_step do
            x := 0
            y := 0
            char := " "
            i := 0

            while i < max_iterations do
                x_x := x^2 / 200
                y_y := y^2 / 200

                if x_x + y_y > 800 then
                    char := i
                    if i > 9 then
                        char := "@"
                    end
                    i := max_iterations
                end
                y := x * y / 100 + y0
                x := x_x - y_y + x0
                i := i + 1
            end
            print char
        end
        println " "
    end
end

make_mandelbrot()
```

```bash
stinky path_to_your_stinky_code.sy --verbose
```

`--verbose` emits the stinky source code, the stinky tokens and the stinky AST

## File extension
The file extension for your stinky files is `.sy` (pronounced exactly as "sigh").
