const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for shared utilities
    const utils = b.addModule("utils", .{
        .root_source_file = b.path("src/utils.zig"),
    });

    // Create test step once
    const test_step = b.step("test", "Run all tests");

    // Build and test all existing day solutions
    inline for (1..26) |day| {
        const day_num = comptime std.fmt.comptimePrint("{d:0>2}", .{day});
        const name = "day" ++ day_num;
        const source_file = "src/" ++ name ++ ".zig";

        // Check if file exists
        const file_exists = blk: {
            std.fs.cwd().access(source_file, .{}) catch break :blk false;
            break :blk true;
        };

        if (file_exists) {
            // Build executable
            const exe = b.addExecutable(.{
                .name = name,
                .root_module = b.createModule(.{
                    .root_source_file = b.path(source_file),
                    .target = target,
                    .optimize = optimize,
                }),
            });
            exe.root_module.addImport("utils", utils);
            b.installArtifact(exe);

            // Add tests
            const exe_tests = b.addTest(.{
                .root_module = b.createModule(.{
                    .root_source_file = b.path(source_file),
                    .target = target,
                    .optimize = optimize,
                }),
            });
            exe_tests.root_module.addImport("utils", utils);

            test_step.dependOn(&b.addRunArtifact(exe_tests).step);
        }
    }
}
