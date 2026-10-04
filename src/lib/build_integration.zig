//! These structs are used for the build integration. By importing flint in your build.zig file you get access to the
//! `integrate` function which takes a `*std.Build` and an `IntegrateOptions` struct and returns an `IntegrateResult`
//! struct.
const std = @import("std");

/// This struct defines the options that need to be passed to the `integrate` function.
pub const IntegrateOptions = struct {
    dependency: *std.Build.Dependency,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    build_options: *std.Build.Step.Options,
    sdl_build_options: SDLBuildOptions = .{},
    internal: bool = true,
    name: []const u8 = "game",
    lib_only: bool = false,
    skip_run_step: bool = false,
    install_step: *std.Build.Step,
    dest_dir: std.Build.Step.InstallArtifact.Options.Dir = .default,
};

/// Paths needed to build SDL when the target has been specified, this is needed for the `buildMatrix` function.
/// They are also needed when cross compiling MacOS builds from other platforms, but that isn't supported by Apple.
/// The default values are what you would expect on a standard MacOS installation.
pub const SDLBuildOptions = struct {
    system_include_path: std.Build.LazyPath = .{
        .cwd_relative = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include",
    },
    system_framework_path: std.Build.LazyPath = .{
        .cwd_relative = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks",
    },
    library_path: std.Build.LazyPath = .{
        .cwd_relative = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib",
    },
};

/// This struct contains the results of the `integrate` function.
pub const IntegrateResult = struct {
    flint_mod: *std.Build.Module,
    exe: ?*std.Build.Step.Compile,
    build_options_mod: *std.Build.Module,
};
