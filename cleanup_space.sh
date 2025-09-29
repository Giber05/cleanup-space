#!/bin/bash

# Flutter/Gradle Space Cleanup Script
# This script safely removes cache files and build artifacts to free up disk space

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get directory size
get_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1 || echo "0B"
    else
        echo "0B"
    fi
}

# Function to safely remove directory
safe_remove() {
    if [ -d "$1" ]; then
        local size=$(get_size "$1")
        print_status "Removing $1 (Size: $size)"
        rm -rf "$1"
        print_success "Removed $1"
        return 0
    else
        print_warning "Directory $1 does not exist, skipping"
        return 1
    fi
}

# Function to safely remove file
safe_remove_file() {
    if [ -f "$1" ]; then
        local size=$(du -sh "$1" 2>/dev/null | cut -f1 || echo "0B")
        print_status "Removing $1 (Size: $size)"
        rm -f "$1"
        print_success "Removed $1"
        return 0
    else
        print_warning "File $1 does not exist, skipping"
        return 1
    fi
}

# Function to ask for confirmation
ask_confirmation() {
    local message="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        echo -e "${YELLOW}$message [Y/n]${NC}"
    else
        echo -e "${YELLOW}$message [y/N]${NC}"
    fi
    
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        [nN][oO]|[nN]) return 1 ;;
        "") 
            if [ "$default" = "y" ]; then
                return 0
            else
                return 1
            fi
            ;;
        *) 
            print_warning "Invalid response. Please answer y or n."
            ask_confirmation "$message" "$default"
            ;;
    esac
}

# Function to clean with confirmation
clean_with_confirmation() {
    local path="$1"
    local description="$2"
    local size=""
    
    if [ -d "$path" ]; then
        size=$(get_size "$path")
        if ask_confirmation "Remove $description? (Size: $size)"; then
            safe_remove "$path"
        else
            print_status "Skipped $description"
        fi
    elif [ -f "$path" ]; then
        size=$(du -sh "$path" 2>/dev/null | cut -f1 || echo "0B")
        if ask_confirmation "Remove $description? (Size: $size)"; then
            safe_remove_file "$path"
        else
            print_status "Skipped $description"
        fi
    else
        print_warning "$description does not exist, skipping"
    fi
}

print_status "🧹 Starting Flutter/Gradle cleanup process..."
echo

# Store initial size
initial_size=$(du -sh . 2>/dev/null | cut -f1 || echo "Unknown")
print_status "Initial project size: $initial_size"
echo

# 1. Clean Flutter build cache
print_status "🏗️  Cleaning Flutter build cache..."
safe_remove "build"

# 2. Clean Android Gradle cache and build files
print_status "🤖 Cleaning Android Gradle cache..."
safe_remove "android/.gradle"
safe_remove "android/app/build"
safe_remove "android/build"

# 3. Clean iOS build files
print_status "🍎 Cleaning iOS build files..."
safe_remove "ios/build"
safe_remove "ios/Pods"
safe_remove "ios/.symlinks"
safe_remove "ios/Flutter/Flutter.framework"
safe_remove "ios/Flutter/Flutter.podspec"
safe_remove_file "ios/Podfile.lock"

# 4. Clean macOS build files
print_status "💻 Cleaning macOS build files..."
safe_remove "macos/build"
safe_remove "macos/Pods"
safe_remove_file "macos/Podfile.lock"

# 5. Clean Windows build files
print_status "🪟 Cleaning Windows build files..."
safe_remove "windows/build"

# 6. Clean Linux build files
print_status "🐧 Cleaning Linux build files..."
safe_remove "linux/build"

# 7. Clean Web build files
print_status "🌐 Cleaning Web build files..."
safe_remove "web/build"

# 8. Clean Flutter ephemeral files
print_status "📱 Cleaning Flutter ephemeral files..."
safe_remove ".dart_tool"
safe_remove_file ".packages"

# 9. Clean test coverage
print_status "🧪 Cleaning test coverage files..."
safe_remove "coverage"

# 10. Clean temporary files
print_status "🗑️  Cleaning temporary files..."
find . -name "*.DS_Store" -type f -delete 2>/dev/null && print_success "Removed .DS_Store files" || print_warning "No .DS_Store files found"
find . -name "*.tmp" -type f -delete 2>/dev/null && print_success "Removed .tmp files" || print_warning "No .tmp files found"
find . -name "*.log" -type f -delete 2>/dev/null && print_success "Removed .log files" || print_warning "No .log files found"

echo
print_status "🔧 Running Flutter commands to clean cache..."

