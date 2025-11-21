const std = @import("std");

/// Read entire file content into a string
/// Caller owns the returned memory
pub fn readInput(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    const content = try file.readToEndAlloc(allocator, stat.size);
    return content;
}

/// Parse input into lines, filtering out empty lines
/// Caller owns the returned ArrayList
pub fn parseLines(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList([]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, input, '\n');

    while (iter.next()) |line| {
        if (line.len > 0) {
            try lines.append(line);
        }
    }

    return lines;
}

/// Split input on blank lines (double newlines)
/// Useful for puzzles with grouped data
/// Caller owns the returned ArrayList
pub fn splitOnBlankLines(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList([]const u8) {
    var groups = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitSequence(u8, input, "\n\n");

    while (iter.next()) |group| {
        if (group.len > 0) {
            try groups.append(group);
        }
    }

    return groups;
}

/// Parse a string of space-separated numbers
/// Caller owns the returned ArrayList
pub fn parseNumbers(allocator: std.mem.Allocator, line: []const u8, comptime T: type) !std.ArrayList(T) {
    var numbers = std.ArrayList(T).init(allocator);
    var iter = std.mem.splitScalar(u8, line, ' ');

    while (iter.next()) |num_str| {
        const trimmed = std.mem.trim(u8, num_str, " \t\r\n");
        if (trimmed.len > 0) {
            const num = try std.fmt.parseInt(T, trimmed, 10);
            try numbers.append(num);
        }
    }

    return numbers;
}

test "parseLines basic" {
    const allocator = std.testing.allocator;
    const input = "line1\nline2\nline3\n";

    var lines = try parseLines(allocator, input);
    defer lines.deinit();

    try std.testing.expectEqual(@as(usize, 3), lines.items.len);
    try std.testing.expectEqualStrings("line1", lines.items[0]);
    try std.testing.expectEqualStrings("line2", lines.items[1]);
    try std.testing.expectEqualStrings("line3", lines.items[2]);
}

test "parseLines with empty lines" {
    const allocator = std.testing.allocator;
    const input = "line1\n\nline2\n";

    var lines = try parseLines(allocator, input);
    defer lines.deinit();

    try std.testing.expectEqual(@as(usize, 2), lines.items.len);
    try std.testing.expectEqualStrings("line1", lines.items[0]);
    try std.testing.expectEqualStrings("line2", lines.items[1]);
}

test "splitOnBlankLines" {
    const allocator = std.testing.allocator;
    const input = "group1\npart2\n\ngroup2\npart2";

    var groups = try splitOnBlankLines(allocator, input);
    defer groups.deinit();

    try std.testing.expectEqual(@as(usize, 2), groups.items.len);
    try std.testing.expectEqualStrings("group1\npart2", groups.items[0]);
    try std.testing.expectEqualStrings("group2\npart2", groups.items[1]);
}

test "parseNumbers" {
    const allocator = std.testing.allocator;
    const input = "1 2 3 4 5";

    var numbers = try parseNumbers(allocator, input, u64);
    defer numbers.deinit();

    try std.testing.expectEqual(@as(usize, 5), numbers.items.len);
    try std.testing.expectEqual(@as(u64, 1), numbers.items[0]);
    try std.testing.expectEqual(@as(u64, 5), numbers.items[4]);
}
