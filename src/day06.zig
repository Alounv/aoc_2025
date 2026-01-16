const std = @import("std");
const utils = @import("utils");

// Helper functions for operator handling
fn apply(op: u8, result: i64, num: i64) i64 {
    return switch (op) {
        '+' => result + num,
        '*' => result * num,
        else => unreachable,
    };
}

fn identity(op: u8) i64 {
    return switch (op) {
        '+' => 0,
        '*' => 1,
        else => unreachable,
    };
}

fn solveP1(comptime rowCount: usize, comptime colCount: usize, input: []const u8) !i64 {
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
        const op = col[col.len - 1][0];
        var result: i64 = identity(op);
        for (col[0 .. col.len - 1]) |word| {
            const num = try std.fmt.parseInt(i64, word, 10);
            result = apply(op, result, num);
        }
        part1 += result;
    }

    return part1;
}

fn solveP2(comptime rowCount: usize, comptime charCount: usize, input: []const u8) !i64 {
    // Collect lines into array
    var linesIter = std.mem.splitScalar(u8, input, '\n');
    var lines: [rowCount][]const u8 = undefined;
    var row_i: usize = 0;
    while (linesIter.next()) |line| : (row_i += 1) {
        if (row_i >= rowCount) break;
        lines[row_i] = line;
    }
    const op_line = lines[rowCount - 1];

    var part2: i64 = 0;
    var op: u8 = '+';
    var result: i64 = -1;

    for (0..charCount) |col_i| {
        // Collect digit chars from each row at this column
        var chars: [rowCount - 1]u8 = undefined;
        var char_len: usize = 0;
        for (0..rowCount - 1) |ri| {
            if (col_i >= lines[ri].len) continue;
            const c = lines[ri][col_i];
            if (c != ' ') {
                chars[char_len] = c;
                char_len += 1;
            }
        }

        // If all empty, finalize current result and move on
        if (char_len == 0) {
            part2 += result;
            result = 0;
            continue;
        }

        // Parse the vertical number
        const num = try std.fmt.parseInt(i64, chars[0..char_len], 10);

        // Check for new operator
        if (col_i < op_line.len and (op_line[col_i] == '+' or op_line[col_i] == '*')) {
            op = op_line[col_i];
            result = identity(op);
        }

        result = apply(op, result, num);
    }

    return part2;
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 6169101504608;
const EXPECTED_PART2: i64 = 10442199710797;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day06.txt");
    defer allocator.free(content);

    const part1 = try solveP1(5, 1000, content);
    const part2 = try solveP2(5, 4000, content);

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
        \\123 328  51 64
        \\ 45 64  387 23
        \\  6 98  215 314
        \\*   +   *   +
    ;

    const result = try solveP1(4, 4, example_input);
    try std.testing.expectEqual(@as(i64, 4277556), result);
}

test "part2 example" {
    const example_input =
        \\123 328  51 64
        \\ 45 64  387 23
        \\  6 98  215 314
        \\*   +   *   +
    ;

    const result = try solveP2(4, 20, example_input);
    try std.testing.expectEqual(@as(i64, 3263827), result);
}
