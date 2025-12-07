const std = @import("std");
const utils = @import("utils");

// ============================================================================
// LOGIC - Core Problem Solving
// ============================================================================

// Strategy (for 12 on 16)
// - [0..4] - find max - if max, reset following digits.
// - [1..5] - find second - if max, reset following digits.
// - [2..6] - find third digit -...

fn solveLine(line: []const u8, comptime digitsCount: usize) i64 {
    var digits = [_]u8{0} ** digitsCount;

    for (line, 0..) |c, i| {
        const num: u8 = c - '0';

        for (0..digitsCount) |n| {
            if (i > (n + line.len - digitsCount)) { // if no more space for remaining digits
                continue; // move to next digit
            }
            if (num > digits[n]) { // if new max found
                digits[n] = num; // update current digit
                @memset(digits[n + 1 ..], 0); // reset following digits
                break; // move to next character
            }
        }
    }

    // Build the number from the digits
    var result: i64 = 0;
    for (digits) |d| {
        result = result * 10 + d;
    }

    return result;
}

fn solve(input: []const u8, comptime digitsCount: usize) i64 {
    var result: i64 = 0;
    var lines = std.mem.splitScalar(u8, input, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        result += solveLine(line, digitsCount);
    }

    return result;
}

fn solveP1(input: []const u8) i64 {
    return solve(input, 2);
}

fn solveP2(input: []const u8) i64 {
    return solve(input, 12);
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 17087;
const EXPECTED_PART2: i64 = 169019504359949;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day03.txt");
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

// Part 1

test "part1 example" {
    const example_input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;

    const result = solveP1(example_input);
    try std.testing.expectEqual(@as(i64, 357), result);
}

// Part 2

test "part2 example" {
    const example_input =
        \\987654321111111
        \\811111111111119
        \\234234234234278
        \\818181911112111
    ;

    const result = solveP2(example_input);
    try std.testing.expectEqual(@as(i64, 3121910778619), result);
}
