#!/bin/bash

# Quick launcher for cleanup script
echo "🧹 Flutter/Gradle Cleanup Launcher"
echo "=================================="
echo

# Check if cleanup_space.sh exists
if [ -f "cleanup_space.sh" ]; then
    ./cleanup_space.sh
else
    echo "❌ Error: cleanup_space.sh not found in current directory"
    echo "Please make sure you're in the correct project directory"
    exit 1
fi 