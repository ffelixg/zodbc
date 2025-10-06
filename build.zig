const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const skipruntimetest = b.option(
        bool,
        "skipruntimetest",
        "Don't execute tests, only verify correct compilation",
    ) orelse false;

    // ----------------------------
    // Dependencies
    // ----------------------------
    const zig_cli_dep = b.dependency("cli", .{
        .target = target,
        .optimize = optimize,
    });

    // ----------------------------
    // Module
    // ----------------------------
    const c_zig = b.addTranslateC(.{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/c.h"),
    });
    c_zig.addIncludePath(std.Build.LazyPath{ .cwd_relative = "/usr/include/" });
    const c_mod = c_zig.createModule();

    c_mod.addLibraryPath(std.Build.LazyPath{ .cwd_relative = "/lib64/" });
    c_mod.linkSystemLibrary("odbc", .{});

    const odbc_mod = b.addModule("odbc", .{
        .root_source_file = b.path("src/odbc/root.zig"),
        .target = target,
        .link_libc = true,
        .optimize = optimize,
    });
    odbc_mod.addImport("c", c_mod);

    const core_mod = b.addModule("core", .{
        .root_source_file = b.path("src/core/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    core_mod.addImport("odbc", odbc_mod);

    const pool_mod = b.addModule("pool", .{
        .root_source_file = b.path("src/pool/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    pool_mod.addImport("odbc", odbc_mod);
    pool_mod.addImport("core", core_mod);

    const testing_mod = b.addModule("testing", .{
        .root_source_file = b.path("src/testing/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    testing_mod.addImport("core", core_mod);

    const zodbc_mod = b.addModule("zodbc", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    zodbc_mod.addImport("odbc", odbc_mod);
    zodbc_mod.addImport("core", core_mod);
    zodbc_mod.addImport("pool", pool_mod);
    zodbc_mod.addImport("testing", testing_mod);

    const cli_mod = b.addModule("cli", .{
        .root_source_file = b.path("src/cli/root.zig"),
    });
    cli_mod.addImport("zodbc", zodbc_mod);
    cli_mod.addImport("zig-cli", zig_cli_dep.module("cli"));

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("cli", cli_mod);

    // ----------------------------
    // Library
    // ----------------------------
    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "zodbc",
        .root_module = zodbc_mod,
        .version = .{ .major = 0, .minor = 0, .patch = 0 },
    });
    // lib.root_module.addImport("odbc", odbc_mod);
    // lib.root_module.addImport("core", core_mod);
    // lib.root_module.addImport("pool", pool_mod);
    lib.linkage = .dynamic;
    b.installArtifact(lib);

    // ----------------------------
    // Executable
    // ----------------------------
    const exe = b.addExecutable(.{
        .name = "zodbc",
        .root_module = exe_mod,
    });
    exe.root_module.addImport("zig-cli", zig_cli_dep.module("cli"));
    exe.linkLibrary(lib);
    b.installArtifact(exe);

    // ----------------------------
    // Run
    // ----------------------------
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // ----------------------------
    // Tests
    // ----------------------------
    const test_runner: std.Build.Step.Compile.TestRunner = .{
        .mode = .simple,
        .path = b.path(if (skipruntimetest) "test_runner_noexecute.zig" else "test_runner.zig"),
    };

    const lib_core_unit_tests = b.addTest(.{
        .name = "[LIB CORE UNIT]",
        .test_runner = test_runner,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/core/test_unit.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    lib_core_unit_tests.root_module.addImport("odbc", odbc_mod);
    const run_lib_core_unit_tests = b.addRunArtifact(lib_core_unit_tests);

    const lib_pool_unit_tests = b.addTest(.{
        .name = "[LIB POOL UNIT]",
        .test_runner = test_runner,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/pool/test_unit.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    lib_pool_unit_tests.root_module.addImport("odbc", odbc_mod);
    lib_pool_unit_tests.root_module.addImport("core", core_mod);
    const run_lib_pool_unit_tests = b.addRunArtifact(lib_pool_unit_tests);

    const lib_unit_tests = b.addTest(.{
        .name = "[LIB UNIT]",
        .test_runner = test_runner,
        .root_module = zodbc_mod,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .name = "[EXE UNIT]",
        .test_runner = test_runner,
        .root_module = exe_mod,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_unit_step = b.step("test:unit", "Run unit tests");
    test_unit_step.dependOn(&run_lib_core_unit_tests.step);
    test_unit_step.dependOn(&run_lib_pool_unit_tests.step);
    test_unit_step.dependOn(&run_lib_unit_tests.step);
    test_unit_step.dependOn(&run_exe_unit_tests.step);

    // Db2 integration tests
    const db2_integration_tests = b.addTest(.{
        .name = "[DB2 INTEGRATION]",
        .test_runner = test_runner,
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/db2/test_integration.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    // db2_integration_tests.root_module.addImport("odbc", odbc_mod);
    db2_integration_tests.root_module.addImport("zodbc", zodbc_mod);
    const run_db2_integration_tests = b.addRunArtifact(db2_integration_tests);
    const test_integration_db2_step = b.step("test:integration:db2", "Run Db2 integration tests");
    test_integration_db2_step.dependOn(&run_db2_integration_tests.step);

    // MariaDB integration tests
    const mariadb_integration_tests = b.addTest(.{
        .name = "[MARIADB INTEGRATION]",
        .test_runner = test_runner,
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/mariadb/test_integration.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    // mariadb_integration_tests.root_module.addImport("odbc", odbc_mod);
    mariadb_integration_tests.root_module.addImport("zodbc", zodbc_mod);
    const run_mariadb_integration_tests = b.addRunArtifact(mariadb_integration_tests);
    const test_integration_mariadb_step = b.step("test:integration:mariadb", "Run MariaDB integration tests");
    test_integration_mariadb_step.dependOn(&run_mariadb_integration_tests.step);

    // Postgres integration tests
    const postgres_integration_tests = b.addTest(.{
        .name = "[POSTGRES INTEGRATION]",
        .test_runner = test_runner,
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/postgres/test_integration.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    // postgres_integration_tests.root_module.addImport("odbc", odbc_mod);
    postgres_integration_tests.root_module.addImport("zodbc", zodbc_mod);
    const run_postgres_integration_tests = b.addRunArtifact(postgres_integration_tests);
    const test_integration_postgres_step = b.step("test:integration:postgres", "Run Postgres integration tests");
    test_integration_postgres_step.dependOn(&run_postgres_integration_tests.step);

    const test_integration_step = b.step("test:integration", "Run integration tests");
    test_integration_step.dependOn(test_integration_db2_step);
    test_integration_step.dependOn(test_integration_mariadb_step);
    test_integration_step.dependOn(test_integration_postgres_step);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(test_unit_step);
    test_step.dependOn(test_integration_step);
}
