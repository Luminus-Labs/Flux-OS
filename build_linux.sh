#!/bin/bash

# ReactOS Build Script for Linux (Ubuntu/WSL)
# This script configures and builds ReactOS using CMake

# Default values
ARCHITECTURE="i386"
BUILD_TYPE="Debug"
GENERATOR="Ninja"
CLEAN=false
CONFIG_ONLY=false
SKIP_COMPILER_CHECK=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--arch)
            ARCHITECTURE="$2"
            shift 2
            ;;
        -b|--build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -g|--generator)
            GENERATOR="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --config-only)
            CONFIG_ONLY=true
            shift
            ;;
        --skip-compiler-check)
            SKIP_COMPILER_CHECK=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -a, --arch ARCH           Target architecture (i386, amd64, arm, arm64) [default: i386]"
            echo "  -b, --build-type TYPE    Build type (Debug, Release, MinSizeRel, RelWithDebInfo) [default: Debug]"
            echo "  -g, --generator NAME     CMake generator (Unix Makefiles, Ninja) [default: Unix Makefiles]"
            echo "  --clean                  Clean build directory before building"
            echo "  --config-only            Configure only (don't build)"
            echo "  --skip-compiler-check    Skip compiler availability checks (for debugging)"
            exit 1
            ;;
    esac
done

# Validate architecture
valid_architectures=("i386" "amd64" "arm" "arm64")
if ! [[ " ${valid_architectures[*]} " =~ " ${ARCHITECTURE} " ]]; then
    echo "Error: Invalid architecture: $ARCHITECTURE"
    echo "Valid options: ${valid_architectures[*]}"
    exit 1
fi

# Validate build type
valid_build_types=("Debug" "Release" "MinSizeRel" "RelWithDebInfo")
if ! [[ " ${valid_build_types[*]} " =~ " ${BUILD_TYPE} " ]]; then
    echo "Error: Invalid build type: $BUILD_TYPE"
    echo "Valid options: ${valid_build_types[*]}"
    exit 1
fi

# Set up paths
SCRIPT_DIR=$(dirname "$(realpath "$0")")
BUILD_DIR="${SCRIPT_DIR}/build_${ARCHITECTURE}_${BUILD_TYPE}"
SOURCE_DIR="${SCRIPT_DIR}/reactos"

# Check if compilers are available (unless SkipCompilerCheck is used)
if [[ "$SKIP_COMPILER_CHECK" == "false" ]]; then
    if [[ "$GENERATOR" == *"Makefiles"* || "$GENERATOR" == *"Ninja"* ]]; then
        compiler_found=false

        # For i386 architecture on x86_64 systems, we need to check for cross-compilers
        if [[ "$ARCHITECTURE" == "i386" && "$(uname -m)" == "x86_64" ]]; then
            compilers_to_check=("i686-w64-mingw32-gcc" "gcc -m32")
        else
            compilers_to_check=("gcc" "clang")
        fi

        for compiler in "${compilers_to_check[@]}"; do
            if command -v "$compiler" &> /dev/null; then
                compiler_found=true
                break
            fi
        done

        if [[ "$compiler_found" == "false" ]]; then
            echo "Error: No compatible compiler found!"
            echo "Please install build tools:"
            if [[ "$ARCHITECTURE" == "i386" && "$(uname -m)" == "x86_64" ]]; then
                echo "  sudo apt-get update"
                echo "  sudo apt-get install gcc-multilib g++-multilib"
                echo "or for mingw:"
                echo "  sudo apt-get install mingw-w64"
            else
                echo "  sudo apt-get update"
                echo "  sudo apt-get install build-essential"
            fi
            exit 1
        fi

        # Check for the generator's build tool
        if [[ "$GENERATOR" == "Ninja" ]]; then
            if ! command -v "ninja" &> /dev/null; then
                echo "Error: Ninja build tool not found!"
                echo "Please install it with:"
                echo "  sudo apt-get update && sudo apt-get install ninja-build"
                exit 1
            fi
        fi

        # Check for specific tools needed by ReactOS
        if ! command -v "bison" &> /dev/null; then
            echo "Warning: bison not found. Install with:"
            echo "  sudo apt-get install bison"
        fi

        if ! command -v "flex" &> /dev/null; then
            echo "Warning: flex not found. Install with:"
            echo "  sudo apt-get install flex"
        fi
    fi
fi

