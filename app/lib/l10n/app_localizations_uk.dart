// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTagline => 'Кар\'єрна розвідка для моряків';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get add => 'Додати';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Редагувати';

  @override
  String get verify => 'Підтвердити';

  @override
  String get required => 'Обов\'язкове поле';

  @override
  String get unknown => 'Невідомо';

  @override
  String get notSet => 'Не вказано';

  @override
  String get all => 'Усі';

  @override
  String get tryAgain => 'Спробувати ще';

  @override
  String get somethingWentWrong => 'Щось пішло не так';

  @override
  String get errorNetwork => 'Немає зв\'язку із сервером. Перевірте інтернет.';

  @override
  String get errorTimeout => 'Сервер занадто довго не відповідає.';

  @override
  String get errorRateLimited => 'Забагато запитів. Зачекайте трохи й повторіть.';

  @override
  String get errorServer => 'Сервер не зміг виконати запит.';

  @override
  String get errorSessionExpired => 'Сеанс завершено. Увійдіть знову.';

  @override
  String couldNotSave(String error) {
    return 'Не вдалося зберегти: $error';
  }

  @override
  String get invalidUrl => 'Введіть повне посилання, що починається з https://';

  @override
  String get invalidEmail => 'Це не адреса e-mail';

  @override
  String get twoLetters => '2 літери';

  @override
  String sourceLabel(String url) {
    return 'Джерело: $url';
  }

  @override
  String get demoBanner =>
      'ДЕМО-РЕЖИМ — без сервера · вхід з будь-яким e-mail · дані живуть лише в цій вкладці';

  @override
  String comingInPhase(int phase) {
    return 'З\'явиться у фазі $phase';
  }

  @override
  String get notYetAvailable => 'ПОКИ НЕДОСТУПНО';

  @override
  String get notFound => 'Не знайдено';

  @override
  String get navHome => 'Головна';

  @override
  String get navDiscover => 'Пошук';

  @override
  String get navCompanies => 'Компанії';

  @override
  String get navMail => 'Пошта';

  @override
  String get navProfile => 'Профіль';

  @override
  String get settings => 'Налаштування';

  @override
  String get tools => 'Інструменти';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Як у системі';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Увійти';

  @override
  String get signOut => 'Вийти';

  @override
  String get createAccount => 'Створити акаунт';

  @override
  String get haveAccountSignIn => 'Вже маєте акаунт? Увійти';

  @override
  String get newCreateAccount => 'Вперше в SEA SPACE? Створіть акаунт';

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get enterValidEmail => 'Введіть коректний e-mail';

  @override
  String get passwordMin8 => 'Щонайменше 8 символів';

  @override
  String get enterPassword => 'Введіть пароль';

  @override
  String get confirmEmailSent => 'Перевірте пошту, підтвердьте e-mail і увійдіть.';

  @override
  String get enterEmailFirst => 'Спершу введіть e-mail.';

  @override
  String get resetSent => 'Якщо акаунт існує, посилання для скидання надіслано.';

  @override
  String get authUnavailable => 'Сервіс входу недоступний.';

  @override
  String get authNotConfigured => 'Вхід не налаштовано';

  @override
  String get authNotConfiguredBody =>
      'У цій збірці немає налаштувань проєкту Supabase, тому вхід недоступний. Перезберіть застосунок так:';

  @override
  String get statCompanies => 'Компанії';

  @override
  String get statVerifiedContacts => 'Перевірені HR-контакти';

  @override
  String get statApplicationsSent => 'Надіслано відгуків';

  @override
  String get statReplies => 'Відповіді';

  @override
  String get statPendingFollowUps => 'Очікують нагадування';

  @override
  String get statInterviews => 'Співбесіди';

  @override
  String get statOffers => 'Пропозиції';

  @override
  String get startWithProfile => 'Почніть із профілю';

  @override
  String get startWithProfileBody => 'Ваш досвід і бажані посади визначають пошук компаній і листи.';

  @override
  String get upcomingFollowUps => 'Найближчі нагадування';

  @override
  String get noFollowUps => 'Нагадувань немає.';

  @override
  String get newCompanies => 'Нові компанії';

  @override
  String get noCompaniesShort => 'Компаній поки немає.';

  @override
  String get recentActivity => 'Останні дії';

  @override
  String get activityEmpty => 'Тут з\'являться ваші дії.';

  @override
  String get profile => 'Профіль';

  @override
  String get editProfile => 'Редагувати профіль';

  @override
  String get newProfile => 'Новий профіль';

  @override
  String get createProfileTitle => 'Створіть морський профіль';

  @override
  String get createProfileBody =>
      'Почніть із запропонованого профілю (перед збереженням усе можна змінити) або з порожньої форми.';

  @override
  String get reviewSuggestedProfile => 'Переглянути запропонований профіль';

  @override
  String get startBlank => 'Почати з нуля';

  @override
  String get prefilledNotice =>
      'Заповнено за вашим описом. Перевірте кожне поле — нічого не збережеться, доки ви не натиснете «Зберегти». Сертифікати й дати навмисно залишено порожніми.';

  @override
  String get profileName => 'Назва профілю';

  @override
  String get profileNameHint => 'напр. «Trawl Deckhand»';

  @override
  String get fullName => 'Повне ім\'я';

  @override
  String get nameNotSet => 'Ім\'я не вказано';

  @override
  String get nationality => 'Громадянство';

  @override
  String get englishLevel => 'Рівень англійської';

  @override
  String get english => 'Англійська';

  @override
  String get yearsAtSea => 'Років у морі';

  @override
  String get yearsRange => 'Введіть число від 0 до 70';

  @override
  String get approximate => 'Приблизно';

  @override
  String get seaExperience => 'Стаж у морі';

  @override
  String yearsValue(String approx, String years) {
    return '$approx$years років';
  }

  @override
  String get targetPositions => 'Бажані посади';

  @override
  String get noTargetPositions => 'Посади поки не вказано.';

  @override
  String get addPosition => 'Додати посаду';

  @override
  String get experienceAreas => 'Сфери досвіду';

  @override
  String get noExperienceAreas => 'Сфери досвіду поки не вказано.';

  @override
  String get addArea => 'Додати сферу';

  @override
  String get summary => 'Про себе';

  @override
  String get summaryHint => 'Коротко про професійний досвід';

  @override
  String alsoAddVessel(String vessel) {
    return 'Також додати судно: $vessel';
  }

  @override
  String get withoutDates => 'Без дат — додайте їх пізніше, якщо вони є.';

  @override
  String get primary => 'ОСНОВНИЙ';

  @override
  String get seaService => 'Плавання';

  @override
  String get noVesselsAdded => 'Судна поки не додано.';

  @override
  String get vesselNotNamed => 'Судно без назви';

  @override
  String get datesNotProvided => 'Дати не вказано';

  @override
  String get present => 'дотепер';

  @override
  String get deleteEntry => 'Видалити запис?';

  @override
  String get experienceEntry => 'Запис про досвід';

  @override
  String get addSeaService => 'Додати плавання';

  @override
  String get editSeaService => 'Редагувати плавання';

  @override
  String get vesselName => 'Назва судна';

  @override
  String get vesselType => 'Тип судна';

  @override
  String get position => 'Посада';

  @override
  String get employer => 'Роботодавець';

  @override
  String get duties => 'Обов\'язки (через кому)';

  @override
  String get startDate => 'Дата початку';

  @override
  String get endDate => 'Дата закінчення';

  @override
  String get clearDates => 'Очистити дати';

  @override
  String get endBeforeStart => 'Дата закінчення раніша за дату початку.';

  @override
  String get englishBeginner => 'Початковий';

  @override
  String get englishElementary => 'Елементарний';

  @override
  String get englishIntermediate => 'Середній';

  @override
  String get englishUpperIntermediate => 'Вище середнього';

  @override
  String get englishAdvanced => 'Просунутий';

  @override
  String get englishFluent => 'Вільний';

  @override
  String get account => 'Акаунт';

  @override
  String get signedIn => 'Вхід виконано';

  @override
  String get server => 'Сервер';

  @override
  String get serverUnreachable => 'Сервер недоступний';

  @override
  String get apiConnected => 'Сервер підключено';

  @override
  String get configured => 'НАЛАШТОВАНО';

  @override
  String get notConfigured => 'НЕ НАЛАШТОВАНО';

  @override
  String get integrationSupabase => 'Вхід через Supabase';

  @override
  String get integrationEncryption => 'Ключ шифрування токенів';

  @override
  String get integrationAnthropic => 'Claude API (ШІ-асистент)';

  @override
  String get integrationGmail => 'Gmail OAuth';

  @override
  String get integrationPubsub => 'Push-сповіщення Gmail (Pub/Sub)';

  @override
  String get integrationSearch => 'Вебпошук (Brave)';

  @override
  String get privacy => 'Конфіденційність';

  @override
  String get deleteAccount => 'Видалити акаунт';

  @override
  String get deleteAccountSubtitle => 'Назавжди видаляє ваші дані в SEA SPACE';

  @override
  String get deleteAccountTitle => 'Видалити акаунт назавжди?';

  @override
  String get deleteAccountBody =>
      'Усі ваші профілі, компанії, відгуки та інші дані в SEA SPACE буде видалено. Це не можна скасувати.';

  @override
  String get addCompany => 'Додати компанію';

  @override
  String get searchCompanies => 'Пошук компаній';

  @override
  String duplicatesToReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count можливих дублів',
      many: '$count можливих дублів',
      few: '$count можливі дублі',
      one: '$count можливий дубль',
    );
    return '$_temp0';
  }

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контакту',
      many: '$count контактів',
      few: '$count контакти',
      one: '$count контакт',
    );
    return '$_temp0';
  }

  @override
  String openVacanciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count відкритої вакансії',
      many: '$count відкритих вакансій',
      few: '$count відкриті вакансії',
      one: '$count відкрита вакансія',
    );
    return '$_temp0';
  }

  @override
  String get noCompaniesMatch => 'Немає компаній за цим фільтром';

  @override
  String get noCompaniesYet => 'Компаній поки немає';

  @override
  String get noCompaniesBody => 'Додайте роботодавця самі або почніть зі списку цілей у розділі «Пошук».';

  @override
  String get openDiscover => 'Відкрити «Пошук»';

  @override
  String get newCompany => 'Нова компанія';

  @override
  String get editCompany => 'Редагувати компанію';

  @override
  String get companyNameRequired => 'Назва компанії *';

  @override
  String get companyName => 'Назва компанії';

  @override
  String get country => 'Країна';

  @override
  String get countryTwoLetters => 'Країна (2 літери)';

  @override
  String get headquarters => 'Головний офіс';

  @override
  String get hiringStatus => 'Статус найму';

  @override
  String get industry => 'Галузь';

  @override
  String get recruitment => 'Найм';

  @override
  String get officialWebsite => 'Офіційний сайт';

  @override
  String get careersPage => 'Сторінка вакансій';

  @override
  String get recruitmentEmail => 'E-mail для відгуків';

  @override
  String get recruitmentEmailHelper => 'Лише адреса, опублікована самою компанією';

  @override
  String get speculativePolicy => 'Прийом ініціативних резюме';

  @override
  String get speculativeShort => 'Ініціативні';

  @override
  String get fleetAndNotes => 'Флот і нотатки';

  @override
  String get fleetSummary => 'Коротко про флот';

  @override
  String get description => 'Опис';

  @override
  String get duplicateTitle => 'Можливо, компанія вже є';

  @override
  String get duplicateSameNameCountry => 'Компанію з такою самою назвою та країною вже збережено.';

  @override
  String get createAnyway => 'Однаково створити';

  @override
  String usingSavedCompany(String name) {
    return 'Використовується збережена компанія «$name»';
  }

  @override
  String get markVerified => 'Позначити як перевірене';

  @override
  String get markVerifiedMenu => 'Позначити як перевірене…';

  @override
  String get verifiedPageLabel => 'Сторінка, де ви перевірили дані';

  @override
  String get markedVerified => 'Позначено як перевірене';

  @override
  String deleteCompanyTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String get deleteCompanyBody => 'Компанію буде прибрано з вашого списку.';

  @override
  String get researchWebsite => 'Дослідити сайт';

  @override
  String get researchCompanyWebsite => 'Дослідити сайт компанії';

  @override
  String get companyWebsite => 'Сайт компанії';

  @override
  String get research => 'Дослідити';

  @override
  String mergeInto(String name) {
    return 'Об\'єднати $name з…';
  }

  @override
  String get mergeMenu => 'Об\'єднати з іншою компанією…';

  @override
  String get noOtherCompanies => 'Інших компаній немає.';

  @override
  String mergeConfirmTitle(String name) {
    return 'Об\'єднати з $name?';
  }

  @override
  String mergeConfirmBody(String target, String source) {
    return 'Контакти, нотатки, джерела, вакансії та зв\'язки із суднами перейдуть до $target. $source буде приховано.';
  }

  @override
  String get merge => 'Об\'єднати';

  @override
  String get verifiedOn => 'Перевірено';

  @override
  String get source => 'Джерело';

  @override
  String get hrContacts => 'HR-контакти';

  @override
  String get noContactsYet => 'Контактів поки немає.';

  @override
  String get fleet => 'Флот';

  @override
  String get noVesselsLinked => 'Судна не прив\'язано. Додайте їх в «Інструменти → Флот».';

  @override
  String get owner => 'Власник';

  @override
  String get operator => 'Оператор';

  @override
  String operatorCrewing(String value) {
    return 'Оператор · наймає екіпаж: $value';
  }

  @override
  String get yes => 'так';

  @override
  String get no => 'ні';

  @override
  String get unknownLower => 'невідомо';

  @override
  String get notes => 'Нотатки';

  @override
  String get addNote => 'Додати нотатку';

  @override
  String get note => 'Нотатка';

  @override
  String get noNotes => 'Нотаток немає.';

  @override
  String get deleteNote => 'Видалити нотатку';

  @override
  String get websitesSources => 'Сайти та джерела';

  @override
  String get noSources => 'Джерел немає.';

  @override
  String get hiringActive => 'Активно наймає';

  @override
  String get hiringNone => 'Зараз немає вакансій';

  @override
  String get hiringSpeculative => 'Приймає ініціативні резюме';

  @override
  String get hiringAgency => 'Крюїнгове агентство';

  @override
  String get hiringUnknown => 'Статус найму невідомий';

  @override
  String get industryFishing => 'Рибальство';

  @override
  String get industryTrawling => 'Траловий лов';

  @override
  String get industryKrill => 'Криль';

  @override
  String get industrySeafood => 'Переробка риби';

  @override
  String get industryFactory => 'Судна-заводи';

  @override
  String get industryAgency => 'Крюїнгове агентство';

  @override
  String get industryShipManagement => 'Судноменеджмент';

  @override
  String get industryOther => 'Інше';

  @override
  String get verVerified => 'Перевірено';

  @override
  String get verUnverified => 'Не перевірено';

  @override
  String get verInferred => 'Припущення';

  @override
  String get verUserProvided => 'Введено вами';

  @override
  String get addContact => 'Додати контакт';

  @override
  String get genericInbox => 'Загальна скринька для відгуків';

  @override
  String get genericInboxHint => 'напр. jobs@, crew@ — не конкретна людина';

  @override
  String get jobTitle => 'Посада';

  @override
  String get emailOrigin => 'Звідки ця адреса?';

  @override
  String get emailPublishedVerified => 'Опублікована · перевірена';

  @override
  String get emailPublishedUnverified => 'Опублікована · ще не перевірена';

  @override
  String get emailGuessed => 'Вгадана (не опублікована)';

  @override
  String get emailEnteredByYou => 'Введена вами';

  @override
  String get sourcePage => 'Сторінка-джерело';

  @override
  String get guessedWarning => 'Вгадані адреси зберігаються окремо й не можуть бути позначені як перевірені.';

  @override
  String get enterNameOrEmail => 'Введіть ім\'я або адресу e-mail';

  @override
  String get addSourceLink => 'Додайте посилання на сторінку, де опубліковано адресу';

  @override
  String get guessedEmailBadge => 'ВГАДАНИЙ E-MAIL';

  @override
  String get differentDomainBadge => 'ІНШИЙ ДОМЕН';

  @override
  String get verifyContact => 'Підтвердити контакт';

  @override
  String get contactPublishedPage => 'Сторінка, де опубліковано контакт';

  @override
  String get deleteContactTitle => 'Видалити контакт?';

  @override
  String get recruitmentInbox => 'Скринька для відгуків';

  @override
  String get unnamedContact => 'Контакт без імені';

  @override
  String get contactsTitle => 'HR-контакти';

  @override
  String get filterVerified => 'Перевірені';

  @override
  String get filterUnverified => 'Неперевірені';

  @override
  String get filterInboxes => 'Скриньки для відгуків';

  @override
  String get filterPeople => 'Люди';

  @override
  String get filterGuessed => 'Вгадані e-mail';

  @override
  String get noContactsHere => 'Тут немає контактів';

  @override
  String get noContactsHereBody =>
      'Контакти додаються на сторінці компанії або імпортуються з дослідження сайту.';

  @override
  String get findingWebsite => 'Сайт';

  @override
  String get findingEmails => 'Адреси e-mail';

  @override
  String get findingCareers => 'Сторінки вакансій';

  @override
  String get findingContacts => 'Сторінки контактів';

  @override
  String get findingSpeculative => 'Ініціативні відгуки';

  @override
  String get findingPositions => 'Згадані посади (ключові слова, не вакансії)';

  @override
  String get websiteResearch => 'Дослідження сайту';

  @override
  String get readingWebsite => 'Читаю сайт…';

  @override
  String get readingWebsiteBody =>
      'Читаються лише публічні сторінки, дозволені robots.txt, по одному запиту за раз.';

  @override
  String get researchFailed => 'Не вдалося дослідити сайт';

  @override
  String pagesReadNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Прочитано $count сторінки.',
      many: 'Прочитано $count сторінок.',
      few: 'Прочитано $count сторінки.',
      one: 'Прочитано $count сторінку.',
    );
    return '$_temp0 Імпортуйте лише те, що перевірили; імпортоване залишається «неперевіреним», доки ви його не підтвердите.';
  }

  @override
  String get nothingFound => 'На цих сторінках нічого корисного не знайдено.';

  @override
  String get skippedPages => 'Пропущені сторінки';

  @override
  String get limitations => 'Обмеження';

  @override
  String get hintRecruitmentInbox => 'Скринька для відгуків';

  @override
  String get hintGenericInbox => 'Загальна скринька';

  @override
  String get hintDifferentDomain => 'Домен відрізняється від сайту';

  @override
  String get hintExternalPortal => 'Зовнішній сайт вакансій';

  @override
  String get import => 'Імпорт';

  @override
  String get tabEmployers => 'Роботодавці';

  @override
  String get tabVacancies => 'Вакансії';

  @override
  String get researchEmployerTitle => 'Дослідити сайт роботодавця';

  @override
  String get researchEmployerBody =>
      'Читає публічні сторінки компанії: e-mail для відгуків, сторінки вакансій, прийом ініціативних резюме. Працює, навіть якщо вакансій немає.';

  @override
  String get researchAWebsite => 'Дослідити сайт';

  @override
  String get researchTargets => 'Цілі з вашого опису';

  @override
  String get addAll => 'Додати всі';

  @override
  String get notInCompanies => 'Ще немає у ваших компаніях';

  @override
  String get inCompanies => 'Є у ваших компаніях';

  @override
  String get targetsNotice =>
      'З опису взято лише назви. Країна, сайт і статус найму лишаються порожніми, доки ви їх не дослідите. Це стартовий список, а не весь ринок.';

  @override
  String get webSearch => 'Вебпошук';

  @override
  String get searchHint => 'напр. krill trawler crew Norway';

  @override
  String get noResults => 'Нічого не знайдено.';

  @override
  String get snippetsWarning => 'Фрагменти з пошуку — лише зачіпки: відкрийте сторінку й перевірте.';

  @override
  String get enterCompanyName => 'Введіть назву компанії';

  @override
  String get addVacancy => 'Додати вакансію';

  @override
  String get vacActive => 'Активні';

  @override
  String get vacUnverified => 'Неперевірені';

  @override
  String get vacExpired => 'Минулі';

  @override
  String get vacStatusActive => 'АКТИВНА';

  @override
  String get vacStatusUnverified => 'НЕ ПЕРЕВІРЕНА';

  @override
  String get vacStatusExpired => 'ЗАКІНЧИЛАСЯ';

  @override
  String get noVacancies => 'Збережених вакансій немає';

  @override
  String get noVacanciesBody =>
      'Додайте вакансію з посиланням на оголошення. Вона лишається «неперевіреною», доки ви не підтвердите, що оголошення ще відкрите.';

  @override
  String deadline(String date) {
    return 'Термін $date';
  }

  @override
  String get checkedStillOpen => 'Я перевірив: ще відкрита';

  @override
  String get markExpired => 'Позначити як закінчену';

  @override
  String get employerPositionRequired => 'Потрібні роботодавець і посада';

  @override
  String postingLinkError(String error) {
    return 'Посилання на оголошення: $error';
  }

  @override
  String get positionRequired => 'Посада *';

  @override
  String get employerRequired => 'Роботодавець *';

  @override
  String get postingLinkRequired => 'Посилання на оголошення *';

  @override
  String get rotation => 'Ротація';

  @override
  String get addVessel => 'Додати судно';

  @override
  String get noVesselsYet => 'Суден поки немає';

  @override
  String get noVesselsBody =>
      'Додавайте судна й вказуйте власника та оператора. Оператор часто, але не завжди, — та компанія, що наймає екіпаж.';

  @override
  String get imo => 'IMO';

  @override
  String get flag => 'Прапор';

  @override
  String get type => 'Тип';

  @override
  String get typicalPositions => 'Типові посади';

  @override
  String get linkOwnerOperator => 'Вказати власника / оператора';

  @override
  String get addCompanyFirst => 'Спершу додайте компанію в розділі «Компанії».';

  @override
  String get vesselNameRequired => 'Потрібна назва судна';

  @override
  String get imoInvalid => 'Неправильний номер IMO (7 цифр із контрольною цифрою)';

  @override
  String get vesselNameStar => 'Назва судна *';

  @override
  String get imoNumber => 'Номер IMO';

  @override
  String get flagTwoLetters => 'Прапор (2 літери)';

  @override
  String get registrySource => 'Джерело (сторінка реєстру)';

  @override
  String get linkCompany => 'Прив\'язати компанію';

  @override
  String get company => 'Компанія';

  @override
  String get link => 'Прив\'язати';

  @override
  String get possibleDuplicates => 'Можливі дублі';

  @override
  String get noDuplicates => 'Дублів не знайдено';

  @override
  String get duplicatesHelp => 'Відкрийте зайву компанію й виберіть «Об\'єднати з іншою компанією».';

  @override
  String get featCrm => 'Воронка відгуків';

  @override
  String get featCrmDesc => 'Дошка відгуків від «Знайдено» до «Найнято», з історією та нагадуваннями.';

  @override
  String get featContacts => 'HR-контакти';

  @override
  String get featContactsDesc => 'Публічні контакти крюїнгу та HR із джерелом і датою перевірки.';

  @override
  String get featFleet => 'Флот';

  @override
  String get featFleetDesc => 'Судна з власниками й операторами — вони не завжди роботодавець.';

  @override
  String get featAssistant => 'ШІ-асистент';

  @override
  String get featAssistantDesc =>
      'Супровідні листи, відповіді, переклади (EN / UK / RU). Нічого не надсилається без вашої згоди.';

  @override
  String get featDocuments => 'Документи';

  @override
  String get featDocumentsDesc =>
      'Особисте сховище CV, посвідчення моряка, STCW, медкомісій — з нагадуваннями про терміни.';

  @override
  String get featSalaries => 'Зарплати';

  @override
  String get featSalariesDesc => 'Порівняння пропозицій і зарплат, зведених до одного періоду.';

  @override
  String get featMap => 'Мапа найму';

  @override
  String get featMapDesc => 'Роботодавці, крюїнгові офіси та порти на мапі.';

  @override
  String get featInterview => 'Тренажер співбесід';

  @override
  String get featInterviewDesc => 'Тренування морських співбесід англійською з розбором відповідей.';

  @override
  String get featSafety => 'Перевірка на шахраїв';

  @override
  String get featSafetyDesc => 'Перевіряє домени, прохання про оплату та підозрілі пропозиції — з доказами.';

  @override
  String get featAnalytics => 'Аналітика';

  @override
  String get featAnalyticsDesc => 'Частка відповідей і статистика відгуків за вашими даними.';

  @override
  String get discoverDesc =>
      'Пошук морських роботодавців, контактів і вакансій — зокрема компаній без відкритих вакансій.';

  @override
  String get mailDesc =>
      'Пошта Gmail, пов\'язана з компаніями та відгуками. Кожен вихідний лист — лише з вашого підтвердження.';

  @override
  String get crm => 'Відгуки';

  @override
  String get board => 'Дошка';

  @override
  String get followUps => 'Нагадування';

  @override
  String get stDiscovered => 'Знайдено';

  @override
  String get stResearched => 'Досліджено';

  @override
  String get stReadyToContact => 'Готово до контакту';

  @override
  String get stDraftCreated => 'Чернетку створено';

  @override
  String get stSent => 'Надіслано';

  @override
  String get stWaitingForReply => 'Чекаємо відповіді';

  @override
  String get stFollowUpNeeded => 'Треба нагадати';

  @override
  String get stReplied => 'Відповіли';

  @override
  String get stInterview => 'Співбесіда';

  @override
  String get stOffer => 'Пропозиція';

  @override
  String get stHired => 'Найнято';

  @override
  String get stRejected => 'Відмова';

  @override
  String get stNoVacancies => 'Немає вакансій';

  @override
  String get stKeepInTouch => 'На зв\'язку';

  @override
  String get trackApplication => 'Відстежувати відгук';

  @override
  String get applications => 'Відгуки';

  @override
  String get noApplications => 'Відгуків поки немає';

  @override
  String get noApplicationsBody => 'Відкрийте компанію й натисніть «Відстежувати відгук», щоб почати.';

  @override
  String get noApplicationsForCompany => 'Щодо цієї компанії відгуків немає.';

  @override
  String get changeStatus => 'Змінити статус';

  @override
  String get status => 'Статус';

  @override
  String get statusNote => 'Нотатка в історію (необов\'язково)';

  @override
  String get remindInDays => 'Нагадати через (днів)';

  @override
  String get noReminder => 'Без нагадування';

  @override
  String get history => 'Історія';

  @override
  String get created => 'Створено';

  @override
  String get addFollowUp => 'Додати нагадування';

  @override
  String get followUpTitle => 'Що зробити';

  @override
  String get followUpDefaultTitle => 'Нагадати про себе';

  @override
  String get dueDate => 'Термін';

  @override
  String get overdue => 'ПРОСТРОЧЕНО';

  @override
  String get done => 'Виконано';

  @override
  String get markDone => 'Позначити виконаним';

  @override
  String get reopen => 'Повернути в роботу';

  @override
  String get followUpsOpen => 'Відкриті';

  @override
  String get followUpsOverdue => 'Прострочені';

  @override
  String get followUpsDone => 'Виконані';

  @override
  String get noFollowUpsHere => 'Тут немає нагадувань';

  @override
  String nextFollowUp(String date) {
    return 'Наступне нагадування $date';
  }

  @override
  String sentOn(String date) {
    return 'Надіслано $date';
  }

  @override
  String get deleteApplication => 'Видалити відгук?';

  @override
  String get openCompany => 'Відкрити компанію';

  @override
  String get timeline => 'Хронологія';

  @override
  String get noTimeline => 'Поки нічого не відбувалося.';

  @override
  String get tlCompanyAdded => 'Компанію додано';

  @override
  String get tlNote => 'Нотатка';

  @override
  String get tlContactAdded => 'Додано контакт';

  @override
  String get tlApplicationCreated => 'Розпочато відгук';

  @override
  String get tlStatusChanged => 'Статус змінено';

  @override
  String get tlFollowUpCreated => 'Заплановано нагадування';

  @override
  String get tlFollowUpDone => 'Нагадування виконано';

  @override
  String get tlVacancyAdded => 'Додано вакансію';

  @override
  String get tlSourceAdded => 'Додано джерело';

  @override
  String get statTotal => 'Усього';

  @override
  String get statReplyRate => 'Частка відповідей';

  @override
  String get statMedianReply => 'Медіана відповіді';

  @override
  String daysValue(String days) {
    return '$days дн.';
  }

  @override
  String get notEnoughData => '—';

  @override
  String get contact => 'Контакт';

  @override
  String get noContact => 'Без контакту';
}
