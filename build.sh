#!/bin/bash
# Script to build an XCFramework using Swift Package Manager with Swift 5.9

# Configuration
PACKAGE_NAME="MyPackage"
LIBRARY_NAME="MyLibrary" # The name of the library product defined in Package.swift
OUTPUT_DIR="./XCFrameworks"
FRAMEWORK_NAME="MyLibrary.xcframework"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clean any previous builds
rm -rf .build
rm -rf "$OUTPUT_DIR/$FRAMEWORK_NAME"

# Create Package.swift with TCA dependency if it doesn't exist
if [ ! -f "Package.swift" ]; then
  cat > Package.swift << EOF
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "$PACKAGE_NAME",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "$LIBRARY_NAME",
            type: .dynamic,
            targets: ["$LIBRARY_NAME"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.12.1"),
    ],
    targets: [
        .target(
            name: "$LIBRARY_NAME",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            path: "Sources/$LIBRARY_NAME"
        ),
    ]
)
EOF
  echo "Created Package.swift with Swift tools version 5.9 and TCA 1.12.1 dependency"
  
  # Create basic directory structure if it doesn't exist
  mkdir -p "Sources/$LIBRARY_NAME"
fi

# Resolve dependencies
echo "Resolving dependencies..."
swift package resolve

# Build for iOS
echo "Building for iOS..."
xcodebuild archive \
    -scheme "$PACKAGE_NAME" \
    -destination "generic/platform=iOS" \
    -archivePath ".build/archives/ios.xcarchive" \
    -derivedDataPath ".build/derived" \
    -sdk iphoneos \
    -skipMacroValidation \
    # SWIFT_OPTIMIZATION_LEVEL=-Onone \
    SWIFT_VERSION=5.9 \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

Build for iOS Simulator
echo "Building for iOS Simulator..."
xcodebuild archive \
    -scheme "$PACKAGE_NAME" \
    -destination "generic/platform=iOS Simulator" \
    -archivePath ".build/archives/ios-simulator.xcarchive" \
    -derivedDataPath ".build/derived" \
    -sdk iphonesimulator \
    -skipMacroValidation \
    # SWIFT_OPTIMIZATION_LEVEL=-Onone \
    SWIFT_VERSION=5.9 \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework ".build/archives/ios.xcarchive/Products/usr/local/lib/$LIBRARY_NAME.framework" \
    -framework ".build/archives/ios-simulator.xcarchive/Products/usr/local/lib/$LIBRARY_NAME.framework" \
    -output "$OUTPUT_DIR/$FRAMEWORK_NAME"

echo "XCFramework created at $OUTPUT_DIR/$FRAMEWORK_NAME"

