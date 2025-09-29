# 🧹 Cleanup Space

A comprehensive collection of scripts to clean up Flutter/Gradle development environments and free up disk space by removing cache files, build artifacts, and unused development tools.

## 📋 Features

### 🚀 Core Cleanup
- **Flutter Build Cache** - Removes `build/` directories
- **Android Gradle Cache** - Cleans `.gradle` and build directories
- **iOS Build Files** - Removes `Pods/`, `build/`, and related files
- **macOS Build Files** - Cleans macOS-specific build artifacts
- **Windows Build Files** - Removes Windows build directories
- **Linux Build Files** - Cleans Linux build artifacts
- **Web Build Files** - Removes web build outputs
- **Flutter Ephemeral Files** - Cleans `.dart_tool/` and `.packages`

### 🔧 Advanced Cleanup
- **FVM Versions** - Interactive cleanup of Flutter Version Management versions
- **Android NDK** - Selective removal of Native Development Kit versions
- **Global Caches** - Cleanup of system-wide development caches
- **Package Managers** - NPM, Yarn, CocoaPods cache cleanup
- **Browser Caches** - Chrome, Safari, Edge cache cleanup
- **System Temp Files** - Cleanup of temporary system files

### 🛡️ Safety Features
- **Interactive Prompts** - Confirmation before each cleanup operation
- **Size Display** - Shows disk space usage before removal
- **Safe Removal** - Uses safe deletion functions with error handling
- **Current Version Protection** - Prevents removal of active FVM/NDK versions

## 📁 Files

| File | Platform | Description |
|------|----------|-------------|
| `cleanup_space.sh` | Unix/Linux/macOS | Main cleanup script with full features |
| `cleanup_space.bat` | Windows | Windows batch file equivalent |
| `show_cleanup_sizes.sh` | Unix/Linux/macOS | Shows sizes of cleanable directories |
| `clean.sh` | Unix/Linux/macOS | Simple Flutter clean script |

## 🚀 Quick Start

### For Unix/Linux/macOS:
```bash
# Make the script executable
chmod +x cleanup_space.sh

# Run the cleanup script
./cleanup_space.sh
```

### For Windows:
```cmd
# Run the batch file
cleanup_space.bat
```

## 📖 Detailed Usage

### Main Cleanup Script

The main script (`cleanup_space.sh` or `cleanup_space.bat`) performs a comprehensive cleanup:

1. **Project-Level Cleanup** (Automatic)
   - Flutter build cache
   - Platform-specific build files
   - Temporary files
   - Test coverage files

2. **Interactive Cleanup** (With Confirmation)
   - Global Flutter pub cache
   - Global Gradle cache
   - Android build cache
   - CocoaPods cache
   - NPM/Yarn caches
   - Browser caches
   - System temp files

3. **Advanced Cleanup** (Selective)
   - FVM versions (with size display)
   - Android NDK versions (with size display)

### FVM Cleanup

The script automatically detects FVM installations and allows selective cleanup:

- **Detection**: Finds FVM cache in common locations
- **Listing**: Shows all available FVM versions with sizes
- **Protection**: Excludes current project version from cleanup
- **Interactive**: Prompts for each version individually

### Android NDK Cleanup

Comprehensive NDK management with size information:

- **SDK Detection**: Finds Android SDK automatically
- **Version Listing**: Shows all NDK versions with sizes
- **Selective Removal**: Choose which versions to remove
- **Size Display**: Shows individual and total sizes

## 🔍 Size Analysis

Use `show_cleanup_sizes.sh` to analyze disk usage before cleanup:

```bash
chmod +x show_cleanup_sizes.sh
./show_cleanup_sizes.sh
```

This script shows:
- Project directory sizes
- Cache directory sizes
- Build artifact sizes
- Available cleanup space

## ⚙️ Configuration

### Environment Variables

The scripts automatically detect these environment variables:

- `ANDROID_HOME` - Android SDK location
- `ANDROID_SDK_ROOT` - Alternative Android SDK location
- `FLUTTER_ROOT` - Flutter SDK location

### Custom Locations

Scripts check these common locations:

**Unix/Linux/macOS:**
- `~/.fvm/versions` - FVM cache
- `~/Android/Sdk` - Android SDK
- `~/Library/Caches` - macOS caches
- `~/.gradle` - Gradle cache
- `~/.pub-cache` - Flutter pub cache

**Windows:**
- `%USERPROFILE%\.fvm\versions` - FVM cache
- `%USERPROFILE%\AppData\Local\Android\Sdk` - Android SDK
- `%USERPROFILE%\.gradle` - Gradle cache
- `%USERPROFILE%\.pub-cache` - Flutter pub cache

## 🛠️ Requirements

### Unix/Linux/macOS:
- Bash shell
- `du` command (for size calculation)
- `find` command (for file operations)

### Windows:
- Command Prompt or PowerShell
- Windows batch file support

### Optional:
- Flutter SDK (for `flutter clean` command)
- FVM (for FVM version management)
- Android SDK (for NDK cleanup)

## 📊 Space Savings

Typical space savings from cleanup:

- **Flutter Build Cache**: 100MB - 2GB
- **Gradle Cache**: 500MB - 5GB
- **FVM Versions**: 200MB - 1GB per version
- **Android NDK**: 1GB - 3GB per version
- **iOS Pods**: 100MB - 1GB
- **Browser Caches**: 50MB - 500MB

## 🔒 Safety Notes

- **Backup Important Data**: Always backup important project files
- **Current Versions Protected**: Scripts won't remove active FVM/NDK versions
- **Interactive Prompts**: All destructive operations require confirmation
- **Error Handling**: Safe removal functions prevent accidental deletion

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on your platform
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

If you encounter any issues:

1. Check the script output for error messages
2. Verify your environment variables are set correctly
3. Ensure you have the required permissions
4. Create an issue on GitHub with details

## 🔄 After Cleanup

After running the cleanup scripts, you may need to:

```bash
# Restore Flutter dependencies
flutter pub get

# Restore iOS dependencies (macOS only)
cd ios && pod install

# Restore macOS dependencies (macOS only)
cd macos && pod install

# Rebuild your project
flutter build <platform>
```

---

**Happy Cleaning! 🧹✨**