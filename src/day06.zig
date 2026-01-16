const std = @import("std");
const utils = @import("utils");

fn solve(comptime rowCount: usize, comptime colCount: usize, input: []const u8) !struct { i64, i64 } {
    // Create a table to store the words (columns x rows)
    var table: [colCount][rowCount][]const u8 = undefined;
    var lines = std.mem.splitScalar(u8, input, '\n');
    var row_i: usize = 0;
    while (lines.next()) |line| : (row_i += 1) {
        if (line.len == 0) continue;
        var col_i: usize = 0;
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        while (words.next()) |word| : (col_i += 1) {
            table[col_i][row_i] = word;
        }
    }

    // Count for part 1
    var part1: i64 = 0;
    for (table) |col| {
        const op = col[col.len - 1];
        var result: i64 = switch (op[0]) {
            '+' => 0,
            '*' => 1,
            else => unreachable,
        };
        for (col[0 .. col.len - 1]) |word| {
            const num = try std.fmt.parseInt(i64, word, 10);
            switch (op[0]) {
                '+' => result += num,
                '*' => result *= num,
                else => unreachable,
            }
        }
        part1 += result;
    }

    const part2: i64 = 0;

    return .{ part1, part2 };
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 6169101504608;
const EXPECTED_PART2: i64 = 0;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day06.txt");
    defer allocator.free(content);

    const result = try solve(5, 1000, content);
    const part1 = result[0];
    const part2 = result[1];

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
        \\123 328   51 64
        \\ 45  64  387 23
        \\  6  98  215 314
        \\  *   +   *   +
    ;

    const result = try solve(4, 4, example_input);
    try std.testing.expectEqual(@as(i64, 4277556), result[0]);
}

test "part2 example" {
    const example_input =
        \\123 328   51 64
        \\ 45  64  387 23
        \\  6  98  215 314
        \\  *   +   *   +
    ;

    const result = try solve(4, 4, example_input);
    try std.testing.expectEqual(@as(i64, 0), result[1]);
}
