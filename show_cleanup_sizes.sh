#!/bin/bash

# Flutter/Gradle Space Analysis Script
# This script shows potential cleanup sizes without removing anything

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_size() {
    echo -e "${GREEN}[SIZE]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

get_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1 || echo "0B"
    else
        echo "0B"
    fi
}

echo "🔍 CLEANUP SIZE ANALYSIS"
echo "========================"
echo

print_status "Analyzing potential cleanup targets..."
echo

total_project_size=0
total_global_size=0

# Project-level analysis
echo "📁 PROJECT-LEVEL CLEANUP:"
echo "-------------------------"

# Flutter build cache
if [ -d "build" ]; then
    size=$(get_size "build")
    print_size "Flutter build cache: $size"
fi

# Android
if [ -d "android/.gradle" ]; then
    size=$(get_size "android/.gradle")
    print_size "Android Gradle cache: $size"
fi

if [ -d "android/app/build" ]; then
    size=$(get_size "android/app/build")
    print_size "Android app build: $size"
fi

if [ -d "android/build" ]; then
    size=$(get_size "android/build")
    print_size "Android build: $size"
fi

# iOS/macOS
if [ -d "ios/Pods" ]; then
    size=$(get_size "ios/Pods")
    print_size "iOS Pods: $size"
fi

if [ -d "macos/Pods" ]; then
    size=$(get_size "macos/Pods")
    print_size "macOS Pods: $size"
fi

# Flutter ephemeral
if [ -d ".dart_tool" ]; then
    size=$(get_size ".dart_tool")
    print_size "Dart tool cache: $size"
fi

# Node modules
if [ -d "node_modules" ]; then
    size=$(get_size "node_modules")
    print_size "Node modules: $size"
fi

echo

# Global cache analysis
echo "🌍 GLOBAL CACHE CLEANUP:"
echo "-------------------------"

# Flutter global cache
if [ -d "$HOME/.pub-cache" ]; then
    size=$(get_size "$HOME/.pub-cache")
    print_size "Flutter pub cache: $size"
fi

# Gradle global cache
if [ -d "$HOME/.gradle" ]; then
    size=$(get_size "$HOME/.gradle")
    print_size "Gradle global cache: $size"
    
    if [ -d "$HOME/.gradle/caches" ]; then
        cache_size=$(get_size "$HOME/.gradle/caches")
        print_size "  └─ Gradle caches: $cache_size"
    fi
    
    if [ -d "$HOME/.gradle/wrapper" ]; then
        wrapper_size=$(get_size "$HOME/.gradle/wrapper")
        print_size "  └─ Gradle wrapper: $wrapper_size"
    fi
fi

# Android build cache
if [ -d "$HOME/.android/build-cache" ]; then
    size=$(get_size "$HOME/.android/build-cache")
    print_size "Android build cache: $size"
fi

# CocoaPods cache
if [ -d "$HOME/Library/Caches/CocoaPods" ]; then
    size=$(get_size "$HOME/Library/Caches/CocoaPods")
    print_size "CocoaPods cache: $size"
fi

# Yarn cache
if [ -d "$HOME/Library/Caches/Yarn" ]; then
    size=$(get_size "$HOME/Library/Caches/Yarn")
    print_size "Yarn cache: $size"
fi

# NPM cache
if [ -d "$HOME/.npm" ]; then
    size=$(get_size "$HOME/.npm")
    print_size "NPM cache: $size"
fi

echo

# FVM versions
echo "📦 FVM VERSIONS:"
echo "----------------"
if [ -d ".fvm/versions" ]; then
    current_version=$(cat .fvm/version 2>/dev/null || echo "unknown")
    print_status "Current FVM version: $current_version"
    
    total_fvm_size=$(get_size ".fvm/versions")
    print_size "Total FVM versions: $total_fvm_size"
    
    print_status "Individual versions:"
    for version_dir in .fvm/versions/*/; do
        if [ -d "$version_dir" ]; then
            version_name=$(basename "$version_dir")
            version_size=$(get_size "$version_dir")
            if [ "$version_name" = "$current_version" ]; then
                print_size "  ✓ $version_name: $version_size (current)"
            else
                print_size "  ✗ $version_name: $version_size (removable)"
            fi
        fi
    done
else
    print_warning "No FVM versions found"
fi

echo

# Browser caches
echo "🌐 BROWSER CACHES:"
echo "------------------"

if [ -d "$HOME/Library/Caches/Google/Chrome" ]; then
    size=$(get_size "$HOME/Library/Caches/Google/Chrome")
    print_size "Chrome cache: $size"
fi

if [ -d "$HOME/Library/Caches/com.apple.Safari" ]; then
    size=$(get_size "$HOME/Library/Caches/com.apple.Safari")
    print_size "Safari cache: $size"
fi

echo

# System caches
echo "🗑️ SYSTEM CLEANUP:"
echo "-------------------"

if [ -d "/tmp" ]; then
    size=$(get_size "/tmp")
    print_size "System temp files: $size"
fi

if [ -d "$HOME/Library/Caches" ]; then
    size=$(get_size "$HOME/Library/Caches")
    print_size "User cache directory: $size"
    
    print_status "Top 5 largest cache directories:"
    du -sh "$HOME/Library/Caches"/* 2>/dev/null | sort -hr | head -5 | while read line; do
        print_size "  └─ $line"
    done
fi

echo
echo "💡 RECOMMENDATIONS:"
echo "==================="
echo "• Run './cleanup_space.sh' to clean with confirmations"
echo "• Focus on large global caches (Gradle: 7.3G is significant!)"
echo "• Review FVM versions and remove unused ones"
echo "• Consider browser cache cleanup if very large"
echo "• Project-level cleanup is always safe"

echo
print_status "Analysis complete! Use the cleanup script to proceed with actual cleanup." 