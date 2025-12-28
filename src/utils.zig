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

/// Create a grid of max lines with '.' padding
pub fn getGrid(comptime max: usize, input: []const u8) [max][max]u8 {
    var grid = [_][max]u8{[_]u8{'.'} ** max} ** max;
    var l: usize = 0;

    var lines_iter = std.mem.splitScalar(u8, input, '\n');

    while (lines_iter.next()) |line| {
        if (line.len == 0) continue;
        for (line, 0..) |char, c| {
            grid[l + 1][c + 1] = char;
        }
        l += 1;
    }

    return grid;
}

/// Print a grid of max lines
pub fn printGrid(comptime max: usize, grid: [max][max]u8) void {
    for (grid) |line| {
        for (line) |char| {
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }
}
