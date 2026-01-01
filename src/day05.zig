const std = @import("std");
const utils = @import("utils");

const Range = struct { i64, i64 };

fn compareRanges(context: void, a: Range, b: Range) bool {
    _ = context;
    return if (a[0] == b[0]) a[1] < b[1] else a[0] < b[0];
}

fn solve(comptime dim: i64, input: []const u8) !struct { i64, i64 } {
    var ranges = [_]Range{.{ 0, 0 }} ** dim;
    var ids = [_]i64{-1} ** dim;
    var range_count: usize = 0;
    var id_count: usize = 0;

    var lines = std.mem.splitScalar(u8, input, '\n');
    var parsing_ranges = true;

    while (lines.next()) |line| {
        if (line.len == 0) {
            parsing_ranges = false;
        } else if (parsing_ranges) {
            var parts = std.mem.splitScalar(u8, line, '-');
            ranges[range_count] = .{
                try std.fmt.parseInt(i64, parts.next().?, 10),
                try std.fmt.parseInt(i64, parts.next().?, 10),
            };
            range_count += 1;
        } else {
            ids[id_count] = try std.fmt.parseInt(i64, line, 10);
            id_count += 1;
        }
    }

    // Part 1: Count IDs within any range (kinda bruteforce)
    var part1: i64 = 0;
    for (ids[0..id_count]) |id| {
        for (ranges[0..range_count]) |range| {
            if (id >= range[0] and id <= range[1]) {
                part1 += 1;
                break;
            }
        }
    }

    // Part 2: Count total coverage after merging overlapping ranges
    std.mem.sort(Range, ranges[0..range_count], {}, compareRanges);

    var part2: i64 = ranges[0][1] - ranges[0][0] + 1; // init count with first range size
    var prev_end = ranges[0][1];

    for (ranges[1..range_count]) |range| {
        if (range[0] > prev_end) { // means no overlap (ex 1-4 5-6) - count
            part2 += range[1] - range[0] + 1;
            prev_end = range[1];
        } else if (range[1] > prev_end) { // means partial overlap (ex 1-4 3-6) - count only the diff
            part2 += range[1] - prev_end;
            prev_end = range[1];
        }
        // else means full overlap (ex 1-4 2-3) - do nothing (do not update the prev_end)
    }

    return .{ part1, part2 };
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 529;
const EXPECTED_PART2: i64 = 344260049617193;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day05.txt");
    defer allocator.free(content);

    const result = try solve(1182, content);
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
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;

    const result = try solve(20, example_input);
    try std.testing.expectEqual(@as(i64, 3), result[0]);
}

test "part2 example" {
    const example_input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;

    const result = try solve(20, example_input);
    try std.testing.expectEqual(@as(i64, 14), result[1]);
}