# 11. Flutter clean
if command -v flutter >/dev/null 2>&1; then
    print_status "Running flutter clean..."
    flutter clean
    print_success "Flutter clean completed"
    
    # 12. Flutter pub cache repair (optional - uncomment if needed)
    # print_status "Running flutter pub cache repair..."
    # flutter pub cache repair
    # print_success "Flutter pub cache repair completed"
else
    print_warning "Flutter command not found, skipping flutter clean"
fi

echo
print_status "🧹 AGGRESSIVE CLEANUP OPTIONS (with confirmation)"
print_warning "The following cleanups can affect other projects on your system!"
echo

# Global Flutter cache cleanup
if [ -d "$HOME/.pub-cache" ]; then
    global_pub_size=$(get_size "$HOME/.pub-cache")
    if ask_confirmation "Clean global Flutter pub cache? This affects ALL Flutter projects! (Size: $global_pub_size)"; then
        print_status "Cleaning global pub cache..."
        if command -v flutter >/dev/null 2>&1; then
            flutter pub cache clean
            print_success "Global pub cache cleaned"
        else
            safe_remove "$HOME/.pub-cache"
        fi
    else
        print_status "Skipped global pub cache cleanup"
    fi
else
    print_warning "Global pub cache not found"
fi

echo

# Global Gradle cache cleanup
if [ -d "$HOME/.gradle" ]; then
    gradle_size=$(get_size "$HOME/.gradle")
    if ask_confirmation "Clean global Gradle cache? This affects ALL Gradle projects! (Size: $gradle_size)"; then
        print_status "Cleaning global Gradle cache..."
        safe_remove "$HOME/.gradle/caches"
        safe_remove "$HOME/.gradle/wrapper"
        safe_remove "$HOME/.gradle/daemon"
        print_success "Global Gradle cache cleaned"
    else
        print_status "Skipped global Gradle cache cleanup"
    fi
else
    print_warning "Global Gradle cache not found"
fi

echo

# Android build tools cache
if [ -d "$HOME/.android/build-cache" ]; then
    android_cache_size=$(get_size "$HOME/.android/build-cache")
    if ask_confirmation "Clean Android build cache? (Size: $android_cache_size)"; then
        safe_remove "$HOME/.android/build-cache"
    else
        print_status "Skipped Android build cache cleanup"
    fi
else
    print_warning "Android build cache not found"
fi

echo

# Android NDK cleanup
print_status "🤖 Android NDK cleanup..."

# Function to find Android SDK directory
find_android_sdk() {
    local sdk_path=""
    
    # Check common Android SDK locations
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
        sdk_path="$ANDROID_HOME"
    elif [ -n "$ANDROID_SDK_ROOT" ] && [ -d "$ANDROID_SDK_ROOT" ]; then
        sdk_path="$ANDROID_SDK_ROOT"
    elif [ -d "$HOME/Android/Sdk" ]; then
        sdk_path="$HOME/Android/Sdk"
    elif [ -d "$HOME/Library/Android/sdk" ]; then
        sdk_path="$HOME/Library/Android/sdk"
    elif [ -d "/opt/android-sdk" ]; then
        sdk_path="/opt/android-sdk"
    fi
    
    echo "$sdk_path"
}

# Find Android SDK directory
android_sdk=$(find_android_sdk)

