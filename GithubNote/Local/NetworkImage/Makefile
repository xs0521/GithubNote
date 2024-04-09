test-macos:
	xcodebuild test \
			-scheme NetworkImage \
			-destination platform="macOS"

test-ios:
	xcodebuild test \
			-scheme NetworkImage \
			-destination platform="iOS Simulator,name=iPhone SE (3rd generation)"

test-tvos:
	xcodebuild test \
			-scheme NetworkImage \
			-destination platform="tvOS Simulator,name=Apple TV"

test-watchos:
	xcodebuild test \
			-scheme NetworkImage \
			-destination platform="watchOS Simulator,name=Apple Watch SE (40mm) (2nd generation)"

test: test-macos test-ios test-tvos test-watchos

format:
	swift format --in-place --recursive .

.PHONY: format
