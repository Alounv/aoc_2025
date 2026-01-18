const std = @import("std");
const utils = @import("utils");

const Point = struct { u64, u64, u64 };

const Pair = struct {
    p1: usize,
    p2: usize,
    dist: u64,

    fn lessThan(_: void, a: Pair, b: Pair) bool {
        return a.dist < b.dist;
    }
};

fn distance3D(p1: Point, p2: Point) u64 {
    const dx = if (p1[0] > p2[0]) p1[0] - p2[0] else p2[0] - p1[0];
    const dy = if (p1[1] > p2[1]) p1[1] - p2[1] else p2[1] - p1[1];
    const dz = if (p1[2] > p2[2]) p1[2] - p2[2] else p2[2] - p1[2];
    return dx * dx + dy * dy + dz * dz;
}

fn listPoints(points: []Point, input: []const u8) !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var l: usize = 0;
    while (lines.next()) |line| : (l += 1) {
        if (line.len == 0) continue;
        var words = std.mem.splitScalar(u8, line, ',');
        points[l] = .{
            try std.fmt.parseUnsigned(u64, words.next().?, 10),
            try std.fmt.parseUnsigned(u64, words.next().?, 10),
            try std.fmt.parseUnsigned(u64, words.next().?, 10),
        };
    }
}

fn getPairsSortedByDistance(pairs: []Pair, points: []const Point) usize {
    var index: usize = 0;
    for (points, 0..) |p1, i| {
        for (points[i + 1 ..], (i + 1)..) |p2, j| {
            pairs[index] = .{ .p1 = i, .p2 = j, .dist = distance3D(p1, p2) };
            index += 1;
        }
    }
    std.mem.sort(Pair, pairs[0..index], {}, Pair.lessThan);
    return index;
}

fn UnionFind(comptime max: usize) type {
    return struct {
        parent: [max]usize,
        groupCount: usize,

        const Self = @This();

        fn init() Self {
            var parent: [max]usize = undefined;
            for (0..max) |i| {
                parent[i] = i;
            }
            return .{ .parent = parent, .groupCount = max };
        }

        /// Find the root of the set containing x with path compression.
        /// Path compression flattens the tree structure by making each node
        /// point directly to the root, optimizing future lookups.
        fn find(self: *Self, x: usize) usize {
            // If x is not its own parent, recursively find the root
            if (self.parent[x] != x) {
                // Path compression: update parent to point directly to root
                // This reduces tree height and speeds up subsequent find operations
                self.parent[x] = self.find(self.parent[x]);
            }
            return self.parent[x];
        }

        fn unite(self: *Self, x: usize, y: usize) void {
            const px = self.find(x);
            const py = self.find(y);
            if (px != py) {
                self.parent[py] = px;
                self.groupCount -= 1;
            }
        }

        fn hasOnlyOneGroup(self: *Self) bool {
            return self.groupCount == 1;
        }
    };
}

fn solveP1(
    comptime max: usize,
    comptime junct: u64,
    input: []const u8,
) !u64 {
    // List points
    var points: [max]Point = undefined;
    try listPoints(&points, input);

    // List pairs and distances and sort by distances
    var pairs: [max * (max - 1) / 2]Pair = undefined;
    _ = getPairsSortedByDistance(&pairs, &points);

    // Union-Find to group points
    var uf = UnionFind(max).init();
    for (pairs[0..junct]) |pair| {
        uf.unite(pair.p1, pair.p2);
    }

    // Count group sizes
    var groupSizes = std.mem.zeroes([max]u64);
    for (0..max) |i| {
        const root = uf.find(i);
        groupSizes[root] += 1;
    }

    // Get top 3 groups
    std.mem.sort(u64, &groupSizes, {}, comptime std.sort.desc(u64));

    return groupSizes[0] * groupSizes[1] * groupSizes[2];
}

fn solveP2(comptime max: usize, input: []const u8) !u64 {
    // List points
    var points: [max]Point = undefined;
    try listPoints(&points, input);

    // List pairs and distances and sort by distances
    var pairs: [max * (max - 1) / 2]Pair = undefined;
    const pairCount = getPairsSortedByDistance(&pairs, &points);

    // Union-Find to group points
    var uf = UnionFind(max).init();
    for (pairs[0..pairCount]) |pair| {
        uf.unite(pair.p1, pair.p2);

        if (uf.hasOnlyOneGroup()) {
            return points[pair.p1][0] * points[pair.p2][0];
        }
    }

    return 0;
}

// ============================================================================
// GENERIC - Boilerplate & Entry Point
// ============================================================================

const EXPECTED_PART1: i64 = 181584;
const EXPECTED_PART2: i64 = 8465902405;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const content = try utils.readInput(allocator, "inputs/day08.txt");
    defer allocator.free(content);

    const part1 = try solveP1(1000, 1000, content);
    const part2 = try solveP2(1000, content);

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
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
    ;

    const result = solveP1(20, 10, example_input);
    try std.testing.expectEqual(@as(u64, 40), result);
}

test "part2 example" {
    const example_input =
        \\162,817,812
        \\57,618,57
        \\906,360,560
        \\592,479,940
        \\352,342,300
        \\466,668,158
        \\542,29,236
        \\431,825,988
        \\739,650,466
        \\52,470,668
        \\216,146,977
        \\819,987,18
        \\117,168,530
        \\805,96,715
        \\346,949,466
        \\970,615,88
        \\941,993,340
        \\862,61,35
        \\984,92,344
        \\425,690,689
    ;

    const result = try solveP2(20, example_input);
    try std.testing.expectEqual(@as(u64, 25272), result);
}