if [ -n "$android_sdk" ] && [ -d "$android_sdk" ]; then
    ndk_dir="$android_sdk/ndk"
    print_status "Found Android SDK: $android_sdk"
    
    if [ -d "$ndk_dir" ]; then
        print_status "Found NDK directory: $ndk_dir"
        
        # List all NDK versions with sizes
        print_status "Available NDK versions:"
        total_ndk_size=0
        declare -a ndk_versions
        declare -a ndk_sizes
        
        for ndk_version in "$ndk_dir"/*; do
            if [ -d "$ndk_version" ]; then
                version_name=$(basename "$ndk_version")
                version_size=$(get_size "$ndk_version")
                total_ndk_size=$((total_ndk_size + $(du -s "$ndk_version" 2>/dev/null | cut -f1 || echo 0)))
                
                ndk_versions+=("$version_name")
                ndk_sizes+=("$version_size")
                
                print_status "  - $version_name (Size: $version_size)"
            fi
        done
        
        if [ ${#ndk_versions[@]} -gt 0 ]; then
            total_ndk_size_human=$(du -sh "$ndk_dir" 2>/dev/null | cut -f1 || echo "Unknown")
            print_status "Total NDK size: $total_ndk_size_human"
            
            if ask_confirmation "Do you want to remove NDK versions? (You'll be prompted for each)"; then
                for i in "${!ndk_versions[@]}"; do
                    version_name="${ndk_versions[$i]}"
                    version_size="${ndk_sizes[$i]}"
                    
                    if ask_confirmation "Remove NDK version $version_name? (Size: $version_size)"; then
                        safe_remove "$ndk_dir/$version_name"
                    else
                        print_status "Skipped NDK version $version_name"
                    fi
                done
            else
                print_status "Skipped NDK cleanup"
            fi
        else
            print_warning "No NDK versions found in $ndk_dir"
        fi
    else
        print_warning "NDK directory not found at $ndk_dir"
    fi
else
    print_warning "Android SDK not found"
    print_status "Checked locations:"
    print_status "  - ANDROID_HOME environment variable"
    print_status "  - ANDROID_SDK_ROOT environment variable"
    print_status "  - $HOME/Android/Sdk"
    print_status "  - $HOME/Library/Android/sdk"
    print_status "  - /opt/android-sdk"
fi

echo

# CocoaPods cache (iOS/macOS)
if [ -d "$HOME/Library/Caches/CocoaPods" ]; then
    cocoapods_size=$(get_size "$HOME/Library/Caches/CocoaPods")
    if ask_confirmation "Clean CocoaPods cache? (Size: $cocoapods_size)"; then
        safe_remove "$HOME/Library/Caches/CocoaPods"
        print_success "CocoaPods cache cleaned"
    else
        print_status "Skipped CocoaPods cache cleanup"
    fi
else
    print_warning "CocoaPods cache not found"
fi

echo

# Yarn cache
if [ -d "$HOME/Library/Caches/Yarn" ]; then
    yarn_size=$(get_size "$HOME/Library/Caches/Yarn")
    if ask_confirmation "Clean Yarn cache? Packages will be re-downloaded when needed (Size: $yarn_size)"; then
        if command -v yarn >/dev/null 2>&1; then
            print_status "Cleaning Yarn cache using yarn command..."
            yarn cache clean
            print_success "Yarn cache cleaned"
        else
            safe_remove "$HOME/Library/Caches/Yarn"
        fi
    else
        print_status "Skipped Yarn cache cleanup"
    fi
else
    print_warning "Yarn cache not found"
fi

# NPM cache
if [ -d "$HOME/.npm" ]; then
    npm_size=$(get_size "$HOME/.npm")
    if ask_confirmation "Clean NPM cache? Packages will be re-downloaded when needed (Size: $npm_size)"; then
        if command -v npm >/dev/null 2>&1; then
            print_status "Cleaning NPM cache using npm command..."
            npm cache clean --force
            print_success "NPM cache cleaned"
        else
            safe_remove "$HOME/.npm"
        fi
    else
        print_status "Skipped NPM cache cleanup"
    fi
else
    print_warning "NPM cache not found"
fi

echo

# FVM versions cleanup
print_status "🔧 FVM versions cleanup..."

# Function to find FVM cache directory
find_fvm_cache() {
    local fvm_cache=""
    
    # Check common FVM cache locations
    if [ -d "$HOME/.fvm/versions" ]; then
        fvm_cache="$HOME/.fvm/versions"
    elif [ -d "$HOME/Library/Caches/fvm/versions" ]; then
        fvm_cache="$HOME/Library/Caches/fvm/versions"
    elif [ -d "$HOME/.local/share/fvm/versions" ]; then
        fvm_cache="$HOME/.local/share/fvm/versions"
    elif command -v fvm >/dev/null 2>&1; then
        # Try to get cache directory from fvm command
        fvm_cache=$(fvm config --cache-path 2>/dev/null || echo "")
        if [ -n "$fvm_cache" ] && [ -d "$fvm_cache" ]; then
            fvm_cache="$fvm_cache/versions"
        else
            fvm_cache=""
        fi
    fi
    
    echo "$fvm_cache"
}

# Get current project FVM version
current_version=$(cat .fvm/version 2>/dev/null || echo "unknown")

# Find FVM cache directory
fvm_cache_dir=$(find_fvm_cache)

if [ -n "$fvm_cache_dir" ] && [ -d "$fvm_cache_dir" ]; then
    print_status "Found FVM cache directory: $fvm_cache_dir"
    print_status "Current project FVM version: $current_version"
    
    fvm_size=$(get_size "$fvm_cache_dir")
    
    if ask_confirmation "Show FVM versions for manual cleanup? (Total size: $fvm_size)"; then
        if command -v fvm >/dev/null 2>&1; then
            print_status "Available FVM versions:"
            fvm list
            echo
            if ask_confirmation "Do you want to remove unused FVM versions? (You'll be prompted for each)"; then
                print_status "Listing versions for removal..."
                for version_dir in "$fvm_cache_dir"/*/; do
                    if [ -d "$version_dir" ]; then
                        version_name=$(basename "$version_dir")
                        if [ "$version_name" != "$current_version" ]; then
                            version_size=$(get_size "$version_dir")
                            if ask_confirmation "Remove FVM version $version_name? (Size: $version_size)"; then
                                if command -v fvm >/dev/null 2>&1; then
                                    fvm remove "$version_name"
                                else
                                    safe_remove "$version_dir"
                                fi
                            else
                                print_status "Skipped FVM version $version_name"
                            fi
                        fi
                    fi
                done
            fi
        else
            print_warning "FVM command not found, manual cleanup required"
            print_status "Available versions in cache:"
            ls -la "$fvm_cache_dir" 2>/dev/null || print_warning "Cannot list versions"
        fi
    else
        print_status "Skipped FVM versions cleanup"
    fi
