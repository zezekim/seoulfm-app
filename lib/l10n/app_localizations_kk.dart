// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Басты бет';

  @override
  String get tabRequest => 'Тапсырыс';

  @override
  String get tabCharts => 'Чарттар';

  @override
  String get tabWall => 'Арнаулар';

  @override
  String get tabMore => 'Тағы';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Эфирден тыс';

  @override
  String get stationBreak => 'Станция қысқа үзілісте. Жақында ораламыз.';

  @override
  String get nowPlaying => 'Қазір эфирде';

  @override
  String get upNext => 'Келесі';

  @override
  String get stations => 'Станциялар';

  @override
  String get recentlyPlayed => 'Жақында ойнағандар';

  @override
  String get requestASong => 'Әнге тапсырыс беру';

  @override
  String get requestHint => 'Әнді таңда — ол бәріне тікелей эфирде ойнайды.';

  @override
  String get searchHint => 'Әндер, орындаушылар, альбомдар';

  @override
  String searchEmpty(String query) {
    return '«$query» бойынша ештеңе табылмады';
  }

  @override
  String get searchIntro =>
      'Кітапханадан ізде, ән мәтінін оқы және тікелей эфирде ойнауы үшін тапсырыс бер.';

  @override
  String get newSongs => 'SeoulFM-дегі жаңа әндер';

  @override
  String get songs => 'Әндер';

  @override
  String get artists => 'Орындаушылар';

  @override
  String get play => 'Ойнату';

  @override
  String get pause => 'Кідірту';

  @override
  String get request => 'Тапсырыс';

  @override
  String get requestTitle => 'Осы әнге тапсырыс беру';

  @override
  String get yourName => 'Атың (міндетті емес)';

  @override
  String get dedication => 'Арнау мәтіні (міндетті емес)';

  @override
  String get sendRequest => 'Тапсырысты жіберу';

  @override
  String get verifying => 'Адам екеніңді тексеріп жатырмыз…';

  @override
  String get requestAccepted => 'Тапсырыс берілді!';

  @override
  String etaMinutes(int minutes) {
    return 'Шамамен $minutes минуттан кейін ойнайды';
  }

  @override
  String get etaSoon => 'Жақында ойнайды';

  @override
  String requestQueued(String title) {
    return '«$title» кезекте тұр';
  }

  @override
  String requestScheduled(String title) {
    return '«$title» келесі болып ойнайды';
  }

  @override
  String requestPlayed(String title) {
    return '«$title» қазір эфирде';
  }

  @override
  String requestExpired(String title) {
    return '«$title» бұл жолы эфирге шықпады';
  }

  @override
  String get notRequestable => 'Қазір тапсырыс беруге болмайды';

  @override
  String get errorGeneric => 'Бірдеңе дұрыс болмады. Қайта байқап көр.';

  @override
  String get offline => 'SeoulFM-ге қосылу мүмкін болмады. Байланысты тексер.';

  @override
  String get retry => 'Қайта байқау';

  @override
  String get chartsWeekly => 'Осы апта';

  @override
  String get chartsHot => 'Қазір хит';

  @override
  String get chartsRequested => 'Ең көп сұралған';

  @override
  String get chartsTrending => 'Трендте';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ойнату',
      one: '$count ойнату',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тапсырыс',
      one: '$count тапсырыс',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'ЖАҢА';

  @override
  String get dedicationsEmpty =>
      'Әзірге арнау жоқ. Әнге тапсырыс беріп, арнау қос.';

  @override
  String dedicatedBy(String name) {
    return 'Арнаған: $name';
  }

  @override
  String get lyrics => 'Ән мәтіні';

  @override
  String get lyricsNone => 'Бұл әннің мәтіні әзірге жоқ.';

  @override
  String get share => 'Бөлісу';

  @override
  String shareSong(String title, String artist) {
    return '«$title» — $artist, SeoulFM тікелей эфирінде';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: тәулік бойы тегін K-pop радиосы';
  }

  @override
  String get close => 'Жабу';

  @override
  String get startListeningToRate => 'Бағалау үшін тыңдауды баста';

  @override
  String get like => 'Бұл ән ұнайды';

  @override
  String get dislike => 'Маған емес';

  @override
  String get hot => 'Хит';

  @override
  String get topTracks => 'Топ әндер';

  @override
  String get albums => 'Альбомдар';

  @override
  String get related => 'Саған ұнауы мүмкін';

  @override
  String get settings => 'Баптаулар';

  @override
  String get theme => 'Тақырып';

  @override
  String get themeSystem => 'Жүйелік';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get themeLight => 'Жарық';

  @override
  String get sleepTimer => 'Ұйқы таймері';

  @override
  String get sleepOff => 'Өшірулі';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String sleepStopsIn(int minutes) {
    return '$minutes минуттан кейін тоқтайды';
  }

  @override
  String get inTheCar => 'Көлікте';

  @override
  String get carBody =>
      'SeoulFM Android Auto-мен жұмыс істейді. Телефоныңды қосып, көлік экранынан станцияны таңда; рульдегі ауыстыру түймелері станцияны ауыстырады.';

  @override
  String get about => 'SeoulFM туралы';

  @override
  String get aboutBody =>
      'SeoulFM — тәулік бойы тегін K-pop радиосы және корей музыкасы стриминг платформасы: он екі тікелей станция және іздеп, тапсырыс беруге болатын, күн сайын толығып отыратын ән кітапханасы, әр әннің мәтіні бар. Тапсырыс берілген ән бәріне тікелей эфирде ойнайды. 2009 жылдан бері эфирде, әрқашан тегін.';

  @override
  String get website => 'Веб-сайт';

  @override
  String get privacy => 'Құпиялылық';

  @override
  String get terms => 'Шарттар';

  @override
  String get contact => 'Байланыс';

  @override
  String version(String version) {
    return 'Нұсқа $version';
  }

  @override
  String get losslessTitle => 'Шығынсыз FLAC';

  @override
  String losslessUses(int mb) {
    return 'Сағатына шамамен $mb МБ';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Қалыпты сапа: сағатына шамамен $mb МБ';
  }

  @override
  String get losslessFallbackNotice =>
      'Шығынсыз дыбыс қалыпты эфирден әлдеқайда көп трафик жұмсайды. Wi-Fi не шексіз тарифті қолдан.';

  @override
  String get losslessAccept => 'Шығынсыз ойнату';

  @override
  String get losslessDecline => 'Қалыпты сапаны қолдану';

  @override
  String get losslessFailed =>
      'Шығынсыз сапа ойнамай тұр, сондықтан қалыпты сапа қосылды.';

  @override
  String get retryFlac => 'FLAC-ты қайта қосу';

  @override
  String get marathonOnAir => 'Осы сағатта эфирде';

  @override
  String get marathonQueue => 'Кезекте';

  @override
  String get marathonNominations => 'Дауыс бер';

  @override
  String get marathonVote => 'Дауыс беру';

  @override
  String marathonVotes(int votes, int required) {
    return 'Дауыс: $votes / $required';
  }

  @override
  String get marathonNominate => 'Орындаушыны ұсыну';

  @override
  String get marathonNominateHint => 'Орындаушы іздеу';

  @override
  String get marathonVoted => 'Дауыс есептелді';

  @override
  String get marathonEmpty =>
      'Ашық ұсыныс жоқ. Келесі бос сағатқа орындаушы ұсын.';

  @override
  String get marathonVotedIn => 'Дауыспен өтті';

  @override
  String get marathonIntro =>
      'Бір топ, толық бір сағат. Келесі бос сағатты алуы үшін орындаушыға дауыс бер.';

  @override
  String get seeAll => 'Барлығын көру';

  @override
  String get justNow => 'жаңа ғана';

  @override
  String minutesAgo(int n) {
    return '$n мин бұрын';
  }

  @override
  String hoursAgo(int n) {
    return '$n сағ бұрын';
  }

  @override
  String inMinutes(int n) {
    return '$n минуттан кейін';
  }

  @override
  String get requestBadge => 'Тапсырыс';

  @override
  String get artistPage => 'Орындаушы парағы';

  @override
  String get openSong => 'Ән парағы';

  @override
  String get nextStation => 'Келесі станция';

  @override
  String get previousStation => 'Алдыңғы станция';

  @override
  String get quality => 'Сапа';

  @override
  String get qualityAuto => 'Авто';

  @override
  String get comingSoon => 'Жақында';

  @override
  String get captchaFailed => 'Тексеруден өтпеді. Қайта байқап көр.';

  @override
  String get goodMorning => 'Қайырлы таң';

  @override
  String get goodAfternoon => 'Қайырлы күн';

  @override
  String get goodEvening => 'Қайырлы кеш';

  @override
  String get featuredStations => 'Таңдаулы станциялар';

  @override
  String get genresAndEras => 'Жанрлар мен дәуірлер';

  @override
  String get playingFrom => 'Ойнап тұрған станция';

  @override
  String get chooseStation => 'Станцияңды таңда';

  @override
  String get listenNow => 'Қазір тыңдау';

  @override
  String get showLyrics => 'Ән мәтінін көрсету';

  @override
  String get shareCardSong => 'Ән';

  @override
  String get editLyrics => 'Жолдарды таңдау';

  @override
  String get copyLink => 'Сілтемені көшіру';

  @override
  String get linkCopied => 'Көшірілді';

  @override
  String get shareImage => 'Суретпен бөлісу';

  @override
  String get done => 'Дайын';

  @override
  String pickLines(int count) {
    return '$count жолға дейін таңда';
  }

  @override
  String get goToSong => 'Әнге өту';

  @override
  String get goToArtist => 'Орындаушыға өту';

  @override
  String get swipeToRequest => 'Тапсырыс';

  @override
  String get offlineTitle => 'Интернет жоқ';

  @override
  String get serverErrorTitle => 'Бірдеңе дұрыс болмады';

  @override
  String get noResultsTitle => 'Ештеңе табылмады';

  @override
  String get noResultsBody =>
      'Басқаша жазып көр, ағылшынша не корейше атауын немесе орындаушының атын енгіз.';

  @override
  String get wallEmptyTitle => 'Әзірге арнау жоқ';

  @override
  String get requestTrackerQueued => 'Сенің тапсырысың · кезекте';

  @override
  String requestTrackerEta(int minutes) {
    return 'Сенің тапсырысың · ~$minutes минуттан кейін ойнайды';
  }

  @override
  String get requestTrackerNext => 'Сенің тапсырысың келесі ойнайды';

  @override
  String get requestTrackerPlaying => 'Сенің тапсырысың қазір ойнап тұр!';

  @override
  String get welcomeTitle => 'K-pop радиосы: тікелей және тегін';

  @override
  String get welcomeBody =>
      'Он екі станция, тәулік бойы, ән мәтіні бар, күн сайын толығып отыратын ән кітапханасы. Әнге тапсырыс бер — ол бәріне тікелей эфирде ойнайды.';

  @override
  String get continueLabel => 'Жалғастыру';

  @override
  String get pickStationsTitle => 'Станцияларыңды таңда';

  @override
  String get pickStationsBody =>
      'Оларды алдыңғы қатарда ұстаймыз. Кез келген уақытта өзгерте аласың.';

  @override
  String get requestsTitle => 'Келесі не ойнайтынын сен таңдайсың';

  @override
  String get requestsBody =>
      'Кез келген әнді тауып, тапсырыс бер. Ол ойнағанда тыңдап отырғандардың бәрі оны естиді — әрі сенің арнауыңды көреді.';

  @override
  String get startListening => 'Тыңдауды бастау';

  @override
  String get skip => 'Өткізу';

  @override
  String get yourStations => 'Сенің станцияларың';

  @override
  String get support => 'Қолдау';

  @override
  String get supportEyebrow => 'Тыңдармандардың қолдауымен';

  @override
  String get supportH1 => 'Жарнамасыз. Ақылы жазылымсыз.';

  @override
  String get supportH1Sub => 'Эфирді тыңдайтын адамдар ұстап тұр.';

  @override
  String get supportLead =>
      'SeoulFM тегін және солай қала береді. Саған сататын ештеңеміз жоқ, сені біреуге сатып та жатпаймыз. Егер станция күнделікті өміріңнің бір бөлігі болса, оның жұмысын жалғастыруға көмектесе аласың.';

  @override
  String get supportWhereItGoes => 'Қаражат неге жұмсалады';

  @override
  String get supportCostStreamTitle => 'Эфир';

  @override
  String get supportCostStreamBody =>
      'Он екі арна, күн сайын әр сағат эфирде, бүкіл әлемге таратылады. HIFI-дағы шығынсыз дыбыс — біз жіберетін ең қымбат нәрсе, және біз оны тегін жібереміз.';

  @override
  String get supportCostLibraryTitle => 'Кітапхана';

  @override
  String get supportCostLibraryBody =>
      'Он мыңдаған ән — сақталған, белгіленген және ретке келтірілген, әрқайсысында мұқаба, синхрондалған ән мәтіні және эфирлік деңгейдегі өңдеу бар.';

  @override
  String get supportCostWorkTitle => 'Жұмыс';

  @override
  String get supportCostWorkBody =>
      'Сайт, қосымшалар, тапсырыстар, қабырға мен чат, сондай-ақ музыкалық лицензиялаудың тұрақты шығыны. Мұның бәрін өте шағын команда жасап, жүргізеді.';

  @override
  String get supportStaysTheSame => 'Не өзгермейді';

  @override
  String get supportPromiseNoAds =>
      'Аудиожарнама да, баннер де жоқ. Қазір де, кейін де.';

  @override
  String get supportPromiseNothingLocked =>
      'Ештеңе жабық емес. Әр арна, тапсырыс және мүмкіндік бәріне тегін болып қала береді.';

  @override
  String get supportPromiseOptional =>
      'Қолдау көрсету — өз еркің, ол тыңдау тәсіліңе ешқандай әсер етпейді.';

  @override
  String get supportBecome => 'Қолдаушы бол';

  @override
  String get supportBecomeBody =>
      'Бір рет немесе ай сайын. Төлемдер App Store не Google Play арқылы өтеді; біз карта деректеріңді ешқашан көрмейміз.';

  @override
  String get supportMonthly => 'Ай сайынғы қолдаушы';

  @override
  String get supportMonthlyBody =>
      'Бір арнаны ай сайын эфирде ұстап тұр. Кез келген уақытта тоқтата аласың.';

  @override
  String supportPerMonth(String price) {
    return '$price / ай';
  }

  @override
  String get supportOnce => 'Бір реттік қолдау';

  @override
  String get supportTipSmall => 'Бір кесе кофе';

  @override
  String get supportTipMedium => 'Бір түскі ас';

  @override
  String get supportTipLarge => 'Бір кешкі серуен';

  @override
  String get supportRestore => 'Сатып алуларды қалпына келтіру';

  @override
  String get supportUnavailable =>
      'Дүкен арқылы қолдау қазір қолжетімсіз. Кейінірек қайта байқап көр.';

  @override
  String get supportThanksTitle => 'Рақмет';

  @override
  String get supportThanksBody =>
      'Сен SeoulFM-нің бәріне тегін болып қалуына көмектесіп жатырсың.';

  @override
  String get supportYouAreSupporter => 'Сен — қолдаушысың. Рақмет.';

  @override
  String get supportFreeWays =>
      'Ақшалай көмектесу мүмкіндігің жоқ па? Тыңдаудың өзі маңызды. Сол сияқты әнге тапсырыс беру, қабырғаға жазба қалдыру немесе станцияны оны жақсы көретін бір досыңа жіберу де көмек.';

  @override
  String get supportCardTitle => 'SeoulFM тегін болып қалсын';

  @override
  String get supportCardBody =>
      'Жарнамасыз, ақылы жазылымсыз — эфирді сен сияқты тыңдармандар ұстап тұр.';

  @override
  String get supportSubscriptionTerms =>
      'Ай сайынғы қолдау дүкендегі аккаунт баптауларынан тоқтатқанша автоматты түрде жаңарып отырады.';

  @override
  String get language => 'Тіл';

  @override
  String get languageSystem => 'Жүйе тілін қолдану';

  @override
  String get qualityAutoBody =>
      'Байланысың көтеретін ең жақсы сапа. Нашарласа, төмендейді.';

  @override
  String get qualityVeryHigh => 'Өте жоғары';

  @override
  String get qualityHigh => 'Жоғары';

  @override
  String get qualityNormal => 'Қалыпты';

  @override
  String get qualityDataSaver => 'Трафикті үнемдеу';

  @override
  String get qualityFixedBody => 'Байланыс әлсіз болса да, әрқашан осы сапа.';

  @override
  String get qualityLosslessNote =>
      'Ескертуін қабылдасаң, HIFI шығынсыз FLAC форматында ойнайды.';

  @override
  String get moreOptions => 'Қосымша опциялар';

  @override
  String get reportDedication => 'Шағымдану';

  @override
  String hideDedicationsFrom(String name) {
    return '$name арнауларын жасыру';
  }

  @override
  String get reportThanks => 'Хабарлағаның үшін рахмет. Қарап шығамыз.';

  @override
  String get showHiddenDedications => 'Жасырылған арнауларды көрсету';

  @override
  String get verifyFailed =>
      'Тексеруден өтпеді. Байланысты тексеріп, қайта байқап көр.';

  @override
  String get restoreDone => 'Сатып алуларың қалпына келтірілді.';

  @override
  String get restoreNothing => 'Қалпына келтіретін сатып алу жоқ.';

  @override
  String get playbackFailed =>
      'Эфирге қосылу мүмкін болмады. Байланысты тексеріп, қайта байқап көр.';

  @override
  String get audioOutput => 'Дыбыс шығысы';

  @override
  String get openPlayer => 'Ойнатқышты ашу';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ән',
      one: '$count ән',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Станциялар';

  @override
  String get spatialAudioBody =>
      'SeoulFM құлаққапқа арналған BS2B (Bauer stereophonic-to-binaural) кроссфидпен араластырылған. Бөлмедегі динамиктердегідей, әр арнаның дыбысы екінші құлаққа да сәл жетеді, сондықтан дыбыс кеңірек, табиғирақ естіледі және сағаттап тыңдағанда құлақ шаршамайды.';

  @override
  String get requestNotificationChannel => 'Your requests';

  @override
  String get requestNotificationChannelDescription =>
      'Tells you when a song you requested is coming up and when it’s on air.';

  @override
  String get yourSongs => 'Your songs';

  @override
  String get favourite => 'Favourite';

  @override
  String get saveToYourSongs => 'Save to Your songs';

  @override
  String get removeFromYourSongs => 'Remove from Your songs';

  @override
  String get savedToYourSongs => 'Saved to Your songs';

  @override
  String get removedFromYourSongs => 'Removed from Your songs';

  @override
  String get view => 'View';

  @override
  String get undo => 'Undo';

  @override
  String get yourSongsEmptyTitle => 'Keep the songs you love';

  @override
  String get yourSongsEmptyBody =>
      'Tap the heart on the player or on a song’s page, or choose Save to Your songs in a song’s menu. They stay on this phone, no account needed.';

  @override
  String get requestFromYourSongs => 'Request one of them';
}
