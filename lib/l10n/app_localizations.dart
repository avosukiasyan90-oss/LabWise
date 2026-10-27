import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LabWise Health'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @tabAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get tabAnalyze;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get tabPlan;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Sign in once to keep your lab history synced across devices. You stay signed in until you sign out.'**
  String get authTagline;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// No description provided for @authExplainer.
  ///
  /// In en, this message translates to:
  /// **'Signing in creates your account automatically if you are new, or logs you back in if you already use LabWise Health.'**
  String get authExplainer;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @authPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your reports stay private to your account.'**
  String get authPrivacyNote;

  /// No description provided for @signInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was canceled.'**
  String get signInCanceled;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with {provider}. {detail}'**
  String signInFailed(String provider, String detail);

  /// No description provided for @firebaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Firebase is not configured yet on this machine.'**
  String get firebaseNotConfigured;

  /// No description provided for @firebaseSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Create the LabWise Health Firebase project and enable Google Sign-In, then run:'**
  String get firebaseSetupIntro;

  /// No description provided for @firebaseSetupFooter.
  ///
  /// In en, this message translates to:
  /// **'This links Auth, Firestore, and Storage so history syncs across devices.'**
  String get firebaseSetupFooter;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in anytime. Cloud history stays saved to your account.'**
  String get signOutBody;

  /// No description provided for @cloudSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sync cloud history. Showing local copy.'**
  String get cloudSyncFailed;

  /// No description provided for @analyzeIntro.
  ///
  /// In en, this message translates to:
  /// **'We read the full report, extract every test point, and explain each one with clear information, description, and suggestions.'**
  String get analyzeIntro;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @stepUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get stepUploadTitle;

  /// No description provided for @stepUploadBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or Word report from your device.'**
  String get stepUploadBody;

  /// No description provided for @stepUnderstandTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand'**
  String get stepUnderstandTitle;

  /// No description provided for @stepUnderstandBody.
  ///
  /// In en, this message translates to:
  /// **'Every test point gets information, description, and a suggestion.'**
  String get stepUnderstandBody;

  /// No description provided for @stepActTitle.
  ///
  /// In en, this message translates to:
  /// **'Act'**
  String get stepActTitle;

  /// No description provided for @stepActBody.
  ///
  /// In en, this message translates to:
  /// **'Review needs-attention items first, then confirm with your clinician.'**
  String get stepActBody;

  /// No description provided for @filesStayOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Your files stay on this device. History is saved locally.'**
  String get filesStayOnDevice;

  /// No description provided for @uploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a lab report'**
  String get uploadTitle;

  /// No description provided for @uploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PDF or Word (.docx). We read the full document and explain each result.'**
  String get uploadSubtitle;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @readingReport.
  ///
  /// In en, this message translates to:
  /// **'Reading your report…'**
  String get readingReport;

  /// No description provided for @readingReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extracting markers and preparing guidance'**
  String get readingReportSubtitle;

  /// No description provided for @alreadyUploadedTitle.
  ///
  /// In en, this message translates to:
  /// **'Already uploaded'**
  String get alreadyUploadedTitle;

  /// No description provided for @alreadyUploadedBody.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is already in your history. Open History to view it instead of uploading a duplicate.'**
  String alreadyUploadedBody(String fileName);

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @errorReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file. Please try again.'**
  String get errorReadFile;

  /// No description provided for @errorScannedPdf.
  ///
  /// In en, this message translates to:
  /// **'This PDF looks scanned. Try a text-based PDF or Word export.'**
  String get errorScannedPdf;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while reading the file. Please try another PDF or DOCX.'**
  String get errorGeneric;

  /// No description provided for @errorUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type.'**
  String get errorUnsupportedType;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySummary.
  ///
  /// In en, this message translates to:
  /// **'{reports, plural, =1{1 report} other{{reports} reports}} in {folders, plural, =1{1 folder} other{{folders} folders}}.'**
  String historySummary(int reports, int folders);

  /// No description provided for @reportCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 report} other{{count} reports}}'**
  String reportCount(int count);

  /// No description provided for @needAttentionSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} need attention'**
  String needAttentionSuffix(int count);

  /// No description provided for @noReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsTitle;

  /// No description provided for @noReportsBody.
  ///
  /// In en, this message translates to:
  /// **'Upload a lab PDF or Word file from the Analyze tab. Reports get sorted into folders by test type automatically.'**
  String get noReportsBody;

  /// No description provided for @deleteReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete report?'**
  String get deleteReportTitle;

  /// No description provided for @deleteReportBody.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{fileName}\" from history?'**
  String deleteReportBody(String fileName);

  /// No description provided for @categoryBloodCount.
  ///
  /// In en, this message translates to:
  /// **'Blood Count'**
  String get categoryBloodCount;

  /// No description provided for @categoryBloodCountDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete blood counts — cells, hemoglobin, platelets'**
  String get categoryBloodCountDesc;

  /// No description provided for @categoryBiochemistry.
  ///
  /// In en, this message translates to:
  /// **'Blood Chemistry'**
  String get categoryBiochemistry;

  /// No description provided for @categoryBiochemistryDesc.
  ///
  /// In en, this message translates to:
  /// **'Glucose, cholesterol, liver and kidney markers'**
  String get categoryBiochemistryDesc;

  /// No description provided for @categoryHormones.
  ///
  /// In en, this message translates to:
  /// **'Hormones'**
  String get categoryHormones;

  /// No description provided for @categoryHormonesDesc.
  ///
  /// In en, this message translates to:
  /// **'Thyroid and other hormone panels'**
  String get categoryHormonesDesc;

  /// No description provided for @categoryUrinalysis.
  ///
  /// In en, this message translates to:
  /// **'Urine Tests'**
  String get categoryUrinalysis;

  /// No description provided for @categoryUrinalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Urine strip and microscopy results'**
  String get categoryUrinalysisDesc;

  /// No description provided for @categoryUrogenital.
  ///
  /// In en, this message translates to:
  /// **'Urogenital'**
  String get categoryUrogenital;

  /// No description provided for @categoryUrogenitalDesc.
  ///
  /// In en, this message translates to:
  /// **'Smear microscopy and PCR panels'**
  String get categoryUrogenitalDesc;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other Reports'**
  String get categoryOther;

  /// No description provided for @categoryOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Reports we could not categorize yet'**
  String get categoryOtherDesc;

  /// No description provided for @categoryInfection.
  ///
  /// In en, this message translates to:
  /// **'Infection Tests'**
  String get categoryInfection;

  /// No description provided for @categoryInfectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Helicobacter and other infection screens'**
  String get categoryInfectionDesc;

  /// No description provided for @yourResults.
  ///
  /// In en, this message translates to:
  /// **'Your results'**
  String get yourResults;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @needsAttentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Values outside typical ranges, with clear next-step guidance.'**
  String get needsAttentionSubtitle;

  /// No description provided for @allFindings.
  ///
  /// In en, this message translates to:
  /// **'All findings'**
  String get allFindings;

  /// No description provided for @otherFindings.
  ///
  /// In en, this message translates to:
  /// **'Other findings'**
  String get otherFindings;

  /// No description provided for @everyPointRead.
  ///
  /// In en, this message translates to:
  /// **'Every test point read from your document.'**
  String get everyPointRead;

  /// No description provided for @noStructuredPoints.
  ///
  /// In en, this message translates to:
  /// **'No structured test points were extracted. Your file is saved in History so you can open it again later.'**
  String get noStructuredPoints;

  /// No description provided for @resultsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Educational guidance only — not medical advice. Always confirm decisions with a licensed clinician.'**
  String get resultsDisclaimer;

  /// No description provided for @pointsRead.
  ///
  /// In en, this message translates to:
  /// **'Points read'**
  String get pointsRead;

  /// No description provided for @needAttentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Need attention'**
  String get needAttentionLabel;

  /// No description provided for @documentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document details'**
  String get documentDetails;

  /// No description provided for @fieldExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get fieldExam;

  /// No description provided for @fieldClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get fieldClinic;

  /// No description provided for @fieldPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get fieldPatient;

  /// No description provided for @fieldReportNumber.
  ///
  /// In en, this message translates to:
  /// **'Report #'**
  String get fieldReportNumber;

  /// No description provided for @fieldSampleDate.
  ///
  /// In en, this message translates to:
  /// **'Sample date'**
  String get fieldSampleDate;

  /// No description provided for @fieldDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get fieldDoctor;

  /// No description provided for @fieldMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get fieldMethod;

  /// No description provided for @fieldAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get fieldAddress;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldLabLicence.
  ///
  /// In en, this message translates to:
  /// **'Lab licence'**
  String get fieldLabLicence;

  /// No description provided for @healthNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get healthNeedsReview;

  /// No description provided for @healthLookingGood.
  ///
  /// In en, this message translates to:
  /// **'Looking good'**
  String get healthLookingGood;

  /// No description provided for @healthSomeAttention.
  ///
  /// In en, this message translates to:
  /// **'Some attention needed'**
  String get healthSomeAttention;

  /// No description provided for @healthFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow up recommended'**
  String get healthFollowUp;

  /// No description provided for @markerInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get markerInformation;

  /// No description provided for @markerDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get markerDescription;

  /// No description provided for @markerSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get markerSuggestion;

  /// No description provided for @markerCode.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String markerCode(String code);

  /// No description provided for @markerRef.
  ///
  /// In en, this message translates to:
  /// **'Ref: {range}'**
  String markerRef(String range);

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// No description provided for @statusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get statusHigh;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get statusUnknown;

  /// No description provided for @attachedFile.
  ///
  /// In en, this message translates to:
  /// **'Attached file'**
  String get attachedFile;

  /// No description provided for @attachedFileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'File unavailable for download'**
  String get attachedFileUnavailable;

  /// No description provided for @attachedFileOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get attachedFileOnDevice;

  /// No description provided for @attachedFileSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced from your account'**
  String get attachedFileSynced;

  /// No description provided for @downloadFile.
  ///
  /// In en, this message translates to:
  /// **'Download file'**
  String get downloadFile;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparing;

  /// No description provided for @attachedFileMissing.
  ///
  /// In en, this message translates to:
  /// **'Attached file is not available.'**
  String get attachedFileMissing;

  /// No description provided for @attachedFileExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export the file. Please try again.'**
  String get attachedFileExportFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Google details stay as they are. Health details are optional and only used to give better context.'**
  String get profileSubtitle;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google account'**
  String get googleAccount;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldSurname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get fieldSurname;

  /// No description provided for @managedByGoogle.
  ///
  /// In en, this message translates to:
  /// **'Managed by your account'**
  String get managedByGoogle;

  /// No description provided for @healthDetails.
  ///
  /// In en, this message translates to:
  /// **'Health details'**
  String get healthDetails;

  /// No description provided for @updateAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can update these anytime.'**
  String get updateAnytime;

  /// No description provided for @fieldWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get fieldWeight;

  /// No description provided for @fieldHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get fieldHeight;

  /// No description provided for @fieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fieldAge;

  /// No description provided for @fieldCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get fieldCountry;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitYearsOld.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get unitYearsOld;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @noCountryMatch.
  ///
  /// In en, this message translates to:
  /// **'No country matches \"{query}\".'**
  String noCountryMatch(String query);

  /// No description provided for @bmiNote.
  ///
  /// In en, this message translates to:
  /// **'BMI {bmi} — educational estimate only.'**
  String bmiNote(String bmi);

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile. Try again.'**
  String get profileSaveFailed;

  /// No description provided for @validationWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight between 2 and 400 kg.'**
  String get validationWeight;

  /// No description provided for @validationHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a height between 40 and 260 cm.'**
  String get validationHeight;

  /// No description provided for @validationAge.
  ///
  /// In en, this message translates to:
  /// **'Enter an age between 1 and 120 years.'**
  String get validationAge;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Changes apply across the whole app.'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @setupWelcomeNamed.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String setupWelcomeNamed(String name);

  /// No description provided for @setupWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LabWise'**
  String get setupWelcome;

  /// No description provided for @setupBody.
  ///
  /// In en, this message translates to:
  /// **'Add a few health details so results have better context. You can skip this and fill it in later from Profile.'**
  String get setupBody;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @setupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. You can add this later.'**
  String get setupSaveFailed;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Plan'**
  String get planTitle;

  /// No description provided for @planHeadlineUnder.
  ///
  /// In en, this message translates to:
  /// **'{who}, here\'s a plan to build weight steadily and keep energy up.'**
  String planHeadlineUnder(String who);

  /// No description provided for @planHeadlineHealthy.
  ///
  /// In en, this message translates to:
  /// **'{who}, here\'s a plan to hold your healthy range and stay strong.'**
  String planHeadlineHealthy(String who);

  /// No description provided for @planHeadlineAbove.
  ///
  /// In en, this message translates to:
  /// **'{who}, here\'s a plan to trim gradually without feeling hungry.'**
  String planHeadlineAbove(String who);

  /// No description provided for @planHeadlineWellAbove.
  ///
  /// In en, this message translates to:
  /// **'{who}, here\'s a gentle, joint-friendly plan to start losing weight.'**
  String planHeadlineWellAbove(String who);

  /// No description provided for @planHeadlineFallback.
  ///
  /// In en, this message translates to:
  /// **'Add your height and weight to unlock a plan built for you.'**
  String get planHeadlineFallback;

  /// No description provided for @planWhoFallback.
  ///
  /// In en, this message translates to:
  /// **'Here'**
  String get planWhoFallback;

  /// No description provided for @bmiUnder.
  ///
  /// In en, this message translates to:
  /// **'Under range'**
  String get bmiUnder;

  /// No description provided for @bmiHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy range'**
  String get bmiHealthy;

  /// No description provided for @bmiAbove.
  ///
  /// In en, this message translates to:
  /// **'Above range'**
  String get bmiAbove;

  /// No description provided for @bmiWellAbove.
  ///
  /// In en, this message translates to:
  /// **'Well above range'**
  String get bmiWellAbove;

  /// No description provided for @bmiProfileNeeded.
  ///
  /// In en, this message translates to:
  /// **'Profile needed'**
  String get bmiProfileNeeded;

  /// No description provided for @targetsTuned.
  ///
  /// In en, this message translates to:
  /// **'Targets below are tuned to this range.'**
  String get targetsTuned;

  /// No description provided for @metricKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal / day'**
  String get metricKcal;

  /// No description provided for @metricWater.
  ///
  /// In en, this message translates to:
  /// **'water'**
  String get metricWater;

  /// No description provided for @metricSteps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get metricSteps;

  /// No description provided for @eatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Eating window'**
  String get eatingWindow;

  /// No description provided for @eatingWindowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep food inside {window}'**
  String eatingWindowSubtitle(String window);

  /// No description provided for @eatingWindowFallback.
  ///
  /// In en, this message translates to:
  /// **'When to eat across the day'**
  String get eatingWindowFallback;

  /// No description provided for @movement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get movement;

  /// No description provided for @movementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sports picked for your body and age'**
  String get movementSubtitle;

  /// No description provided for @dailyHabits.
  ///
  /// In en, this message translates to:
  /// **'Daily habits'**
  String get dailyHabits;

  /// No description provided for @dailyHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small things that compound'**
  String get dailyHabitsSubtitle;

  /// No description provided for @fromYourReports.
  ///
  /// In en, this message translates to:
  /// **'From your reports'**
  String get fromYourReports;

  /// No description provided for @fromYourReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjusted for values that need attention'**
  String get fromYourReportsSubtitle;

  /// No description provided for @planDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'General wellbeing guidance based on the details you entered — not medical advice. Check with a clinician before changing diet, exercise, or medication.'**
  String get planDisclaimer;

  /// No description provided for @planSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little more'**
  String get planSetupTitle;

  /// No description provided for @planSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Add your {fields} in Profile and this tab will build meal timings, sport suggestions, and daily targets around you.'**
  String planSetupBody(String fields);

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open Profile'**
  String get openProfile;

  /// No description provided for @planMissingHint.
  ///
  /// In en, this message translates to:
  /// **'Add your {fields} for a sharper plan.'**
  String planMissingHint(String fields);

  /// No description provided for @fieldWeightLower.
  ///
  /// In en, this message translates to:
  /// **'weight'**
  String get fieldWeightLower;

  /// No description provided for @fieldHeightLower.
  ///
  /// In en, this message translates to:
  /// **'height'**
  String get fieldHeightLower;

  /// No description provided for @fieldAgeLower.
  ///
  /// In en, this message translates to:
  /// **'age'**
  String get fieldAgeLower;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealBreakfastIdea.
  ///
  /// In en, this message translates to:
  /// **'Protein plus slow carbs — eggs or yogurt with oats and fruit.'**
  String get mealBreakfastIdea;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealLunchIdea.
  ///
  /// In en, this message translates to:
  /// **'Half the plate vegetables, a palm of protein, a fist of grains.'**
  String get mealLunchIdea;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @mealSnackIdea.
  ///
  /// In en, this message translates to:
  /// **'Nuts, cheese, or a smoothie to add calories without bloating.'**
  String get mealSnackIdea;

  /// No description provided for @mealLightSnack.
  ///
  /// In en, this message translates to:
  /// **'Light snack'**
  String get mealLightSnack;

  /// No description provided for @mealLightSnackIdea.
  ///
  /// In en, this message translates to:
  /// **'Fruit with a handful of nuts if you feel a dip.'**
  String get mealLightSnackIdea;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealDinnerIdeaLight.
  ///
  /// In en, this message translates to:
  /// **'Lighter and earlier — vegetables, lean protein, minimal oil.'**
  String get mealDinnerIdeaLight;

  /// No description provided for @mealDinnerIdeaBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced plate, finish about 2 hours before bed.'**
  String get mealDinnerIdeaBalanced;

  /// No description provided for @mealKitchenClosed.
  ///
  /// In en, this message translates to:
  /// **'Kitchen closed'**
  String get mealKitchenClosed;

  /// No description provided for @mealKitchenClosedIdea.
  ///
  /// In en, this message translates to:
  /// **'Water or herbal tea only after this — it protects your sleep.'**
  String get mealKitchenClosedIdea;

  /// No description provided for @activityWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get activityWalking;

  /// No description provided for @activityWalkingSchedule.
  ///
  /// In en, this message translates to:
  /// **'30–40 min, most days'**
  String get activityWalkingSchedule;

  /// No description provided for @activityWalkingWhy.
  ///
  /// In en, this message translates to:
  /// **'Easiest way to burn fat without stressing knees and hips.'**
  String get activityWalkingWhy;

  /// No description provided for @activitySwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming or water aerobics'**
  String get activitySwimming;

  /// No description provided for @activitySwimmingSchedule.
  ///
  /// In en, this message translates to:
  /// **'2× per week'**
  String get activitySwimmingSchedule;

  /// No description provided for @activitySwimmingWhy.
  ///
  /// In en, this message translates to:
  /// **'Water carries your weight, so joints stay comfortable.'**
  String get activitySwimmingWhy;

  /// No description provided for @activityLightStrength.
  ///
  /// In en, this message translates to:
  /// **'Light strength circuit'**
  String get activityLightStrength;

  /// No description provided for @activityLightStrengthSchedule.
  ///
  /// In en, this message translates to:
  /// **'2× per week, 20 min'**
  String get activityLightStrengthSchedule;

  /// No description provided for @activityLightStrengthWhy.
  ///
  /// In en, this message translates to:
  /// **'Keeps muscle while you lose fat, which protects metabolism.'**
  String get activityLightStrengthWhy;

  /// No description provided for @activityBriskWalk.
  ///
  /// In en, this message translates to:
  /// **'Brisk walking or cycling'**
  String get activityBriskWalk;

  /// No description provided for @activityBriskWalkSchedule.
  ///
  /// In en, this message translates to:
  /// **'35 min, 5× per week'**
  String get activityBriskWalkSchedule;

  /// No description provided for @activityBriskWalkWhy.
  ///
  /// In en, this message translates to:
  /// **'Steady cardio is the most reliable driver of fat loss.'**
  String get activityBriskWalkWhy;

  /// No description provided for @activityStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength training'**
  String get activityStrength;

  /// No description provided for @activityStrengthSchedule2.
  ///
  /// In en, this message translates to:
  /// **'2× per week'**
  String get activityStrengthSchedule2;

  /// No description provided for @activityStrengthSchedule3.
  ///
  /// In en, this message translates to:
  /// **'3× per week'**
  String get activityStrengthSchedule3;

  /// No description provided for @activityStrengthWhyMuscle.
  ///
  /// In en, this message translates to:
  /// **'Builds muscle so you burn more at rest.'**
  String get activityStrengthWhyMuscle;

  /// No description provided for @activityStrengthWhyBone.
  ///
  /// In en, this message translates to:
  /// **'Protects bone density and muscle as you age.'**
  String get activityStrengthWhyBone;

  /// No description provided for @activityStrengthWhyGain.
  ///
  /// In en, this message translates to:
  /// **'Turns the extra calories you eat into muscle, not just fat.'**
  String get activityStrengthWhyGain;

  /// No description provided for @activityPostMeal.
  ///
  /// In en, this message translates to:
  /// **'Post-meal walk'**
  String get activityPostMeal;

  /// No description provided for @activityPostMealSchedule.
  ///
  /// In en, this message translates to:
  /// **'10–15 min after dinner'**
  String get activityPostMealSchedule;

  /// No description provided for @activityPostMealWhy.
  ///
  /// In en, this message translates to:
  /// **'Blunts the blood-sugar spike from your largest meal.'**
  String get activityPostMealWhy;

  /// No description provided for @activityEasyWalk.
  ///
  /// In en, this message translates to:
  /// **'Easy walking'**
  String get activityEasyWalk;

  /// No description provided for @activityEasyWalkSchedule.
  ///
  /// In en, this message translates to:
  /// **'20–30 min daily'**
  String get activityEasyWalkSchedule;

  /// No description provided for @activityEasyWalkWhy.
  ///
  /// In en, this message translates to:
  /// **'Keeps the heart fit without burning the calories you need.'**
  String get activityEasyWalkWhy;

  /// No description provided for @activityMixedCardio.
  ///
  /// In en, this message translates to:
  /// **'Mixed cardio'**
  String get activityMixedCardio;

  /// No description provided for @activityMixedCardioSchedule.
  ///
  /// In en, this message translates to:
  /// **'150 min per week'**
  String get activityMixedCardioSchedule;

  /// No description provided for @activityMixedCardioWhy.
  ///
  /// In en, this message translates to:
  /// **'Meets the activity level linked with the best heart markers.'**
  String get activityMixedCardioWhy;

  /// No description provided for @activityEnjoy.
  ///
  /// In en, this message translates to:
  /// **'Something you enjoy'**
  String get activityEnjoy;

  /// No description provided for @activityEnjoySchedule.
  ///
  /// In en, this message translates to:
  /// **'1× per week'**
  String get activityEnjoySchedule;

  /// No description provided for @activityEnjoyWhy.
  ///
  /// In en, this message translates to:
  /// **'Football, dancing, hiking — enjoyment is what makes it stick.'**
  String get activityEnjoyWhy;

  /// No description provided for @activityBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance and mobility'**
  String get activityBalance;

  /// No description provided for @activityBalanceSchedule.
  ///
  /// In en, this message translates to:
  /// **'10 min daily'**
  String get activityBalanceSchedule;

  /// No description provided for @activityBalanceWhy.
  ///
  /// In en, this message translates to:
  /// **'Reduces fall risk and keeps joints moving freely.'**
  String get activityBalanceWhy;

  /// No description provided for @habitWater.
  ///
  /// In en, this message translates to:
  /// **'Drink about {litres} L of water across the day.'**
  String habitWater(String litres);

  /// No description provided for @habitSleep.
  ///
  /// In en, this message translates to:
  /// **'Aim for 7–9 hours of sleep at consistent times.'**
  String get habitSleep;

  /// No description provided for @habitSugar.
  ///
  /// In en, this message translates to:
  /// **'Keep sugary drinks for special occasions only.'**
  String get habitSugar;

  /// No description provided for @habitFrequentMeals.
  ///
  /// In en, this message translates to:
  /// **'Eat something every 3–4 hours so you never run empty.'**
  String get habitFrequentMeals;

  /// No description provided for @habitCalcium.
  ///
  /// In en, this message translates to:
  /// **'Include calcium and vitamin D rich foods most days.'**
  String get habitCalcium;

  /// No description provided for @habitStand.
  ///
  /// In en, this message translates to:
  /// **'Stand up and move for 2 minutes every hour you sit.'**
  String get habitStand;

  /// No description provided for @noteCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Your cholesterol needs attention — favour oats, beans, and olive oil over fried food.'**
  String get noteCholesterol;

  /// No description provided for @noteHdl.
  ///
  /// In en, this message translates to:
  /// **'Low HDL responds best to regular aerobic activity, so prioritise the cardio days.'**
  String get noteHdl;

  /// No description provided for @noteTriglycerides.
  ///
  /// In en, this message translates to:
  /// **'High triglycerides improve quickly when you cut sugary drinks and alcohol.'**
  String get noteTriglycerides;

  /// No description provided for @noteGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar needs attention — the post-meal walk matters more than anything else here.'**
  String get noteGlucose;

  /// No description provided for @noteHemoglobin.
  ///
  /// In en, this message translates to:
  /// **'Hemoglobin is outside range — include iron-rich foods and ask your clinician about testing.'**
  String get noteHemoglobin;

  /// No description provided for @noteVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D is low — daylight and a clinician-advised supplement usually fix this.'**
  String get noteVitaminD;

  /// No description provided for @noteThyroid.
  ///
  /// In en, this message translates to:
  /// **'Thyroid values need review; keep activity gentle until your clinician advises.'**
  String get noteThyroid;

  /// No description provided for @noteHPylori.
  ///
  /// In en, this message translates to:
  /// **'Your Helicobacter test is positive — follow the treatment your clinician prescribes and keep meals regular and gentle meanwhile.'**
  String get noteHPylori;

  /// No description provided for @comparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared with your last test'**
  String get comparisonTitle;

  /// No description provided for @trendBetter.
  ///
  /// In en, this message translates to:
  /// **'Better than last time'**
  String get trendBetter;

  /// No description provided for @trendWorse.
  ///
  /// In en, this message translates to:
  /// **'Worth a closer look'**
  String get trendWorse;

  /// No description provided for @trendSteady.
  ///
  /// In en, this message translates to:
  /// **'Holding steady'**
  String get trendSteady;

  /// No description provided for @trendBetterBody.
  ///
  /// In en, this message translates to:
  /// **'More of your values sit inside their healthy range than they did before.'**
  String get trendBetterBody;

  /// No description provided for @trendWorseBody.
  ///
  /// In en, this message translates to:
  /// **'A few values drifted out of range since your previous test.'**
  String get trendWorseBody;

  /// No description provided for @trendSteadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your values landed in much the same place as last time.'**
  String get trendSteadyBody;

  /// No description provided for @previousTestOn.
  ///
  /// In en, this message translates to:
  /// **'Previous test {date}'**
  String previousTestOn(String date);

  /// No description provided for @scoreBetterBy.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts'**
  String scoreBetterBy(String points);

  /// No description provided for @scoreWorseBy.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String scoreWorseBy(String points);

  /// No description provided for @scoreNoChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get scoreNoChange;

  /// No description provided for @inRangeNow.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} in range'**
  String inRangeNow(int current, int total);

  /// No description provided for @wasInRange.
  ///
  /// In en, this message translates to:
  /// **'was {previous} of {total}'**
  String wasInRange(int previous, int total);

  /// No description provided for @countImproved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} improved} other{{count} improved}}'**
  String countImproved(int count);

  /// No description provided for @countWorsened.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} declined} other{{count} declined}}'**
  String countWorsened(int count);

  /// No description provided for @countSteady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} steady} other{{count} steady}}'**
  String countSteady(int count);

  /// No description provided for @whatChanged.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get whatChanged;

  /// No description provided for @whatChangedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Values measured in both tests'**
  String get whatChangedSubtitle;

  /// No description provided for @backInRange.
  ///
  /// In en, this message translates to:
  /// **'Back in range'**
  String get backInRange;

  /// No description provided for @leftRange.
  ///
  /// In en, this message translates to:
  /// **'Left range'**
  String get leftRange;

  /// No description provided for @showAllChanges.
  ///
  /// In en, this message translates to:
  /// **'Show all {count} values'**
  String showAllChanges(int count);

  /// No description provided for @showFewerChanges.
  ///
  /// In en, this message translates to:
  /// **'Show only what moved'**
  String get showFewerChanges;

  /// No description provided for @updatedBadge.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updatedBadge;

  /// No description provided for @replacedEarlierVersion.
  ///
  /// In en, this message translates to:
  /// **'Replaced your earlier upload from {date}'**
  String replacedEarlierVersion(String date);

  /// No description provided for @markersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} marker} other{{count} markers}}'**
  String markersCount(int count);

  /// No description provided for @toReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} to review'**
  String toReviewCount(int count);

  /// No description provided for @folderTrendImproved.
  ///
  /// In en, this message translates to:
  /// **'{count} improving'**
  String folderTrendImproved(int count);

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity calendar'**
  String get activityTitle;

  /// No description provided for @activitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any day to see what you did'**
  String get activitySubtitle;

  /// No description provided for @activityLoading.
  ///
  /// In en, this message translates to:
  /// **'Reading your activity…'**
  String get activityLoading;

  /// No description provided for @activityNoneRecorded.
  ///
  /// In en, this message translates to:
  /// **'No movement recorded on this day.'**
  String get activityNoneRecorded;

  /// No description provided for @activityDistance.
  ///
  /// In en, this message translates to:
  /// **'distance'**
  String get activityDistance;

  /// No description provided for @activityMinutes.
  ///
  /// In en, this message translates to:
  /// **'active min'**
  String get activityMinutes;

  /// No description provided for @activityWalkRun.
  ///
  /// In en, this message translates to:
  /// **'Walking & running'**
  String get activityWalkRun;

  /// No description provided for @activityCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get activityCycling;

  /// No description provided for @activitySessions.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get activitySessions;

  /// No description provided for @activityKindWalking.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get activityKindWalking;

  /// No description provided for @activityKindRunning.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get activityKindRunning;

  /// No description provided for @activityKindCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get activityKindCycling;

  /// No description provided for @activityKindOther.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get activityKindOther;

  /// No description provided for @activityDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String activityDurationMinutes(int count);

  /// No description provided for @activityConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your activity'**
  String get activityConnectTitle;

  /// No description provided for @activityConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Let LabWise read your steps, walking, running, and cycling so the calendar can show each day. It reads only — nothing is ever written back, and the data stays on your phone.'**
  String get activityConnectBody;

  /// No description provided for @activityConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get activityConnectButton;

  /// No description provided for @activityHealthConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Android needs the Health Connect app to share your activity. Install or update it, then come back here.'**
  String get activityHealthConnectBody;

  /// No description provided for @activityInstallHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Get Health Connect'**
  String get activityInstallHealthConnect;

  /// No description provided for @activityRestartNeeded.
  ///
  /// In en, this message translates to:
  /// **'Activity tracking was just installed. Fully close the app and open it again to finish setting it up — a hot restart is not enough.'**
  String get activityRestartNeeded;

  /// No description provided for @activityToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get activityToday;

  /// No description provided for @activityOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get activityOpenCalendar;

  /// No description provided for @activityConnectShort.
  ///
  /// In en, this message translates to:
  /// **'Read-only, stays on your phone'**
  String get activityConnectShort;

  /// No description provided for @targetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your targets'**
  String get targetsTitle;

  /// No description provided for @targetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where each number comes from, and why it matters'**
  String get targetsSubtitle;

  /// No description provided for @targetsTapHint.
  ///
  /// In en, this message translates to:
  /// **'Why these numbers?'**
  String get targetsTapHint;

  /// No description provided for @targetsInputsTitle.
  ///
  /// In en, this message translates to:
  /// **'Worked out from'**
  String get targetsInputsTitle;

  /// No description provided for @targetsInputsBody.
  ///
  /// In en, this message translates to:
  /// **'Weight {weight} kg · Height {height} cm · Age {age}'**
  String targetsInputsBody(String weight, String height, String age);

  /// No description provided for @targetsInputsNote.
  ///
  /// In en, this message translates to:
  /// **'Change any of these in Profile and every target below updates.'**
  String get targetsInputsNote;

  /// No description provided for @targetBmiTitle.
  ///
  /// In en, this message translates to:
  /// **'Body mass index'**
  String get targetBmiTitle;

  /// No description provided for @targetBmiWhat.
  ///
  /// In en, this message translates to:
  /// **'Your weight divided by your height squared. It puts one number on the relationship between the two.'**
  String get targetBmiWhat;

  /// No description provided for @targetBmiWhy.
  ///
  /// In en, this message translates to:
  /// **'Every other target on this screen is tuned by which band you fall into, so it is the starting point rather than a score in itself.'**
  String get targetBmiWhy;

  /// No description provided for @targetBmiBands.
  ///
  /// In en, this message translates to:
  /// **'Under 18.5 is under range · 18.5 to 25 is healthy · 25 to 30 is above · 30 and over is well above.'**
  String get targetBmiBands;

  /// No description provided for @targetBmiCaveat.
  ///
  /// In en, this message translates to:
  /// **'BMI cannot tell muscle from fat, so athletes often read high while being perfectly healthy. Treat it as a rough guide, not a verdict.'**
  String get targetBmiCaveat;

  /// No description provided for @targetCaloriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get targetCaloriesTitle;

  /// No description provided for @targetCaloriesWhat.
  ///
  /// In en, this message translates to:
  /// **'An estimate of what your body burns in a lightly active day, adjusted toward your goal.'**
  String get targetCaloriesWhat;

  /// No description provided for @targetCaloriesWhy.
  ///
  /// In en, this message translates to:
  /// **'Eating roughly this much keeps weight steady. The adjustment is deliberately small so progress is gradual rather than punishing.'**
  String get targetCaloriesWhy;

  /// No description provided for @targetCaloriesHow.
  ///
  /// In en, this message translates to:
  /// **'Calculated with the Mifflin-St Jeor equation from your weight, height, and age, multiplied by 1.45 for daily movement. Because the app does not ask your sex, the result is averaged between the male and female formulas, which can be off by roughly 80 kcal either way.'**
  String get targetCaloriesHow;

  /// No description provided for @targetCaloriesAdjustUnder.
  ///
  /// In en, this message translates to:
  /// **'300 kcal was added to help you gain steadily.'**
  String get targetCaloriesAdjustUnder;

  /// No description provided for @targetCaloriesAdjustHealthy.
  ///
  /// In en, this message translates to:
  /// **'No adjustment — this is your maintenance level.'**
  String get targetCaloriesAdjustHealthy;

  /// No description provided for @targetCaloriesAdjustAbove.
  ///
  /// In en, this message translates to:
  /// **'350 kcal was removed for gradual loss.'**
  String get targetCaloriesAdjustAbove;

  /// No description provided for @targetCaloriesAdjustWellAbove.
  ///
  /// In en, this message translates to:
  /// **'500 kcal was removed for steady, sustainable loss.'**
  String get targetCaloriesAdjustWellAbove;

  /// No description provided for @targetWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get targetWaterTitle;

  /// No description provided for @targetWaterWhat.
  ///
  /// In en, this message translates to:
  /// **'Roughly 33 ml for every kilogram you weigh, which is why a heavier body gets a larger figure.'**
  String get targetWaterWhat;

  /// No description provided for @targetWaterWhy.
  ///
  /// In en, this message translates to:
  /// **'Being even mildly short on fluid shows up as tiredness and headaches long before you feel thirsty, and it skews several blood markers.'**
  String get targetWaterWhy;

  /// No description provided for @targetWaterCaveat.
  ///
  /// In en, this message translates to:
  /// **'Drink more in heat, during exercise, or when unwell. Food contributes too, so this is not all from a glass.'**
  String get targetWaterCaveat;

  /// No description provided for @targetStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get targetStepsTitle;

  /// No description provided for @targetStepsWhat.
  ///
  /// In en, this message translates to:
  /// **'A daily movement target, starting from 8,000 and shifted for your situation.'**
  String get targetStepsWhat;

  /// No description provided for @targetStepsWhy.
  ///
  /// In en, this message translates to:
  /// **'Regular walking does more for blood pressure, blood sugar, and mood than almost any other single habit, and it needs no equipment.'**
  String get targetStepsWhy;

  /// No description provided for @targetStepsHow.
  ///
  /// In en, this message translates to:
  /// **'Raised for an above-range BMI, lowered again when well above so joints are not overloaded at the start, reduced past 60, and raised for under-30s.'**
  String get targetStepsHow;

  /// No description provided for @targetsClinicianTitle.
  ///
  /// In en, this message translates to:
  /// **'This is not medical advice'**
  String get targetsClinicianTitle;

  /// No description provided for @targetsClinicianBody.
  ///
  /// In en, this message translates to:
  /// **'These are general wellbeing estimates calculated on your phone from three numbers you typed in. They know nothing about your medical history, medication, pregnancy, or conditions. Talk to a clinician before acting on them.'**
  String get targetsClinicianBody;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Looking good'**
  String get statusGood;

  /// No description provided for @statusWatch.
  ///
  /// In en, this message translates to:
  /// **'Worth an eye'**
  String get statusWatch;

  /// No description provided for @statusAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get statusAttention;

  /// No description provided for @statusUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Add your details or upload a report to see where you stand.'**
  String get statusUnknownBody;

  /// No description provided for @statusFlagged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} value to review} other{{count} values to review}}'**
  String statusFlagged(int count);

  /// No description provided for @statusAllClear.
  ///
  /// In en, this message translates to:
  /// **'All {count} values in range'**
  String statusAllClear(int count);

  /// No description provided for @statusNoReport.
  ///
  /// In en, this message translates to:
  /// **'No report yet'**
  String get statusNoReport;

  /// No description provided for @statusBmi.
  ///
  /// In en, this message translates to:
  /// **'BMI {bmi}'**
  String statusBmi(String bmi);

  /// No description provided for @statusAddDetails.
  ///
  /// In en, this message translates to:
  /// **'Add your {fields}'**
  String statusAddDetails(String fields);

  /// No description provided for @statusTitle.
  ///
  /// In en, this message translates to:
  /// **'Your health right now'**
  String get statusTitle;

  /// No description provided for @tabMeds.
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get tabMeds;

  /// No description provided for @medsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medsTitle;

  /// No description provided for @medsSubtitlePending.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} taken today'**
  String medsSubtitlePending(int taken, int total);

  /// No description provided for @medsSubtitleAllDone.
  ///
  /// In en, this message translates to:
  /// **'All done for today'**
  String get medsSubtitleAllDone;

  /// No description provided for @medsSubtitleNoneToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today'**
  String get medsSubtitleNoneToday;

  /// No description provided for @medsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet'**
  String get medsEmptyTitle;

  /// No description provided for @medsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a tablet, vitamin, or supplement and the app will remind you when a dose is due.'**
  String get medsEmptyBody;

  /// No description provided for @medsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get medsAdd;

  /// No description provided for @medsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get medsEdit;

  /// No description provided for @medsFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get medsFieldName;

  /// No description provided for @medsFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D, Omeprazole…'**
  String get medsFieldNameHint;

  /// No description provided for @medsFieldCount.
  ///
  /// In en, this message translates to:
  /// **'How many per dose'**
  String get medsFieldCount;

  /// No description provided for @medsFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get medsFieldNotes;

  /// No description provided for @medsFieldFrequency.
  ///
  /// In en, this message translates to:
  /// **'How often'**
  String get medsFieldFrequency;

  /// No description provided for @medsFieldTimes.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get medsFieldTimes;

  /// No description provided for @medsAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add a time'**
  String get medsAddTime;

  /// No description provided for @medsFieldStart.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get medsFieldStart;

  /// No description provided for @medsFieldEnd.
  ///
  /// In en, this message translates to:
  /// **'Ends (optional)'**
  String get medsFieldEnd;

  /// No description provided for @medsNoEnd.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get medsNoEnd;

  /// No description provided for @medsFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get medsFrequencyDaily;

  /// No description provided for @medsFrequencyEveryOther.
  ///
  /// In en, this message translates to:
  /// **'Every other day'**
  String get medsFrequencyEveryOther;

  /// No description provided for @medsFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get medsFrequencyWeekly;

  /// No description provided for @medsFrequencyAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Only when needed'**
  String get medsFrequencyAsNeeded;

  /// No description provided for @medsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get medsSave;

  /// No description provided for @medsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get medsDelete;

  /// No description provided for @medsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this medicine?'**
  String get medsDeleteTitle;

  /// No description provided for @medsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} and its reminders will be removed.'**
  String medsDeleteBody(String name);

  /// No description provided for @medsStateOverdue.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get medsStateOverdue;

  /// No description provided for @medsStateUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get medsStateUpcoming;

  /// No description provided for @medsStateDone.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get medsStateDone;

  /// No description provided for @medsStateInactive.
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get medsStateInactive;

  /// No description provided for @medsDoseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} tablet} other{{count} tablets}}'**
  String medsDoseCount(int count);

  /// No description provided for @medsTakenOf.
  ///
  /// In en, this message translates to:
  /// **'{taken}/{total}'**
  String medsTakenOf(int taken, int total);

  /// No description provided for @medsNextDose.
  ///
  /// In en, this message translates to:
  /// **'Next at {time}'**
  String medsNextDose(String time);

  /// No description provided for @medsNextOn.
  ///
  /// In en, this message translates to:
  /// **'Next on {date}'**
  String medsNextOn(String date);

  /// No description provided for @medsAsNeededHint.
  ///
  /// In en, this message translates to:
  /// **'Taken only when needed — no reminders'**
  String get medsAsNeededHint;

  /// No description provided for @medsMarkTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as taken'**
  String get medsMarkTaken;

  /// No description provided for @medsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get medsUndo;

  /// No description provided for @medsNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Give the medicine a name.'**
  String get medsNeedsName;

  /// No description provided for @medsNeedsTime.
  ///
  /// In en, this message translates to:
  /// **'Add at least one reminder time.'**
  String get medsNeedsTime;

  /// No description provided for @medsNotificationsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get medsNotificationsOffTitle;

  /// No description provided for @medsNotificationsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so the app can remind you when a dose is due.'**
  String get medsNotificationsOffBody;

  /// No description provided for @medsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get medsEnableNotifications;

  /// No description provided for @medsStateDueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get medsStateDueNow;

  /// No description provided for @doseTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get doseTimeTitle;

  /// No description provided for @doseTimeQuick.
  ///
  /// In en, this message translates to:
  /// **'Common times'**
  String get doseTimeQuick;

  /// No description provided for @doseTimeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get doseTimeMorning;

  /// No description provided for @doseTimeMidday.
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get doseTimeMidday;

  /// No description provided for @doseTimeEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get doseTimeEvening;

  /// No description provided for @doseTimeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get doseTimeNight;

  /// No description provided for @doseTimeSet.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get doseTimeSet;

  /// No description provided for @doseTimeAlready.
  ///
  /// In en, this message translates to:
  /// **'That time is already added.'**
  String get doseTimeAlready;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
