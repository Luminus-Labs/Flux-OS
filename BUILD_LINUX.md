# ReactOS Linux Build Script

This guide explains how to use the `build_linux.sh` script to build ReactOS on Linux (including Ubuntu in WSL).

## 📋 Prerequisites

Before building ReactOS, you need to install the required tools:

### For Ubuntu/WSL (i386 target):

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake bison flex ninja-build \
    gcc-multilib g++-multilib mingw-w64
```

### For Ubuntu (amd64 target):

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake bison flex ninja-build
```

## 🚀 Usage

### Basic Build

```bash
./build_linux.sh
```

### Configuration Only

```bash
./build_linux.sh --config-only
```

### Clean Build

```bash
./build_linux.sh --clean
```

### Custom Architecture

```bash
./build_linux.sh --arch amd64 --build-type Release
```

### Use Ninja Generator

```bash
./build_linux.sh --generator Ninja
```

## 🌟 Features

- **Automatic Tool Detection**: Checks for required tools and provides installation commands
- **Cross-compilation Support**: Handles i386 builds on x86_64 systems
- **Parallel Builds**: Uses all available CPU cores for faster compilation
- **Clean Build Support**: `–clean` option removes previous build artifacts
- **Configuration Only**: `–config-only` for CMake configuration testing
- **Flexible Generators**: Supports Unix Makefiles and Ninja

## 📝 Command Line Options

| Option | Description |
|--------|-------------|
| `-a, --arch ARCH` | Target architecture (i386, amd64, arm, arm64) |
| `-b, --build-type TYPE` | Build type (Debug, Release, MinSizeRel, RelWithDebInfo) |
| `-g, --generator NAME` | CMake generator (Unix Makefiles, Ninja) |
| `--clean` | Clean build directory before building |
| `--config-only` | Configure only (don't build) |
| `--skip-compiler-check` | Skip compiler availability checks |

## 🐧 WSL Notes

1. **File System Performance**: Build in the Linux file system (`/home/youruser/project`) rather than Windows mounted drives for better performance
2. **Disk Space**: ReactOS build requires several GB of disk space
3. **Memory**: Allocate sufficient memory to WSL (recommended 4GB+)

## 🔧 Troubleshooting

### Missing Tools

If you get errors about missing tools, run the prerequisite commands above.

### CMake Version Too Old

If your CMake version is too old:
```bash
sudo apt-get remove --purge cmake
sudo snap install cmake --classic
```

### Compilation Errors

For common compilation issues:
```bash
./build_linux.sh --clean --config-only
```

Then review the CMake configuration output for missing dependencies.

## 🎓 Build Examples

### Full Clean Build (i386 Debug)

```bash
./build_linux.sh --clean
```

### Release Build (amd64)

```bash
./build_linux.sh --arch amd64 --build-type Release
```

### Test Configuration Only

```bash
./build_linux.sh --config-only --skip-compiler-check
```

### Fast Build with Ninja

```bash
./build_linux.sh --generator Ninja
```

The script provides helpful error messages and installation commands when requirements are missing!