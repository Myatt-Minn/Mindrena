#!/bin/bash

# Update iOS deployment target and Swift version in Xcode project
PROJECT_FILE="ios/Runner.xcodeproj/project.pbxproj"

# Replace iOS deployment target
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 12.0;/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/g' "$PROJECT_FILE"

# Replace Swift version
sed -i '' 's/SWIFT_VERSION = 5.0;/SWIFT_VERSION = 5.7;/g' "$PROJECT_FILE"

echo "Updated iOS deployment target to 13.0 and Swift version to 5.7"
