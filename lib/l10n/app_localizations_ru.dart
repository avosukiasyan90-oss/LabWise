// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'LabWise Health';

  @override
  String get cancel => 'Отмена';

  @override
  String get ok => 'ОК';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get signOut => 'Выйти';

  @override
  String get tabAnalyze => 'Анализ';

  @override
  String get tabHistory => 'История';

  @override
  String get tabPlan => 'План';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get authTagline =>
      'Войдите один раз, и история анализов будет синхронизирована на всех устройствах. Вы останетесь в системе, пока не выйдете сами.';

  @override
  String get authWelcome => 'Добро пожаловать';

  @override
  String get authExplainer =>
      'Вход автоматически создаёт аккаунт, если вы новый пользователь, или возвращает вас в существующий.';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get signingIn => 'Выполняется вход…';

  @override
  String get authPrivacyNote => 'Ваши отчёты доступны только вашему аккаунту.';

  @override
  String get signInCanceled => 'Вход отменён.';

  @override
  String signInFailed(String provider, String detail) {
    return 'Не удалось войти через $provider. $detail';
  }

  @override
  String get firebaseNotConfigured =>
      'Firebase ещё не настроен на этом компьютере.';

  @override
  String get firebaseSetupIntro =>
      'Создайте проект LabWise в Firebase, включите вход через Google и выполните:';

  @override
  String get firebaseSetupFooter =>
      'Это подключит Auth, Firestore и Storage, чтобы история синхронизировалась между устройствами.';

  @override
  String get signOutQuestion => 'Выйти из аккаунта?';

  @override
  String get signOutBody =>
      'Вы можете войти снова в любой момент. Облачная история останется в вашем аккаунте.';

  @override
  String get cloudSyncFailed =>
      'Не удалось синхронизировать облачную историю. Показана локальная копия.';

  @override
  String get analyzeIntro =>
      'Мы читаем отчёт целиком, извлекаем каждый показатель и объясняем его简 понятно: информация, описание и рекомендация.';

  @override
  String get howItWorks => 'Как это работает';

  @override
  String get stepUploadTitle => 'Загрузите';

  @override
  String get stepUploadBody =>
      'Выберите отчёт в формате PDF или Word с устройства.';

  @override
  String get stepUnderstandTitle => 'Разберитесь';

  @override
  String get stepUnderstandBody =>
      'Для каждого показателя есть информация, описание и рекомендация.';

  @override
  String get stepActTitle => 'Действуйте';

  @override
  String get stepActBody =>
      'Сначала просмотрите показатели, требующие внимания, затем обсудите их с врачом.';

  @override
  String get filesStayOnDevice =>
      'Ваши файлы остаются на этом устройстве. История сохраняется локально.';

  @override
  String get uploadTitle => 'Загрузите анализ';

  @override
  String get uploadSubtitle =>
      'PDF или Word (.docx). Мы читаем документ целиком и объясняем каждый результат.';

  @override
  String get chooseFile => 'Выбрать файл';

  @override
  String get readingReport => 'Читаем ваш отчёт…';

  @override
  String get readingReportSubtitle =>
      'Извлекаем показатели и готовим рекомендации';

  @override
  String get alreadyUploadedTitle => 'Уже загружено';

  @override
  String alreadyUploadedBody(String fileName) {
    return '«$fileName» уже есть в истории. Откройте «Историю», вместо того чтобы загружать дубликат.';
  }

  @override
  String get viewHistory => 'Открыть историю';

  @override
  String get errorReadFile => 'Не удалось прочитать файл. Попробуйте ещё раз.';

  @override
  String get errorScannedPdf =>
      'Похоже, это отсканированный PDF. Попробуйте текстовый PDF или экспорт из Word.';

  @override
  String get errorGeneric =>
      'При чтении файла произошла ошибка. Попробуйте другой PDF или DOCX.';

  @override
  String get errorUnsupportedType => 'Неподдерживаемый тип файла.';

  @override
  String get historyTitle => 'История';

  @override
  String historySummary(int reports, int folders) {
    String _temp0 = intl.Intl.pluralLogic(
      reports,
      locale: localeName,
      other: '$reports отчётов',
      few: '$reports отчёта',
      one: '$reports отчёт',
    );
    String _temp1 = intl.Intl.pluralLogic(
      folders,
      locale: localeName,
      other: '$folders папках',
      one: '$folders папке',
    );
    return '$_temp0 в $_temp1.';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отчётов',
      few: '$count отчёта',
      one: '$count отчёт',
    );
    return '$_temp0';
  }

  @override
  String needAttentionSuffix(int count) {
    return '$count требуют внимания';
  }

  @override
  String get noReportsTitle => 'Отчётов пока нет';

  @override
  String get noReportsBody =>
      'Загрузите PDF или Word со вкладки «Анализ». Отчёты автоматически распределяются по папкам по типу исследования.';

  @override
  String get deleteReportTitle => 'Удалить отчёт?';

  @override
  String deleteReportBody(String fileName) {
    return 'Удалить «$fileName» из истории?';
  }

  @override
  String get categoryBloodCount => 'Общий анализ крови';

  @override
  String get categoryBloodCountDesc => 'Клетки крови, гемоглобин, тромбоциты';

  @override
  String get categoryBiochemistry => 'Биохимия крови';

  @override
  String get categoryBiochemistryDesc =>
      'Глюкоза, холестерин, показатели печени и почек';

  @override
  String get categoryHormones => 'Гормоны';

  @override
  String get categoryHormonesDesc =>
      'Щитовидная железа и другие гормональные панели';

  @override
  String get categoryUrinalysis => 'Анализы мочи';

  @override
  String get categoryUrinalysisDesc => 'Тест-полоски и микроскопия мочи';

  @override
  String get categoryUrogenital => 'Урогенитальные';

  @override
  String get categoryUrogenitalDesc => 'Микроскопия мазков и ПЦР-панели';

  @override
  String get categoryOther => 'Другие отчёты';

  @override
  String get categoryOtherDesc =>
      'Отчёты, которые пока не удалось отнести к категории';

  @override
  String get categoryInfection => 'Тесты на инфекции';

  @override
  String get categoryInfectionDesc => 'Хеликобактер и другие тесты на инфекции';

  @override
  String get yourResults => 'Ваши результаты';

  @override
  String get done => 'Готово';

  @override
  String get suggestions => 'Рекомендации';

  @override
  String get needsAttention => 'Требует внимания';

  @override
  String get needsAttentionSubtitle =>
      'Значения вне типичных диапазонов с понятными следующими шагами.';

  @override
  String get allFindings => 'Все показатели';

  @override
  String get otherFindings => 'Остальные показатели';

  @override
  String get everyPointRead => 'Каждый показатель, прочитанный из документа.';

  @override
  String get noStructuredPoints =>
      'Структурированные показатели не найдены. Файл сохранён в истории, и вы сможете открыть его позже.';

  @override
  String get resultsDisclaimer =>
      'Только образовательные рекомендации — не медицинская консультация. Всегда согласовывайте решения с врачом.';

  @override
  String get pointsRead => 'Показателей';

  @override
  String get needAttentionLabel => 'Требуют внимания';

  @override
  String get documentDetails => 'Данные документа';

  @override
  String get fieldExam => 'Исследование';

  @override
  String get fieldClinic => 'Клиника';

  @override
  String get fieldPatient => 'Пациент';

  @override
  String get fieldReportNumber => '№ отчёта';

  @override
  String get fieldSampleDate => 'Дата забора';

  @override
  String get fieldDoctor => 'Врач';

  @override
  String get fieldMethod => 'Метод';

  @override
  String get fieldAddress => 'Адрес';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get fieldEmail => 'Эл. почта';

  @override
  String get fieldLabLicence => 'Лицензия лаборатории';

  @override
  String get healthNeedsReview => 'Нужен разбор';

  @override
  String get healthLookingGood => 'Всё хорошо';

  @override
  String get healthSomeAttention => 'Нужно внимание';

  @override
  String get healthFollowUp => 'Рекомендуется наблюдение';

  @override
  String get markerInformation => 'Информация';

  @override
  String get markerDescription => 'Описание';

  @override
  String get markerSuggestion => 'Рекомендация';

  @override
  String markerCode(String code) {
    return 'Код: $code';
  }

  @override
  String markerRef(String range) {
    return 'Норма: $range';
  }

  @override
  String get statusNormal => 'Норма';

  @override
  String get statusLow => 'Ниже нормы';

  @override
  String get statusHigh => 'Выше нормы';

  @override
  String get statusUnknown => 'Начнём';

  @override
  String get attachedFile => 'Прикреплённый файл';

  @override
  String get attachedFileUnavailable => 'Файл недоступен для скачивания';

  @override
  String get attachedFileOnDevice => 'Сохранён на этом устройстве';

  @override
  String get attachedFileSynced => 'Синхронизирован с вашим аккаунтом';

  @override
  String get downloadFile => 'Скачать файл';

  @override
  String get preparing => 'Подготовка…';

  @override
  String get attachedFileMissing => 'Прикреплённый файл недоступен.';

  @override
  String get attachedFileExportFailed =>
      'Не удалось экспортировать файл. Попробуйте ещё раз.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileSubtitle =>
      'Данные из аккаунта остаются без изменений. Медицинские данные не обязательны и нужны только для контекста.';

  @override
  String get googleAccount => 'Аккаунт Google';

  @override
  String get fieldName => 'Имя';

  @override
  String get fieldSurname => 'Фамилия';

  @override
  String get managedByGoogle => 'Управляется вашим аккаунтом';

  @override
  String get healthDetails => 'Данные о здоровье';

  @override
  String get updateAnytime => 'Их можно изменить в любой момент.';

  @override
  String get fieldWeight => 'Вес';

  @override
  String get fieldHeight => 'Рост';

  @override
  String get fieldAge => 'Возраст';

  @override
  String get fieldCountry => 'Страна';

  @override
  String get unitKg => 'кг';

  @override
  String get unitCm => 'см';

  @override
  String get unitYearsOld => 'лет';

  @override
  String get selectCountry => 'Выберите страну';

  @override
  String get searchCountry => 'Поиск страны';

  @override
  String noCountryMatch(String query) {
    return 'Нет стран по запросу «$query».';
  }

  @override
  String bmiNote(String bmi) {
    return 'ИМТ $bmi — ориентировочная оценка.';
  }

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get profileSaveFailed =>
      'Не удалось сохранить профиль. Попробуйте ещё раз.';

  @override
  String get validationWeight => 'Введите вес от 2 до 400 кг.';

  @override
  String get validationHeight => 'Введите рост от 40 до 260 см.';

  @override
  String get validationAge => 'Введите возраст от 1 до 120 лет.';

  @override
  String get language => 'Язык';

  @override
  String get languageSubtitle => 'Изменения применяются ко всему приложению.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String setupWelcomeNamed(String name) {
    return 'Добро пожаловать, $name';
  }

  @override
  String get setupWelcome => 'Добро пожаловать в LabWise';

  @override
  String get setupBody =>
      'Добавьте несколько данных о здоровье, чтобы результаты были понятнее. Это можно пропустить и заполнить позже в профиле.';

  @override
  String get saveAndContinue => 'Сохранить и продолжить';

  @override
  String get skipForNow => 'Пропустить';

  @override
  String get setupSaveFailed =>
      'Не удалось сохранить. Это можно добавить позже.';

  @override
  String get planTitle => 'Ваш план';

  @override
  String planHeadlineUnder(String who) {
    return '$who план, чтобы постепенно набрать вес и сохранить энергию.';
  }

  @override
  String planHeadlineHealthy(String who) {
    return '$who план, чтобы удержать здоровый диапазон и оставаться в форме.';
  }

  @override
  String planHeadlineAbove(String who) {
    return '$who план, чтобы постепенно снижать вес без чувства голода.';
  }

  @override
  String planHeadlineWellAbove(String who) {
    return '$who мягкий план, щадящий суставы, чтобы начать снижать вес.';
  }

  @override
  String get planHeadlineFallback =>
      'Укажите рост и вес, чтобы получить персональный план.';

  @override
  String get planWhoFallback => 'Вот';

  @override
  String get bmiUnder => 'Ниже нормы';

  @override
  String get bmiHealthy => 'Здоровый диапазон';

  @override
  String get bmiAbove => 'Выше нормы';

  @override
  String get bmiWellAbove => 'Значительно выше нормы';

  @override
  String get bmiProfileNeeded => 'Нужен профиль';

  @override
  String get targetsTuned => 'Цели ниже подобраны под этот диапазон.';

  @override
  String get metricKcal => 'ккал / день';

  @override
  String get metricWater => 'вода';

  @override
  String get metricSteps => 'шагов';

  @override
  String get eatingWindow => 'Окно питания';

  @override
  String eatingWindowSubtitle(String window) {
    return 'Принимайте пищу в интервале $window';
  }

  @override
  String get eatingWindowFallback => 'Когда есть в течение дня';

  @override
  String get movement => 'Движение';

  @override
  String get movementSubtitle =>
      'Виды спорта, подобранные под ваше тело и возраст';

  @override
  String get dailyHabits => 'Ежедневные привычки';

  @override
  String get dailyHabitsSubtitle => 'Мелочи, которые дают результат';

  @override
  String get fromYourReports => 'По вашим анализам';

  @override
  String get fromYourReportsSubtitle =>
      'Скорректировано по показателям, требующим внимания';

  @override
  String get planDisclaimer =>
      'Общие рекомендации по образу жизни на основе введённых данных — не медицинская консультация. Перед изменением питания, нагрузок или приёма лекарств проконсультируйтесь с врачом.';

  @override
  String get planSetupTitle => 'Расскажите немного о себе';

  @override
  String planSetupBody(String fields) {
    return 'Добавьте $fields в профиле, и эта вкладка построит время приёмов пищи, виды спорта и дневные цели именно для вас.';
  }

  @override
  String get openProfile => 'Открыть профиль';

  @override
  String planMissingHint(String fields) {
    return 'Добавьте $fields для более точного плана.';
  }

  @override
  String get fieldWeightLower => 'вес';

  @override
  String get fieldHeightLower => 'рост';

  @override
  String get fieldAgeLower => 'возраст';

  @override
  String get mealBreakfast => 'Завтрак';

  @override
  String get mealBreakfastIdea =>
      'Белок и медленные углеводы — яйца или йогурт с овсянкой и фруктами.';

  @override
  String get mealLunch => 'Обед';

  @override
  String get mealLunchIdea =>
      'Половина тарелки овощей, ладонь белка, кулак крупы.';

  @override
  String get mealSnack => 'Перекус';

  @override
  String get mealSnackIdea =>
      'Орехи, сыр или смузи — добавят калорий без тяжести.';

  @override
  String get mealLightSnack => 'Лёгкий перекус';

  @override
  String get mealLightSnackIdea =>
      'Фрукт с горстью орехов, если почувствуете упадок сил.';

  @override
  String get mealDinner => 'Ужин';

  @override
  String get mealDinnerIdeaLight =>
      'Легче и раньше — овощи, нежирный белок, минимум масла.';

  @override
  String get mealDinnerIdeaBalanced =>
      'Сбалансированная тарелка, закончите примерно за 2 часа до сна.';

  @override
  String get mealKitchenClosed => 'Кухня закрыта';

  @override
  String get mealKitchenClosedIdea =>
      'После этого только вода или травяной чай — это бережёт сон.';

  @override
  String get activityWalking => 'Ходьба';

  @override
  String get activityWalkingSchedule => '30–40 мин, почти каждый день';

  @override
  String get activityWalkingWhy =>
      'Самый простой способ сжигать жир без нагрузки на колени и бёдра.';

  @override
  String get activitySwimming => 'Плавание или аквааэробика';

  @override
  String get activitySwimmingSchedule => '2 раза в неделю';

  @override
  String get activitySwimmingWhy =>
      'Вода держит вес тела, поэтому суставам комфортно.';

  @override
  String get activityLightStrength => 'Лёгкая силовая программа';

  @override
  String get activityLightStrengthSchedule => '2 раза в неделю, 20 мин';

  @override
  String get activityLightStrengthWhy =>
      'Сохраняет мышцы при снижении веса и защищает обмен веществ.';

  @override
  String get activityBriskWalk => 'Быстрая ходьба или велосипед';

  @override
  String get activityBriskWalkSchedule => '35 мин, 5 раз в неделю';

  @override
  String get activityBriskWalkWhy =>
      'Регулярное кардио — самый надёжный способ снижать жир.';

  @override
  String get activityStrength => 'Силовые тренировки';

  @override
  String get activityStrengthSchedule2 => '2 раза в неделю';

  @override
  String get activityStrengthSchedule3 => '3 раза в неделю';

  @override
  String get activityStrengthWhyMuscle =>
      'Наращивает мышцы, поэтому вы тратите больше в покое.';

  @override
  String get activityStrengthWhyBone =>
      'Защищает плотность костей и мышцы с возрастом.';

  @override
  String get activityStrengthWhyGain =>
      'Превращает дополнительные калории в мышцы, а не только в жир.';

  @override
  String get activityPostMeal => 'Прогулка после еды';

  @override
  String get activityPostMealSchedule => '10–15 мин после ужина';

  @override
  String get activityPostMealWhy =>
      'Сглаживает скачок сахара после самого плотного приёма пищи.';

  @override
  String get activityEasyWalk => 'Спокойная ходьба';

  @override
  String get activityEasyWalkSchedule => '20–30 мин ежедневно';

  @override
  String get activityEasyWalkWhy =>
      'Поддерживает сердце, не сжигая нужные вам калории.';

  @override
  String get activityMixedCardio => 'Смешанное кардио';

  @override
  String get activityMixedCardioSchedule => '150 мин в неделю';

  @override
  String get activityMixedCardioWhy =>
      'Соответствует уровню активности с лучшими показателями сердца.';

  @override
  String get activityEnjoy => 'То, что нравится';

  @override
  String get activityEnjoySchedule => '1 раз в неделю';

  @override
  String get activityEnjoyWhy =>
      'Футбол, танцы, походы — удовольствие помогает не бросать.';

  @override
  String get activityBalance => 'Баланс и подвижность';

  @override
  String get activityBalanceSchedule => '10 мин ежедневно';

  @override
  String get activityBalanceWhy =>
      'Снижает риск падений и сохраняет свободу движений в суставах.';

  @override
  String habitWater(String litres) {
    return 'Выпивайте около $litres л воды в течение дня.';
  }

  @override
  String get habitSleep => 'Спите 7–9 часов и ложитесь примерно в одно время.';

  @override
  String get habitSugar => 'Сладкие напитки — только по особым случаям.';

  @override
  String get habitFrequentMeals =>
      'Ешьте каждые 3–4 часа, чтобы не оставаться без сил.';

  @override
  String get habitCalcium =>
      'Включайте продукты с кальцием и витамином D почти каждый день.';

  @override
  String get habitStand =>
      'Вставайте и двигайтесь 2 минуты каждый час сидячей работы.';

  @override
  String get noteCholesterol =>
      'Холестерин требует внимания — выбирайте овсянку, бобовые и оливковое масло вместо жареного.';

  @override
  String get noteHdl =>
      'Низкий ЛПВП лучше всего растёт от регулярного кардио — не пропускайте такие дни.';

  @override
  String get noteTriglycerides =>
      'Высокие триглицериды быстро снижаются, если убрать сладкие напитки и алкоголь.';

  @override
  String get noteGlucose =>
      'Сахар крови требует внимания — прогулка после еды здесь важнее всего остального.';

  @override
  String get noteHemoglobin =>
      'Гемоглобин вне нормы — добавьте продукты с железом и обсудите анализы с врачом.';

  @override
  String get noteVitaminD =>
      'Витамин D понижен — обычно помогают дневной свет и назначенная врачом добавка.';

  @override
  String get noteThyroid =>
      'Показатели щитовидной железы требуют разбора; до консультации врача оставьте нагрузки умеренными.';

  @override
  String get noteHPylori =>
      'Тест на хеликобактер положительный — следуйте назначенному врачом лечению и пока придерживайтесь регулярного щадящего питания.';

  @override
  String get comparisonTitle => 'Сравнение с прошлым анализом';

  @override
  String get trendBetter => 'Лучше, чем в прошлый раз';

  @override
  String get trendWorse => 'Стоит присмотреться';

  @override
  String get trendSteady => 'Без изменений';

  @override
  String get trendBetterBody =>
      'Больше показателей вернулось в пределы нормы по сравнению с прошлым разом.';

  @override
  String get trendWorseBody =>
      'Несколько показателей вышли за пределы нормы со времени прошлого анализа.';

  @override
  String get trendSteadyBody =>
      'Показатели остались примерно на том же уровне, что и в прошлый раз.';

  @override
  String previousTestOn(String date) {
    return 'Прошлый анализ $date';
  }

  @override
  String scoreBetterBy(String points) {
    return '+$points п.';
  }

  @override
  String scoreWorseBy(String points) {
    return '$points п.';
  }

  @override
  String get scoreNoChange => 'Без изменений';

  @override
  String inRangeNow(int current, int total) {
    return '$current из $total в норме';
  }

  @override
  String wasInRange(int previous, int total) {
    return 'было $previous из $total';
  }

  @override
  String countImproved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count улучшились',
      few: '$count улучшились',
      one: '$count улучшился',
    );
    return '$_temp0';
  }

  @override
  String countWorsened(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ухудшились',
      few: '$count ухудшились',
      one: '$count ухудшился',
    );
    return '$_temp0';
  }

  @override
  String countSteady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count без изменений',
      one: '$count без изменений',
    );
    return '$_temp0';
  }

  @override
  String get whatChanged => 'Что изменилось';

  @override
  String get whatChangedSubtitle => 'Показатели, измеренные в обоих анализах';

  @override
  String get backInRange => 'Вернулся в норму';

  @override
  String get leftRange => 'Вышел из нормы';

  @override
  String showAllChanges(int count) {
    return 'Показать все показатели ($count)';
  }

  @override
  String get showFewerChanges => 'Только изменившиеся';

  @override
  String get updatedBadge => 'Обновлён';

  @override
  String replacedEarlierVersion(String date) {
    return 'Заменил загрузку от $date';
  }

  @override
  String markersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count показателей',
      few: '$count показателя',
      one: '$count показатель',
    );
    return '$_temp0';
  }

  @override
  String toReviewCount(int count) {
    return '$count на проверку';
  }

  @override
  String folderTrendImproved(int count) {
    return '$count с улучшением';
  }

  @override
  String get activityTitle => 'Календарь активности';

  @override
  String get activitySubtitle => 'Нажмите на любой день, чтобы увидеть детали';

  @override
  String get activityLoading => 'Читаем вашу активность…';

  @override
  String get activityNoneRecorded => 'В этот день активность не записана.';

  @override
  String get activityDistance => 'дистанция';

  @override
  String get activityMinutes => 'актив. мин';

  @override
  String get activityWalkRun => 'Ходьба и бег';

  @override
  String get activityCycling => 'Велосипед';

  @override
  String get activitySessions => 'Тренировки';

  @override
  String get activityKindWalking => 'Ходьба';

  @override
  String get activityKindRunning => 'Бег';

  @override
  String get activityKindCycling => 'Велосипед';

  @override
  String get activityKindOther => 'Тренировка';

  @override
  String activityDurationMinutes(int count) {
    return '$count мин';
  }

  @override
  String get activityConnectTitle => 'Подключите активность';

  @override
  String get activityConnectBody =>
      'Разрешите LabWise читать шаги, ходьбу, бег и велосипед, чтобы календарь показывал каждый день. Приложение только читает — ничего не записывает, и данные остаются на вашем телефоне.';

  @override
  String get activityConnectButton => 'Подключить';

  @override
  String get activityHealthConnectBody =>
      'Для Android нужно приложение Health Connect. Установите или обновите его и вернитесь сюда.';

  @override
  String get activityInstallHealthConnect => 'Установить Health Connect';

  @override
  String get activityRestartNeeded =>
      'Отслеживание активности только что установлено. Полностью закройте приложение и откройте снова, чтобы завершить настройку — горячего перезапуска недостаточно.';

  @override
  String get activityToday => 'Сегодня';

  @override
  String get activityOpenCalendar => 'Календарь';

  @override
  String get activityConnectShort =>
      'Только чтение, данные остаются на телефоне';

  @override
  String get targetsTitle => 'Ваши цели';

  @override
  String get targetsSubtitle =>
      'Откуда берётся каждое число и почему это важно';

  @override
  String get targetsTapHint => 'Откуда эти числа?';

  @override
  String get targetsInputsTitle => 'Рассчитано по данным';

  @override
  String targetsInputsBody(String weight, String height, String age) {
    return 'Вес $weight кг · Рост $height см · Возраст $age';
  }

  @override
  String get targetsInputsNote =>
      'Измените любое из них в профиле, и все цели ниже обновятся.';

  @override
  String get targetBmiTitle => 'Индекс массы тела';

  @override
  String get targetBmiWhat =>
      'Вес, делённый на квадрат роста. Одно число, описывающее их соотношение.';

  @override
  String get targetBmiWhy =>
      'Все остальные цели на этом экране настраиваются по вашему диапазону, поэтому это отправная точка, а не оценка сама по себе.';

  @override
  String get targetBmiBands =>
      'Ниже 18,5 — недостаточный · от 18,5 до 25 — норма · от 25 до 30 — выше нормы · 30 и больше — значительно выше.';

  @override
  String get targetBmiCaveat =>
      'ИМТ не отличает мышцы от жира, поэтому у спортсменов он часто завышен при отличном здоровье. Это ориентир, а не приговор.';

  @override
  String get targetCaloriesTitle => 'Калории в день';

  @override
  String get targetCaloriesWhat =>
      'Оценка того, сколько организм тратит за день при небольшой активности, с поправкой на вашу цель.';

  @override
  String get targetCaloriesWhy =>
      'Такое питание удерживает вес. Поправка намеренно небольшая, чтобы результат был постепенным, а не изнуряющим.';

  @override
  String get targetCaloriesHow =>
      'Рассчитано по формуле Миффлина — Сан Жеора из веса, роста и возраста, умножено на 1,45 за повседневную активность. Приложение не спрашивает пол, поэтому результат усреднён между мужской и женской формулами — погрешность около 80 ккал в обе стороны.';

  @override
  String get targetCaloriesAdjustUnder =>
      'Добавлено 300 ккал для постепенного набора веса.';

  @override
  String get targetCaloriesAdjustHealthy =>
      'Без поправки — это ваш уровень поддержания.';

  @override
  String get targetCaloriesAdjustAbove =>
      'Вычтено 350 ккал для постепенного снижения.';

  @override
  String get targetCaloriesAdjustWellAbove =>
      'Вычтено 500 ккал для устойчивого снижения веса.';

  @override
  String get targetWaterTitle => 'Вода';

  @override
  String get targetWaterWhat =>
      'Примерно 33 мл на каждый килограмм веса — поэтому при большем весе и норма выше.';

  @override
  String get targetWaterWhy =>
      'Даже лёгкая нехватка жидкости проявляется усталостью и головной болью задолго до чувства жажды и искажает некоторые анализы.';

  @override
  String get targetWaterCaveat =>
      'Пейте больше в жару, при нагрузках и во время болезни. Часть жидкости поступает с едой, так что это не только стаканы.';

  @override
  String get targetStepsTitle => 'Шаги';

  @override
  String get targetStepsWhat =>
      'Дневная цель по движению: базовые 8 000 с поправкой на вашу ситуацию.';

  @override
  String get targetStepsWhy =>
      'Регулярная ходьба влияет на давление, сахар и настроение сильнее почти любой другой привычки и не требует инвентаря.';

  @override
  String get targetStepsHow =>
      'Повышена при ИМТ выше нормы, снижена при значительном превышении, чтобы не перегружать суставы в начале, уменьшена после 60 лет и увеличена до 30 лет.';

  @override
  String get targetsClinicianTitle => 'Это не медицинская рекомендация';

  @override
  String get targetsClinicianBody =>
      'Это общие оценки благополучия, рассчитанные на вашем телефоне по трём введённым числам. Они ничего не знают о вашей истории болезни, лекарствах, беременности или состояниях. Обсудите их с врачом, прежде чем что-то менять.';

  @override
  String get statusGood => 'Всё хорошо';

  @override
  String get statusWatch => 'Стоит последить';

  @override
  String get statusAttention => 'Требует внимания';

  @override
  String get statusUnknownBody =>
      'Добавьте свои данные или загрузите анализ, чтобы увидеть картину.';

  @override
  String statusFlagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count показателей на проверку',
      few: '$count показателя на проверку',
      one: '$count показатель на проверку',
    );
    return '$_temp0';
  }

  @override
  String statusAllClear(int count) {
    return 'Все $count показателей в норме';
  }

  @override
  String get statusNoReport => 'Анализов пока нет';

  @override
  String statusBmi(String bmi) {
    return 'ИМТ $bmi';
  }

  @override
  String statusAddDetails(String fields) {
    return 'Добавьте $fields';
  }

  @override
  String get statusTitle => 'Ваше состояние сейчас';

  @override
  String get tabMeds => 'Лекарства';

  @override
  String get medsTitle => 'Лекарства';

  @override
  String medsSubtitlePending(int taken, int total) {
    return 'Принято сегодня: $taken из $total';
  }

  @override
  String get medsSubtitleAllDone => 'На сегодня всё принято';

  @override
  String get medsSubtitleNoneToday => 'На сегодня ничего не запланировано';

  @override
  String get medsEmptyTitle => 'Лекарств пока нет';

  @override
  String get medsEmptyBody =>
      'Добавьте таблетку, витамин или добавку, и приложение напомнит, когда придёт время приёма.';

  @override
  String get medsAdd => 'Добавить лекарство';

  @override
  String get medsEdit => 'Изменить лекарство';

  @override
  String get medsFieldName => 'Название';

  @override
  String get medsFieldNameHint => 'Витамин D, Омепразол…';

  @override
  String get medsFieldCount => 'Сколько за приём';

  @override
  String get medsFieldNotes => 'Заметки (необязательно)';

  @override
  String get medsFieldFrequency => 'Как часто';

  @override
  String get medsFieldTimes => 'Время напоминаний';

  @override
  String get medsAddTime => 'Добавить время';

  @override
  String get medsFieldStart => 'Начало';

  @override
  String get medsFieldEnd => 'Окончание (необязательно)';

  @override
  String get medsNoEnd => 'Без даты окончания';

  @override
  String get medsFrequencyDaily => 'Каждый день';

  @override
  String get medsFrequencyEveryOther => 'Через день';

  @override
  String get medsFrequencyWeekly => 'Раз в неделю';

  @override
  String get medsFrequencyAsNeeded => 'Только при необходимости';

  @override
  String get medsSave => 'Сохранить';

  @override
  String get medsDelete => 'Удалить';

  @override
  String get medsDeleteTitle => 'Удалить это лекарство?';

  @override
  String medsDeleteBody(String name) {
    return '$name и его напоминания будут удалены.';
  }

  @override
  String get medsStateOverdue => 'Пропущено';

  @override
  String get medsStateUpcoming => 'Предстоит';

  @override
  String get medsStateDone => 'Принято';

  @override
  String get medsStateInactive => 'Не сегодня';

  @override
  String medsDoseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count таблеток',
      few: '$count таблетки',
      one: '$count таблетка',
    );
    return '$_temp0';
  }

  @override
  String medsTakenOf(int taken, int total) {
    return '$taken/$total';
  }

  @override
  String medsNextDose(String time) {
    return 'Следующий приём в $time';
  }

  @override
  String medsNextOn(String date) {
    return 'Следующий приём $date';
  }

  @override
  String get medsAsNeededHint =>
      'Принимается при необходимости — без напоминаний';

  @override
  String get medsMarkTaken => 'Отметить как принятое';

  @override
  String get medsUndo => 'Отменить';

  @override
  String get medsNeedsName => 'Укажите название лекарства.';

  @override
  String get medsNeedsTime => 'Добавьте хотя бы одно время напоминания.';

  @override
  String get medsNotificationsOffTitle => 'Напоминания выключены';

  @override
  String get medsNotificationsOffBody =>
      'Разрешите уведомления, чтобы приложение напоминало о приёме.';

  @override
  String get medsEnableNotifications => 'Разрешить уведомления';

  @override
  String get medsStateDueNow => 'Пора принять';

  @override
  String get doseTimeTitle => 'Время напоминания';

  @override
  String get doseTimeQuick => 'Частые варианты';

  @override
  String get doseTimeMorning => 'Утро';

  @override
  String get doseTimeMidday => 'День';

  @override
  String get doseTimeEvening => 'Вечер';

  @override
  String get doseTimeNight => 'Ночь';

  @override
  String get doseTimeSet => 'Выбрать время';

  @override
  String get doseTimeAlready => 'Это время уже добавлено.';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';
}
