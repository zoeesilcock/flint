//! This is the "flint" module that is exposed by flint which contains various building blocks that
//! can be imported into your game to serve as a basis for your game engine.
//!
//! ## Quick start
//! The easiest way to get started is to use the new project generator:
//! ```
//! git clone https://github.com/zoeesilcock/flint.git && cd flint
//!
//! zig build new -- ../my_new_project
//!
//! cd ../my_new_project && zig build run
//! ```
//!
//! ## Manual build integration
//! * Add flint as a dependency in your `build.zig.zon` file by running:
//! ```
//! zig fetch --save git+https://github.com/zoeesilcock/flint.git#v0.11.0
//! ```
//! * Example `build.zig` file:
//! ```
//! const std = @import("std");
//! const flint = @import("flint");
//!
//! pub fn build(b: *std.Build) void {
//!     const target = b.standardTargetOptions(.{});
//!     const optimize = b.standardOptimizeOption(.{});
//!     const name = b.option([]const u8, "name", "name of the game (used for exe and lib)") orelse "template";
//!     const internal = b.option(bool, "internal", "include debug interface") orelse true;
//!     const lib_only = b.option(bool, "lib_only", "only build the shared library") orelse false;
//!
//!     // Integrate Flint.
//!     const flint_options: flint.IntegrateOptions = .{
//!         .dependency = b.dependency("flint", .{ .target = target, .optimize = optimize, .internal = internal }),
//!         .target = target,
//!         .optimize = optimize,
//!         .build_options = b.addOptions(),
//!         .name = name,
//!         .internal = internal,
//!         .lib_only = lib_only,
//!         .install_step = b.getInstallStep(),
//!         .dest_dir = .default,
//!     };
//!     const result = flint.integrate(b, flint_options);
//!
//!     // Install executable.
//!     if (result.exe) |exe| {
//!         b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{}).step);
//!     }
//!
//!     // Game library.
//!     const module = b.createModule(.{
//!         .root_source_file = b.path("src/root.zig"),
//!         .target = flint_options.target,
//!         .optimize = flint_options.optimize,
//!     });
//!     module.addImport("build_options", result.build_options_mod);
//!     module.addImport("flint", result.flint_mod);
//!
//!     const lib = b.addLibrary(.{
//!         .name = flint_options.name,
//!         .linkage = .dynamic,
//!         .root_module = module,
//!     });
//!
//!     // Install library.
//!     b.getInstallStep().dependOn(&b.addInstallArtifact(lib, .{}).step);
//!
//!     // Check library.
//!     const lib_check = b.addLibrary(.{
//!         .name = name,
//!         .linkage = .dynamic,
//!         .root_module = lib.root_module,
//!     });
//!     const check = b.step("check", "Check if it compiles");
//!     check.dependOn(&lib_check.step);
//!
//!     // Tests.
//!     const test_step = b.step("test", "Run unit tests");
//!     const lib_tests = b.addTest(.{ .root_module = lib.root_module });
//!     const run_lib_tests = b.addRunArtifact(lib_tests);
//!     test_step.dependOn(&run_lib_tests.step);
//!
//!     // Build all variations.
//!     const build_all_step = b.step("all", "Builds all permutations of the game for testing purposes.");
//!     flint.buildMatrixDefault(b, build_all_step, name, b.path("assets"));
//! }
//! ```
//!
//! * The `internal` option decides if things like inspectors, editors, debug visualizations,
//!   and such will be included in the build. This aims to be the main way of defining whether
//!   a build is meant for internal testing or for release. Import it into your own code like this:
//! ```
//! const INTERNAL: bool = @import("build_options").internal;
//! ```
//!
//! * See `src/examples/template` for a complete example.
//!
//! ## Game library
//! Flint expects you to create a library which exposes specific functions that will get called at various points in
//! your games life cycle, this is where you will write your game. See the [GameLib](#docs.GameLib) struct for a list
//! of functions and their signatures. The Template example has a minimal example of using the Full2D dependency set
//! in `src/examples/template/root.src`.
pub const sdl = @import("sdl.zig");
pub const fs = @import("fs.zig");
pub const os = @import("os.zig");
pub const aseprite = @import("aseprite.zig");
pub const imgui = @import("imgui.zig");
pub const internal = @import("internal.zig");

pub const GameLib = @import("GameLib.zig");

pub const build_integration = @import("build_integration.zig");
