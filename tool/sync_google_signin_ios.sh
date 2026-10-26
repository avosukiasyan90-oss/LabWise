#!/usr/bin/env bash
# After enabling Google Sign-In in Firebase Console, run this to:
# 1) refresh GoogleService-Info.plist / firebase_options.dart
# 2) add the REVERSED_CLIENT_ID URL scheme required by iOS Google Sign-In
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"
PROJECT_ID="${1:-labwise-e7923}"

dart pub global run flutterfire_cli:flutterfire configure \
  --project="$PROJECT_ID" \
  --yes \
  --platforms=ios,android,web \
  --ios-bundle-id=com.healthy.healthyProject \
  --android-package-name=com.healthy.healthy_project \
  --out=lib/firebase_options.dart

PLIST="$ROOT_DIR/ios/Runner/GoogleService-Info.plist"
INFO="$ROOT_DIR/ios/Runner/Info.plist"

if [[ ! -f "$PLIST" ]]; then
  echo "Missing $PLIST"
  exit 1
fi

REVERSED="$(/usr/libexec/PlistBuddy -c 'Print :REVERSED_CLIENT_ID' "$PLIST" 2>/dev/null || true)"
CLIENT_ID="$(/usr/libexec/PlistBuddy -c 'Print :CLIENT_ID' "$PLIST" 2>/dev/null || true)"

if [[ -z "${REVERSED}" ]]; then
  cat <<EOF
Google OAuth client is still missing from GoogleService-Info.plist.

In Firebase Console:
  Authentication -> Sign-in method -> Google -> Enable -> Save

Then run this script again.
EOF
  exit 1
fi

# Ensure CFBundleURLTypes contains the reversed client id scheme.
if /usr/libexec/PlistBuddy -c 'Print :CFBundleURLTypes' "$INFO" >/dev/null 2>&1; then
  if grep -q "$REVERSED" "$INFO"; then
    echo "URL scheme already present: $REVERSED"
  else
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$INFO" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleTypeRole string Editor" "$INFO" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$INFO" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $REVERSED" "$INFO"
    echo "Added URL scheme: $REVERSED"
  fi
else
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$INFO"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$INFO"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleTypeRole string Editor" "$INFO"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$INFO"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $REVERSED" "$INFO"
  echo "Added URL scheme: $REVERSED"
fi

if [[ -n "$CLIENT_ID" ]]; then
  echo "CLIENT_ID present for Google Sign-In."
fi

echo "Done. Full restart the app: flutter run"