# Handle build directory cleaning and creation
if [[ -d "$BUILD_DIR" ]]; then
    if [[ "$CLEAN" == "true" ]]; then
        echo "Cleaning build directory: $BUILD_DIR"
        rm -rf "$BUILD_DIR"
    elif [[ -f "$BUILD_DIR/CMakeCache.txt" ]]; then
        # Check for Windows cache
        if grep -q "[a-zA-Z]:/" "$BUILD_DIR/CMakeCache.txt"; then
            echo "Warning: Detected a CMake cache generated on Windows. This is incompatible with Linux/WSL."
            echo "Cleaning build directory to prevent configuration failure..."
            rm -rf "$BUILD_DIR"
        else
            # Check for generator mismatch
            PREVIOUS_GENERATOR=$(grep "CMAKE_GENERATOR:INTERNAL" "$BUILD_DIR/CMakeCache.txt" | head -n 1 | cut -d'=' -f2)
            if [[ "$PREVIOUS_GENERATOR" != "$GENERATOR" ]]; then
                echo "Warning: Detected a CMake cache generated with '$PREVIOUS_GENERATOR'."
                echo "This is incompatible with the requested generator '$GENERATOR'."
                echo "Cleaning build directory to prevent configuration failure..."
                rm -rf "$BUILD_DIR"
            fi
        fi
    fi
fi

if [[ ! -d "$BUILD_DIR" ]]; then
    echo "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
fi

# Change to build directory
cd "$BUILD_DIR" || exit 1

# Run CMake configuration
echo "Configuring ReactOS build..."
echo "  Architecture: $ARCHITECTURE"
echo "  Build Type: $BUILD_TYPE"
echo "  Generator: $GENERATOR"
echo "  Source: $SOURCE_DIR"
echo "  Build Dir: $BUILD_DIR"
echo ""

# Find CMake
CMAKE=$(command -v cmake3 || command -v cmake)
if [[ -z "$CMAKE" ]]; then
    echo "Error: CMake not found in PATH!"
    echo "Please install CMake:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install cmake"
    exit 1
fi

echo "Using CMake: $CMAKE"

# Set up CMake arguments
CMAKE_ARGS=(
    "-S" "$SOURCE_DIR"
    "-B" "."
    "-G" "$GENERATOR"
    "-DARCH=$ARCHITECTURE"
    "-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
)

# Suppress GCC 11+ strictness errors for legacy 3rd party libraries (e.g., FreeType, DbgHelp)
CMAKE_ARGS+=(
    "-DCMAKE_C_FLAGS=-Wno-error=array-parameter -Wno-error=attributes"
    "-DCMAKE_CXX_FLAGS=-Wno-error=array-parameter -Wno-error=attributes"
)

# Add toolchain file for MinGW builds
if [[ "$GENERATOR" == *"MinGW"* || "$GENERATOR" == *"Unix Makefiles"* || "$GENERATOR" == *"Ninja"* ]]; then
    if [[ -f "$SOURCE_DIR/toolchain-gcc.cmake" ]]; then
        CMAKE_ARGS+=("-DCMAKE_TOOLCHAIN_FILE=$SOURCE_DIR/toolchain-gcc.cmake")
    else
        echo "Warning: GCC toolchain file not found at $SOURCE_DIR/toolchain-gcc.cmake"
    fi
fi

# Run CMake
"$CMAKE" "${CMAKE_ARGS[@]}"

if [[ $? -ne 0 ]]; then
    echo "Error: CMake configuration failed!"
    exit 1
fi

# Stop after configuration if requested
if [[ "$CONFIG_ONLY" == "true" ]]; then
    echo "Configuration complete. Build directory: $BUILD_DIR"
    exit 0
fi

# Build the project
echo ""
echo "Building ReactOS..."
echo ""

if [[ "$GENERATOR" == "Ninja" ]]; then
    ninja
elif [[ "$GENERATOR" == *"Makefiles"* ]]; then
    if ! command -v "make" &> /dev/null; then
        echo "Error: make not found! Install with:"
        echo "  sudo apt-get install build-essential"
        exit 1
    fi
    # Use parallel builds if available
    if command -v "nproc" &> /dev/null; then
        make -j$(nproc)
    else
        make
    fi
else
    "$CMAKE" --build . --config "$BUILD_TYPE"
fi

if [[ $? -ne 0 ]]; then
    echo "Error: Build failed!"
    exit 1
fi

echo ""
echo "Build completed successfully!"
echo "Build output: $BUILD_DIR"