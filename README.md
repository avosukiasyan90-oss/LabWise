# LabWise Health

Reads a lab report PDF or Word document and explains every value on it in
plain language — what each marker means, whether it sits inside its reference
range, and what the result generally suggests.

Parsing happens entirely on the device. The report is never uploaded for
analysis, and no AI service is involved.

## What it does

- **Reads reports.** 94 markers across blood count, biochemistry, hormones,
  urinalysis, urogenital panels, and Helicobacter breath tests. Armenian,
  Russian, and English lab layouts.
- **Tracks change.** Uploading a repeat of the same panel replaces the older
  one and shows which values improved or declined, and by how much.
- **Groups history.** Reports are filed into folders by test type.
- **Builds a plan.** Meal timing, activity suggestions, and daily targets
  derived from weight, height, and age.
- **Shows activity.** A calendar of steps, walking, running, and cycling read
  from Apple Health or Health Connect.

## How the analysis works

There is no model and no inference. Report parsing is regular expressions
against a hand-written marker catalogue; the wellness plan is the
Mifflin-St Jeor equation plus BMI and age bands. The same inputs always
produce the same output, which is why it works offline and why the medical
text can be reviewed line by line.

Consequences worth knowing: a scanned or photographed PDF cannot be read,
because there is no OCR and the file must contain real text. An unfamiliar
lab layout may yield few or no values until its format is added.

## Running it

```sh
flutter pub get
flutter run
```

Firebase configuration (`firebase_options.dart`, `google-services.json`,
`GoogleService-Info.plist`) is committed — it is client configuration, not
secret, and access is enforced by the Firestore rules in `firestore.rules`,
which scope every document to its owner's uid.

The Telegram signup notifier is off unless a token is supplied at build time:

```sh
flutter run --dart-define=TELEGRAM_BOT_TOKEN=... --dart-define=TELEGRAM_CHANNEL=@LabWiseApp
```

## Platform requirements

| | Minimum | Why |
|---|---|---|
| iOS | 15.0 | Cloud Firestore |
| Android | API 26 | Health Connect |

iOS also needs the HealthKit capability enabled on the Runner target for
device builds, and Android needs Health Connect installed.

## Tests

```sh
flutter test
```

126 tests covering report parsing against real fixtures, test-to-test
comparison, the wellness planner, activity aggregation, localisation, and
the signup notifier.

## Not medical advice

Everything the app says is general wellbeing information generated from the
numbers on a document and three values the user typed in. It knows nothing
about medical history, medication, or conditions.
