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

fn walk(comptime max: usize, grid: *[max][max]u8, cache: *[max][max]?u64, y: usize, x: usize) u64 {
    // Base case
    if (y >= max) return 1;
    // Check cache
    if (cache[y][x]) |result| return result;
    // Recursive case
    const result = switch (grid[y][x]) {
        '.' => walk(max, grid, cache, y + 1, x),
        '^' => walk(max, grid, cache, y + 1, x + 1) + walk(max, grid, cache, y + 1, x - 1),
        else => unreachable,
    };
    // Save in cache
    cache[y][x] = result;
    return result;
}

fn solveP2(comptime max: usize, input: []const u8) u64 {
    var grid = utils.getGrid(max, input);
    const x = std.mem.indexOfScalar(u8, &grid[1], 'S').?;
    var cache = [_][max]?u64{[_]?u64{null} ** max} ** max;
    return walk(max, &grid, &cache, 2, x);
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 1651;
const EXPECTED_PART2: i64 = 108924003331749;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day07.txt");
    defer allocator.free(content);

    const part1 = solveP1(143, content);
    const part2 = solveP2(143, content);

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

    const result = solveP2(143, example_input);
    try std.testing.expectEqual(@as(u64, 40), result);
}
