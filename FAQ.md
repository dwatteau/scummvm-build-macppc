# Building ScummVM for OSX PPC: FAQ

Feel free to open [an issue](https://github.com/dwatteau/scummvm-build-macppc/issues) or [a discussion](https://github.com/dwatteau/scummvm-build-macppc/discussions) if something's missing here.

## With which CPUs and OSX releases are supported?

OSX 10.4 (Tiger) and OSX 10.5 (Leopard), on PowerPC systems. (It should also work for users of so-called "Sorbet Leopard", but it's untested.)

It can also be made to run on Intel/i386 (until OSX 10.6) through Rosetta 1. Or you could tweak the build scripts, so that they target i386 instead of ppc32. It's not officially supported, though.

The resulting app should be compatible with G3, G4 and G5 processors. Yes, I try to take care of not breaking G3 (or non-Altivec) compatibility (although my own testing on G3 is lightweight).

## Do you plan on adding support for older OSX releases, such as 10.2 or 10.3?

Very unlikely. Building for OSX 10.4 is already quite difficult; going back to 10.3 would mean even more work, and I don't have much interest in that myself. I do know that older OSX releases run better on G3s. But unless someone wants to contribute on this, I don't think I will do that myself.

The biggest problem is that there's no C++11 toolchain for OSX 10.3, AFAICS.

[ScummVM 1.6.0](https://downloads.scummvm.org/frs/scummvm/1.6.0/scummvm-1.6.0-macosx.dmg) (2013) has been confirmed to work on OSX 10.3. Maybe some releases between ScummVM 1.6.0 and ScummVM 2.5.0 still worked on OSX 10.3; but this has been untested.

ScummVM 2.5.x (2021; the last release not requiring a C++11 compiler) *could* be made to work on OSX 10.3, though. As of mid-2026, I have [a local branch](https://github.com/dwatteau/scummvm/tree/fix/v25-branch-older-toolchains-fixes) restoring OSX 10.3 compatibility to this older ScummVM release, but it's still a work-in-progress.

## Do you plan on doing an optimized build for G4s/Altivec/G5s or 10.4-10.6 Intel?

Since ScummVM mostly (but not only!) targets "old games", I haven't seen any reason to spend time on this, so far. I don't think it'd bring a real performance improvement. Building a multi-architecture binary would require even more work, so my time is probably better spent on other areas, for the moment.

The performance improvements between late PPC systems and OSX 10.4/10.5/10.6 Intel means that most of the games appear to work fine, even when using Rosetta 1 to translate the PowerPC code to x86 code. So, I don't see the point in doing an i386 build for i386 Tiger/Leopard/Snow Leopard either.

Regarding ppc64, I don't see the point; even TenFourFox kept its G5-optimized build 32-bit. Tiger's support for ppc64 is extremely minimal, and I'm not sure we'd see much benefit for the vast majority of supported games. Also, it appears (from some MacRumors forum discussions) that the GCC 7.5 compiler that's used to build ScummVM may have some issues when targeting ppc64. So, it doesn't seem to be worth the trouble.

For now (2026), a unique, stable and (mostly) reproducible build is preferred.

## Why aren't you using a newer compiler toolchain?

The work done by MacPorts for preserving OSX 10.4/10.5 PPC compatibility is amazing. But it's a moving target; what works in January may not build anymore in March, because the whole MacPorts tree is always being updated, and regressions happen. Also, bootstrapping the full C++11 toolchain (and some other tools such as `cmake`, `git`…) is really, really slow. Also, support for OSX 10.4 was recently dropped from upstream MacPorts.

The old "Unofficial TenFourFox Development Toolkit" just works out of the box, and its results are reproducible.

## How to run a debugger on ScummVM for OSX PPC?

Get a [newer GDB from the old TenFourFox files](https://sourceforge.net/projects/tenfourfox/files/tools/), called `gdb768-104fx-3.tar.gz`. Get *exactly* this one.

Using your own GDB binary requires special permissions, documented here for example:

* <https://sourceware.org/gdb/wiki/PermissionsDarwin>
* <http://gridlab-d.shoutwiki.com/wiki/Mac_OSX/Setup>

> [!NOTE]
> It looks like trying to make this work on OSX 10.5 is pointless. So OSX 10.4 may be a hard requirement!

Ensure there's a `-p` option set up in the file below (Leopard only):
```sh
cat /System/Library/LaunchDaemons/com.apple.taskgated.plist
```

i.e. something like this:
```xml
<array>
	<string>/usr/libexec/taskgated</string>
	<string>-p</string>
```

Allow your current user to run this GDB binary with particular privileges (Leopard only):

```sh
sudo dseditgroup -o edit -a YOURUSERNAMEHERE -t user procmod
sudo chgrp procmod /path/to/extracted/gdb/archive/above/gdb7 # parent directory may also need 'chmod g+s'?
```

and then reboot for the changes to take effect.

Then, after doing an `--disable-optimizations --enable-debug` build (warning: if you don't use `--enable-plugins --default-dynamic`, building too many engines will trigger internal linker errors. So, if you need to debug a particular engine, do your ScummVM debug build with `--disable-detection-full --disable-all-engines --enable-engine=your-engine-name`):

```sh
/path/to/gdb7 -q ./path/to/scummvm
(gdb) run

(gdb) bt
(gdb) bt full
```

Running GDB on the official releases for OSX PPC is not going to be really helpful, because they're built with optimizations and no debug information.

### I have a `GNU Make 3.81 or higher is required` error when trying to build ScummVM

The `/usr/bin/make` binary that's part of OSX 10.4 is way too old (the one on OSX 10.5 is fine, though).

Use the `/opt/macports-tff/bin/gmake` binary provided by the toolkit, instead.

### I have an `ld: library not found for -lcrt1.10.5.o` error at the very end of the build

Maybe you tried running `make` instead of running the included provided build scripts?

If you really want to call `make` yourself, do this first:

```sh
eval "$(grep ^'export ' /path/to/this/scummvm-build-macppc/config.sh)"
```

in order to have the proper environment variables exported.

### I'm getting an `hdiutil` error when building the `ScummVM-snapshot.dmg` file

It looks like `hdiutil` may randomly fail when run from OSX 10.4. Just run the same command again and it should work. Yes, strange.

### How do I test that a ScummVM build works on non-Altivec CPUs, if I don't have one?

OSX 10.4 can be made to run without Altivec support with the following boot setting:

```sh
sudo nvram boot-args="novmx=1"
```

and then, reboot. Then, try your ScummVM binary, with as many settings as possible (OpenGL renderer, SDL renderer, running a game engine with JPEG/MPEG2 decoding...).

To revert to the default boot settings, type `sudo nvram boot-args=""` instead.

If you want to be sure whether Altivec/VMX is enabled/disabled, run this command:
```sh
sysctl hw.optional.altivec
```

where `1` in the output means that it's available, and `0` means it's unavailable.
