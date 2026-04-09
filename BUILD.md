# Building ReactOS

This directory contains build scripts to help configure and build ReactOS using CMake.

## Prerequisites

Before building ReactOS, ensure you have:

- **CMake** (3.17.0 or later): Download from https://cmake.org/download/
- **Ninja** or **Visual Studio** (recommended for Windows)
- **Git**: For version control
- **Compiler Toolchain**: One of the following:
  - MSVC (Visual Studio 2015 or later)
  - GCC or Clang (via RosBE or MinGW)

### For Windows (Recommended Setup)

1. Install CMake
2. Install Ninja: `choco install ninja` (if using Chocolatey)
3. Install Visual Studio with C++ build tools, OR
4. Use the ReactOS Build Environment (RosBE): https://reactos.org/wiki/Build_Environment

## Usage

### PowerShell (Recommended for Windows)

```powershell
# Basic build (i386 Debug)
.\build.ps1

# Build specific architecture
.\build.ps1 -Architecture amd64

# Build with different build type
.\build.ps1 -Architecture amd64 -BuildType Release

# Clean and rebuild
.\build.ps1 -Clean

# Configuration only (don't build)
.\build.ps1 -ConfigOnly
```

### Batch Script

```cmd
REM Basic build
build.cmd

REM Build specific architecture
build.cmd --arch amd64

REM Build with Release configuration
build.cmd --build-type Release

REM Clean build directory
build.cmd --clean

REM Configuration only
build.cmd --config-only
```

## Options

### Architecture
- `i386` - 32-bit x86 (default)
- `amd64` - 64-bit x86-64
- `arm` - 32-bit ARM
- `arm64` - 64-bit ARM

### Build Type
- `Debug` - Debug build with symbols (default)
- `Release` - Optimized release build
- `MinSizeRel` - Minimized size release build
- `RelWithDebInfo` - Release with debug info

### Generator (PowerShell)
- `Ninja` - Ninja build system (default, faster)
- `Visual Studio 16 2019` - Visual Studio
- `Unix Makefiles` - GNU Make

## Build Directories

Build outputs are placed in directories named like:
```
build_[ARCH]_[BUILD_TYPE]/
```

Examples:
- `build_i386_Debug/`
- `build_amd64_Release/`
- `build_arm_Debug/`

## Common Commands

```powershell
# Debug build for i386
.\build.ps1

# Release build for amd64
.\build.ps1 -Architecture amd64 -BuildType Release

# Clean and rebuild everything
.\build.ps1 -Clean

# Just configure without building
.\build.ps1 -ConfigOnly

# Build with Visual Studio generator (requires Visual Studio installed)
.\build.ps1 -Generator "Visual Studio 16 2019"
```

## Output

After a successful build, the compiled ReactOS files will be in the `build_[ARCH]_[BUILD_TYPE]` directory. This includes:
- Kernel and system libraries
- Device drivers
- Applications
- Documentation

## Troubleshooting

### CMake not found
- Ensure CMake is installed and in your PATH
- Try using the full path to cmake
- Set the PATH environment variable or customize the script

### Ninja not found
- Install Ninja: `choco install ninja`
- Or use Visual Studio generator: `-Generator "Visual Studio 16 2019"`

### Compiler not found
- Ensure a compiler toolchain is installed (MSVC, GCC, or Clang)
- Check your PATH environment variable
- Consider using RosBE (ReactOS Build Environment)

### Build fails with permission errors
- Run the terminal as Administrator
- Check that the build directory is writable

## Manual Build (Advanced)

If the scripts don't work, you can build manually:

```cmd
mkdir build_i386_Debug
cd build_i386_Debug
cmake -G Ninja -DARCH=i386 -DCMAKE_BUILD_TYPE=Debug ..
ninja
```

## References

- ReactOS Official Website: https://reactos.org/
- Build Documentation: https://reactos.org/wiki/Build_Instructions
- CMake Documentation: https://cmake.org/documentation/
- Ninja Documentation: https://ninja-build.org/
