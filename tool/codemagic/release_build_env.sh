#!/usr/bin/env bash
# Shared Codemagic release flags for Sentry Dart symbolication (sourced by build scripts).
FLUTTER_SENTRY_SYMBOL_FLAGS=(
  --obfuscate
  --split-debug-info=build/app/symbols
  --extra-gen-snapshot-options=--save-obfuscation-map=build/app/obfuscation.map.json
)