const std = @import("std");
const utils = @import("utils");

// ============================================================================
// LOGIC - Core Problem Solving
// ============================================================================

fn isFake(num: usize) !bool {
    // Using stack allocation with maximum size because Zig cannot know the size
    // of the string representation of the number at compile time.
    var buf: [20]u8 = undefined;
    const num_str = try std.fmt.bufPrint(&buf, "{}", .{num});
    const h = num_str.len / 2;
    return std.mem.eql(u8, num_str[0..h], num_str[h..]);
}

fn solve(input: []const u8) !struct { usize, usize } {
    var part1: usize = 0;
    const part2: usize = 0;

    var lines = std.mem.splitScalar(u8, input, '\n');
    var ranges = std.mem.splitScalar(u8, lines.next().?, ',');

    while (ranges.next()) |range| {
        var parts = std.mem.splitScalar(u8, range, '-');
        const start = try std.fmt.parseInt(usize, parts.next().?, 10);
        const end = try std.fmt.parseInt(usize, parts.next().?, 10);

        for (start..end + 1) |num| {
            if (try isFake(num)) part1 += num;
        }
    }

    std.debug.print("Part 1: {}\n", .{part1});

    return .{ part1, part2 };
}

fn solveP1(input: []const u8) !usize {
    const result = try solve(input);
    return result[0];
}

fn solveP2(_: []const u8) !usize {
    return 0;
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: usize = 0;
const EXPECTED_PART2: usize = 0;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day02.txt");
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

test "part1 example" {
    const example_input =
        \\11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
    ;

    const result = try solveP1(example_input);
    try std.testing.expectEqual(@as(usize, 1227775554), result);
}

test "part2 example" {
    const example_input =
        \\
    ;

    const result = solveP2(example_input);
    try std.testing.expectEqual(@as(usize, 0), result);
}
