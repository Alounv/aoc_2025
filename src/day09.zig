const std = @import("std");
const utils = @import("utils");

fn getArea(a: utils.Point, b: utils.Point) u64 {
    const dx = if (a.x > b.x) a.x - b.x else b.x - a.x;
    const dy = if (a.y > b.y) a.y - b.y else b.y - a.y;
    return (dx + 1) * (dy + 1);
}

// Check if a rectangle (defined by two opposite corners) is inside a polygon
// Returns true if all corners are inside and no edges intersect
fn isRectangleInPolygon(a: utils.Point, c: utils.Point, polygon: []const utils.Point) bool {
    // Compute the other two corners from the opposite corners
    const b = utils.Point{ .x = a.x, .y = c.y };
    const d = utils.Point{ .x = c.x, .y = a.y };

    // First, check if all four corners are inside the polygon
    // If any corner is outside, the rectangle cannot be inside
    if (!utils.isPointInPolygon(a, polygon)) return false;
    if (!utils.isPointInPolygon(b, polygon)) return false;
    if (!utils.isPointInPolygon(c, polygon)) return false;
    if (!utils.isPointInPolygon(d, polygon)) return false;

    // Even if all corners are inside, we need to check for edge intersections
    // (the polygon could "cut through" the rectangle)
    const rect_edges = [4][2]utils.Point{
        .{ a, b }, // Top edge
        .{ b, c }, // Right edge
        .{ c, d }, // Bottom edge
        .{ d, a }, // Left edge
    };

    const n = polygon.len;
    for (0..n) |i| {
        const poly_p1 = polygon[i];
        const poly_p2 = polygon[(i + 1) % n];

        for (rect_edges) |rect_edge| {
            if (utils.doSegmentsIntersect(rect_edge[0], rect_edge[1], poly_p1, poly_p2)) {
                return false;
            }
        }
    }

    return true;
}

fn solveP1(comptime max: usize, input: []const u8) !u64 {
    const points = try utils.getPoints(max, input);
    var max_area: u64 = 0;
    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            const area = getArea(points[i], points[j]);
            if (area <= max_area) continue;
            max_area = area;
        }
    }
    return max_area;
}

fn solveP2(comptime max: usize, input: []const u8) !u64 {
    const points = try utils.getPoints(max, input);
    var max_area: u64 = 0;
    var pairs: struct { utils.Point, utils.Point } = undefined;
    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            const area = getArea(points[i], points[j]);
            if (area <= max_area) continue;

            // Check if rectangle is inside the polygon
            if (!isRectangleInPolygon(points[i], points[j], &points)) {
                continue;
            }

            max_area = area;
            pairs = .{ points[i], points[j] };
        }
    }

    return max_area;
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 4774877510;
const EXPECTED_PART2: i64 = 1560475800;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day09.txt");
    defer allocator.free(content);

    const part1 = try solveP1(496, content);
    const part2 = try solveP2(496, content);

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
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
    ;

    const result = try solveP1(8, example_input);
    try std.testing.expectEqual(@as(u64, 50), result);
}

test "part2 example" {
    const example_input =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
    ;

    const result = try solveP2(8, example_input);
    try std.testing.expectEqual(@as(u64, 24), result);
}
