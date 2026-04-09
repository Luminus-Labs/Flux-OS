# ReactOS Build Script
# This script configures and builds ReactOS using CMake

param(
    [string]$Architecture = "i386",
    [string]$BuildType = "Debug",
    [string]$Generator = "NMake Makefiles",
    [switch]$Clean,
    [switch]$ConfigOnly,
    [switch]$SkipCompilerCheck
)

# Validate architecture
$validArchitectures = @("i386", "amd64", "arm", "arm64")
if ($validArchitectures -notcontains $Architecture) {
    Write-Error "Invalid architecture: $Architecture. Must be one of: $($validArchitectures -join ', ')"
    exit 1
}

# Validate build type
$validBuildTypes = @("Debug", "Release", "MinSizeRel", "RelWithDebInfo")
if ($validBuildTypes -notcontains $BuildType) {
    Write-Error "Invalid build type: $BuildType. Must be one of: $($validBuildTypes -join ', ')"
    exit 1
}

# Set up paths
$scriptDir = $PSScriptRoot
$buildDir = Join-Path $scriptDir "build_$Architecture`_$BuildType"
$sourceDir = Join-Path $scriptDir "reactos"

# Check if compilers are available (unless SkipCompilerCheck is used)
if (-not $SkipCompilerCheck) {
    if ($Generator -eq "NMake Makefiles") {
        $compilerFound = $false
        $compilersToCheck = @("cl", "gcc", "cc")

        foreach ($compiler in $compilersToCheck) {
            if (Get-Command $compiler -ErrorAction SilentlyContinue) {
                $compilerFound = $true
                break
            }
        }

        if (-not $compilerFound) {
            Write-Error "No compatible compiler found! Required: Visual Studio (cl) or MinGW/GCC (gcc)"
            Write-Error "Please install Visual Studio or MinGW to build ReactOS"
            exit 1
        }
    }
}

# Create or clean build directory
if (Test-Path $buildDir) {
    if ($Clean) {
        Write-Host "Cleaning build directory: $buildDir"
        Remove-Item $buildDir -Recurse -Force
    }
}

if (-not (Test-Path $buildDir)) {
    Write-Host "Creating build directory: $buildDir"
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

# Change to build directory
Push-Location $buildDir

try {
    # Run CMake configuration
    Write-Host "Configuring ReactOS build..."
    Write-Host "  Architecture: $Architecture"
    Write-Host "  Build Type: $BuildType"
    Write-Host "  Generator: $Generator"
    Write-Host "  Source: $sourceDir"
    Write-Host "  Build Dir: $buildDir"
    Write-Host ""

    # Try to use a newer CMake if available (minimum 3.17.0 required)
    $newerCMake = Get-Command "cmake3" -ErrorAction SilentlyContinue
    if (-not $newerCMake) {
        $newerCMake = Get-Command "cmake" -ErrorAction SilentlyContinue
    }

    if ($newerCMake) {
        Write-Host "Using CMake: $($newerCMake.Source)"

        # Build the argument array properly using the call operator
        $allArgs = @("-S", "`"$sourceDir`"", "-B", ".", "-G", $Generator)
        $allArgs += "-DARCH=$Architecture"
        $allArgs += "-DCMAKE_BUILD_TYPE=$BuildType"

        # Add toolchain file for MinGW builds
        if ($Generator -eq "MinGW Makefiles" -or $Generator -eq "NMake Makefiles") {
            $mingwToolchain = Join-Path $sourceDir "toolchain-gcc.cmake"
            if (Test-Path $mingwToolchain) {
                $allArgs += "-DCMAKE_TOOLCHAIN_FILE=`"$mingwToolchain`""
            }
        }

        # Execute CMake using call operator
        & $newerCMake.Source $allArgs
    } else {
        Write-Error "CMake not found in PATH!"
        exit 1
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "CMake configuration failed!"
        exit 1
    }

    # Stop after configuration if requested
    if ($ConfigOnly) {
        Write-Host "Configuration complete. Build directory: $buildDir"
        exit 0
    }

    # Build the project
    Write-Host ""
    Write-Host "Building ReactOS..."
    Write-Host ""

    if ($Generator -eq "Ninja") {
        $ninjaPath = Get-Command "ninja" -ErrorAction SilentlyContinue
        if (-not $ninjaPath) {
            Write-Error "Ninja build tool not found! Install Ninja or use a different generator."
            exit 1
        }
        & ninja
    } elseif ($Generator -eq "NMake Makefiles") {
        $nmakePath = Get-Command "nmake" -ErrorAction SilentlyContinue
        if (-not $nmakePath) {
            Write-Error "nmake not found! Ensure Visual Studio is installed and in PATH."
            exit 1
        }
        # For NMake Makefiles, we need to specify the build type
        & cmake --build . --config $BuildType
    } else {
        & cmake --build . --config $BuildType
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Build failed!"
        exit 1
    }

    Write-Host ""
    Write-Host "Build completed successfully!"
    Write-Host "Build output: $buildDir"

} finally {
    Pop-Location
}
