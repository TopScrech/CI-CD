# Repository Guidelines

A concise contributor guide for the CI-CD SwiftUI app targeting iOS, macOS, and visionOS

## Project Structure & Module Organization
- `CI-CD/` primary app sources, split into feature folders such as `App Store Connect`, `Coolify`, `Nav`, `Settings`, `Utils`
- `macOS/` macOS-specific entry points and views
- `visionOS/` visionOS-specific assets and entry points
- `Unit Tests/` XCTest target sources
- `CI-CD.xcodeproj/` Xcode project and shared settings
- Asset catalogs live in `CI-CD/Assets.xcassets` and `visionOS/Assets.xcassets`

## Coding Style & Naming Conventions
- Follow existing formatting and match surrounding indentation

## Testing Guidelines
- Tests live in `Unit Tests/` and use XCTest
- Name test methods with the `test` prefix and keep them deterministic

## Commit & Pull Request Guidelines
- Recent commits are short and plain like `shorter Button API`, `upgrade`, or version bumps like `v26.1.1 -> v26.2`
