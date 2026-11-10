import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ru'), Locale('uk')];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Maritime Career Intelligence'**
  String get appTagline;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Check your network.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond.'**
  String get errorTimeout;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server could not complete the request.'**
  String get errorServer;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String couldNotSave(String error);

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a full link starting with https://'**
  String get invalidUrl;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Not an e-mail address'**
  String get invalidEmail;

  /// No description provided for @twoLetters.
  ///
  /// In en, this message translates to:
  /// **'2 letters'**
  String get twoLetters;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {url}'**
  String sourceLabel(String url);

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'DEMO MODE — no server · sign in with any e-mail · data is kept only in this tab'**
  String get demoBanner;

  /// No description provided for @comingInPhase.
  ///
  /// In en, this message translates to:
  /// **'Coming in Phase {phase}'**
  String comingInPhase(int phase);

  /// No description provided for @notYetAvailable.
  ///
  /// In en, this message translates to:
  /// **'NOT YET AVAILABLE'**
  String get notYetAvailable;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get navCompanies;

  /// No description provided for @navMail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get navMail;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @newCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New to SEA SPACE? Create an account'**
  String get newCreateAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid e-mail'**
  String get enterValidEmail;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMin8;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @confirmEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox to confirm your e-mail, then sign in.'**
  String get confirmEmailSent;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail first.'**
  String get enterEmailFirst;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, a reset link has been sent.'**
  String get resetSent;

  /// No description provided for @authUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the authentication service.'**
  String get authUnavailable;

  /// No description provided for @authNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Authentication is not configured'**
  String get authNotConfigured;

  /// No description provided for @authNotConfiguredBody.
  ///
  /// In en, this message translates to:
  /// **'This build has no Supabase project settings, so sign-in is unavailable. Rebuild the app with:'**
  String get authNotConfiguredBody;

  /// No description provided for @statCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get statCompanies;

  /// No description provided for @statVerifiedContacts.
  ///
  /// In en, this message translates to:
  /// **'Verified HR contacts'**
  String get statVerifiedContacts;

  /// No description provided for @statApplicationsSent.
  ///
  /// In en, this message translates to:
  /// **'Applications sent'**
  String get statApplicationsSent;

  /// No description provided for @statReplies.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get statReplies;

  /// No description provided for @statPendingFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Pending follow-ups'**
  String get statPendingFollowUps;

  /// No description provided for @statInterviews.
  ///
  /// In en, this message translates to:
  /// **'Interviews'**
  String get statInterviews;

  /// No description provided for @statOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get statOffers;

  /// No description provided for @startWithProfile.
  ///
  /// In en, this message translates to:
  /// **'Start with your profile'**
  String get startWithProfile;

  /// No description provided for @startWithProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Your experience and target positions drive company research and outreach.'**
  String get startWithProfileBody;

  /// No description provided for @upcomingFollowUps.
  ///
  /// In en, this message translates to:
  /// **'Upcoming follow-ups'**
  String get upcomingFollowUps;

  /// No description provided for @noFollowUps.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups scheduled.'**
  String get noFollowUps;

  /// No description provided for @newCompanies.
  ///
  /// In en, this message translates to:
  /// **'New companies'**
  String get newCompanies;

  /// No description provided for @noCompaniesShort.
  ///
  /// In en, this message translates to:
  /// **'No companies yet.'**
  String get noCompaniesShort;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your activity will appear here.'**
  String get activityEmpty;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @newProfile.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get newProfile;

  /// No description provided for @createProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your maritime profile'**
  String get createProfileTitle;

  /// No description provided for @createProfileBody.
  ///
  /// In en, this message translates to:
  /// **'Start from the suggested profile (you can change everything before saving), or start from a blank form.'**
  String get createProfileBody;

  /// No description provided for @reviewSuggestedProfile.
  ///
  /// In en, this message translates to:
  /// **'Review suggested profile'**
  String get reviewSuggestedProfile;

  /// No description provided for @startBlank.
  ///
  /// In en, this message translates to:
  /// **'Start blank'**
  String get startBlank;

  /// No description provided for @prefilledNotice.
  ///
  /// In en, this message translates to:
  /// **'Pre-filled from your brief. Check every field — nothing is saved until you tap Save. Certificates and dates are left empty on purpose.'**
  String get prefilledNotice;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get profileName;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Trawl Deckhand\"'**
  String get profileNameHint;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @nameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Name not set'**
  String get nameNotSet;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @englishLevel.
  ///
  /// In en, this message translates to:
  /// **'English level'**
  String get englishLevel;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @yearsAtSea.
  ///
  /// In en, this message translates to:
  /// **'Years at sea'**
  String get yearsAtSea;

  /// No description provided for @yearsRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a number between 0 and 70'**
  String get yearsRange;

  /// No description provided for @approximate.
  ///
  /// In en, this message translates to:
  /// **'Approximate'**
  String get approximate;

  /// No description provided for @seaExperience.
  ///
  /// In en, this message translates to:
  /// **'Sea experience'**
  String get seaExperience;

  /// No description provided for @yearsValue.
  ///
  /// In en, this message translates to:
  /// **'{approx}{years} years'**
  String yearsValue(String approx, String years);

  /// No description provided for @targetPositions.
  ///
  /// In en, this message translates to:
  /// **'Target positions'**
  String get targetPositions;

  /// No description provided for @noTargetPositions.
  ///
  /// In en, this message translates to:
  /// **'No target positions yet.'**
  String get noTargetPositions;

  /// No description provided for @addPosition.
  ///
  /// In en, this message translates to:
  /// **'Add position'**
  String get addPosition;

  /// No description provided for @experienceAreas.
  ///
  /// In en, this message translates to:
  /// **'Experience areas'**
  String get experienceAreas;

  /// No description provided for @noExperienceAreas.
  ///
  /// In en, this message translates to:
  /// **'No experience areas yet.'**
  String get noExperienceAreas;

  /// No description provided for @addArea.
  ///
  /// In en, this message translates to:
  /// **'Add area'**
  String get addArea;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @summaryHint.
  ///
  /// In en, this message translates to:
  /// **'Short professional summary'**
  String get summaryHint;

  /// No description provided for @alsoAddVessel.
  ///
  /// In en, this message translates to:
  /// **'Also add vessel: {vessel}'**
  String alsoAddVessel(String vessel);

  /// No description provided for @withoutDates.
  ///
  /// In en, this message translates to:
  /// **'Without dates — add them later if you have them.'**
  String get withoutDates;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY'**
  String get primary;

  /// No description provided for @seaService.
  ///
  /// In en, this message translates to:
  /// **'Sea service'**
  String get seaService;

  /// No description provided for @noVesselsAdded.
  ///
  /// In en, this message translates to:
  /// **'No vessels added yet.'**
  String get noVesselsAdded;

  /// No description provided for @vesselNotNamed.
  ///
  /// In en, this message translates to:
  /// **'Vessel not named'**
  String get vesselNotNamed;

  /// No description provided for @datesNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Dates not provided'**
  String get datesNotProvided;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'present'**
  String get present;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntry;

  /// No description provided for @experienceEntry.
  ///
  /// In en, this message translates to:
  /// **'Experience entry'**
  String get experienceEntry;

  /// No description provided for @addSeaService.
  ///
  /// In en, this message translates to:
  /// **'Add sea service'**
  String get addSeaService;

  /// No description provided for @editSeaService.
  ///
  /// In en, this message translates to:
  /// **'Edit sea service'**
  String get editSeaService;

  /// No description provided for @vesselName.
  ///
  /// In en, this message translates to:
  /// **'Vessel name'**
  String get vesselName;

  /// No description provided for @vesselType.
  ///
  /// In en, this message translates to:
  /// **'Vessel type'**
  String get vesselType;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @employer.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employer;

  /// No description provided for @duties.
  ///
  /// In en, this message translates to:
  /// **'Duties (comma separated)'**
  String get duties;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @clearDates.
  ///
  /// In en, this message translates to:
  /// **'Clear dates'**
  String get clearDates;

  /// No description provided for @endBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End date is before start date.'**
  String get endBeforeStart;

  /// No description provided for @englishBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get englishBeginner;

  /// No description provided for @englishElementary.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get englishElementary;

  /// No description provided for @englishIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get englishIntermediate;

  /// No description provided for @englishUpperIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Upper-intermediate'**
  String get englishUpperIntermediate;

  /// No description provided for @englishAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get englishAdvanced;

  /// No description provided for @englishFluent.
  ///
  /// In en, this message translates to:
  /// **'Fluent'**
  String get englishFluent;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable'**
  String get serverUnreachable;

  /// No description provided for @apiConnected.
  ///
  /// In en, this message translates to:
  /// **'API connected'**
  String get apiConnected;

  /// No description provided for @configured.
  ///
  /// In en, this message translates to:
  /// **'CONFIGURED'**
  String get configured;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'NOT CONFIGURED'**
  String get notConfigured;

  /// No description provided for @integrationSupabase.
  ///
  /// In en, this message translates to:
  /// **'Supabase authentication'**
  String get integrationSupabase;

  /// No description provided for @integrationEncryption.
  ///
  /// In en, this message translates to:
  /// **'Token encryption key'**
  String get integrationEncryption;

  /// No description provided for @integrationAnthropic.
  ///
  /// In en, this message translates to:
  /// **'Claude API (AI assistant)'**
  String get integrationAnthropic;

  /// No description provided for @integrationGmail.
  ///
  /// In en, this message translates to:
  /// **'Gmail OAuth'**
  String get integrationGmail;

  /// No description provided for @integrationPubsub.
  ///
  /// In en, this message translates to:
  /// **'Gmail push notifications (Pub/Sub)'**
  String get integrationPubsub;

  /// No description provided for @integrationSearch.
  ///
  /// In en, this message translates to:
  /// **'Web search (Brave)'**
  String get integrationSearch;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently removes your SEA SPACE data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'All your profiles, companies, applications and other data in SEA SPACE will be deleted. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @addCompany.
  ///
  /// In en, this message translates to:
  /// **'Add company'**
  String get addCompany;

  /// No description provided for @searchCompanies.
  ///
  /// In en, this message translates to:
  /// **'Search companies'**
  String get searchCompanies;

  /// No description provided for @duplicatesToReview.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} possible duplicate to review} other{{count} possible duplicates to review}}'**
  String duplicatesToReview(int count);

  /// No description provided for @contactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} contact} other{{count} contacts}}'**
  String contactsCount(int count);

  /// No description provided for @openVacanciesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} open vacancy} other{{count} open vacancies}}'**
  String openVacanciesCount(int count);

  /// No description provided for @noCompaniesMatch.
  ///
  /// In en, this message translates to:
  /// **'No companies match this filter'**
  String get noCompaniesMatch;

  /// No description provided for @noCompaniesYet.
  ///
  /// In en, this message translates to:
  /// **'No companies yet'**
  String get noCompaniesYet;

  /// No description provided for @noCompaniesBody.
  ///
  /// In en, this message translates to:
  /// **'Add an employer yourself, or start from the research targets in Discover.'**
  String get noCompaniesBody;

  /// No description provided for @openDiscover.
  ///
  /// In en, this message translates to:
  /// **'Open Discover'**
  String get openDiscover;

  /// No description provided for @newCompany.
  ///
  /// In en, this message translates to:
  /// **'New company'**
  String get newCompany;

  /// No description provided for @editCompany.
  ///
  /// In en, this message translates to:
  /// **'Edit company'**
  String get editCompany;

  /// No description provided for @companyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Company name *'**
  String get companyNameRequired;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryTwoLetters.
  ///
  /// In en, this message translates to:
  /// **'Country (2 letters)'**
  String get countryTwoLetters;

  /// No description provided for @headquarters.
  ///
  /// In en, this message translates to:
  /// **'Headquarters'**
  String get headquarters;

  /// No description provided for @hiringStatus.
  ///
  /// In en, this message translates to:
  /// **'Hiring status'**
  String get hiringStatus;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @recruitment.
  ///
  /// In en, this message translates to:
  /// **'Recruitment'**
  String get recruitment;

  /// No description provided for @officialWebsite.
  ///
  /// In en, this message translates to:
  /// **'Official website'**
  String get officialWebsite;

  /// No description provided for @careersPage.
  ///
  /// In en, this message translates to:
  /// **'Careers page'**
  String get careersPage;

  /// No description provided for @recruitmentEmail.
  ///
  /// In en, this message translates to:
  /// **'Recruitment e-mail'**
  String get recruitmentEmail;

  /// No description provided for @recruitmentEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'Only an address published by the company'**
  String get recruitmentEmailHelper;

  /// No description provided for @speculativePolicy.
  ///
  /// In en, this message translates to:
  /// **'Speculative application policy'**
  String get speculativePolicy;

  /// No description provided for @speculativeShort.
  ///
  /// In en, this message translates to:
  /// **'Speculative'**
  String get speculativeShort;

  /// No description provided for @fleetAndNotes.
  ///
  /// In en, this message translates to:
  /// **'Fleet & notes'**
  String get fleetAndNotes;

  /// No description provided for @fleetSummary.
  ///
  /// In en, this message translates to:
  /// **'Fleet summary'**
  String get fleetSummary;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @duplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'This company may already exist'**
  String get duplicateTitle;

  /// No description provided for @duplicateSameNameCountry.
  ///
  /// In en, this message translates to:
  /// **'A company with the same name and country is already saved.'**
  String get duplicateSameNameCountry;

  /// No description provided for @createAnyway.
  ///
  /// In en, this message translates to:
  /// **'Create anyway'**
  String get createAnyway;

  /// No description provided for @usingSavedCompany.
  ///
  /// In en, this message translates to:
  /// **'Using the saved company \"{name}\"'**
  String usingSavedCompany(String name);

  /// No description provided for @markVerified.
  ///
  /// In en, this message translates to:
  /// **'Mark as verified'**
  String get markVerified;

  /// No description provided for @markVerifiedMenu.
  ///
  /// In en, this message translates to:
  /// **'Mark as verified…'**
  String get markVerifiedMenu;

  /// No description provided for @verifiedPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page where you checked these details'**
  String get verifiedPageLabel;

  /// No description provided for @markedVerified.
  ///
  /// In en, this message translates to:
  /// **'Marked as verified'**
  String get markedVerified;

  /// No description provided for @deleteCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteCompanyTitle(String name);

  /// No description provided for @deleteCompanyBody.
  ///
  /// In en, this message translates to:
  /// **'The company is removed from your list.'**
  String get deleteCompanyBody;

  /// No description provided for @researchWebsite.
  ///
  /// In en, this message translates to:
  /// **'Research website'**
  String get researchWebsite;

  /// No description provided for @researchCompanyWebsite.
  ///
  /// In en, this message translates to:
  /// **'Research company website'**
  String get researchCompanyWebsite;

  /// No description provided for @companyWebsite.
  ///
  /// In en, this message translates to:
  /// **'Company website'**
  String get companyWebsite;

  /// No description provided for @research.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get research;

  /// No description provided for @mergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge {name} into…'**
  String mergeInto(String name);

  /// No description provided for @mergeMenu.
  ///
  /// In en, this message translates to:
  /// **'Merge into another company…'**
  String get mergeMenu;

  /// No description provided for @noOtherCompanies.
  ///
  /// In en, this message translates to:
  /// **'No other companies.'**
  String get noOtherCompanies;

  /// No description provided for @mergeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge into {name}?'**
  String mergeConfirmTitle(String name);

  /// No description provided for @mergeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Contacts, notes, sources, vacancies and vessel links move to {target}. {source} is then hidden.'**
  String mergeConfirmBody(String target, String source);

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @verifiedOn.
  ///
  /// In en, this message translates to:
  /// **'Verified on'**
  String get verifiedOn;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @hrContacts.
  ///
  /// In en, this message translates to:
  /// **'HR contacts'**
  String get hrContacts;

  /// No description provided for @noContactsYet.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet.'**
  String get noContactsYet;

  /// No description provided for @fleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get fleet;

  /// No description provided for @noVesselsLinked.
  ///
  /// In en, this message translates to:
  /// **'No vessels linked. Add them under Tools → Fleet.'**
  String get noVesselsLinked;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @operatorCrewing.
  ///
  /// In en, this message translates to:
  /// **'Operator · crewing employer: {value}'**
  String operatorCrewing(String value);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get no;

  /// No description provided for @unknownLower.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknownLower;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes.'**
  String get noNotes;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get deleteNote;

  /// No description provided for @websitesSources.
  ///
  /// In en, this message translates to:
  /// **'Websites & sources'**
  String get websitesSources;

  /// No description provided for @noSources.
  ///
  /// In en, this message translates to:
  /// **'No sources recorded.'**
  String get noSources;

  /// No description provided for @hiringActive.
  ///
  /// In en, this message translates to:
  /// **'Actively hiring'**
  String get hiringActive;

  /// No description provided for @hiringNone.
  ///
  /// In en, this message translates to:
  /// **'No current vacancies'**
  String get hiringNone;

  /// No description provided for @hiringSpeculative.
  ///
  /// In en, this message translates to:
  /// **'Speculative applications accepted'**
  String get hiringSpeculative;

  /// No description provided for @hiringAgency.
  ///
  /// In en, this message translates to:
  /// **'Recruitment agency'**
  String get hiringAgency;

  /// No description provided for @hiringUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown hiring status'**
  String get hiringUnknown;

  /// No description provided for @industryFishing.
  ///
  /// In en, this message translates to:
  /// **'Fishing'**
  String get industryFishing;

  /// No description provided for @industryTrawling.
  ///
  /// In en, this message translates to:
  /// **'Trawling'**
  String get industryTrawling;

  /// No description provided for @industryKrill.
  ///
  /// In en, this message translates to:
  /// **'Krill'**
  String get industryKrill;

  /// No description provided for @industrySeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood processing'**
  String get industrySeafood;

  /// No description provided for @industryFactory.
  ///
  /// In en, this message translates to:
  /// **'Factory vessels'**
  String get industryFactory;

  /// No description provided for @industryAgency.
  ///
  /// In en, this message translates to:
  /// **'Recruitment agency'**
  String get industryAgency;

  /// No description provided for @industryShipManagement.
  ///
  /// In en, this message translates to:
  /// **'Ship management'**
  String get industryShipManagement;

  /// No description provided for @industryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get industryOther;

  /// No description provided for @verVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verVerified;

  /// No description provided for @verUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get verUnverified;

  /// No description provided for @verInferred.
  ///
  /// In en, this message translates to:
  /// **'Inferred'**
  String get verInferred;

  /// No description provided for @verUserProvided.
  ///
  /// In en, this message translates to:
  /// **'Entered by you'**
  String get verUserProvided;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContact;

  /// No description provided for @genericInbox.
  ///
  /// In en, this message translates to:
  /// **'Generic recruitment inbox'**
  String get genericInbox;

  /// No description provided for @genericInboxHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. jobs@, crew@ — not a named person'**
  String get genericInboxHint;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitle;

  /// No description provided for @emailOrigin.
  ///
  /// In en, this message translates to:
  /// **'Where is this address from?'**
  String get emailOrigin;

  /// No description provided for @emailPublishedVerified.
  ///
  /// In en, this message translates to:
  /// **'Published · verified'**
  String get emailPublishedVerified;

  /// No description provided for @emailPublishedUnverified.
  ///
  /// In en, this message translates to:
  /// **'Published · not yet verified'**
  String get emailPublishedUnverified;

  /// No description provided for @emailGuessed.
  ///
  /// In en, this message translates to:
  /// **'Guessed (not published)'**
  String get emailGuessed;

  /// No description provided for @emailEnteredByYou.
  ///
  /// In en, this message translates to:
  /// **'Entered by you'**
  String get emailEnteredByYou;

  /// No description provided for @sourcePage.
  ///
  /// In en, this message translates to:
  /// **'Source page'**
  String get sourcePage;

  /// No description provided for @guessedWarning.
  ///
  /// In en, this message translates to:
  /// **'Guessed addresses are kept separate and can never be marked verified.'**
  String get guessedWarning;

  /// No description provided for @enterNameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or an e-mail address'**
  String get enterNameOrEmail;

  /// No description provided for @addSourceLink.
  ///
  /// In en, this message translates to:
  /// **'Add the link of the page where the address is published'**
  String get addSourceLink;

  /// No description provided for @guessedEmailBadge.
  ///
  /// In en, this message translates to:
  /// **'GUESSED E-MAIL'**
  String get guessedEmailBadge;

  /// No description provided for @differentDomainBadge.
  ///
  /// In en, this message translates to:
  /// **'DIFFERENT DOMAIN'**
  String get differentDomainBadge;

  /// No description provided for @verifyContact.
  ///
  /// In en, this message translates to:
  /// **'Verify contact'**
  String get verifyContact;

  /// No description provided for @contactPublishedPage.
  ///
  /// In en, this message translates to:
  /// **'Page where this contact is published'**
  String get contactPublishedPage;

  /// No description provided for @deleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete contact?'**
  String get deleteContactTitle;

  /// No description provided for @recruitmentInbox.
  ///
  /// In en, this message translates to:
  /// **'Recruitment inbox'**
  String get recruitmentInbox;

  /// No description provided for @unnamedContact.
  ///
  /// In en, this message translates to:
  /// **'Unnamed contact'**
  String get unnamedContact;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'HR Contacts'**
  String get contactsTitle;

  /// No description provided for @filterVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get filterVerified;

  /// No description provided for @filterUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get filterUnverified;

  /// No description provided for @filterInboxes.
  ///
  /// In en, this message translates to:
  /// **'Recruitment inboxes'**
  String get filterInboxes;

  /// No description provided for @filterPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get filterPeople;

  /// No description provided for @filterGuessed.
  ///
  /// In en, this message translates to:
  /// **'Guessed e-mails'**
  String get filterGuessed;

  /// No description provided for @noContactsHere.
  ///
  /// In en, this message translates to:
  /// **'No contacts here'**
  String get noContactsHere;

  /// No description provided for @noContactsHereBody.
  ///
  /// In en, this message translates to:
  /// **'Contacts are added on a company page, or imported from website research.'**
  String get noContactsHereBody;

  /// No description provided for @findingWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get findingWebsite;

  /// No description provided for @findingEmails.
  ///
  /// In en, this message translates to:
  /// **'E-mail addresses'**
  String get findingEmails;

  /// No description provided for @findingCareers.
  ///
  /// In en, this message translates to:
  /// **'Careers pages'**
  String get findingCareers;

  /// No description provided for @findingContacts.
  ///
  /// In en, this message translates to:
  /// **'Contact pages'**
  String get findingContacts;

  /// No description provided for @findingSpeculative.
  ///
  /// In en, this message translates to:
  /// **'Speculative applications'**
  String get findingSpeculative;

  /// No description provided for @findingPositions.
  ///
  /// In en, this message translates to:
  /// **'Positions mentioned (keywords, not vacancies)'**
  String get findingPositions;

  /// No description provided for @websiteResearch.
  ///
  /// In en, this message translates to:
  /// **'Website research'**
  String get websiteResearch;

  /// No description provided for @readingWebsite.
  ///
  /// In en, this message translates to:
  /// **'Reading the website…'**
  String get readingWebsite;

  /// No description provided for @readingWebsiteBody.
  ///
  /// In en, this message translates to:
  /// **'Only public pages allowed by robots.txt are read, one request at a time.'**
  String get readingWebsiteBody;

  /// No description provided for @researchFailed.
  ///
  /// In en, this message translates to:
  /// **'Research failed'**
  String get researchFailed;

  /// No description provided for @pagesReadNotice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Read {count} page.} other{Read {count} pages.}} Import only what you have checked; imported data stays \"unverified\" until you verify it.'**
  String pagesReadNotice(int count);

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing relevant was found on these pages.'**
  String get nothingFound;

  /// No description provided for @skippedPages.
  ///
  /// In en, this message translates to:
  /// **'Skipped pages'**
  String get skippedPages;

  /// No description provided for @limitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get limitations;

  /// No description provided for @hintRecruitmentInbox.
  ///
  /// In en, this message translates to:
  /// **'Recruitment inbox'**
  String get hintRecruitmentInbox;

  /// No description provided for @hintGenericInbox.
  ///
  /// In en, this message translates to:
  /// **'Generic inbox'**
  String get hintGenericInbox;

  /// No description provided for @hintDifferentDomain.
  ///
  /// In en, this message translates to:
  /// **'Different domain from the website'**
  String get hintDifferentDomain;

  /// No description provided for @hintExternalPortal.
  ///
  /// In en, this message translates to:
  /// **'External job portal'**
  String get hintExternalPortal;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @tabEmployers.
  ///
  /// In en, this message translates to:
  /// **'Employers'**
  String get tabEmployers;

  /// No description provided for @tabVacancies.
  ///
  /// In en, this message translates to:
  /// **'Vacancies'**
  String get tabVacancies;

  /// No description provided for @researchEmployerTitle.
  ///
  /// In en, this message translates to:
  /// **'Research an employer website'**
  String get researchEmployerTitle;

  /// No description provided for @researchEmployerBody.
  ///
  /// In en, this message translates to:
  /// **'Reads the company\'s own public pages for recruitment e-mails, careers pages and open-application policies. Works even when no vacancy is advertised.'**
  String get researchEmployerBody;

  /// No description provided for @researchAWebsite.
  ///
  /// In en, this message translates to:
  /// **'Research a website'**
  String get researchAWebsite;

  /// No description provided for @researchTargets.
  ///
  /// In en, this message translates to:
  /// **'Research targets from your brief'**
  String get researchTargets;

  /// No description provided for @addAll.
  ///
  /// In en, this message translates to:
  /// **'Add all'**
  String get addAll;

  /// No description provided for @notInCompanies.
  ///
  /// In en, this message translates to:
  /// **'Not in your companies yet'**
  String get notInCompanies;

  /// No description provided for @inCompanies.
  ///
  /// In en, this message translates to:
  /// **'In your companies'**
  String get inCompanies;

  /// No description provided for @targetsNotice.
  ///
  /// In en, this message translates to:
  /// **'Only the names come from your brief. Country, website and hiring status stay empty until you research them. This is a starting list, not the whole market.'**
  String get targetsNotice;

  /// No description provided for @webSearch.
  ///
  /// In en, this message translates to:
  /// **'Web search'**
  String get webSearch;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. krill trawler crew Norway'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @snippetsWarning.
  ///
  /// In en, this message translates to:
  /// **'Search snippets are leads only — open the page and check it.'**
  String get snippetsWarning;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter the company name'**
  String get enterCompanyName;

  /// No description provided for @addVacancy.
  ///
  /// In en, this message translates to:
  /// **'Add vacancy'**
  String get addVacancy;

  /// No description provided for @vacActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get vacActive;

  /// No description provided for @vacUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get vacUnverified;

  /// No description provided for @vacExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get vacExpired;

  /// No description provided for @vacStatusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get vacStatusActive;

  /// No description provided for @vacStatusUnverified.
  ///
  /// In en, this message translates to:
  /// **'UNVERIFIED'**
  String get vacStatusUnverified;

  /// No description provided for @vacStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get vacStatusExpired;

  /// No description provided for @noVacancies.
  ///
  /// In en, this message translates to:
  /// **'No vacancies saved'**
  String get noVacancies;

  /// No description provided for @noVacanciesBody.
  ///
  /// In en, this message translates to:
  /// **'Add a vacancy with the link to its posting. It stays \"unverified\" until you confirm the posting is still open.'**
  String get noVacanciesBody;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline {date}'**
  String deadline(String date);

  /// No description provided for @checkedStillOpen.
  ///
  /// In en, this message translates to:
  /// **'I checked: still open'**
  String get checkedStillOpen;

  /// No description provided for @markExpired.
  ///
  /// In en, this message translates to:
  /// **'Mark as expired'**
  String get markExpired;

  /// No description provided for @employerPositionRequired.
  ///
  /// In en, this message translates to:
  /// **'Employer and position are required'**
  String get employerPositionRequired;

  /// No description provided for @postingLinkError.
  ///
  /// In en, this message translates to:
  /// **'Link to the posting: {error}'**
  String postingLinkError(String error);

  /// No description provided for @positionRequired.
  ///
  /// In en, this message translates to:
  /// **'Position *'**
  String get positionRequired;

  /// No description provided for @employerRequired.
  ///
  /// In en, this message translates to:
  /// **'Employer *'**
  String get employerRequired;

  /// No description provided for @postingLinkRequired.
  ///
  /// In en, this message translates to:
  /// **'Link to the posting *'**
  String get postingLinkRequired;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// No description provided for @addVessel.
  ///
  /// In en, this message translates to:
  /// **'Add vessel'**
  String get addVessel;

  /// No description provided for @noVesselsYet.
  ///
  /// In en, this message translates to:
  /// **'No vessels yet'**
  String get noVesselsYet;

  /// No description provided for @noVesselsBody.
  ///
  /// In en, this message translates to:
  /// **'Add vessels and link their owner and operator. The operator is often, but not always, the company that hires the crew.'**
  String get noVesselsBody;

  /// No description provided for @imo.
  ///
  /// In en, this message translates to:
  /// **'IMO'**
  String get imo;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flag;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @typicalPositions.
  ///
  /// In en, this message translates to:
  /// **'Typical positions'**
  String get typicalPositions;

  /// No description provided for @linkOwnerOperator.
  ///
  /// In en, this message translates to:
  /// **'Link owner / operator'**
  String get linkOwnerOperator;

  /// No description provided for @addCompanyFirst.
  ///
  /// In en, this message translates to:
  /// **'Add the company first under Companies.'**
  String get addCompanyFirst;

  /// No description provided for @vesselNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Vessel name is required'**
  String get vesselNameRequired;

  /// No description provided for @imoInvalid.
  ///
  /// In en, this message translates to:
  /// **'IMO number is not valid (7 digits with a check digit)'**
  String get imoInvalid;

  /// No description provided for @vesselNameStar.
  ///
  /// In en, this message translates to:
  /// **'Vessel name *'**
  String get vesselNameStar;

  /// No description provided for @imoNumber.
  ///
  /// In en, this message translates to:
  /// **'IMO number'**
  String get imoNumber;

  /// No description provided for @flagTwoLetters.
  ///
  /// In en, this message translates to:
  /// **'Flag (2 letters)'**
  String get flagTwoLetters;

  /// No description provided for @registrySource.
  ///
  /// In en, this message translates to:
  /// **'Source (registry page)'**
  String get registrySource;

  /// No description provided for @linkCompany.
  ///
  /// In en, this message translates to:
  /// **'Link company'**
  String get linkCompany;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @possibleDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicates'**
  String get possibleDuplicates;

  /// No description provided for @noDuplicates.
  ///
  /// In en, this message translates to:
  /// **'No duplicates found'**
  String get noDuplicates;

  /// No description provided for @duplicatesHelp.
  ///
  /// In en, this message translates to:
  /// **'Open the one to remove and choose \"Merge into another company\".'**
  String get duplicatesHelp;

  /// No description provided for @featCrm.
  ///
  /// In en, this message translates to:
  /// **'CRM Pipeline'**
  String get featCrm;

  /// No description provided for @featCrmDesc.
  ///
  /// In en, this message translates to:
  /// **'Kanban board of applications from Discovered to Hired, with timelines and follow-ups.'**
  String get featCrmDesc;

  /// No description provided for @featContacts.
  ///
  /// In en, this message translates to:
  /// **'HR Contacts'**
  String get featContacts;

  /// No description provided for @featContactsDesc.
  ///
  /// In en, this message translates to:
  /// **'Publicly listed crewing and recruitment contacts, with source and verification date.'**
  String get featContactsDesc;

  /// No description provided for @featFleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get featFleet;

  /// No description provided for @featFleetDesc.
  ///
  /// In en, this message translates to:
  /// **'Vessels linked to their owners and operators — which are not always the employer.'**
  String get featFleetDesc;

  /// No description provided for @featAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get featAssistant;

  /// No description provided for @featAssistantDesc.
  ///
  /// In en, this message translates to:
  /// **'Cover letters, replies, translations (EN / UK / RU). Nothing is sent without your approval.'**
  String get featAssistantDesc;

  /// No description provided for @featDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get featDocuments;

  /// No description provided for @featDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Private vault for CVs, Seaman\'s Book, STCW, medicals — with expiry reminders.'**
  String get featDocumentsDesc;

  /// No description provided for @featSalaries.
  ///
  /// In en, this message translates to:
  /// **'Salary Database'**
  String get featSalaries;

  /// No description provided for @featSalariesDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare offers and reported salaries, normalised to the same pay period.'**
  String get featSalariesDesc;

  /// No description provided for @featMap.
  ///
  /// In en, this message translates to:
  /// **'Recruitment Map'**
  String get featMap;

  /// No description provided for @featMapDesc.
  ///
  /// In en, this message translates to:
  /// **'Employers, crewing offices and ports on a map.'**
  String get featMapDesc;

  /// No description provided for @featInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview Trainer'**
  String get featInterview;

  /// No description provided for @featInterviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Practise maritime interviews in English with feedback.'**
  String get featInterviewDesc;

  /// No description provided for @featSafety.
  ///
  /// In en, this message translates to:
  /// **'Scam Detector'**
  String get featSafety;

  /// No description provided for @featSafetyDesc.
  ///
  /// In en, this message translates to:
  /// **'Checks domains, payment requests and suspicious offers, with evidence.'**
  String get featSafetyDesc;

  /// No description provided for @featAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get featAnalytics;

  /// No description provided for @featAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Response rates and pipeline statistics from your own data.'**
  String get featAnalyticsDesc;

  /// No description provided for @discoverDesc.
  ///
  /// In en, this message translates to:
  /// **'Find maritime employers, recruitment contacts and vacancies — including companies with no advertised openings.'**
  String get discoverDesc;

  /// No description provided for @mailDesc.
  ///
  /// In en, this message translates to:
  /// **'Gmail inbox linked to companies and applications. Every outgoing e-mail needs your explicit approval.'**
  String get mailDesc;

  /// No description provided for @crm.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get crm;

  /// No description provided for @board.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get board;

  /// No description provided for @followUps.
  ///
  /// In en, this message translates to:
  /// **'Follow-ups'**
  String get followUps;

  /// No description provided for @stDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Discovered'**
  String get stDiscovered;

  /// No description provided for @stResearched.
  ///
  /// In en, this message translates to:
  /// **'Researched'**
  String get stResearched;

  /// No description provided for @stReadyToContact.
  ///
  /// In en, this message translates to:
  /// **'Ready to contact'**
  String get stReadyToContact;

  /// No description provided for @stDraftCreated.
  ///
  /// In en, this message translates to:
  /// **'Draft created'**
  String get stDraftCreated;

  /// No description provided for @stSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get stSent;

  /// No description provided for @stWaitingForReply.
  ///
  /// In en, this message translates to:
  /// **'Waiting for reply'**
  String get stWaitingForReply;

  /// No description provided for @stFollowUpNeeded.
  ///
  /// In en, this message translates to:
  /// **'Follow-up needed'**
  String get stFollowUpNeeded;

  /// No description provided for @stReplied.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get stReplied;

  /// No description provided for @stInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get stInterview;

  /// No description provided for @stOffer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get stOffer;

  /// No description provided for @stHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get stHired;

  /// No description provided for @stRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get stRejected;

  /// No description provided for @stNoVacancies.
  ///
  /// In en, this message translates to:
  /// **'No vacancies'**
  String get stNoVacancies;

  /// No description provided for @stKeepInTouch.
  ///
  /// In en, this message translates to:
  /// **'Keep in touch'**
  String get stKeepInTouch;

  /// No description provided for @trackApplication.
  ///
  /// In en, this message translates to:
  /// **'Track application'**
  String get trackApplication;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @noApplications.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplications;

  /// No description provided for @noApplicationsBody.
  ///
  /// In en, this message translates to:
  /// **'Open a company and choose \"Track application\" to start your pipeline.'**
  String get noApplicationsBody;

  /// No description provided for @noApplicationsForCompany.
  ///
  /// In en, this message translates to:
  /// **'No applications for this company.'**
  String get noApplicationsForCompany;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the history (optional)'**
  String get statusNote;

  /// No description provided for @remindInDays.
  ///
  /// In en, this message translates to:
  /// **'Remind me to follow up in (days)'**
  String get remindInDays;

  /// No description provided for @noReminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get noReminder;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @addFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Add follow-up'**
  String get addFollowUp;

  /// No description provided for @followUpTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get followUpTitle;

  /// No description provided for @followUpDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow up on application'**
  String get followUpDefaultTitle;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get overdue;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDone;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @followUpsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get followUpsOpen;

  /// No description provided for @followUpsOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get followUpsOverdue;

  /// No description provided for @followUpsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get followUpsDone;

  /// No description provided for @noFollowUpsHere.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups here'**
  String get noFollowUpsHere;

  /// No description provided for @nextFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Next follow-up {date}'**
  String nextFollowUp(String date);

  /// No description provided for @sentOn.
  ///
  /// In en, this message translates to:
  /// **'Sent {date}'**
  String sentOn(String date);

  /// No description provided for @deleteApplication.
  ///
  /// In en, this message translates to:
  /// **'Delete application?'**
  String get deleteApplication;

  /// No description provided for @openCompany.
  ///
  /// In en, this message translates to:
  /// **'Open company'**
  String get openCompany;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @noTimeline.
  ///
  /// In en, this message translates to:
  /// **'Nothing has happened yet.'**
  String get noTimeline;

  /// No description provided for @tlCompanyAdded.
  ///
  /// In en, this message translates to:
  /// **'Company added'**
  String get tlCompanyAdded;

  /// No description provided for @tlNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get tlNote;

  /// No description provided for @tlContactAdded.
  ///
  /// In en, this message translates to:
  /// **'Contact added'**
  String get tlContactAdded;

  /// No description provided for @tlApplicationCreated.
  ///
  /// In en, this message translates to:
  /// **'Application started'**
  String get tlApplicationCreated;

  /// No description provided for @tlStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Status changed'**
  String get tlStatusChanged;

  /// No description provided for @tlFollowUpCreated.
  ///
  /// In en, this message translates to:
  /// **'Follow-up scheduled'**
  String get tlFollowUpCreated;

  /// No description provided for @tlFollowUpDone.
  ///
  /// In en, this message translates to:
  /// **'Follow-up done'**
  String get tlFollowUpDone;

  /// No description provided for @tlVacancyAdded.
  ///
  /// In en, this message translates to:
  /// **'Vacancy added'**
  String get tlVacancyAdded;

  /// No description provided for @tlSourceAdded.
  ///
  /// In en, this message translates to:
  /// **'Source added'**
  String get tlSourceAdded;

  /// No description provided for @statTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// No description provided for @statReplyRate.
  ///
  /// In en, this message translates to:
  /// **'Reply rate'**
  String get statReplyRate;

  /// No description provided for @statMedianReply.
  ///
  /// In en, this message translates to:
  /// **'Median reply time'**
  String get statMedianReply;

  /// No description provided for @daysValue.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String daysValue(String days);

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notEnoughData;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @noContact.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get noContact;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
