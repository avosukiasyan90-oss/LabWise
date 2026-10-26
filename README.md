# LabWise

Upload a medical lab report (PDF or Word) and get a clear summary of common test markers, what they mean, and short next steps.

## Features

- Upload **PDF** or **Word (.docx)** lab reports
- Extracts recognizable markers across biochemistry, CBC, and urinalysis panels
- Plain-language information, description, and suggestions per marker
- **Google Sign-In** (sign up + login) via Firebase
- **Cloud history** in Firestore + file backups in Storage (syncs across devices)
- Analyze / History tabs with attached-file download

> Educational support only — not a diagnosis. Always confirm with a clinician.

## Firebase setup (required once)

I cannot create the Firebase project in your Google account without your browser login. Run this once on your Mac:

```bash
./tool/setup_firebase.sh
```

Then in [Firebase Console](https://console.firebase.google.com/):

1. **Authentication → Sign-in method → Google → Enable**
2. **Firestore Database → Create database**
3. **Storage → Get started**

The script writes `lib/firebase_options.dart`, `GoogleService-Info.plist`, and `google-services.json`.

## Run

```bash
flutter pub get
flutter run
```

## How to use

1. Tap **Continue with Google**
2. Upload a lab PDF/DOCX from **Analyze**
3. Review results + download the attached file
4. Open **History** on any signed-in device

## Privacy

- Account auth uses Google via Firebase Auth
- Reports sync to your own Firebase user path: `users/{uid}/reports`
- Security rules allow only the signed-in owner to read/write their data
