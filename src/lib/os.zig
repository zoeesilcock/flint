//! Exposes platform specific functionality.
const std = @import("std");

pub const windows = @import("os/windows.zig");

// Build options.
const PLATFORM = @import("builtin").os.tag;

pub const LoadedLibrary = if (PLATFORM == .windows) windows.HMODULE else std.DynLib;

/// A wrapper which uses kernel32 on Windows and the standard library on other platforms.
pub fn loadLibrary(path: []const u8, allocator: std.mem.Allocator) !?LoadedLibrary {
    var result: ?LoadedLibrary = null;
    if (PLATFORM == .windows) {
        const path_w = try std.unicode.utf8ToUtf16LeAllocZ(allocator, path);
        defer allocator.free(path_w);

        result = windows.LoadLibraryExW(path_w, null, 0);
        if (result == null) {
            const error_code = windows.GetLastError();
            std.log.err(
                "Failed to load dynamic library from path {s}, error code: {d} (0x{x})",
                .{ path, error_code, error_code },
            );
            return error.LibraryLoadFailed;
        }
    } else {
        result = std.DynLib.open(path) catch |err| {
            if (std.mem.span(std.c.dlerror())) |dl_err| {
                std.log.err("Failed to load dynamic library from path {s},\nreason: {s}", .{ path, dl_err });
                return error.LibraryLoadFailed;
            } else {
                std.log.err("Failed to load dynamic library from path {s},\nreason: {}", .{ path, err });
                return err;
            }
        };
    }
    return result;
}

/// A wrapper which uses kernel32 on Windows and the standard library on other platforms.
pub fn unloadLibrary(library: *LoadedLibrary) void {
    if (PLATFORM == .windows) {
        _ = windows.FreeLibrary(library.*);
    } else {
        library.close();
    }
}

/// A wrapper which uses kernel32 on Windows and the standard library on other platforms.
pub fn lookupLibraryFunction(
    library: *LoadedLibrary,
    comptime name: [:0]const u8,
    comptime T: type,
) ?T {
    var result: ?T = null;
    if (PLATFORM == .windows) {
        if (windows.GetProcAddress(library.*, name)) |function| {
            result = @ptrCast(function);
        }
    } else {
        if (library.lookup(T, name)) |function| {
            result = function;
        }
    }
    return result;
}
