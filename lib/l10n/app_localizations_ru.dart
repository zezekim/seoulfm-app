// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabRequest => 'Заказ';

  @override
  String get tabCharts => 'Чарты';

  @override
  String get tabWall => 'Посвящения';

  @override
  String get tabMore => 'Ещё';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Не в эфире';

  @override
  String get stationBreak => 'У станции небольшой перерыв. Скоро вернёмся.';

  @override
  String get nowPlaying => 'Сейчас в эфире';

  @override
  String get upNext => 'Далее';

  @override
  String get stations => 'Станции';

  @override
  String get recentlyPlayed => 'Недавно звучали';

  @override
  String get requestASong => 'Заказать песню';

  @override
  String get requestHint =>
      'Выбери песню — и она прозвучит в прямом эфире для всех.';

  @override
  String get searchHint => 'Песни, исполнители, альбомы';

  @override
  String searchEmpty(String query) {
    return 'Ничего не найдено по запросу «$query»';
  }

  @override
  String get searchIntro =>
      'Ищи в библиотеке, читай тексты и заказывай песни в прямой эфир.';

  @override
  String get newSongs => 'Новое на SeoulFM';

  @override
  String get songs => 'Песни';

  @override
  String get artists => 'Исполнители';

  @override
  String get play => 'Слушать';

  @override
  String get pause => 'Пауза';

  @override
  String get request => 'Заказать';

  @override
  String get requestTitle => 'Заказать эту песню';

  @override
  String get yourName => 'Твоё имя (необязательно)';

  @override
  String get dedication => 'Посвящение (необязательно)';

  @override
  String get sendRequest => 'Отправить заявку';

  @override
  String get verifying => 'Проверяем, что ты не робот…';

  @override
  String get requestAccepted => 'Заявка принята!';

  @override
  String etaMinutes(int minutes) {
    return 'Прозвучит примерно через $minutes мин';
  }

  @override
  String get etaSoon => 'Скоро прозвучит';

  @override
  String requestQueued(String title) {
    return '«$title» в очереди';
  }

  @override
  String requestScheduled(String title) {
    return '«$title» скоро прозвучит';
  }

  @override
  String requestPlayed(String title) {
    return '«$title» сейчас в эфире';
  }

  @override
  String requestExpired(String title) {
    return 'В этот раз «$title» не удалось поставить в эфир';
  }

  @override
  String get notRequestable => 'Сейчас нельзя заказать';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуй ещё раз.';

  @override
  String get offline =>
      'Не удаётся подключиться к SeoulFM. Проверь соединение.';

  @override
  String get retry => 'Повторить';

  @override
  String get chartsWeekly => 'Эта неделя';

  @override
  String get chartsHot => 'Горячее';

  @override
  String get chartsRequested => 'Самые заказываемые';

  @override
  String get chartsTrending => 'В тренде';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count эфира',
      many: '$count эфиров',
      few: '$count эфира',
      one: '$count эфир',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заявки',
      many: '$count заявок',
      few: '$count заявки',
      one: '$count заявка',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NEW';

  @override
  String get dedicationsEmpty =>
      'Посвящений пока нет. Закажи песню и добавь своё.';

  @override
  String dedicatedBy(String name) {
    return 'Посвящение от: $name';
  }

  @override
  String get lyrics => 'Текст';

  @override
  String get lyricsNone => 'Текста этой песни пока нет.';

  @override
  String get share => 'Поделиться';

  @override
  String shareSong(String title, String artist) {
    return '«$title» — $artist, в прямом эфире SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: бесплатное K-pop радио 24/7';
  }

  @override
  String get close => 'Закрыть';

  @override
  String get startListeningToRate => 'Начни слушать, чтобы оценить';

  @override
  String get like => 'Мне нравится';

  @override
  String get dislike => 'Не моё';

  @override
  String get hot => 'Хит';

  @override
  String get topTracks => 'Лучшие песни';

  @override
  String get albums => 'Альбомы';

  @override
  String get related => 'Тебе может понравиться';

  @override
  String get settings => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get sleepTimer => 'Таймер сна';

  @override
  String get sleepOff => 'Выкл.';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Выключится через $minutes мин';
  }

  @override
  String get inTheCar => 'В машине';

  @override
  String get carBody =>
      'SeoulFM работает с Android Auto. Подключи телефон и выбери станцию на экране автомобиля; кнопки переключения треков на руле меняют станцию.';

  @override
  String get about => 'О SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM — бесплатное K-pop радио 24/7 и платформа для стриминга корейской музыки: двенадцать станций в прямом эфире и ежедневно пополняемая библиотека песен с текстами, которые можно искать и заказывать. Заказанная песня звучит в прямом эфире для всех. В эфире с 2009 года, всегда бесплатно.';

  @override
  String get website => 'Сайт';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get terms => 'Условия использования';

  @override
  String get contact => 'Контакты';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get losslessTitle => 'FLAC без потерь';

  @override
  String losslessUses(int mb) {
    return 'Около $mb МБ в час';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Обычное качество: около $mb МБ в час';
  }

  @override
  String get losslessFallbackNotice =>
      'Звук без потерь расходует намного больше трафика, чем обычный поток. Слушай через Wi-Fi или на безлимитном тарифе.';

  @override
  String get losslessAccept => 'Слушать без потерь';

  @override
  String get losslessDecline => 'Обычное качество';

  @override
  String get losslessFailed =>
      'Звук без потерь не воспроизводится, поэтому включено обычное качество.';

  @override
  String get retryFlac => 'Снова FLAC';

  @override
  String get marathonOnAir => 'В эфире в этот час';

  @override
  String get marathonQueue => 'Скоро в эфире';

  @override
  String get marathonNominations => 'Голосуй за них';

  @override
  String get marathonVote => 'Голосовать';

  @override
  String marathonVotes(int votes, int required) {
    return 'Голосов: $votes из $required';
  }

  @override
  String get marathonNominate => 'Номинировать исполнителя';

  @override
  String get marathonNominateHint => 'Искать исполнителей';

  @override
  String get marathonVoted => 'Голос учтён';

  @override
  String get marathonEmpty =>
      'Открытых номинаций нет. Номинируй исполнителя на следующий свободный час.';

  @override
  String get marathonVotedIn => 'Выбран голосованием';

  @override
  String get marathonIntro =>
      'Одна группа, целый час. Проголосуй за исполнителя на следующий свободный час.';

  @override
  String get seeAll => 'Показать все';

  @override
  String get justNow => 'только что';

  @override
  String minutesAgo(int n) {
    return '$n мин назад';
  }

  @override
  String hoursAgo(int n) {
    return '$n ч назад';
  }

  @override
  String inMinutes(int n) {
    return 'через $n мин';
  }

  @override
  String get requestBadge => 'Заявка';

  @override
  String get artistPage => 'Страница исполнителя';

  @override
  String get openSong => 'Страница песни';

  @override
  String get nextStation => 'Следующая станция';

  @override
  String get previousStation => 'Предыдущая станция';

  @override
  String get quality => 'Качество';

  @override
  String get qualityAuto => 'Авто';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get captchaFailed => 'Не удалось пройти проверку. Попробуй ещё раз.';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get featuredStations => 'Избранные станции';

  @override
  String get genresAndEras => 'Жанры и эпохи';

  @override
  String get playingFrom => 'Сейчас играет станция';

  @override
  String get chooseStation => 'Выбери станцию';

  @override
  String get listenNow => 'Слушать';

  @override
  String get showLyrics => 'Показать текст';

  @override
  String get shareCardSong => 'Песня';

  @override
  String get editLyrics => 'Выбрать строки';

  @override
  String get copyLink => 'Скопировать ссылку';

  @override
  String get linkCopied => 'Скопировано';

  @override
  String get shareImage => 'Поделиться картинкой';

  @override
  String get done => 'Готово';

  @override
  String pickLines(int count) {
    return 'Выбери строки (максимум $count)';
  }

  @override
  String get goToSong => 'Перейти к песне';

  @override
  String get goToArtist => 'Перейти к исполнителю';

  @override
  String get swipeToRequest => 'Заказать';

  @override
  String get offlineTitle => 'Нет подключения';

  @override
  String get serverErrorTitle => 'Что-то пошло не так';

  @override
  String get noResultsTitle => 'Ничего не найдено';

  @override
  String get noResultsBody =>
      'Попробуй другое написание, английское или корейское название или имя исполнителя.';

  @override
  String get wallEmptyTitle => 'Посвящений пока нет';

  @override
  String get requestTrackerQueued => 'Твоя заявка · в очереди';

  @override
  String requestTrackerEta(int minutes) {
    return 'Твоя заявка · прозвучит через ~$minutes мин';
  }

  @override
  String get requestTrackerNext => 'Твоя заявка — следующая';

  @override
  String get requestTrackerPlaying => 'Твоя заявка уже в эфире!';

  @override
  String get welcomeTitle => 'K-pop радио — в прямом эфире и бесплатно';

  @override
  String get welcomeBody =>
      'Двенадцать станций 24/7 и библиотека песен с текстами, которая пополняется каждый день. Закажи песню — и она прозвучит в прямом эфире для всех.';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get pickStationsTitle => 'Выбери свои станции';

  @override
  String get pickStationsBody =>
      'Мы покажем их первыми. Изменить можно в любой момент.';

  @override
  String get requestsTitle => 'Ты выбираешь, что сыграет следующим';

  @override
  String get requestsBody =>
      'Найди любую песню и закажи её. Когда она зазвучит, её услышат все слушатели — и увидят твоё посвящение.';

  @override
  String get startListening => 'Начать слушать';

  @override
  String get skip => 'Пропустить';

  @override
  String get yourStations => 'Твои станции';

  @override
  String get support => 'Поддержать';

  @override
  String get supportEyebrow => 'На поддержке слушателей';

  @override
  String get supportH1 => 'Без рекламы. Без платного доступа.';

  @override
  String get supportH1Sub => 'В эфире благодаря тем, кто слушает.';

  @override
  String get supportLead =>
      'SeoulFM бесплатный и таким останется. Нам нечего тебе продать, и тебя мы никому не продаём. Если станция — часть твоего дня, ты можешь помочь ей работать дальше.';

  @override
  String get supportWhereItGoes => 'На что идут деньги';

  @override
  String get supportCostStreamTitle => 'Трансляция';

  @override
  String get supportCostStreamBody =>
      'Двенадцать станций в эфире каждый час каждого дня, по всему миру. Звук без потерь на HIFI — самое дорогое, что мы передаём, и мы передаём его бесплатно.';

  @override
  String get supportCostLibraryTitle => 'Библиотека';

  @override
  String get supportCostLibraryBody =>
      'Десятки тысяч треков: хранятся, размечены и упорядочены, у каждого — обложка, синхронизированный текст и обработка эфирного качества.';

  @override
  String get supportCostWorkTitle => 'Работа';

  @override
  String get supportCostWorkBody =>
      'Сайт, приложения, заявки, стена и чат, плюс постоянные расходы на лицензирование музыки. Всё это создаёт и поддерживает очень маленькая команда.';

  @override
  String get supportStaysTheSame => 'Что не изменится';

  @override
  String get supportPromiseNoAds =>
      'Никакой аудиорекламы и баннеров. Ни сейчас, ни потом.';

  @override
  String get supportPromiseNothingLocked =>
      'Ничего не закрыто. Все станции, заявки и функции остаются бесплатными для всех.';

  @override
  String get supportPromiseOptional =>
      'Поддержка — по желанию, и она никак не меняет то, как ты слушаешь.';

  @override
  String get supportBecome => 'Поддержи SeoulFM';

  @override
  String get supportBecomeBody =>
      'Разово или ежемесячно. Платежи проходят через App Store или Google Play; данные твоей карты мы никогда не видим.';

  @override
  String get supportMonthly => 'Ежемесячная поддержка';

  @override
  String get supportMonthlyBody =>
      'Помогай держать станцию в эфире каждый месяц. Отменить можно в любой момент.';

  @override
  String supportPerMonth(String price) {
    return '$price / мес.';
  }

  @override
  String get supportOnce => 'Разовая поддержка';

  @override
  String get supportTipSmall => 'Чашка кофе';

  @override
  String get supportTipMedium => 'Обед';

  @override
  String get supportTipLarge => 'Вечер в городе';

  @override
  String get supportRestore => 'Восстановить покупки';

  @override
  String get supportUnavailable =>
      'Поддержка через магазин приложений сейчас недоступна. Попробуй позже.';

  @override
  String get supportThanksTitle => 'Спасибо';

  @override
  String get supportThanksBody =>
      'Ты помогаешь SeoulFM оставаться бесплатным для всех.';

  @override
  String get supportYouAreSupporter => 'Ты поддерживаешь SeoulFM. Спасибо!';

  @override
  String get supportFreeWays =>
      'Нет возможности помочь деньгами? Слушать — это уже помощь. Как и заказать песню, оставить запись на стене или отправить станцию другу, которому она понравится.';

  @override
  String get supportCardTitle => 'Помоги SeoulFM остаться бесплатным';

  @override
  String get supportCardBody =>
      'Без рекламы и подписки — в эфире благодаря таким слушателям, как ты.';

  @override
  String get supportSubscriptionTerms =>
      'Ежемесячная поддержка продлевается автоматически, пока ты не отменишь её в настройках аккаунта магазина приложений.';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get qualityAutoBody =>
      'Лучшее, что выдержит соединение. Снижается, если связь слабеет.';

  @override
  String get qualityVeryHigh => 'Очень высокое';

  @override
  String get qualityHigh => 'Высокое';

  @override
  String get qualityNormal => 'Обычное';

  @override
  String get qualityDataSaver => 'Экономия трафика';

  @override
  String get qualityFixedBody =>
      'Всегда это качество, даже при слабом соединении.';

  @override
  String get qualityLosslessNote =>
      'HIFI звучит в FLAC без потерь, когда ты принимаешь его уведомление.';

  @override
  String get moreOptions => 'Ещё';

  @override
  String get reportDedication => 'Пожаловаться';

  @override
  String hideDedicationsFrom(String name) {
    return 'Скрыть посвящения от $name';
  }

  @override
  String get reportThanks => 'Спасибо, что дал знать. Мы разберёмся.';

  @override
  String get showHiddenDedications => 'Показать скрытые посвящения';

  @override
  String get verifyFailed =>
      'Не удалось пройти проверку. Проверь соединение и попробуй ещё раз.';

  @override
  String get restoreDone => 'Покупки восстановлены.';

  @override
  String get restoreNothing => 'Нет покупок для восстановления.';

  @override
  String get playbackFailed =>
      'Не удаётся подключиться к трансляции. Проверь соединение и попробуй ещё раз.';

  @override
  String get audioOutput => 'Вывод звука';

  @override
  String get openPlayer => 'Открыть плеер';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count песни',
      many: '$count песен',
      few: '$count песни',
      one: '$count песня',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Станции';
}
