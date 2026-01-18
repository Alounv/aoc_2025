const std = @import("std");

pub const Point = struct { x: u64, y: u64 };

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

/// Create a list of points from a input
pub fn getPoints(comptime dim: usize, input: []const u8) ![dim]Point {
    var points = [_]Point{.{ .x = 0, .y = 0 }} ** dim;
    var i: usize = 0;

    var lines_iter = std.mem.splitScalar(u8, input, '\n');

    while (lines_iter.next()) |line| {
        if (line.len == 0) continue;
        var parts = std.mem.splitScalar(u8, line, ',');
        const x = try std.fmt.parseInt(usize, parts.next().?, 10);
        const y = try std.fmt.parseInt(usize, parts.next().?, 10);
        points[i] = .{ .x = x, .y = y };
        i += 1;
    }

    return points;
}

/// Create a grid from a list of points
pub fn gridFromPoints(comptime max: usize, points: []Point) [max][max]u8 {
    var grid = [_][max]u8{[_]u8{'.'} ** max} ** max;
    for (points) |p| {
        grid[p.y + 1][p.x + 1] = '#';
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

// Check if two line segments intersect
// Line segment 1: from p1 to p2
// Line segment 2: from p3 to p4
pub fn doSegmentsIntersect(p1: Point, p2: Point, p3: Point, p4: Point) bool {
    // Convert to signed integers
    const x1 = @as(i64, @intCast(p1.x));
    const y1 = @as(i64, @intCast(p1.y));
    const x2 = @as(i64, @intCast(p2.x));
    const y2 = @as(i64, @intCast(p2.y));
    const x3 = @as(i64, @intCast(p3.x));
    const y3 = @as(i64, @intCast(p3.y));
    const x4 = @as(i64, @intCast(p4.x));
    const y4 = @as(i64, @intCast(p4.y));

    // Calculate the direction of the cross products
    const d1 = (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
    const d2 = (x2 - x1) * (y4 - y1) - (y2 - y1) * (x4 - x1);
    const d3 = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
    const d4 = (x4 - x3) * (y2 - y3) - (y4 - y3) * (x2 - x3);

    // Check if segments intersect (not including touching at endpoints)
    if (((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and
        ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)))
    {
        return true;
    }

    return false;
}

// Check if a point lies on a line segment
fn isPointOnSegment(point: Point, seg_start: Point, seg_end: Point) bool {
    const px = @as(i64, @intCast(point.x));
    const py = @as(i64, @intCast(point.y));
    const x1 = @as(i64, @intCast(seg_start.x));
    const y1 = @as(i64, @intCast(seg_start.y));
    const x2 = @as(i64, @intCast(seg_end.x));
    const y2 = @as(i64, @intCast(seg_end.y));

    // Check if point is within the bounding box of the segment
    const min_x = @min(x1, x2);
    const max_x = @max(x1, x2);
    const min_y = @min(y1, y2);
    const max_y = @max(y1, y2);

    if (px < min_x or px > max_x or py < min_y or py > max_y) {
        return false;
    }

    // Check collinearity using cross product
    // If cross product is 0, the point is on the line
    const cross = (px - x1) * (y2 - y1) - (py - y1) * (x2 - x1);
    return cross == 0;
}

// Check if a point is inside or on the boundary of a polygon
// Uses ray casting algorithm with explicit boundary checking
// Returns true if the point is inside OR on the polygon boundary
pub fn isPointInPolygon(point: Point, polygon: []const Point) bool {
    const px = @as(i64, @intCast(point.x));
    const py = @as(i64, @intCast(point.y));

    const n = polygon.len;

    // First check if point is exactly on any edge
    for (0..n) |i| {
        const p1 = polygon[i];
        const p2 = polygon[(i + 1) % n];

        if (isPointOnSegment(point, p1, p2)) {
            return true; // Point is on the boundary, consider it inside
        }
    }

    // Ray casting algorithm for interior points
    var inside = false;

    for (0..n) |i| {
        const p1 = polygon[i];
        const p2 = polygon[(i + 1) % n];

        const x1 = @as(i64, @intCast(p1.x));
        const y1 = @as(i64, @intCast(p1.y));
        const x2 = @as(i64, @intCast(p2.x));
        const y2 = @as(i64, @intCast(p2.y));

        // Check if point's y coordinate is between edge's y coordinates
        if ((y1 > py) != (y2 > py)) {
            // Calculate x coordinate of intersection
            const slope = (x2 - x1) * (py - y1);
            const dx = (y2 - y1);
            const intersect_x = x1 + @divTrunc(slope, dx);

            if (px < intersect_x) {
                inside = !inside;
            }
        }
    }

    return inside;
}
