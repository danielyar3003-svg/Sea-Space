// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Maritime Career Intelligence';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get verify => 'Verify';

  @override
  String get required => 'Required';

  @override
  String get unknown => 'Unknown';

  @override
  String get notSet => 'Not set';

  @override
  String get all => 'All';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get errorNetwork => 'No connection to the server. Check your network.';

  @override
  String get errorTimeout => 'The server took too long to respond.';

  @override
  String get errorRateLimited => 'Too many requests. Wait a moment and try again.';

  @override
  String get errorServer => 'The server could not complete the request.';

  @override
  String get errorSessionExpired => 'Your session has ended. Sign in again.';

  @override
  String couldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String get invalidUrl => 'Enter a full link starting with https://';

  @override
  String get invalidEmail => 'Not an e-mail address';

  @override
  String get twoLetters => '2 letters';

  @override
  String sourceLabel(String url) {
    return 'Source: $url';
  }

  @override
  String get demoBanner => 'DEMO MODE — no server · sign in with any e-mail · data is kept only in this tab';

  @override
  String comingInPhase(int phase) {
    return 'Coming in Phase $phase';
  }

  @override
  String get notYetAvailable => 'NOT YET AVAILABLE';

  @override
  String get notFound => 'Not found';

  @override
  String get navHome => 'Home';

  @override
  String get navDiscover => 'Discover';

  @override
  String get navCompanies => 'Companies';

  @override
  String get navMail => 'Mail';

  @override
  String get navProfile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get tools => 'Tools';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get createAccount => 'Create account';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get newCreateAccount => 'New to SEA SPACE? Create an account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get enterValidEmail => 'Enter a valid e-mail';

  @override
  String get passwordMin8 => 'At least 8 characters';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get confirmEmailSent => 'Check your inbox to confirm your e-mail, then sign in.';

  @override
  String get enterEmailFirst => 'Enter your e-mail first.';

  @override
  String get resetSent => 'If an account exists, a reset link has been sent.';

  @override
  String get authUnavailable => 'Could not reach the authentication service.';

  @override
  String get authNotConfigured => 'Authentication is not configured';

  @override
  String get authNotConfiguredBody =>
      'This build has no Supabase project settings, so sign-in is unavailable. Rebuild the app with:';

  @override
  String get statCompanies => 'Companies';

  @override
  String get statVerifiedContacts => 'Verified HR contacts';

  @override
  String get statApplicationsSent => 'Applications sent';

  @override
  String get statReplies => 'Replies';

  @override
  String get statPendingFollowUps => 'Pending follow-ups';

  @override
  String get statInterviews => 'Interviews';

  @override
  String get statOffers => 'Offers';

  @override
  String get startWithProfile => 'Start with your profile';

  @override
  String get startWithProfileBody =>
      'Your experience and target positions drive company research and outreach.';

  @override
  String get upcomingFollowUps => 'Upcoming follow-ups';

  @override
  String get noFollowUps => 'No follow-ups scheduled.';

  @override
  String get newCompanies => 'New companies';

  @override
  String get noCompaniesShort => 'No companies yet.';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get activityEmpty => 'Your activity will appear here.';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get newProfile => 'New profile';

  @override
  String get createProfileTitle => 'Create your maritime profile';

  @override
  String get createProfileBody =>
      'Start from the suggested profile (you can change everything before saving), or start from a blank form.';

  @override
  String get reviewSuggestedProfile => 'Review suggested profile';

  @override
  String get startBlank => 'Start blank';

  @override
  String get prefilledNotice =>
      'Pre-filled from your brief. Check every field — nothing is saved until you tap Save. Certificates and dates are left empty on purpose.';

  @override
  String get profileName => 'Profile name';

  @override
  String get profileNameHint => 'e.g. \"Trawl Deckhand\"';

  @override
  String get fullName => 'Full name';

  @override
  String get nameNotSet => 'Name not set';

  @override
  String get nationality => 'Nationality';

  @override
  String get englishLevel => 'English level';

  @override
  String get english => 'English';

  @override
  String get yearsAtSea => 'Years at sea';

  @override
  String get yearsRange => 'Enter a number between 0 and 70';

  @override
  String get approximate => 'Approximate';

  @override
  String get seaExperience => 'Sea experience';

  @override
  String yearsValue(String approx, String years) {
    return '$approx$years years';
  }

  @override
  String get targetPositions => 'Target positions';

  @override
  String get noTargetPositions => 'No target positions yet.';

  @override
  String get addPosition => 'Add position';

  @override
  String get experienceAreas => 'Experience areas';

  @override
  String get noExperienceAreas => 'No experience areas yet.';

  @override
  String get addArea => 'Add area';

  @override
  String get summary => 'Summary';

  @override
  String get summaryHint => 'Short professional summary';

  @override
  String alsoAddVessel(String vessel) {
    return 'Also add vessel: $vessel';
  }

  @override
  String get withoutDates => 'Without dates — add them later if you have them.';

  @override
  String get primary => 'PRIMARY';

  @override
  String get seaService => 'Sea service';

  @override
  String get noVesselsAdded => 'No vessels added yet.';

  @override
  String get vesselNotNamed => 'Vessel not named';

  @override
  String get datesNotProvided => 'Dates not provided';

  @override
  String get present => 'present';

  @override
  String get deleteEntry => 'Delete this entry?';

  @override
  String get experienceEntry => 'Experience entry';

  @override
  String get addSeaService => 'Add sea service';

  @override
  String get editSeaService => 'Edit sea service';

  @override
  String get vesselName => 'Vessel name';

  @override
  String get vesselType => 'Vessel type';

  @override
  String get position => 'Position';

  @override
  String get employer => 'Employer';

  @override
  String get duties => 'Duties (comma separated)';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get clearDates => 'Clear dates';

  @override
  String get endBeforeStart => 'End date is before start date.';

  @override
  String get englishBeginner => 'Beginner';

  @override
  String get englishElementary => 'Elementary';

  @override
  String get englishIntermediate => 'Intermediate';

  @override
  String get englishUpperIntermediate => 'Upper-intermediate';

  @override
  String get englishAdvanced => 'Advanced';

  @override
  String get englishFluent => 'Fluent';

  @override
  String get account => 'Account';

  @override
  String get signedIn => 'Signed in';

  @override
  String get server => 'Server';

  @override
  String get serverUnreachable => 'Server unreachable';

  @override
  String get apiConnected => 'API connected';

  @override
  String get configured => 'CONFIGURED';

  @override
  String get notConfigured => 'NOT CONFIGURED';

  @override
  String get integrationSupabase => 'Supabase authentication';

  @override
  String get integrationEncryption => 'Token encryption key';

  @override
  String get integrationAnthropic => 'Claude API (AI assistant)';

  @override
  String get integrationGmail => 'Gmail OAuth';

  @override
  String get integrationPubsub => 'Gmail push notifications (Pub/Sub)';

  @override
  String get integrationSearch => 'Web search (Brave)';

  @override
  String get privacy => 'Privacy';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Permanently removes your SEA SPACE data';

  @override
  String get deleteAccountTitle => 'Delete account permanently?';

  @override
  String get deleteAccountBody =>
      'All your profiles, companies, applications and other data in SEA SPACE will be deleted. This cannot be undone.';

  @override
  String get addCompany => 'Add company';

  @override
  String get searchCompanies => 'Search companies';

  @override
  String duplicatesToReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count possible duplicates to review',
      one: '$count possible duplicate to review',
    );
    return '$_temp0';
  }

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contacts',
      one: '$count contact',
    );
    return '$_temp0';
  }

  @override
  String openVacanciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open vacancies',
      one: '$count open vacancy',
    );
    return '$_temp0';
  }

  @override
  String get noCompaniesMatch => 'No companies match this filter';

  @override
  String get noCompaniesYet => 'No companies yet';

  @override
  String get noCompaniesBody => 'Add an employer yourself, or start from the research targets in Discover.';

  @override
  String get openDiscover => 'Open Discover';

  @override
  String get newCompany => 'New company';

  @override
  String get editCompany => 'Edit company';

  @override
  String get companyNameRequired => 'Company name *';

  @override
  String get companyName => 'Company name';

  @override
  String get country => 'Country';

  @override
  String get countryTwoLetters => 'Country (2 letters)';

  @override
  String get headquarters => 'Headquarters';

  @override
  String get hiringStatus => 'Hiring status';

  @override
  String get industry => 'Industry';

  @override
  String get recruitment => 'Recruitment';

  @override
  String get officialWebsite => 'Official website';

  @override
  String get careersPage => 'Careers page';

  @override
  String get recruitmentEmail => 'Recruitment e-mail';

  @override
  String get recruitmentEmailHelper => 'Only an address published by the company';

  @override
  String get speculativePolicy => 'Speculative application policy';

  @override
  String get speculativeShort => 'Speculative';

  @override
  String get fleetAndNotes => 'Fleet & notes';

  @override
  String get fleetSummary => 'Fleet summary';

  @override
  String get description => 'Description';

  @override
  String get duplicateTitle => 'This company may already exist';

  @override
  String get duplicateSameNameCountry => 'A company with the same name and country is already saved.';

  @override
  String get createAnyway => 'Create anyway';

  @override
  String usingSavedCompany(String name) {
    return 'Using the saved company \"$name\"';
  }

  @override
  String get markVerified => 'Mark as verified';

  @override
  String get markVerifiedMenu => 'Mark as verified…';

  @override
  String get verifiedPageLabel => 'Page where you checked these details';

  @override
  String get markedVerified => 'Marked as verified';

  @override
  String deleteCompanyTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteCompanyBody => 'The company is removed from your list.';

  @override
  String get researchWebsite => 'Research website';

  @override
  String get researchCompanyWebsite => 'Research company website';

  @override
  String get companyWebsite => 'Company website';

  @override
  String get research => 'Research';

  @override
  String mergeInto(String name) {
    return 'Merge $name into…';
  }

  @override
  String get mergeMenu => 'Merge into another company…';

  @override
  String get noOtherCompanies => 'No other companies.';

  @override
  String mergeConfirmTitle(String name) {
    return 'Merge into $name?';
  }

  @override
  String mergeConfirmBody(String target, String source) {
    return 'Contacts, notes, sources, vacancies and vessel links move to $target. $source is then hidden.';
  }

  @override
  String get merge => 'Merge';

  @override
  String get verifiedOn => 'Verified on';

  @override
  String get source => 'Source';

  @override
  String get hrContacts => 'HR contacts';

  @override
  String get noContactsYet => 'No contacts yet.';

  @override
  String get fleet => 'Fleet';

  @override
  String get noVesselsLinked => 'No vessels linked. Add them under Tools → Fleet.';

  @override
  String get owner => 'Owner';

  @override
  String get operator => 'Operator';

  @override
  String operatorCrewing(String value) {
    return 'Operator · crewing employer: $value';
  }

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get unknownLower => 'unknown';

  @override
  String get notes => 'Notes';

  @override
  String get addNote => 'Add note';

  @override
  String get note => 'Note';

  @override
  String get noNotes => 'No notes.';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get websitesSources => 'Websites & sources';

  @override
  String get noSources => 'No sources recorded.';

  @override
  String get hiringActive => 'Actively hiring';

  @override
  String get hiringNone => 'No current vacancies';

  @override
  String get hiringSpeculative => 'Speculative applications accepted';

  @override
  String get hiringAgency => 'Recruitment agency';

  @override
  String get hiringUnknown => 'Unknown hiring status';

  @override
  String get industryFishing => 'Fishing';

  @override
  String get industryTrawling => 'Trawling';

  @override
  String get industryKrill => 'Krill';

  @override
  String get industrySeafood => 'Seafood processing';

  @override
  String get industryFactory => 'Factory vessels';

  @override
  String get industryAgency => 'Recruitment agency';

  @override
  String get industryShipManagement => 'Ship management';

  @override
  String get industryOther => 'Other';

  @override
  String get verVerified => 'Verified';

  @override
  String get verUnverified => 'Unverified';

  @override
  String get verInferred => 'Inferred';

  @override
  String get verUserProvided => 'Entered by you';

  @override
  String get addContact => 'Add contact';

  @override
  String get genericInbox => 'Generic recruitment inbox';

  @override
  String get genericInboxHint => 'e.g. jobs@, crew@ — not a named person';

  @override
  String get jobTitle => 'Job title';

  @override
  String get emailOrigin => 'Where is this address from?';

  @override
  String get emailPublishedVerified => 'Published · verified';

  @override
  String get emailPublishedUnverified => 'Published · not yet verified';

  @override
  String get emailGuessed => 'Guessed (not published)';

  @override
  String get emailEnteredByYou => 'Entered by you';

  @override
  String get sourcePage => 'Source page';

  @override
  String get guessedWarning => 'Guessed addresses are kept separate and can never be marked verified.';

  @override
  String get enterNameOrEmail => 'Enter a name or an e-mail address';

  @override
  String get addSourceLink => 'Add the link of the page where the address is published';

  @override
  String get guessedEmailBadge => 'GUESSED E-MAIL';

  @override
  String get differentDomainBadge => 'DIFFERENT DOMAIN';

  @override
  String get verifyContact => 'Verify contact';

  @override
  String get contactPublishedPage => 'Page where this contact is published';

  @override
  String get deleteContactTitle => 'Delete contact?';

  @override
  String get recruitmentInbox => 'Recruitment inbox';

  @override
  String get unnamedContact => 'Unnamed contact';

  @override
  String get contactsTitle => 'HR Contacts';

  @override
  String get filterVerified => 'Verified';

  @override
  String get filterUnverified => 'Unverified';

  @override
  String get filterInboxes => 'Recruitment inboxes';

  @override
  String get filterPeople => 'People';

  @override
  String get filterGuessed => 'Guessed e-mails';

  @override
  String get noContactsHere => 'No contacts here';

  @override
  String get noContactsHereBody => 'Contacts are added on a company page, or imported from website research.';

  @override
  String get findingWebsite => 'Website';

  @override
  String get findingEmails => 'E-mail addresses';

  @override
  String get findingCareers => 'Careers pages';

  @override
  String get findingContacts => 'Contact pages';

  @override
  String get findingSpeculative => 'Speculative applications';

  @override
  String get findingPositions => 'Positions mentioned (keywords, not vacancies)';

  @override
  String get websiteResearch => 'Website research';

  @override
  String get readingWebsite => 'Reading the website…';

  @override
  String get readingWebsiteBody => 'Only public pages allowed by robots.txt are read, one request at a time.';

  @override
  String get researchFailed => 'Research failed';

  @override
  String pagesReadNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Read $count pages.',
      one: 'Read $count page.',
    );
    return '$_temp0 Import only what you have checked; imported data stays \"unverified\" until you verify it.';
  }

  @override
  String get nothingFound => 'Nothing relevant was found on these pages.';

  @override
  String get skippedPages => 'Skipped pages';

  @override
  String get limitations => 'Limitations';

  @override
  String get hintRecruitmentInbox => 'Recruitment inbox';

  @override
  String get hintGenericInbox => 'Generic inbox';

  @override
  String get hintDifferentDomain => 'Different domain from the website';

  @override
  String get hintExternalPortal => 'External job portal';

  @override
  String get import => 'Import';

  @override
  String get tabEmployers => 'Employers';

  @override
  String get tabVacancies => 'Vacancies';

  @override
  String get researchEmployerTitle => 'Research an employer website';

  @override
  String get researchEmployerBody =>
      'Reads the company\'s own public pages for recruitment e-mails, careers pages and open-application policies. Works even when no vacancy is advertised.';

  @override
  String get researchAWebsite => 'Research a website';

  @override
  String get researchTargets => 'Research targets from your brief';

  @override
  String get addAll => 'Add all';

  @override
  String get notInCompanies => 'Not in your companies yet';

  @override
  String get inCompanies => 'In your companies';

  @override
  String get targetsNotice =>
      'Only the names come from your brief. Country, website and hiring status stay empty until you research them. This is a starting list, not the whole market.';

  @override
  String get webSearch => 'Web search';

  @override
  String get searchHint => 'e.g. krill trawler crew Norway';

  @override
  String get noResults => 'No results.';

  @override
  String get snippetsWarning => 'Search snippets are leads only — open the page and check it.';

  @override
  String get enterCompanyName => 'Enter the company name';

  @override
  String get addVacancy => 'Add vacancy';

  @override
  String get vacActive => 'Active';

  @override
  String get vacUnverified => 'Unverified';

  @override
  String get vacExpired => 'Expired';

  @override
  String get vacStatusActive => 'ACTIVE';

  @override
  String get vacStatusUnverified => 'UNVERIFIED';

  @override
  String get vacStatusExpired => 'EXPIRED';

  @override
  String get noVacancies => 'No vacancies saved';

  @override
  String get noVacanciesBody =>
      'Add a vacancy with the link to its posting. It stays \"unverified\" until you confirm the posting is still open.';

  @override
  String deadline(String date) {
    return 'Deadline $date';
  }

  @override
  String get checkedStillOpen => 'I checked: still open';

  @override
  String get markExpired => 'Mark as expired';

  @override
  String get employerPositionRequired => 'Employer and position are required';

  @override
  String postingLinkError(String error) {
    return 'Link to the posting: $error';
  }

  @override
  String get positionRequired => 'Position *';

  @override
  String get employerRequired => 'Employer *';

  @override
  String get postingLinkRequired => 'Link to the posting *';

  @override
  String get rotation => 'Rotation';

  @override
  String get addVessel => 'Add vessel';

  @override
  String get noVesselsYet => 'No vessels yet';

  @override
  String get noVesselsBody =>
      'Add vessels and link their owner and operator. The operator is often, but not always, the company that hires the crew.';

  @override
  String get imo => 'IMO';

  @override
  String get flag => 'Flag';

  @override
  String get type => 'Type';

  @override
  String get typicalPositions => 'Typical positions';

  @override
  String get linkOwnerOperator => 'Link owner / operator';

  @override
  String get addCompanyFirst => 'Add the company first under Companies.';

  @override
  String get vesselNameRequired => 'Vessel name is required';

  @override
  String get imoInvalid => 'IMO number is not valid (7 digits with a check digit)';

  @override
  String get vesselNameStar => 'Vessel name *';

  @override
  String get imoNumber => 'IMO number';

  @override
  String get flagTwoLetters => 'Flag (2 letters)';

  @override
  String get registrySource => 'Source (registry page)';

  @override
  String get linkCompany => 'Link company';

  @override
  String get company => 'Company';

  @override
  String get link => 'Link';

  @override
  String get possibleDuplicates => 'Possible duplicates';

  @override
  String get noDuplicates => 'No duplicates found';

  @override
  String get duplicatesHelp => 'Open the one to remove and choose \"Merge into another company\".';

  @override
  String get featCrm => 'CRM Pipeline';

  @override
  String get featCrmDesc =>
      'Kanban board of applications from Discovered to Hired, with timelines and follow-ups.';

  @override
  String get featContacts => 'HR Contacts';

  @override
  String get featContactsDesc =>
      'Publicly listed crewing and recruitment contacts, with source and verification date.';

  @override
  String get featFleet => 'Fleet';

  @override
  String get featFleetDesc =>
      'Vessels linked to their owners and operators — which are not always the employer.';

  @override
  String get featAssistant => 'AI Assistant';

  @override
  String get featAssistantDesc =>
      'Cover letters, replies, translations (EN / UK / RU). Nothing is sent without your approval.';

  @override
  String get featDocuments => 'Documents';

  @override
  String get featDocumentsDesc =>
      'Private vault for CVs, Seaman\'s Book, STCW, medicals — with expiry reminders.';

  @override
  String get featSalaries => 'Salary Database';

  @override
  String get featSalariesDesc => 'Compare offers and reported salaries, normalised to the same pay period.';

  @override
  String get featMap => 'Recruitment Map';

  @override
  String get featMapDesc => 'Employers, crewing offices and ports on a map.';

  @override
  String get featInterview => 'Interview Trainer';

  @override
  String get featInterviewDesc => 'Practise maritime interviews in English with feedback.';

  @override
  String get featSafety => 'Scam Detector';

  @override
  String get featSafetyDesc => 'Checks domains, payment requests and suspicious offers, with evidence.';

  @override
  String get featAnalytics => 'Analytics';

  @override
  String get featAnalyticsDesc => 'Response rates and pipeline statistics from your own data.';

  @override
  String get discoverDesc =>
      'Find maritime employers, recruitment contacts and vacancies — including companies with no advertised openings.';

  @override
  String get mailDesc =>
      'Gmail inbox linked to companies and applications. Every outgoing e-mail needs your explicit approval.';

  @override
  String get crm => 'Applications';

  @override
  String get board => 'Board';

  @override
  String get followUps => 'Follow-ups';

  @override
  String get stDiscovered => 'Discovered';

  @override
  String get stResearched => 'Researched';

  @override
  String get stReadyToContact => 'Ready to contact';

  @override
  String get stDraftCreated => 'Draft created';

  @override
  String get stSent => 'Sent';

  @override
  String get stWaitingForReply => 'Waiting for reply';

  @override
  String get stFollowUpNeeded => 'Follow-up needed';

  @override
  String get stReplied => 'Replied';

  @override
  String get stInterview => 'Interview';

  @override
  String get stOffer => 'Offer';

  @override
  String get stHired => 'Hired';

  @override
  String get stRejected => 'Rejected';

  @override
  String get stNoVacancies => 'No vacancies';

  @override
  String get stKeepInTouch => 'Keep in touch';

  @override
  String get trackApplication => 'Track application';

  @override
  String get applications => 'Applications';

  @override
  String get noApplications => 'No applications yet';

  @override
  String get noApplicationsBody => 'Open a company and choose \"Track application\" to start your pipeline.';

  @override
  String get noApplicationsForCompany => 'No applications for this company.';

  @override
  String get changeStatus => 'Change status';

  @override
  String get status => 'Status';

  @override
  String get statusNote => 'Note for the history (optional)';

  @override
  String get remindInDays => 'Remind me to follow up in (days)';

  @override
  String get noReminder => 'No reminder';

  @override
  String get history => 'History';

  @override
  String get created => 'Created';

  @override
  String get addFollowUp => 'Add follow-up';

  @override
  String get followUpTitle => 'What to do';

  @override
  String get followUpDefaultTitle => 'Follow up on application';

  @override
  String get dueDate => 'Due date';

  @override
  String get overdue => 'OVERDUE';

  @override
  String get done => 'Done';

  @override
  String get markDone => 'Mark as done';

  @override
  String get reopen => 'Reopen';

  @override
  String get followUpsOpen => 'Open';

  @override
  String get followUpsOverdue => 'Overdue';

  @override
  String get followUpsDone => 'Done';

  @override
  String get noFollowUpsHere => 'No follow-ups here';

  @override
  String nextFollowUp(String date) {
    return 'Next follow-up $date';
  }

  @override
  String sentOn(String date) {
    return 'Sent $date';
  }

  @override
  String get deleteApplication => 'Delete application?';

  @override
  String get openCompany => 'Open company';

  @override
  String get timeline => 'Timeline';

  @override
  String get noTimeline => 'Nothing has happened yet.';

  @override
  String get tlCompanyAdded => 'Company added';

  @override
  String get tlNote => 'Note';

  @override
  String get tlContactAdded => 'Contact added';

  @override
  String get tlApplicationCreated => 'Application started';

  @override
  String get tlStatusChanged => 'Status changed';

  @override
  String get tlFollowUpCreated => 'Follow-up scheduled';

  @override
  String get tlFollowUpDone => 'Follow-up done';

  @override
  String get tlVacancyAdded => 'Vacancy added';

  @override
  String get tlSourceAdded => 'Source added';

  @override
  String get statTotal => 'Total';

  @override
  String get statReplyRate => 'Reply rate';

  @override
  String get statMedianReply => 'Median reply time';

  @override
  String daysValue(String days) {
    return '$days d';
  }

  @override
  String get notEnoughData => '—';

  @override
  String get contact => 'Contact';

  @override
  String get noContact => 'No contact';
}
