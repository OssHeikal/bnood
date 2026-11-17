#!/usr/bin/env bash
# Upload Sentry debug files after a v* tag release build (skips when token unset).
set -euo pipefail

if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  echo "Sentry symbol upload skipped: SENTRY_AUTH_TOKEN is not set."
  exit 0
fi

if [[ -z "${CM_TAG:-}" ]] || [[ "${CM_TAG}" != v* ]]; then
  echo "Sentry symbol upload skipped: not a v* tag build (CM_TAG=${CM_TAG:-<unset>})."
  exit 0
fi

if [[ -z "${VERSION_NAME:-}" ]] || [[ -z "${BUILD_NUMBER:-}" ]]; then
  echo "Sentry symbol upload skipped: VERSION_NAME or BUILD_NUMBER missing."
  exit 0
fi

export SENTRY_URL="${SENTRY_URL:-https://de.sentry.io}"
export SENTRY_ORG="${SENTRY_ORG:-etbaaly}"
export SENTRY_PROJECT="${SENTRY_PROJECT:-bnood-flutter}"
export SENTRY_RELEASE="${VERSION_NAME}+${BUILD_NUMBER}"

echo "Uploading Sentry debug symbols for release ${SENTRY_RELEASE}..."
dart run sentry_dart_plugin