#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${1:-labwise-e7923}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> LabWise Firebase setup"
echo "Project id: $PROJECT_ID"
echo

if ! command -v firebase >/dev/null 2>&1; then
  echo "Installing firebase-tools..."
  npm install -g firebase-tools
fi

if ! dart pub global list | grep -q flutterfire_cli; then
  dart pub global activate flutterfire_cli
fi

echo "==> Login to Firebase (browser will open)"
firebase login

echo "==> Creating / selecting Firebase project"
if firebase projects:list | grep -q "$PROJECT_ID"; then
  echo "Project $PROJECT_ID already exists."
else
  firebase projects:create "$PROJECT_ID" --display-name "LabWise" || true
fi

firebase use "$PROJECT_ID"

echo "==> Configuring FlutterFire (iOS/Android/Web)"
dart pub global run flutterfire_cli:flutterfire configure \
  --project="$PROJECT_ID" \
  --yes \
  --platforms=ios,android,web \
  --ios-bundle-id=com.healthy.healthyProject \
  --android-package-name=com.healthy.healthy_project \
  --out=lib/firebase_options.dart

echo "==> Deploying Firestore + Storage rules"
firebase deploy --only firestore:rules,storage --project "$PROJECT_ID" || true

cat <<'EOF'

Next steps in Firebase Console:
1) Authentication -> Sign-in method -> Enable Google
2) Firestore Database -> Create database (production mode is fine; rules are in firestore.rules)
3) Storage -> Get started
4) For iOS Google Sign-In, add the REVERSED_CLIENT_ID URL scheme from GoogleService-Info.plist into ios/Runner/Info.plist if FlutterFire did not add it

Then run:
  flutter run

EOF
