# ReactOS WSL Setup Guide

This guide explains how to set up ReactOS building in Windows Subsystem for Linux (WSL) and access the files from your Windows file system.

## 🐧 Connecting WSL to Windows Files

You have two options for working with the ReactOS files in WSL:

### ✅ Option 1: Copy Files to Linux Filesystem (Recommended)

```bash
# In WSL terminal:
cd ~
mkdir -p reactos-build
cp -r /mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS/* ./reactos-build/
cd reactos-build

# Make scripts executable
chmod +x build_linux.sh
```

### ✅ Option 2: Mount Windows Drive in WSL

```bash
# In WSL terminal:
cd /mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS
chmod +x build_linux.sh
./build_linux.sh
```

## 🔧 Windows File System Mapped in WSL

Your Windows C: drive is available in WSL at:
```
/mnt/c/
```

So your Flux-OS directory path in WSL is:
```
/mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS
```

## 🚀 Quick Start

```bash
# In WSL terminal:
cd /mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS

# Make the script executable
chmod +x build_linux.sh

# Install required tools
sudo apt-get update
sudo apt-get install -y build-essential cmake bison flex ninja-build gcc-multilib g++-multilib mingw-w64

# Test configuration
./build_linux.sh --config-only

# Full build
./build_linux.sh
```

## ⚠️ Performance Recommendations

1. **Copy to Linux filesystem**: For best performance, copy files to your Linux `/home` directory
2. **SSD recommended**: Building ReactOS requires many file operations
3. **Memory**: Allocate at least 4GB RAM to WSL
4. **CPU**: Use all available cores for parallel builds

## 📁 File Structure

In WSL, your Windows files are mounted at:
```
/mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS/
├── build_linux.sh        ← Linux build script (executable)
├── BUILD_LINUX.md        ← Linux build documentation
├── build.ps1             ← Windows build script
├── BUILD.md              ← Windows build documentation
├── reactos/              ← ReactOS source code
└── build/                ← Build output directory
```

## 🎯 Build Process

```bash
# 1. Navigate to the directory
cd /mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS

# 2. Install dependencies (first time only)
sudo apt-get update
sudo apt-get install -y build-essential cmake bison flex ninja-build gcc-multilib

# 3. Test configuration
./build_linux.sh --config-only

# 4. Start the build
./build_linux.sh

# 5. Build will take some time...
```

## 🔧 Troubleshooting

### "Permission Denied"
```bash
chmod +x build_linux.sh
```

### "No such file or directory"
```bash
# Check current directory
pwd

# List files
ls -la

# Navigate correctly
cd /mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS
```

### Slow performance
```bash
# Copy to Linux filesystem instead of using /mnt/c/
mkdir -p ~/reactos-build
cp -r /mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS/* ~/reactos-build
cd ~/reactos-build
```

The files are ready and waiting for you in WSL at `/mnt/c/Users/olive/OneDrive/Desktop/code/Flux-OS/` !