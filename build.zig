const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "physfs",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    inline for (archiver_options) |opt| {
        const enable = b.option(bool, opt[0], "Enable " ++ opt[1] ++ " support") orelse true;
        if (!enable) lib.defineCMacro("PHYSFS_SUPPORTS_" ++ opt[2], "0");
    }

    lib.addCSourceFiles(&base_sources, &.{});

    switch (lib.target_info.target.os.tag) {
        .windows => {
            lib.defineCMacro("PHYSFS_STATIC", null);
        },
        .macos => {
            lib.linkSystemLibraryName("objc");
            lib.linkFramework("Foundation");
            lib.linkFramework("IOKit");

            lib.addCSourceFiles(&macos_sources, &.{});
        },
        .linux => {},
        .haiku => {
            lib.linkLibCpp();
            lib.linkSystemLibrary("be");
            lib.linkSystemLibrary("root");

            lib.addCSourceFiles(&haiku_sources, &.{});
        },
        else => @panic("unsupported"),
    }

    lib.installHeader("src/physfs.h", "physfs.h");

    b.installArtifact(lib);
}

const archiver_options = .{
    .{ "zip", "ZIP", "ZIP" },
    .{ "7z", "7zip", "7Z" },
    .{ "grp", "Build Engine GRP", "GRP" },
    .{ "wad", "Doom WAD", "WAD" },
    .{ "hog", "Descent I/II HOG", "HOG" },
    .{ "mvl", "Descent I/II MVL", "MVL" },
    .{ "qpak", "Quake I/II QPAK", "QPAK" },
    .{ "slb", "I-War / Independence War SLB", "SLB" },
    .{ "iso9660", "ISO9660", "ISO9660" },
    .{ "vdf", "Gothic I/II VDF archive", "VDF" },
};

const base_sources = [_][]const u8{
    "src/physfs.c",
    "src/physfs_byteorder.c",
    "src/physfs_unicode.c",
    "src/physfs_platform_posix.c",
    "src/physfs_platform_unix.c",
    "src/physfs_platform_windows.c",
    "src/physfs_platform_os2.c",
    "src/physfs_platform_qnx.c",
    "src/physfs_platform_android.c",
    "src/physfs_archiver_dir.c",
    "src/physfs_archiver_unpacked.c",
    "src/physfs_archiver_grp.c",
    "src/physfs_archiver_hog.c",
    "src/physfs_archiver_7z.c",
    "src/physfs_archiver_mvl.c",
    "src/physfs_archiver_qpak.c",
    "src/physfs_archiver_wad.c",
    "src/physfs_archiver_zip.c",
    "src/physfs_archiver_slb.c",
    "src/physfs_archiver_iso9660.c",
    "src/physfs_archiver_vdf.c",
};

const macos_sources = [_][]const u8{
    "src/physfs_platform_apple.m",
};
const haiku_sources = [_][]const u8{
    "src/physfs_platform_haiku.cpp",
};