else
    print_warning "FVM cache directory not found"
    print_status "Checked locations:"
    print_status "  - $HOME/.fvm/versions"
    print_status "  - $HOME/Library/Caches/fvm/versions"
    print_status "  - $HOME/.local/share/fvm/versions"
    if command -v fvm >/dev/null 2>&1; then
        print_status "  - FVM config cache path"
    fi
fi

# Also check for local FVM versions (project-specific)
if [ -d ".fvm/versions" ]; then
    local_fvm_size=$(get_size ".fvm/versions")
    print_status "Found local FVM versions directory (Size: $local_fvm_size)"
    
    if ask_confirmation "Clean local FVM versions? (This only affects this project)"; then
        safe_remove ".fvm/versions"
        print_status "Local FVM versions cleaned"
    else
        print_status "Skipped local FVM versions cleanup"
    fi
fi

echo

# Node modules in project (if exists)
if [ -d "node_modules" ]; then
    node_modules_size=$(get_size "node_modules")
    if ask_confirmation "Remove node_modules directory? (Size: $node_modules_size)"; then
        safe_remove "node_modules"
        print_status "Run 'npm install' or 'yarn install' to restore"
    else
        print_status "Skipped node_modules cleanup"
    fi
else
    print_warning "No node_modules directory found"
fi

echo

# Browser cache directories
print_status "🌐 Browser cache cleanup options:"

# Chrome cache
if [ -d "$HOME/Library/Caches/Google/Chrome" ]; then
    chrome_size=$(get_size "$HOME/Library/Caches/Google/Chrome")
    if ask_confirmation "Clean Chrome cache? (Size: $chrome_size)"; then
        safe_remove "$HOME/Library/Caches/Google/Chrome"
    else
        print_status "Skipped Chrome cache cleanup"
    fi
fi

# Safari cache
if [ -d "$HOME/Library/Caches/com.apple.Safari" ]; then
    safari_size=$(get_size "$HOME/Library/Caches/com.apple.Safari")
    if ask_confirmation "Clean Safari cache? (Size: $safari_size)"; then
        safe_remove "$HOME/Library/Caches/com.apple.Safari"
    else
        print_status "Skipped Safari cache cleanup"
    fi
fi

echo

# System temp files
print_status "🗑️ System cleanup options:"

# Temp directories
if [ -d "/tmp" ]; then
    tmp_size=$(get_size "/tmp")
    if ask_confirmation "Clean system temp files? (Size: $tmp_size)"; then
        print_status "Cleaning system temp files..."
        find /tmp -type f -atime +7 -delete 2>/dev/null || print_warning "Some temp files couldn't be deleted (permission issues)"
        print_success "System temp files cleaned"
    else
        print_status "Skipped system temp cleanup"
    fi
fi

# User temp cache
if [ -d "$HOME/Library/Caches" ]; then
    user_cache_size=$(get_size "$HOME/Library/Caches")
    if ask_confirmation "Show large cache directories for manual review? (Total size: $user_cache_size)"; then
        print_status "Top 10 largest cache directories:"
        du -sh "$HOME/Library/Caches"/* 2>/dev/null | sort -hr | head -10
        echo
        print_warning "Review the above list and manually delete what you don't need"
        print_warning "Common safe-to-delete: com.apple.dt.Xcode, com.spotify.client, etc."
    fi
fi

# Calculate final size
echo
final_size=$(du -sh . 2>/dev/null | cut -f1 || echo "Unknown")
print_status "Final project size: $final_size"

echo
print_success "✅ Cleanup completed successfully!"
print_status "You can now run 'flutter pub get' to restore dependencies"
print_status "For iOS: run 'cd ios && pod install' to restore pods"
print_status "For macOS: run 'cd macos && pod install' to restore pods"

# Show recommendation for next steps
echo
print_status "📋 Recommended next steps:"
echo "1. flutter pub get"
echo "2. cd ios && pod install (if developing for iOS)"
echo "3. cd macos && pod install (if developing for macOS)"
echo "4. flutter build <platform> (to rebuild for your target platform)" 