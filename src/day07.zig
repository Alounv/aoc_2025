const std = @import("std");
const utils = @import("utils");

fn solveP1(comptime max: usize, input: []const u8) u64 {
    var grid = utils.getGrid(max, input);
    var part1: u64 = 0;

    for (1..grid.len) |y| {
        for (0..grid[0].len) |x| {
            const up = grid[y - 1][x];
            if (up == 'S' or up == '|') {
                switch (grid[y][x]) {
                    '.' => {
                        grid[y][x] = '|';
                    },
                    '^' => {
                        part1 += 1;
                        grid[y][x + 1] = '|';
                        grid[y][x - 1] = '|';
                    },
                    '|' => {},
                    else => unreachable,
                }
            }
        }
    }
    // utils.printGrid(max, grid);
    return part1;
}

fn solveP2(input: []const u8) !i64 {
    _ = input;
    // TODO: Implement part 2 solution
    return 0;
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 1651;
const EXPECTED_PART2: i64 = 0;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day07.txt");
    defer allocator.free(content);

    const part1 = solveP1(143, content);
    const part2 = try solveP2(content);

    // Verify expected results
    if (part1 != EXPECTED_PART1) {
        std.debug.print("Part 1 assertion failed: expected {d}, got {d}\n", .{ EXPECTED_PART1, part1 });
        return error.Part1Failed;
    }
    if (part2 != EXPECTED_PART2) {
        std.debug.print("Part 2 assertion failed: expected {d}, got {d}\n", .{ EXPECTED_PART2, part2 });
        return error.Part2Failed;
    }
}

// ============================================================================
// TESTS - Unit Tests & Examples
// ============================================================================

test "part1 example" {
    const example_input =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;

    const result = solveP1(17, example_input);
    try std.testing.expectEqual(@as(u64, 21), result);
}

test "part2 example" {
    const example_input =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
    ;

    const result = try solveP2(example_input);
    try std.testing.expectEqual(@as(i64, 0), result);
}
