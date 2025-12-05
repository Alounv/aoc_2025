const std = @import("std");
const utils = @import("utils");

// ============================================================================
// LOGIC - Core Problem Solving
// ============================================================================

fn solve(input: []const u8) struct { i64, i64 } {
    var dial: i64 = 50;
    var part1: i64 = 0;
    var part2: i64 = 0;

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        const offset = std.fmt.parseInt(i64, line[1..], 10) catch continue;
        const new_pos = switch (line[0]) {
            'L' => dial - offset,
            'R' => dial + offset,
            else => continue,
        };

        // Calculate final position with modulo (0-99)
        const curr = @mod(new_pos, 100);
        const new_dial = if (curr < 0) 100 + curr else curr;

        // Part 1: Count when we land exactly on position 0
        part1 += if (new_dial == 0) 1 else 0;

        // Part 2: Count when we cross zero - check if we cross zero by changing sign or landing exactly on zero
        const rotations: i64 = @intCast(@divFloor(@abs(new_pos), 100));
        const crosses_zero: i64 = if ((dial < 0 and new_pos > 0) or (dial > 0 and new_pos < 0) or new_pos == 0) 1 else 0;
        part2 += rotations + crosses_zero;

        dial = new_dial;
    }

    return .{ part1, part2 };
}

fn solveP1(input: []const u8) i64 {
    const result = solve(input);
    return result[0];
}

fn solveP2(input: []const u8) i64 {
    const result = solve(input);
    return result[1];
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 1074;
const EXPECTED_PART2: i64 = 6254;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day01.txt");
    defer allocator.free(content);

    const part1 = solveP1(content);
    const part2 = solveP2(content);

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
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;

    const result = solveP1(example_input);
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "part2 example" {
    const example_input =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
    ;

    const result = solveP2(example_input);
    try std.testing.expectEqual(@as(i64, 6), result);
}

test "part2 R250" {
    const result = solveP2("R250");
    try std.testing.expectEqual(@as(i64, 3), result);
}

test "part2 L150" {
    const result = solveP2("L150");
    try std.testing.expectEqual(@as(i64, 2), result);
}

test "part2 R50" {
    const result = solveP2("R50");
    try std.testing.expectEqual(@as(i64, 1), result);
}

test "part2 L300" {
    const result = solveP2("L300");
    try std.testing.expectEqual(@as(i64, 3), result);
}
