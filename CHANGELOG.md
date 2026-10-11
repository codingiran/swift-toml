# Changelog

## 2.0.1 — prepared for release

- Add a Swift 5.10 manifest for the same TOML library and C++17 bridge. Swift 6.0+ uses Swift 6 mode and Swift Testing; Swift 5.10 uses Swift 5 mode and standalone compatibility checks.
- Support both toolchains in the TOML compliance harness and CI.
- Throw range errors when decoding narrow or unsigned Swift integers, or when encoding integers outside TOML's signed 64-bit range. Preserve field and array index paths.

Based on mattt/swift-toml 2.0.0 (`827506c90475e82d5a7f191f950fb3025cbdc0d6`). The parser and TOML module name are unchanged.
