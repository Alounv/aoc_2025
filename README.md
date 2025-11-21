# Advent of Code 2025 - Zig Solutions

This repository contains solutions for [Advent of Code 2025](https://adventofcode.com/2025) written in [Zig](https://ziglang.org/).

## Structure

```
aoc_2025/
├── src/
│   ├── day01.zig       # Day 1 solution
│   ├── day02.zig       # Day 2 solution
│   ├── ...
│   ├── day25.zig       # Day 25 solution
│   └── utils.zig       # Shared utilities
├── inputs/
│   ├── day01.txt       # Puzzle input for day 1
│   ├── day02.txt       # Puzzle input for day 2
│   ├── ...
│   └── day25.txt       # Puzzle input for day 25
└── build.zig           # Zig build configuration
```

## Prerequisites

- Zig 0.13.0 or later
- Download from: https://ziglang.org/download/

## Usage

### Building All Solutions

Build all existing day solutions:

```bash
zig build
```

Executables will be placed in `zig-out/bin/` (e.g., `zig-out/bin/day01`, `zig-out/bin/day02`).

### Running a Solution

Run a specific day's solution:

```bash
./zig-out/bin/day01
```

Or for any other day:

```bash
./zig-out/bin/dayXX
```

### Running Tests

Run all tests for all existing days:

```bash
zig build test
```

The build system automatically detects which day files exist and only tests those.

### Workflow for Each Day

1. Create a new solution file: `src/dayXX.zig` (copy from `src/day01.zig` as a template)
2. Add your puzzle input to `inputs/dayXX.txt` (download from Advent of Code)
3. Edit `src/dayXX.zig`:
   - Update the test blocks with example inputs from the puzzle description
   - Implement your solution functions
   - Update the expected results in the main function
4. Build and test: `zig build && zig build test`
5. Run your solution: `./zig-out/bin/dayXX`
6. Submit your answers on Advent of Code!

## Template for New Days

Copy the day01 template:

```bash
cp src/day01.zig src/day05.zig
touch inputs/day05.txt
```

Then update:
- In `src/day05.zig`: Implement your solution and update tests
- In `inputs/day05.txt`: Add your puzzle input

The build system will automatically pick up the new day.

## Tips

- Start by adding example inputs from the puzzle to the test blocks
- Implement solutions incrementally - get Part 1 working before Part 2
- Run `zig build test` frequently to verify your logic
- Use test blocks to verify edge cases and corner cases
- Keep your solution functions pure and testable
- Use the Zig REPL for quick experimentation: `zig repl`
- Leverage Zig's compile-time features for performance
- Use allocators appropriately - the GPA (General Purpose Allocator) is good for development

## Project Structure Details

- `src/utils.zig`: Contains shared utility functions like:
  - `readInput`: Read input files
  - `parseLines`: Parse input into non-empty lines
  - `splitOnBlankLines`: Split input on double newlines
  - `parseNumbers`: Parse space-separated numbers
- `build.zig`: Automatically builds all existing day solutions and sets up test steps

## Resources

- [Advent of Code 2025](https://adventofcode.com/2025)
- [Zig Documentation](https://ziglang.org/documentation/master/)
- [Zig Language Reference](https://ziglang.org/documentation/master/#Introduction)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)

## License

Solutions are provided as-is for educational purposes.
