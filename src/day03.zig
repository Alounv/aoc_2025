const std = @import("std");
const utils = @import("utils");

// ============================================================================
// LOGIC - Core Problem Solving
// ============================================================================

fn solve(input: []const u8) !struct { i64, i64 } {
    var part1: i64 = 0;
    const part2: i64 = 0;

    // TODO: Implement solution logic
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var first: i64 = 0;
        var second: i64 = 0;
        for (line, 0..) |c, i| {
            const num: i64 = @as(i64, @intCast(c - '0'));
            if (num > first and i < (line.len - 1)) {
                first = num;
                second = 0;
            } else if (num > second) {
                second = num;
            }
        }
        part1 += first * 10 + second;
    }

    return .{ part1, part2 };
}

fn solveP1(input: []const u8) !i64 {
    const result = try solve(input);
    return result[0];
}

fn solveP2(input: []const u8) !i64 {
    const result = try solve(input);
    return result[1];
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 17087;
const EXPECTED_PART2: i64 = 0;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day03.txt");
    defer allocator.free(content);

    const part1 = try solveP1(content);
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

// Part 1

test "part1 example" {
    const example_input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;

    const result = try solveP1(example_input);
    try std.testing.expectEqual(@as(i64, 357), result);
}

// Part 2

test "part2 example" {
    const example_input =
        \\
    ;

    const result = try solveP2(example_input);
    try std.testing.expectEqual(@as(i64, 0), result);
}
