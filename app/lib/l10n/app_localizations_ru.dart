// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTagline => 'Карьерная разведка для моряков';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get add => 'Добавить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get verify => 'Подтвердить';

  @override
  String get required => 'Обязательное поле';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get notSet => 'Не указано';

  @override
  String get all => 'Все';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get errorNetwork => 'Нет связи с сервером. Проверьте интернет.';

  @override
  String get errorTimeout => 'Сервер слишком долго не отвечает.';

  @override
  String get errorRateLimited => 'Слишком много запросов. Подождите немного и повторите.';

  @override
  String get errorServer => 'Сервер не смог выполнить запрос.';

  @override
  String get errorSessionExpired => 'Сеанс завершён. Войдите снова.';

  @override
  String couldNotSave(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get invalidUrl => 'Введите полную ссылку, начиная с https://';

  @override
  String get invalidEmail => 'Это не адрес e-mail';

  @override
  String get twoLetters => '2 буквы';

  @override
  String sourceLabel(String url) {
    return 'Источник: $url';
  }

  @override
  String get demoBanner =>
      'ДЕМО-РЕЖИМ — без сервера · вход с любым e-mail · данные живут только в этой вкладке';

  @override
  String comingInPhase(int phase) {
    return 'Будет в фазе $phase';
  }

  @override
  String get notYetAvailable => 'ПОКА НЕДОСТУПНО';

  @override
  String get notFound => 'Не найдено';

  @override
  String get navHome => 'Главная';

  @override
  String get navDiscover => 'Поиск';

  @override
  String get navCompanies => 'Компании';

  @override
  String get navMail => 'Почта';

  @override
  String get navProfile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get tools => 'Инструменты';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get haveAccountSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get newCreateAccount => 'Впервые в SEA SPACE? Создайте аккаунт';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get enterValidEmail => 'Введите корректный e-mail';

  @override
  String get passwordMin8 => 'Не менее 8 символов';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get confirmEmailSent => 'Проверьте почту, подтвердите e-mail и войдите.';

  @override
  String get enterEmailFirst => 'Сначала введите e-mail.';

  @override
  String get resetSent => 'Если аккаунт существует, ссылка для сброса отправлена.';

  @override
  String get authUnavailable => 'Сервис входа недоступен.';

  @override
  String get authNotConfigured => 'Вход не настроен';

  @override
  String get authNotConfiguredBody =>
      'В этой сборке нет настроек проекта Supabase, поэтому вход недоступен. Пересоберите приложение так:';

  @override
  String get statCompanies => 'Компании';

  @override
  String get statVerifiedContacts => 'Проверенные HR-контакты';

  @override
  String get statApplicationsSent => 'Отправлено откликов';

  @override
  String get statReplies => 'Ответы';

  @override
  String get statPendingFollowUps => 'Ожидают напоминания';

  @override
  String get statInterviews => 'Собеседования';

  @override
  String get statOffers => 'Предложения';

  @override
  String get startWithProfile => 'Начните с профиля';

  @override
  String get startWithProfileBody => 'Ваш опыт и желаемые должности определяют поиск компаний и письма.';

  @override
  String get upcomingFollowUps => 'Ближайшие напоминания';

  @override
  String get noFollowUps => 'Напоминаний нет.';

  @override
  String get newCompanies => 'Новые компании';

  @override
  String get noCompaniesShort => 'Компаний пока нет.';

  @override
  String get recentActivity => 'Последние действия';

  @override
  String get activityEmpty => 'Здесь появятся ваши действия.';

  @override
  String get profile => 'Профиль';

  @override
  String get editProfile => 'Изменить профиль';

  @override
  String get newProfile => 'Новый профиль';

  @override
  String get createProfileTitle => 'Создайте морской профиль';

  @override
  String get createProfileBody =>
      'Начните с предложенного профиля (перед сохранением всё можно изменить) или с пустой формы.';

  @override
  String get reviewSuggestedProfile => 'Проверить предложенный профиль';

  @override
  String get startBlank => 'Начать с нуля';

  @override
  String get prefilledNotice =>
      'Заполнено по вашему описанию. Проверьте каждое поле — ничего не сохранится, пока вы не нажмёте «Сохранить». Сертификаты и даты специально оставлены пустыми.';

  @override
  String get profileName => 'Название профиля';

  @override
  String get profileNameHint => 'напр. «Trawl Deckhand»';

  @override
  String get fullName => 'Полное имя';

  @override
  String get nameNotSet => 'Имя не указано';

  @override
  String get nationality => 'Гражданство';

  @override
  String get englishLevel => 'Уровень английского';

  @override
  String get english => 'Английский';

  @override
  String get yearsAtSea => 'Лет в море';

  @override
  String get yearsRange => 'Введите число от 0 до 70';

  @override
  String get approximate => 'Приблизно';

  @override
  String get seaExperience => 'Стаж в море';

  @override
  String yearsValue(String approx, String years) {
    return '$approx$years лет';
  }

  @override
  String get targetPositions => 'Желаемые должности';

  @override
  String get noTargetPositions => 'Должности пока не указаны.';

  @override
  String get addPosition => 'Добавить должность';

  @override
  String get experienceAreas => 'Области опыта';

  @override
  String get noExperienceAreas => 'Области опыта пока не указаны.';

  @override
  String get addArea => 'Добавить область';

  @override
  String get summary => 'О себе';

  @override
  String get summaryHint => 'Коротко о профессиональном опыте';

  @override
  String alsoAddVessel(String vessel) {
    return 'Также добавить судно: $vessel';
  }

  @override
  String get withoutDates => 'Без дат — добавьте их позже, если они есть.';

  @override
  String get primary => 'ОСНОВНОЙ';

  @override
  String get seaService => 'Плавание';

  @override
  String get noVesselsAdded => 'Суда пока не добавлены.';

  @override
  String get vesselNotNamed => 'Судно без названия';

  @override
  String get datesNotProvided => 'Даты не указаны';

  @override
  String get present => 'по н.в.';

  @override
  String get deleteEntry => 'Удалить запись?';

  @override
  String get experienceEntry => 'Запись об опыте';

  @override
  String get addSeaService => 'Добавить плавание';

  @override
  String get editSeaService => 'Изменить плавание';

  @override
  String get vesselName => 'Название судна';

  @override
  String get vesselType => 'Тип судна';

  @override
  String get position => 'Должность';

  @override
  String get employer => 'Работодатель';

  @override
  String get duties => 'Обязанности (через запятую)';

  @override
  String get startDate => 'Дата начала';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get clearDates => 'Очистить даты';

  @override
  String get endBeforeStart => 'Дата окончания раньше даты начала.';

  @override
  String get englishBeginner => 'Начальный';

  @override
  String get englishElementary => 'Элементарный';

  @override
  String get englishIntermediate => 'Средний';

  @override
  String get englishUpperIntermediate => 'Выше среднего';

  @override
  String get englishAdvanced => 'Продвинутый';

  @override
  String get englishFluent => 'Свободный';

  @override
  String get account => 'Аккаунт';

  @override
  String get signedIn => 'Вход выполнен';

  @override
  String get server => 'Сервер';

  @override
  String get serverUnreachable => 'Сервер недоступен';

  @override
  String get apiConnected => 'Сервер подключён';

  @override
  String get configured => 'НАСТРОЕНО';

  @override
  String get notConfigured => 'НЕ НАСТРОЕНО';

  @override
  String get integrationSupabase => 'Вход через Supabase';

  @override
  String get integrationEncryption => 'Ключ шифрования токенов';

  @override
  String get integrationAnthropic => 'Claude API (ИИ-ассистент)';

  @override
  String get integrationGmail => 'Gmail OAuth';

  @override
  String get integrationPubsub => 'Push-уведомления Gmail (Pub/Sub)';

  @override
  String get integrationSearch => 'Веб-поиск (Brave)';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountSubtitle => 'Навсегда удаляет ваши данные в SEA SPACE';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт навсегда?';

  @override
  String get deleteAccountBody =>
      'Все ваши профили, компании, отклики и другие данные в SEA SPACE будут удалены. Это нельзя отменить.';

  @override
  String get addCompany => 'Добавить компанию';

  @override
  String get searchCompanies => 'Поиск компаний';

  @override
  String duplicatesToReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count возможных дублей',
      many: '$count возможных дублей',
      few: '$count возможных дубля',
      one: '$count возможный дубль',
    );
    return '$_temp0';
  }

  @override
  String contactsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контакта',
      many: '$count контактов',
      few: '$count контакта',
      one: '$count контакт',
    );
    return '$_temp0';
  }

  @override
  String openVacanciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count открытой вакансии',
      many: '$count открытых вакансий',
      few: '$count открытые вакансии',
      one: '$count открытая вакансия',
    );
    return '$_temp0';
  }

  @override
  String get noCompaniesMatch => 'Нет компаний по этому фильтру';

  @override
  String get noCompaniesYet => 'Компаний пока нет';

  @override
  String get noCompaniesBody => 'Добавьте работодателя сами или начните со списка целей в разделе «Поиск».';

  @override
  String get openDiscover => 'Открыть «Поиск»';

  @override
  String get newCompany => 'Новая компания';

  @override
  String get editCompany => 'Изменить компанию';

  @override
  String get companyNameRequired => 'Название компании *';

  @override
  String get companyName => 'Название компании';

  @override
  String get country => 'Страна';

  @override
  String get countryTwoLetters => 'Страна (2 буквы)';

  @override
  String get headquarters => 'Штаб-квартира';

  @override
  String get hiringStatus => 'Статус найма';

  @override
  String get industry => 'Отрасль';

  @override
  String get recruitment => 'Найм';

  @override
  String get officialWebsite => 'Официальный сайт';

  @override
  String get careersPage => 'Страница вакансий';

  @override
  String get recruitmentEmail => 'E-mail для откликов';

  @override
  String get recruitmentEmailHelper => 'Только адрес, опубликованный самой компанией';

  @override
  String get speculativePolicy => 'Приём инициативных резюме';

  @override
  String get speculativeShort => 'Инициативные';

  @override
  String get fleetAndNotes => 'Флот и заметки';

  @override
  String get fleetSummary => 'Кратко о флоте';

  @override
  String get description => 'Описание';

  @override
  String get duplicateTitle => 'Возможно, компания уже есть';

  @override
  String get duplicateSameNameCountry => 'Компания с таким же названием и страной уже сохранена.';

  @override
  String get createAnyway => 'Всё равно создать';

  @override
  String usingSavedCompany(String name) {
    return 'Используется сохранённая компания «$name»';
  }

  @override
  String get markVerified => 'Отметить как проверенное';

  @override
  String get markVerifiedMenu => 'Отметить как проверенное…';

  @override
  String get verifiedPageLabel => 'Страница, где вы проверили данные';

  @override
  String get markedVerified => 'Отмечено как проверенное';

  @override
  String deleteCompanyTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String get deleteCompanyBody => 'Компания будет убрана из вашего списка.';

  @override
  String get researchWebsite => 'Изучить сайт';

  @override
  String get researchCompanyWebsite => 'Изучить сайт компании';

  @override
  String get companyWebsite => 'Сайт компании';

  @override
  String get research => 'Изучить';

  @override
  String mergeInto(String name) {
    return 'Объединить $name с…';
  }

  @override
  String get mergeMenu => 'Объединить с другой компанией…';

  @override
  String get noOtherCompanies => 'Других компаний нет.';

  @override
  String mergeConfirmTitle(String name) {
    return 'Объединить с $name?';
  }

  @override
  String mergeConfirmBody(String target, String source) {
    return 'Контакты, заметки, источники, вакансии и связи с судами перейдут в $target. $source будет скрыта.';
  }

  @override
  String get merge => 'Объединить';

  @override
  String get verifiedOn => 'Проверено';

  @override
  String get source => 'Источник';

  @override
  String get hrContacts => 'HR-контакты';

  @override
  String get noContactsYet => 'Контактов пока нет.';

  @override
  String get fleet => 'Флот';

  @override
  String get noVesselsLinked => 'Суда не привязаны. Добавьте их в «Инструменты → Флот».';

  @override
  String get owner => 'Владелец';

  @override
  String get operator => 'Оператор';

  @override
  String operatorCrewing(String value) {
    return 'Оператор · нанимает экипаж: $value';
  }

  @override
  String get yes => 'да';

  @override
  String get no => 'нет';

  @override
  String get unknownLower => 'неизвестно';

  @override
  String get notes => 'Заметки';

  @override
  String get addNote => 'Добавить заметку';

  @override
  String get note => 'Заметка';

  @override
  String get noNotes => 'Заметок нет.';

  @override
  String get deleteNote => 'Удалить заметку';

  @override
  String get websitesSources => 'Сайты и источники';

  @override
  String get noSources => 'Источников нет.';

  @override
  String get hiringActive => 'Активно нанимает';

  @override
  String get hiringNone => 'Сейчас нет вакансий';

  @override
  String get hiringSpeculative => 'Принимает инициативные резюме';

  @override
  String get hiringAgency => 'Крюинговое агентство';

  @override
  String get hiringUnknown => 'Статус найма неизвестен';

  @override
  String get industryFishing => 'Рыболовство';

  @override
  String get industryTrawling => 'Траловый лов';

  @override
  String get industryKrill => 'Криль';

  @override
  String get industrySeafood => 'Переработка рыбы';

  @override
  String get industryFactory => 'Суда-заводы';

  @override
  String get industryAgency => 'Крюинговое агентство';

  @override
  String get industryShipManagement => 'Судоменеджмент';

  @override
  String get industryOther => 'Другое';

  @override
  String get verVerified => 'Проверено';

  @override
  String get verUnverified => 'Не проверено';

  @override
  String get verInferred => 'Предположение';

  @override
  String get verUserProvided => 'Введено вами';

  @override
  String get addContact => 'Добавить контакт';

  @override
  String get genericInbox => 'Общий ящик для откликов';

  @override
  String get genericInboxHint => 'напр. jobs@, crew@ — не конкретный человек';

  @override
  String get jobTitle => 'Должность';

  @override
  String get emailOrigin => 'Откуда этот адрес?';

  @override
  String get emailPublishedVerified => 'Опубликован · проверен';

  @override
  String get emailPublishedUnverified => 'Опубликован · ещё не проверен';

  @override
  String get emailGuessed => 'Угадан (не опубликован)';

  @override
  String get emailEnteredByYou => 'Введён вами';

  @override
  String get sourcePage => 'Страница-источник';

  @override
  String get guessedWarning => 'Угаданные адреса хранятся отдельно и не могут быть отмечены как проверенные.';

  @override
  String get enterNameOrEmail => 'Введите имя или адрес e-mail';

  @override
  String get addSourceLink => 'Добавьте ссылку на страницу, где опубликован адрес';

  @override
  String get guessedEmailBadge => 'УГАДАННЫЙ E-MAIL';

  @override
  String get differentDomainBadge => 'ДРУГОЙ ДОМЕН';

  @override
  String get verifyContact => 'Подтвердить контакт';

  @override
  String get contactPublishedPage => 'Страница, где опубликован контакт';

  @override
  String get deleteContactTitle => 'Удалить контакт?';

  @override
  String get recruitmentInbox => 'Ящик для откликов';

  @override
  String get unnamedContact => 'Контакт без имени';

  @override
  String get contactsTitle => 'HR-контакты';

  @override
  String get filterVerified => 'Проверенные';

  @override
  String get filterUnverified => 'Непроверенные';

  @override
  String get filterInboxes => 'Ящики для откликов';

  @override
  String get filterPeople => 'Люди';

  @override
  String get filterGuessed => 'Угаданные e-mail';

  @override
  String get noContactsHere => 'Здесь нет контактов';

  @override
  String get noContactsHereBody =>
      'Контакты добавляются на странице компании или импортируются из изучения сайта.';

  @override
  String get findingWebsite => 'Сайт';

  @override
  String get findingEmails => 'Адреса e-mail';

  @override
  String get findingCareers => 'Страницы вакансий';

  @override
  String get findingContacts => 'Страницы контактов';

  @override
  String get findingSpeculative => 'Инициативные отклики';

  @override
  String get findingPositions => 'Упомянутые должности (ключевые слова, не вакансии)';

  @override
  String get websiteResearch => 'Изучение сайта';

  @override
  String get readingWebsite => 'Читаю сайт…';

  @override
  String get readingWebsiteBody =>
      'Читаются только публичные страницы, разрешённые robots.txt, по одному запросу за раз.';

  @override
  String get researchFailed => 'Не удалось изучить сайт';

  @override
  String pagesReadNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Прочитано $count страницы.',
      many: 'Прочитано $count страниц.',
      few: 'Прочитано $count страницы.',
      one: 'Прочитана $count страница.',
    );
    return '$_temp0 Импортируйте только то, что проверили; импортированное остаётся «непроверенным», пока вы его не подтвердите.';
  }

  @override
  String get nothingFound => 'На этих страницах ничего полезного не найдено.';

  @override
  String get skippedPages => 'Пропущенные страницы';

  @override
  String get limitations => 'Ограничения';

  @override
  String get hintRecruitmentInbox => 'Ящик для откликов';

  @override
  String get hintGenericInbox => 'Общий ящик';

  @override
  String get hintDifferentDomain => 'Домен отличается от сайта';

  @override
  String get hintExternalPortal => 'Внешний сайт вакансий';

  @override
  String get import => 'Импорт';

  @override
  String get tabEmployers => 'Работодатели';

  @override
  String get tabVacancies => 'Вакансии';

  @override
  String get researchEmployerTitle => 'Изучить сайт работодателя';

  @override
  String get researchEmployerBody =>
      'Читает публичные страницы компании: e-mail для откликов, страницы вакансий, приём инициативных резюме. Работает, даже если вакансий нет.';

  @override
  String get researchAWebsite => 'Изучить сайт';

  @override
  String get researchTargets => 'Цели из вашего описания';

  @override
  String get addAll => 'Добавить все';

  @override
  String get notInCompanies => 'Ещё нет в ваших компаниях';

  @override
  String get inCompanies => 'Есть в ваших компаниях';

  @override
  String get targetsNotice =>
      'Из описания взяты только названия. Страна, сайт и статус найма остаются пустыми, пока вы их не изучите. Это стартовый список, а не весь рынок.';

  @override
  String get webSearch => 'Веб-поиск';

  @override
  String get searchHint => 'напр. krill trawler crew Norway';

  @override
  String get noResults => 'Ничего не найдено.';

  @override
  String get snippetsWarning => 'Фрагменты из поиска — только зацепки: откройте страницу и проверьте.';

  @override
  String get enterCompanyName => 'Введите название компании';

  @override
  String get addVacancy => 'Добавить вакансию';

  @override
  String get vacActive => 'Активные';

  @override
  String get vacUnverified => 'Непроверенные';

  @override
  String get vacExpired => 'Истёкшие';

  @override
  String get vacStatusActive => 'АКТИВНА';

  @override
  String get vacStatusUnverified => 'НЕ ПРОВЕРЕНА';

  @override
  String get vacStatusExpired => 'ИСТЕКЛА';

  @override
  String get noVacancies => 'Сохранённых вакансий нет';

  @override
  String get noVacanciesBody =>
      'Добавьте вакансию со ссылкой на объявление. Она остаётся «непроверенной», пока вы не подтвердите, что объявление ещё открыто.';

  @override
  String deadline(String date) {
    return 'Срок $date';
  }

  @override
  String get checkedStillOpen => 'Я проверил: ещё открыта';

  @override
  String get markExpired => 'Отметить как истёкшую';

  @override
  String get employerPositionRequired => 'Нужны работодатель и должность';

  @override
  String postingLinkError(String error) {
    return 'Ссылка на объявление: $error';
  }

  @override
  String get positionRequired => 'Должность *';

  @override
  String get employerRequired => 'Работодатель *';

  @override
  String get postingLinkRequired => 'Ссылка на объявление *';

  @override
  String get rotation => 'Ротация';

  @override
  String get addVessel => 'Добавить судно';

  @override
  String get noVesselsYet => 'Судов пока нет';

  @override
  String get noVesselsBody =>
      'Добавляйте суда и указывайте владельца и оператора. Оператор часто, но не всегда, — та компания, что нанимает экипаж.';

  @override
  String get imo => 'IMO';

  @override
  String get flag => 'Флаг';

  @override
  String get type => 'Тип';

  @override
  String get typicalPositions => 'Типичные должности';

  @override
  String get linkOwnerOperator => 'Указать владельца / оператора';

  @override
  String get addCompanyFirst => 'Сначала добавьте компанию в разделе «Компании».';

  @override
  String get vesselNameRequired => 'Нужно название судна';

  @override
  String get imoInvalid => 'Неверный номер IMO (7 цифр с контрольной цифрой)';

  @override
  String get vesselNameStar => 'Название судна *';

  @override
  String get imoNumber => 'Номер IMO';

  @override
  String get flagTwoLetters => 'Флаг (2 буквы)';

  @override
  String get registrySource => 'Источник (страница реестра)';

  @override
  String get linkCompany => 'Привязать компанию';

  @override
  String get company => 'Компания';

  @override
  String get link => 'Привязать';

  @override
  String get possibleDuplicates => 'Возможные дубли';

  @override
  String get noDuplicates => 'Дублей не найдено';

  @override
  String get duplicatesHelp => 'Откройте лишнюю компанию и выберите «Объединить с другой компанией».';

  @override
  String get featCrm => 'Воронка откликов';

  @override
  String get featCrmDesc => 'Доска откликов от «Найдено» до «Нанят», с историей и напоминаниями.';

  @override
  String get featContacts => 'HR-контакты';

  @override
  String get featContactsDesc => 'Публичные контакты крюинга и HR с источником и датой проверки.';

  @override
  String get featFleet => 'Флот';

  @override
  String get featFleetDesc => 'Суда с владельцами и операторами — они не всегда работодатель.';

  @override
  String get featAssistant => 'ИИ-ассистент';

  @override
  String get featAssistantDesc =>
      'Сопроводительные письма, ответы, переводы (EN / UK / RU). Ничего не отправляется без вашего согласия.';

  @override
  String get featDocuments => 'Документы';

  @override
  String get featDocumentsDesc =>
      'Личное хранилище CV, мореходной книжки, STCW, медкомиссий — с напоминаниями о сроках.';

  @override
  String get featSalaries => 'Зарплаты';

  @override
  String get featSalariesDesc => 'Сравнение предложений и зарплат, приведённых к одному периоду.';

  @override
  String get featMap => 'Карта найма';

  @override
  String get featMapDesc => 'Работодатели, крюинговые офисы и порты на карте.';

  @override
  String get featInterview => 'Тренажёр собеседований';

  @override
  String get featInterviewDesc => 'Тренировка морских собеседований на английском с разбором ответов.';

  @override
  String get featSafety => 'Проверка на мошенников';

  @override
  String get featSafetyDesc =>
      'Проверяет домены, просьбы об оплате и подозрительные предложения — с доказательствами.';

  @override
  String get featAnalytics => 'Аналитика';

  @override
  String get featAnalyticsDesc => 'Доля ответов и статистика откликов по вашим данным.';

  @override
  String get discoverDesc =>
      'Поиск морских работодателей, контактов и вакансий — включая компании без открытых вакансий.';

  @override
  String get mailDesc =>
      'Почта Gmail, связанная с компаниями и откликами. Каждое исходящее письмо — только с вашего подтверждения.';

  @override
  String get crm => 'Отклики';

  @override
  String get board => 'Доска';

  @override
  String get followUps => 'Напоминания';

  @override
  String get stDiscovered => 'Найдено';

  @override
  String get stResearched => 'Изучено';

  @override
  String get stReadyToContact => 'Готово к контакту';

  @override
  String get stDraftCreated => 'Черновик готов';

  @override
  String get stSent => 'Отправлено';

  @override
  String get stWaitingForReply => 'Ждём ответа';

  @override
  String get stFollowUpNeeded => 'Нужно напомнить';

  @override
  String get stReplied => 'Ответили';

  @override
  String get stInterview => 'Собеседование';

  @override
  String get stOffer => 'Предложение';

  @override
  String get stHired => 'Нанят';

  @override
  String get stRejected => 'Отказ';

  @override
  String get stNoVacancies => 'Нет вакансий';

  @override
  String get stKeepInTouch => 'На связи';

  @override
  String get trackApplication => 'Отслеживать отклик';

  @override
  String get applications => 'Отклики';

  @override
  String get noApplications => 'Откликов пока нет';

  @override
  String get noApplicationsBody => 'Откройте компанию и нажмите «Отслеживать отклик», чтобы начать.';

  @override
  String get noApplicationsForCompany => 'По этой компании откликов нет.';

  @override
  String get changeStatus => 'Изменить статус';

  @override
  String get status => 'Статус';

  @override
  String get statusNote => 'Заметка в историю (необязательно)';

  @override
  String get remindInDays => 'Напомнить через (дней)';

  @override
  String get noReminder => 'Без напоминания';

  @override
  String get history => 'История';

  @override
  String get created => 'Создано';

  @override
  String get addFollowUp => 'Добавить напоминание';

  @override
  String get followUpTitle => 'Что сделать';

  @override
  String get followUpDefaultTitle => 'Напомнить о себе';

  @override
  String get dueDate => 'Срок';

  @override
  String get overdue => 'ПРОСРОЧЕНО';

  @override
  String get done => 'Готово';

  @override
  String get markDone => 'Отметить выполненным';

  @override
  String get reopen => 'Вернуть в работу';

  @override
  String get followUpsOpen => 'Открытые';

  @override
  String get followUpsOverdue => 'Просроченные';

  @override
  String get followUpsDone => 'Выполненные';

  @override
  String get noFollowUpsHere => 'Здесь нет напоминаний';

  @override
  String nextFollowUp(String date) {
    return 'Следующее напоминание $date';
  }

  @override
  String sentOn(String date) {
    return 'Отправлено $date';
  }

  @override
  String get deleteApplication => 'Удалить отклик?';

  @override
  String get openCompany => 'Открыть компанию';

  @override
  String get timeline => 'Хронология';

  @override
  String get noTimeline => 'Пока ничего не происходило.';

  @override
  String get tlCompanyAdded => 'Компания добавлена';

  @override
  String get tlNote => 'Заметка';

  @override
  String get tlContactAdded => 'Добавлен контакт';

  @override
  String get tlApplicationCreated => 'Начат отклик';

  @override
  String get tlStatusChanged => 'Статус изменён';

  @override
  String get tlFollowUpCreated => 'Запланировано напоминание';

  @override
  String get tlFollowUpDone => 'Напоминание выполнено';

  @override
  String get tlVacancyAdded => 'Добавлена вакансия';

  @override
  String get tlSourceAdded => 'Добавлен источник';

  @override
  String get statTotal => 'Всего';

  @override
  String get statReplyRate => 'Доля ответов';

  @override
  String get statMedianReply => 'Медиана ответа';

  @override
  String daysValue(String days) {
    return '$days дн.';
  }

  @override
  String get notEnoughData => '—';

  @override
  String get contact => 'Контакт';

  @override
  String get noContact => 'Без контакта';
}
