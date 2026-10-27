// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LabWise Health';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get signOut => 'Sign out';

  @override
  String get tabAnalyze => 'Analyze';

  @override
  String get tabHistory => 'History';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabProfile => 'Profile';

  @override
  String get authTagline =>
      'Sign in once to keep your lab history synced across devices. You stay signed in until you sign out.';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authExplainer =>
      'Signing in creates your account automatically if you are new, or logs you back in if you already use LabWise Health.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get authPrivacyNote => 'Your reports stay private to your account.';

  @override
  String get signInCanceled => 'Sign-in was canceled.';

  @override
  String signInFailed(String provider, String detail) {
    return 'Could not sign in with $provider. $detail';
  }

  @override
  String get firebaseNotConfigured =>
      'Firebase is not configured yet on this machine.';

  @override
  String get firebaseSetupIntro =>
      'Create the LabWise Health Firebase project and enable Google Sign-In, then run:';

  @override
  String get firebaseSetupFooter =>
      'This links Auth, Firestore, and Storage so history syncs across devices.';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signOutBody =>
      'You can sign back in anytime. Cloud history stays saved to your account.';

  @override
  String get cloudSyncFailed =>
      'Could not sync cloud history. Showing local copy.';

  @override
  String get analyzeIntro =>
      'We read the full report, extract every test point, and explain each one with clear information, description, and suggestions.';

  @override
  String get howItWorks => 'How it works';

  @override
  String get stepUploadTitle => 'Upload';

  @override
  String get stepUploadBody => 'Choose a PDF or Word report from your device.';

  @override
  String get stepUnderstandTitle => 'Understand';

  @override
  String get stepUnderstandBody =>
      'Every test point gets information, description, and a suggestion.';

  @override
  String get stepActTitle => 'Act';

  @override
  String get stepActBody =>
      'Review needs-attention items first, then confirm with your clinician.';

  @override
  String get filesStayOnDevice =>
      'Your files stay on this device. History is saved locally.';

  @override
  String get uploadTitle => 'Upload a lab report';

  @override
  String get uploadSubtitle =>
      'PDF or Word (.docx). We read the full document and explain each result.';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get readingReport => 'Reading your report…';

  @override
  String get readingReportSubtitle =>
      'Extracting markers and preparing guidance';

  @override
  String get alreadyUploadedTitle => 'Already uploaded';

  @override
  String alreadyUploadedBody(String fileName) {
    return '\"$fileName\" is already in your history. Open History to view it instead of uploading a duplicate.';
  }

  @override
  String get viewHistory => 'View History';

  @override
  String get errorReadFile => 'Could not read that file. Please try again.';

  @override
  String get errorScannedPdf =>
      'This PDF looks scanned. Try a text-based PDF or Word export.';

  @override
  String get errorGeneric =>
      'Something went wrong while reading the file. Please try another PDF or DOCX.';

  @override
  String get errorUnsupportedType => 'Unsupported file type.';

  @override
  String get historyTitle => 'History';

  @override
  String historySummary(int reports, int folders) {
    String _temp0 = intl.Intl.pluralLogic(
      reports,
      locale: localeName,
      other: '$reports reports',
      one: '1 report',
    );
    String _temp1 = intl.Intl.pluralLogic(
      folders,
      locale: localeName,
      other: '$folders folders',
      one: '1 folder',
    );
    return '$_temp0 in $_temp1.';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String needAttentionSuffix(int count) {
    return '$count need attention';
  }

  @override
  String get noReportsTitle => 'No reports yet';

  @override
  String get noReportsBody =>
      'Upload a lab PDF or Word file from the Analyze tab. Reports get sorted into folders by test type automatically.';

  @override
  String get deleteReportTitle => 'Delete report?';

  @override
  String deleteReportBody(String fileName) {
    return 'Remove \"$fileName\" from history?';
  }

  @override
  String get categoryBloodCount => 'Blood Count';

  @override
  String get categoryBloodCountDesc =>
      'Complete blood counts — cells, hemoglobin, platelets';

  @override
  String get categoryBiochemistry => 'Blood Chemistry';

  @override
  String get categoryBiochemistryDesc =>
      'Glucose, cholesterol, liver and kidney markers';

  @override
  String get categoryHormones => 'Hormones';

  @override
  String get categoryHormonesDesc => 'Thyroid and other hormone panels';

  @override
  String get categoryUrinalysis => 'Urine Tests';

  @override
  String get categoryUrinalysisDesc => 'Urine strip and microscopy results';

  @override
  String get categoryUrogenital => 'Urogenital';

  @override
  String get categoryUrogenitalDesc => 'Smear microscopy and PCR panels';

  @override
  String get categoryOther => 'Other Reports';

  @override
  String get categoryOtherDesc => 'Reports we could not categorize yet';

  @override
  String get categoryInfection => 'Infection Tests';

  @override
  String get categoryInfectionDesc =>
      'Helicobacter and other infection screens';

  @override
  String get yourResults => 'Your results';

  @override
  String get done => 'Done';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get needsAttention => 'Needs attention';

  @override
  String get needsAttentionSubtitle =>
      'Values outside typical ranges, with clear next-step guidance.';

  @override
  String get allFindings => 'All findings';

  @override
  String get otherFindings => 'Other findings';

  @override
  String get everyPointRead => 'Every test point read from your document.';

  @override
  String get noStructuredPoints =>
      'No structured test points were extracted. Your file is saved in History so you can open it again later.';

  @override
  String get resultsDisclaimer =>
      'Educational guidance only — not medical advice. Always confirm decisions with a licensed clinician.';

  @override
  String get pointsRead => 'Points read';

  @override
  String get needAttentionLabel => 'Need attention';

  @override
  String get documentDetails => 'Document details';

  @override
  String get fieldExam => 'Exam';

  @override
  String get fieldClinic => 'Clinic';

  @override
  String get fieldPatient => 'Patient';

  @override
  String get fieldReportNumber => 'Report #';

  @override
  String get fieldSampleDate => 'Sample date';

  @override
  String get fieldDoctor => 'Doctor';

  @override
  String get fieldMethod => 'Method';

  @override
  String get fieldAddress => 'Address';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldLabLicence => 'Lab licence';

  @override
  String get healthNeedsReview => 'Needs review';

  @override
  String get healthLookingGood => 'Looking good';

  @override
  String get healthSomeAttention => 'Some attention needed';

  @override
  String get healthFollowUp => 'Follow up recommended';

  @override
  String get markerInformation => 'Information';

  @override
  String get markerDescription => 'Description';

  @override
  String get markerSuggestion => 'Suggestion';

  @override
  String markerCode(String code) {
    return 'Code: $code';
  }

  @override
  String markerRef(String range) {
    return 'Ref: $range';
  }

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusLow => 'Low';

  @override
  String get statusHigh => 'High';

  @override
  String get statusUnknown => 'Let\'s get started';

  @override
  String get attachedFile => 'Attached file';

  @override
  String get attachedFileUnavailable => 'File unavailable for download';

  @override
  String get attachedFileOnDevice => 'Saved on this device';

  @override
  String get attachedFileSynced => 'Synced from your account';

  @override
  String get downloadFile => 'Download file';

  @override
  String get preparing => 'Preparing…';

  @override
  String get attachedFileMissing => 'Attached file is not available.';

  @override
  String get attachedFileExportFailed =>
      'Could not export the file. Please try again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle =>
      'Your Google details stay as they are. Health details are optional and only used to give better context.';

  @override
  String get googleAccount => 'Google account';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldSurname => 'Surname';

  @override
  String get managedByGoogle => 'Managed by your account';

  @override
  String get healthDetails => 'Health details';

  @override
  String get updateAnytime => 'You can update these anytime.';

  @override
  String get fieldWeight => 'Weight';

  @override
  String get fieldHeight => 'Height';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldCountry => 'Country';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get unitYearsOld => 'years old';

  @override
  String get selectCountry => 'Select country';

  @override
  String get searchCountry => 'Search country';

  @override
  String noCountryMatch(String query) {
    return 'No country matches \"$query\".';
  }

  @override
  String bmiNote(String bmi) {
    return 'BMI $bmi — educational estimate only.';
  }

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileSaveFailed => 'Could not save profile. Try again.';

  @override
  String get validationWeight => 'Enter a weight between 2 and 400 kg.';

  @override
  String get validationHeight => 'Enter a height between 40 and 260 cm.';

  @override
  String get validationAge => 'Enter an age between 1 and 120 years.';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Changes apply across the whole app.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String setupWelcomeNamed(String name) {
    return 'Welcome, $name';
  }

  @override
  String get setupWelcome => 'Welcome to LabWise';

  @override
  String get setupBody =>
      'Add a few health details so results have better context. You can skip this and fill it in later from Profile.';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get setupSaveFailed => 'Could not save. You can add this later.';

  @override
  String get planTitle => 'Your Plan';

  @override
  String planHeadlineUnder(String who) {
    return '$who, here\'s a plan to build weight steadily and keep energy up.';
  }

  @override
  String planHeadlineHealthy(String who) {
    return '$who, here\'s a plan to hold your healthy range and stay strong.';
  }

  @override
  String planHeadlineAbove(String who) {
    return '$who, here\'s a plan to trim gradually without feeling hungry.';
  }

  @override
  String planHeadlineWellAbove(String who) {
    return '$who, here\'s a gentle, joint-friendly plan to start losing weight.';
  }

  @override
  String get planHeadlineFallback =>
      'Add your height and weight to unlock a plan built for you.';

  @override
  String get planWhoFallback => 'Here';

  @override
  String get bmiUnder => 'Under range';

  @override
  String get bmiHealthy => 'Healthy range';

  @override
  String get bmiAbove => 'Above range';

  @override
  String get bmiWellAbove => 'Well above range';

  @override
  String get bmiProfileNeeded => 'Profile needed';

  @override
  String get targetsTuned => 'Targets below are tuned to this range.';

  @override
  String get metricKcal => 'kcal / day';

  @override
  String get metricWater => 'water';

  @override
  String get metricSteps => 'steps';

  @override
  String get eatingWindow => 'Eating window';

  @override
  String eatingWindowSubtitle(String window) {
    return 'Keep food inside $window';
  }

  @override
  String get eatingWindowFallback => 'When to eat across the day';

  @override
  String get movement => 'Movement';

  @override
  String get movementSubtitle => 'Sports picked for your body and age';

  @override
  String get dailyHabits => 'Daily habits';

  @override
  String get dailyHabitsSubtitle => 'Small things that compound';

  @override
  String get fromYourReports => 'From your reports';

  @override
  String get fromYourReportsSubtitle =>
      'Adjusted for values that need attention';

  @override
  String get planDisclaimer =>
      'General wellbeing guidance based on the details you entered — not medical advice. Check with a clinician before changing diet, exercise, or medication.';

  @override
  String get planSetupTitle => 'Tell us a little more';

  @override
  String planSetupBody(String fields) {
    return 'Add your $fields in Profile and this tab will build meal timings, sport suggestions, and daily targets around you.';
  }

  @override
  String get openProfile => 'Open Profile';

  @override
  String planMissingHint(String fields) {
    return 'Add your $fields for a sharper plan.';
  }

  @override
  String get fieldWeightLower => 'weight';

  @override
  String get fieldHeightLower => 'height';

  @override
  String get fieldAgeLower => 'age';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealBreakfastIdea =>
      'Protein plus slow carbs — eggs or yogurt with oats and fruit.';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealLunchIdea =>
      'Half the plate vegetables, a palm of protein, a fist of grains.';

  @override
  String get mealSnack => 'Snack';

  @override
  String get mealSnackIdea =>
      'Nuts, cheese, or a smoothie to add calories without bloating.';

  @override
  String get mealLightSnack => 'Light snack';

  @override
  String get mealLightSnackIdea =>
      'Fruit with a handful of nuts if you feel a dip.';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealDinnerIdeaLight =>
      'Lighter and earlier — vegetables, lean protein, minimal oil.';

  @override
  String get mealDinnerIdeaBalanced =>
      'Balanced plate, finish about 2 hours before bed.';

  @override
  String get mealKitchenClosed => 'Kitchen closed';

  @override
  String get mealKitchenClosedIdea =>
      'Water or herbal tea only after this — it protects your sleep.';

  @override
  String get activityWalking => 'Walking';

  @override
  String get activityWalkingSchedule => '30–40 min, most days';

  @override
  String get activityWalkingWhy =>
      'Easiest way to burn fat without stressing knees and hips.';

  @override
  String get activitySwimming => 'Swimming or water aerobics';

  @override
  String get activitySwimmingSchedule => '2× per week';

  @override
  String get activitySwimmingWhy =>
      'Water carries your weight, so joints stay comfortable.';

  @override
  String get activityLightStrength => 'Light strength circuit';

  @override
  String get activityLightStrengthSchedule => '2× per week, 20 min';

  @override
  String get activityLightStrengthWhy =>
      'Keeps muscle while you lose fat, which protects metabolism.';

  @override
  String get activityBriskWalk => 'Brisk walking or cycling';

  @override
  String get activityBriskWalkSchedule => '35 min, 5× per week';

  @override
  String get activityBriskWalkWhy =>
      'Steady cardio is the most reliable driver of fat loss.';

  @override
  String get activityStrength => 'Strength training';

  @override
  String get activityStrengthSchedule2 => '2× per week';

  @override
  String get activityStrengthSchedule3 => '3× per week';

  @override
  String get activityStrengthWhyMuscle =>
      'Builds muscle so you burn more at rest.';

  @override
  String get activityStrengthWhyBone =>
      'Protects bone density and muscle as you age.';

  @override
  String get activityStrengthWhyGain =>
      'Turns the extra calories you eat into muscle, not just fat.';

  @override
  String get activityPostMeal => 'Post-meal walk';

  @override
  String get activityPostMealSchedule => '10–15 min after dinner';

  @override
  String get activityPostMealWhy =>
      'Blunts the blood-sugar spike from your largest meal.';

  @override
  String get activityEasyWalk => 'Easy walking';

  @override
  String get activityEasyWalkSchedule => '20–30 min daily';

  @override
  String get activityEasyWalkWhy =>
      'Keeps the heart fit without burning the calories you need.';

  @override
  String get activityMixedCardio => 'Mixed cardio';

  @override
  String get activityMixedCardioSchedule => '150 min per week';

  @override
  String get activityMixedCardioWhy =>
      'Meets the activity level linked with the best heart markers.';

  @override
  String get activityEnjoy => 'Something you enjoy';

  @override
  String get activityEnjoySchedule => '1× per week';

  @override
  String get activityEnjoyWhy =>
      'Football, dancing, hiking — enjoyment is what makes it stick.';

  @override
  String get activityBalance => 'Balance and mobility';

  @override
  String get activityBalanceSchedule => '10 min daily';

  @override
  String get activityBalanceWhy =>
      'Reduces fall risk and keeps joints moving freely.';

  @override
  String habitWater(String litres) {
    return 'Drink about $litres L of water across the day.';
  }

  @override
  String get habitSleep => 'Aim for 7–9 hours of sleep at consistent times.';

  @override
  String get habitSugar => 'Keep sugary drinks for special occasions only.';

  @override
  String get habitFrequentMeals =>
      'Eat something every 3–4 hours so you never run empty.';

  @override
  String get habitCalcium =>
      'Include calcium and vitamin D rich foods most days.';

  @override
  String get habitStand =>
      'Stand up and move for 2 minutes every hour you sit.';

  @override
  String get noteCholesterol =>
      'Your cholesterol needs attention — favour oats, beans, and olive oil over fried food.';

  @override
  String get noteHdl =>
      'Low HDL responds best to regular aerobic activity, so prioritise the cardio days.';

  @override
  String get noteTriglycerides =>
      'High triglycerides improve quickly when you cut sugary drinks and alcohol.';

  @override
  String get noteGlucose =>
      'Blood sugar needs attention — the post-meal walk matters more than anything else here.';

  @override
  String get noteHemoglobin =>
      'Hemoglobin is outside range — include iron-rich foods and ask your clinician about testing.';

  @override
  String get noteVitaminD =>
      'Vitamin D is low — daylight and a clinician-advised supplement usually fix this.';

  @override
  String get noteThyroid =>
      'Thyroid values need review; keep activity gentle until your clinician advises.';

  @override
  String get noteHPylori =>
      'Your Helicobacter test is positive — follow the treatment your clinician prescribes and keep meals regular and gentle meanwhile.';

  @override
  String get comparisonTitle => 'Compared with your last test';

  @override
  String get trendBetter => 'Better than last time';

  @override
  String get trendWorse => 'Worth a closer look';

  @override
  String get trendSteady => 'Holding steady';

  @override
  String get trendBetterBody =>
      'More of your values sit inside their healthy range than they did before.';

  @override
  String get trendWorseBody =>
      'A few values drifted out of range since your previous test.';

  @override
  String get trendSteadyBody =>
      'Your values landed in much the same place as last time.';

  @override
  String previousTestOn(String date) {
    return 'Previous test $date';
  }

  @override
  String scoreBetterBy(String points) {
    return '+$points pts';
  }

  @override
  String scoreWorseBy(String points) {
    return '$points pts';
  }

  @override
  String get scoreNoChange => 'No change';

  @override
  String inRangeNow(int current, int total) {
    return '$current of $total in range';
  }

  @override
  String wasInRange(int previous, int total) {
    return 'was $previous of $total';
  }

  @override
  String countImproved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count improved',
      one: '$count improved',
    );
    return '$_temp0';
  }

  @override
  String countWorsened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count declined',
      one: '$count declined',
    );
    return '$_temp0';
  }

  @override
  String countSteady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steady',
      one: '$count steady',
    );
    return '$_temp0';
  }

  @override
  String get whatChanged => 'What changed';

  @override
  String get whatChangedSubtitle => 'Values measured in both tests';

  @override
  String get backInRange => 'Back in range';

  @override
  String get leftRange => 'Left range';

  @override
  String showAllChanges(int count) {
    return 'Show all $count values';
  }

  @override
  String get showFewerChanges => 'Show only what moved';

  @override
  String get updatedBadge => 'Updated';

  @override
  String replacedEarlierVersion(String date) {
    return 'Replaced your earlier upload from $date';
  }

  @override
  String markersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count markers',
      one: '$count marker',
    );
    return '$_temp0';
  }

  @override
  String toReviewCount(int count) {
    return '$count to review';
  }

  @override
  String folderTrendImproved(int count) {
    return '$count improving';
  }

  @override
  String get activityTitle => 'Activity calendar';

  @override
  String get activitySubtitle => 'Tap any day to see what you did';

  @override
  String get activityLoading => 'Reading your activity…';

  @override
  String get activityNoneRecorded => 'No movement recorded on this day.';

  @override
  String get activityDistance => 'distance';

  @override
  String get activityMinutes => 'active min';

  @override
  String get activityWalkRun => 'Walking & running';

  @override
  String get activityCycling => 'Cycling';

  @override
  String get activitySessions => 'Workouts';

  @override
  String get activityKindWalking => 'Walk';

  @override
  String get activityKindRunning => 'Run';

  @override
  String get activityKindCycling => 'Cycle';

  @override
  String get activityKindOther => 'Workout';

  @override
  String activityDurationMinutes(int count) {
    return '$count min';
  }

  @override
  String get activityConnectTitle => 'Connect your activity';

  @override
  String get activityConnectBody =>
      'Let LabWise read your steps, walking, running, and cycling so the calendar can show each day. It reads only — nothing is ever written back, and the data stays on your phone.';

  @override
  String get activityConnectButton => 'Connect';

  @override
  String get activityHealthConnectBody =>
      'Android needs the Health Connect app to share your activity. Install or update it, then come back here.';

  @override
  String get activityInstallHealthConnect => 'Get Health Connect';

  @override
  String get activityRestartNeeded =>
      'Activity tracking was just installed. Fully close the app and open it again to finish setting it up — a hot restart is not enough.';

  @override
  String get activityToday => 'Today';

  @override
  String get activityOpenCalendar => 'Calendar';

  @override
  String get activityConnectShort => 'Read-only, stays on your phone';

  @override
  String get targetsTitle => 'Your targets';

  @override
  String get targetsSubtitle =>
      'Where each number comes from, and why it matters';

  @override
  String get targetsTapHint => 'Why these numbers?';

  @override
  String get targetsInputsTitle => 'Worked out from';

  @override
  String targetsInputsBody(String weight, String height, String age) {
    return 'Weight $weight kg · Height $height cm · Age $age';
  }

  @override
  String get targetsInputsNote =>
      'Change any of these in Profile and every target below updates.';

  @override
  String get targetBmiTitle => 'Body mass index';

  @override
  String get targetBmiWhat =>
      'Your weight divided by your height squared. It puts one number on the relationship between the two.';

  @override
  String get targetBmiWhy =>
      'Every other target on this screen is tuned by which band you fall into, so it is the starting point rather than a score in itself.';

  @override
  String get targetBmiBands =>
      'Under 18.5 is under range · 18.5 to 25 is healthy · 25 to 30 is above · 30 and over is well above.';

  @override
  String get targetBmiCaveat =>
      'BMI cannot tell muscle from fat, so athletes often read high while being perfectly healthy. Treat it as a rough guide, not a verdict.';

  @override
  String get targetCaloriesTitle => 'Daily calories';

  @override
  String get targetCaloriesWhat =>
      'An estimate of what your body burns in a lightly active day, adjusted toward your goal.';

  @override
  String get targetCaloriesWhy =>
      'Eating roughly this much keeps weight steady. The adjustment is deliberately small so progress is gradual rather than punishing.';

  @override
  String get targetCaloriesHow =>
      'Calculated with the Mifflin-St Jeor equation from your weight, height, and age, multiplied by 1.45 for daily movement. Because the app does not ask your sex, the result is averaged between the male and female formulas, which can be off by roughly 80 kcal either way.';

  @override
  String get targetCaloriesAdjustUnder =>
      '300 kcal was added to help you gain steadily.';

  @override
  String get targetCaloriesAdjustHealthy =>
      'No adjustment — this is your maintenance level.';

  @override
  String get targetCaloriesAdjustAbove =>
      '350 kcal was removed for gradual loss.';

  @override
  String get targetCaloriesAdjustWellAbove =>
      '500 kcal was removed for steady, sustainable loss.';

  @override
  String get targetWaterTitle => 'Water';

  @override
  String get targetWaterWhat =>
      'Roughly 33 ml for every kilogram you weigh, which is why a heavier body gets a larger figure.';

  @override
  String get targetWaterWhy =>
      'Being even mildly short on fluid shows up as tiredness and headaches long before you feel thirsty, and it skews several blood markers.';

  @override
  String get targetWaterCaveat =>
      'Drink more in heat, during exercise, or when unwell. Food contributes too, so this is not all from a glass.';

  @override
  String get targetStepsTitle => 'Steps';

  @override
  String get targetStepsWhat =>
      'A daily movement target, starting from 8,000 and shifted for your situation.';

  @override
  String get targetStepsWhy =>
      'Regular walking does more for blood pressure, blood sugar, and mood than almost any other single habit, and it needs no equipment.';

  @override
  String get targetStepsHow =>
      'Raised for an above-range BMI, lowered again when well above so joints are not overloaded at the start, reduced past 60, and raised for under-30s.';

  @override
  String get targetsClinicianTitle => 'This is not medical advice';

  @override
  String get targetsClinicianBody =>
      'These are general wellbeing estimates calculated on your phone from three numbers you typed in. They know nothing about your medical history, medication, pregnancy, or conditions. Talk to a clinician before acting on them.';

  @override
  String get statusGood => 'Looking good';

  @override
  String get statusWatch => 'Worth an eye';

  @override
  String get statusAttention => 'Needs attention';

  @override
  String get statusUnknownBody =>
      'Add your details or upload a report to see where you stand.';

  @override
  String statusFlagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values to review',
      one: '$count value to review',
    );
    return '$_temp0';
  }

  @override
  String statusAllClear(int count) {
    return 'All $count values in range';
  }

  @override
  String get statusNoReport => 'No report yet';

  @override
  String statusBmi(String bmi) {
    return 'BMI $bmi';
  }

  @override
  String statusAddDetails(String fields) {
    return 'Add your $fields';
  }

  @override
  String get statusTitle => 'Your health right now';

  @override
  String get tabMeds => 'Meds';

  @override
  String get medsTitle => 'Medicine';

  @override
  String medsSubtitlePending(int taken, int total) {
    return '$taken of $total taken today';
  }

  @override
  String get medsSubtitleAllDone => 'All done for today';

  @override
  String get medsSubtitleNoneToday => 'Nothing scheduled today';

  @override
  String get medsEmptyTitle => 'No medicines yet';

  @override
  String get medsEmptyBody =>
      'Add a tablet, vitamin, or supplement and the app will remind you when a dose is due.';

  @override
  String get medsAdd => 'Add medicine';

  @override
  String get medsEdit => 'Edit medicine';

  @override
  String get medsFieldName => 'Name';

  @override
  String get medsFieldNameHint => 'Vitamin D, Omeprazole…';

  @override
  String get medsFieldCount => 'How many per dose';

  @override
  String get medsFieldNotes => 'Notes (optional)';

  @override
  String get medsFieldFrequency => 'How often';

  @override
  String get medsFieldTimes => 'Reminder times';

  @override
  String get medsAddTime => 'Add a time';

  @override
  String get medsFieldStart => 'Starts';

  @override
  String get medsFieldEnd => 'Ends (optional)';

  @override
  String get medsNoEnd => 'No end date';

  @override
  String get medsFrequencyDaily => 'Every day';

  @override
  String get medsFrequencyEveryOther => 'Every other day';

  @override
  String get medsFrequencyWeekly => 'Weekly';

  @override
  String get medsFrequencyAsNeeded => 'Only when needed';

  @override
  String get medsSave => 'Save';

  @override
  String get medsDelete => 'Delete';

  @override
  String get medsDeleteTitle => 'Delete this medicine?';

  @override
  String medsDeleteBody(String name) {
    return '$name and its reminders will be removed.';
  }

  @override
  String get medsStateOverdue => 'Missed';

  @override
  String get medsStateUpcoming => 'Upcoming';

  @override
  String get medsStateDone => 'Taken';

  @override
  String get medsStateInactive => 'Not today';

  @override
  String medsDoseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tablets',
      one: '$count tablet',
    );
    return '$_temp0';
  }

  @override
  String medsTakenOf(int taken, int total) {
    return '$taken/$total';
  }

  @override
  String medsNextDose(String time) {
    return 'Next at $time';
  }

  @override
  String medsNextOn(String date) {
    return 'Next on $date';
  }

  @override
  String get medsAsNeededHint => 'Taken only when needed — no reminders';

  @override
  String get medsMarkTaken => 'Mark as taken';

  @override
  String get medsUndo => 'Undo';

  @override
  String get medsNeedsName => 'Give the medicine a name.';

  @override
  String get medsNeedsTime => 'Add at least one reminder time.';

  @override
  String get medsNotificationsOffTitle => 'Reminders are off';

  @override
  String get medsNotificationsOffBody =>
      'Allow notifications so the app can remind you when a dose is due.';

  @override
  String get medsEnableNotifications => 'Allow notifications';

  @override
  String get medsStateDueNow => 'Due now';

  @override
  String get doseTimeTitle => 'Reminder time';

  @override
  String get doseTimeQuick => 'Common times';

  @override
  String get doseTimeMorning => 'Morning';

  @override
  String get doseTimeMidday => 'Midday';

  @override
  String get doseTimeEvening => 'Evening';

  @override
  String get doseTimeNight => 'Night';

  @override
  String get doseTimeSet => 'Set time';

  @override
  String get doseTimeAlready => 'That time is already added.';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';
}
