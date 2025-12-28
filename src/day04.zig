const std = @import("std");
const utils = @import("utils");

// ============================================================================
// LOGIC - Core Problem Solving
// ============================================================================

fn removeAndCount(comptime max: usize, grid: *[max][max]u8) i64 {
    var removed: i64 = 0;

    // First pass: mark points to remove with 'X'
    for (0..max) |l| {
        for (0..max) |c| {
            if (grid[l][c] != '@') continue;

            const neighbors = [8]u8{
                grid[l - 1][c - 1],
                grid[l - 1][c],
                grid[l - 1][c + 1],
                grid[l][c - 1],
                grid[l][c + 1],
                grid[l + 1][c - 1],
                grid[l + 1][c],
                grid[l + 1][c + 1],
            };

            const adjacent_rolls = std.mem.count(u8, &neighbors, &[_]u8{'@'}) + std.mem.count(u8, &neighbors, &[_]u8{'X'});

            if (adjacent_rolls < 4) {
                removed += 1;
                grid[l][c] = 'X';
            }
        }
    }

    // Second pass: convert all 'X' to '.'
    for (0..max) |l| {
        for (0..max) |c| {
            if (grid[l][c] == 'X') {
                grid[l][c] = '.';
            }
        }
    }

    return removed;
}

fn solveP1(comptime max: usize, input: []const u8) i64 {
    var grid = utils.getGrid(max, input);
    // utils.printGrid(max, grid);
    return removeAndCount(max, &grid);
}

fn solveP2(comptime max: usize, input: []const u8) i64 {
    var grid = utils.getGrid(max, input);
    var removed = removeAndCount(max, &grid);
    var total = removed;
    while (removed > 0) {
        // utils.printGrid(max, grid);
        removed = removeAndCount(max, &grid);
        total += removed;
    }
    return total;
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 1320;
const EXPECTED_PART2: i64 = 8354;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day04.txt");
    defer allocator.free(content);

    const part1 = solveP1(139, content);
    const part2 = solveP2(139, content);

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
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;

    const result = solveP1(12, example_input);
    try std.testing.expectEqual(@as(i64, 13), result);
}

test "part2 example" {
    const example_input =
        \\..@@.@@@@.
        \\@@@.@.@.@@
        \\@@@@@.@.@@
        \\@.@@@@..@.
        \\@@.@@@@.@@
        \\.@@@@@@@.@
        \\.@.@.@.@@@
        \\@.@@@.@@@@
        \\.@@@@@@@@.
        \\@.@.@@@.@.
    ;

    const result = solveP2(12, example_input);
    try std.testing.expectEqual(@as(i64, 43), result);
}
