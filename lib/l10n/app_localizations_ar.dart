// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabRequest => 'اطلب';

  @override
  String get tabCharts => 'الترتيب';

  @override
  String get tabWall => 'الإهداءات';

  @override
  String get tabMore => 'المزيد';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'خارج البث';

  @override
  String get stationBreak => 'المحطة في استراحة قصيرة. سنعود قريبًا.';

  @override
  String get nowPlaying => 'يُذاع الآن';

  @override
  String get upNext => 'التالي';

  @override
  String get stations => 'المحطات';

  @override
  String get recentlyPlayed => 'أُذيع مؤخرًا';

  @override
  String get requestASong => 'اطلب أغنية';

  @override
  String get requestHint => 'اختر أغنية لتُذاع مباشرة للجميع.';

  @override
  String get searchHint => 'أغانٍ، فنانون، ألبومات';

  @override
  String searchEmpty(String query) {
    return 'لا نتائج لـ«⁨$query⁩»';
  }

  @override
  String get searchIntro =>
      'ابحث في المكتبة، واقرأ كلمات الأغاني، واطلب أغنية لتُذاع مباشرة.';

  @override
  String get newSongs => 'جديد SeoulFM';

  @override
  String get songs => 'الأغاني';

  @override
  String get artists => 'الفنانون';

  @override
  String get play => 'تشغيل';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get request => 'اطلب';

  @override
  String get requestTitle => 'اطلب هذه الأغنية';

  @override
  String get yourName => 'اسمك (اختياري)';

  @override
  String get dedication => 'رسالة الإهداء (اختيارية)';

  @override
  String get sendRequest => 'أرسل الطلب';

  @override
  String get verifying => 'جارٍ التحقق من أنك لست روبوتًا…';

  @override
  String get requestAccepted => 'تم الطلب!';

  @override
  String etaMinutes(int minutes) {
    return 'تُذاع خلال ⁨$minutes⁩ د تقريبًا';
  }

  @override
  String get etaSoon => 'تُذاع قريبًا';

  @override
  String requestQueued(String title) {
    return '«⁨$title⁩» في قائمة الانتظار';
  }

  @override
  String requestScheduled(String title) {
    return '«⁨$title⁩» ستُذاع قريبًا';
  }

  @override
  String requestPlayed(String title) {
    return '«⁨$title⁩» على الهواء الآن';
  }

  @override
  String requestExpired(String title) {
    return 'تعذّرت إذاعة «⁨$title⁩» هذه المرة';
  }

  @override
  String get notRequestable => 'غير متاحة للطلب الآن';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get offline => 'تعذّر الوصول إلى SeoulFM. تحقّق من اتصالك.';

  @override
  String get retry => 'حاول مجددًا';

  @override
  String get chartsWeekly => 'هذا الأسبوع';

  @override
  String get chartsHot => 'رائج الآن';

  @override
  String get chartsRequested => 'الأكثر طلبًا';

  @override
  String get chartsTrending => 'الصاعد';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرة تشغيل',
      many: '$count مرة تشغيل',
      few: '$count مرات تشغيل',
      two: 'مرتا تشغيل',
      one: 'مرة تشغيل واحدة',
      zero: 'لا مرات تشغيل',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب',
      many: '$count طلبًا',
      few: '$count طلبات',
      two: 'طلبان اثنان',
      one: 'طلب واحد',
      zero: 'لا طلبات',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'جديد';

  @override
  String get dedicationsEmpty => 'لا إهداءات بعد. اطلب أغنية وأضف إهداءً.';

  @override
  String dedicatedBy(String name) {
    return 'إهداء من ⁨$name⁩';
  }

  @override
  String get lyrics => 'الكلمات';

  @override
  String get lyricsNone => 'لا تتوفر كلمات لهذه الأغنية بعد.';

  @override
  String get share => 'مشاركة';

  @override
  String shareSong(String title, String artist) {
    return '«⁨$title⁩» لـ⁨$artist⁩، مباشرة على SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM ⁨$name⁩: راديو K-pop مجاني على مدار الساعة';
  }

  @override
  String get close => 'إغلاق';

  @override
  String get startListeningToRate => 'ابدأ الاستماع لتقييمها';

  @override
  String get like => 'أعجبتني هذه الأغنية';

  @override
  String get dislike => 'ليست لي';

  @override
  String get hot => 'رائج';

  @override
  String get topTracks => 'أبرز الأغاني';

  @override
  String get albums => 'الألبومات';

  @override
  String get related => 'قد يعجبك أيضًا';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get sleepTimer => 'مؤقّت النوم';

  @override
  String get sleepOff => 'إيقاف';

  @override
  String sleepMinutes(int minutes) {
    return '⁨$minutes⁩ د';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'يتوقف بعد ⁨$minutes⁩ د';
  }

  @override
  String get inTheCar => 'في السيارة';

  @override
  String get carBody =>
      'يعمل SeoulFM مع Android Auto. صِل هاتفك واختر محطة من شاشة السيارة؛ وتنقلك أزرار التخطي على المقود بين المحطات.';

  @override
  String get about => 'عن SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM راديو K-pop مجاني على مدار الساعة ومنصة لبث الموسيقى الكورية: اثنتا عشرة محطة مباشرة، ومكتبة أغانٍ تكبر كل يوم، لكلٍّ منها كلماتها، يمكنك البحث فيها وطلبها. تُذاع الأغنية المطلوبة مباشرة للجميع. على الهواء منذ 2009، ومجاني دائمًا.';

  @override
  String get website => 'الموقع';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get terms => 'الشروط';

  @override
  String get contact => 'اتصل بنا';

  @override
  String version(String version) {
    return 'الإصدار ⁨$version⁩';
  }

  @override
  String get losslessTitle => 'FLAC بلا فقدان';

  @override
  String losslessUses(int mb) {
    return 'نحو ⁨$mb⁩ ميغابايت في الساعة';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'الجودة العادية: نحو ⁨$mb⁩ ميغابايت في الساعة';
  }

  @override
  String get losslessFallbackNotice =>
      'الصوت بلا فقدان يستهلك بيانات أكثر بكثير من البث العادي. استخدم Wi-Fi أو باقة غير محدودة.';

  @override
  String get losslessAccept => 'تشغيل بلا فقدان';

  @override
  String get losslessDecline => 'استخدام الجودة العادية';

  @override
  String get losslessFailed =>
      'تعذّر تشغيل الجودة بلا فقدان، لذا فُعّلت الجودة العادية.';

  @override
  String get retryFlac => 'أعد محاولة FLAC';

  @override
  String get marathonOnAir => 'على الهواء هذه الساعة';

  @override
  String get marathonQueue => 'القادم';

  @override
  String get marathonNominations => 'صوّت لهم';

  @override
  String get marathonVote => 'صوّت';

  @override
  String marathonVotes(int votes, int required) {
    return '⁨$votes⁩ من ⁨$required⁩ أصوات';
  }

  @override
  String get marathonNominate => 'رشّح فنانًا';

  @override
  String get marathonNominateHint => 'ابحث عن فنانين';

  @override
  String get marathonVoted => 'تم احتساب صوتك';

  @override
  String get marathonEmpty =>
      'لا ترشيحات مفتوحة. رشّح فنانًا للساعة المتاحة التالية.';

  @override
  String get marathonVotedIn => 'فاز بالتصويت';

  @override
  String get marathonIntro =>
      'فرقة واحدة، ساعة كاملة. صوّت لفنان ليحصل على الساعة المتاحة التالية.';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int n) {
    return 'قبل ⁨$n⁩ د';
  }

  @override
  String hoursAgo(int n) {
    return 'قبل ⁨$n⁩ س';
  }

  @override
  String inMinutes(int n) {
    return 'بعد ⁨$n⁩ د';
  }

  @override
  String get requestBadge => 'طلب';

  @override
  String get artistPage => 'صفحة الفنان';

  @override
  String get openSong => 'صفحة الأغنية';

  @override
  String get nextStation => 'المحطة التالية';

  @override
  String get previousStation => 'المحطة السابقة';

  @override
  String get quality => 'الجودة';

  @override
  String get qualityAuto => 'تلقائي';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get captchaFailed => 'تعذّر التحقق. حاول مجددًا.';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'طاب نهارك';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get featuredStations => 'محطات مميزة';

  @override
  String get genresAndEras => 'الأنواع والحقب';

  @override
  String get playingFrom => 'يُذاع من';

  @override
  String get chooseStation => 'اختر محطتك';

  @override
  String get listenNow => 'استمع الآن';

  @override
  String get showLyrics => 'إظهار الكلمات';

  @override
  String get shareCardSong => 'أغنية';

  @override
  String get editLyrics => 'اختر الأسطر';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get linkCopied => 'تم النسخ';

  @override
  String get shareImage => 'مشاركة الصورة';

  @override
  String get done => 'تم';

  @override
  String pickLines(int count) {
    return 'اختر حتى ⁨$count⁩ أسطر';
  }

  @override
  String get goToSong => 'انتقل إلى الأغنية';

  @override
  String get goToArtist => 'انتقل إلى الفنان';

  @override
  String get swipeToRequest => 'اطلب';

  @override
  String get offlineTitle => 'أنت غير متصل';

  @override
  String get serverErrorTitle => 'حدث خطأ ما';

  @override
  String get noResultsTitle => 'لا نتائج';

  @override
  String get noResultsBody =>
      'جرّب تهجئة أخرى، أو العنوان بالإنجليزية أو الكورية، أو اسم الفنان.';

  @override
  String get wallEmptyTitle => 'لا إهداءات بعد';

  @override
  String get requestTrackerQueued => 'طلبك · في قائمة الانتظار';

  @override
  String requestTrackerEta(int minutes) {
    return 'طلبك · يُذاع خلال ~⁨$minutes⁩ د';
  }

  @override
  String get requestTrackerNext => 'طلبك هو التالي';

  @override
  String get requestTrackerPlaying => 'طلبك يُذاع الآن!';

  @override
  String get welcomeTitle => 'راديو K-pop مباشر ومجاني';

  @override
  String get welcomeBody =>
      'اثنتا عشرة محطة على مدار الساعة، ومكتبة أغانٍ مع كلماتها تكبر كل يوم. اطلب أغنية لتُذاع مباشرة للجميع.';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get pickStationsTitle => 'اختر محطاتك';

  @override
  String get pickStationsBody => 'سنضعها في المقدمة. يمكنك تغييرها في أي وقت.';

  @override
  String get requestsTitle => 'أنت تختار ما يُذاع تاليًا';

  @override
  String get requestsBody =>
      'ابحث عن أي أغنية واطلبها. عندما تُذاع، يسمعها كل المستمعين — ويرون إهداءك.';

  @override
  String get startListening => 'ابدأ الاستماع';

  @override
  String get skip => 'تخطٍّ';

  @override
  String get yourStations => 'محطاتك';

  @override
  String get support => 'ادعمنا';

  @override
  String get supportEyebrow => 'بدعم من المستمعين';

  @override
  String get supportH1 => 'بلا إعلانات. بلا اشتراك مدفوع.';

  @override
  String get supportH1Sub => 'يبقى على الهواء بفضل من يستمعون إليه.';

  @override
  String get supportLead =>
      'SeoulFM مجاني، وسيبقى مجانيًا. لا شيء نبيعه لك، ولا أحد نبيعك له. إن كانت المحطة جزءًا من يومك، يمكنك المساعدة في إبقائها تعمل.';

  @override
  String get supportWhereItGoes => 'إلى أين يذهب دعمك';

  @override
  String get supportCostStreamTitle => 'البث';

  @override
  String get supportCostStreamBody =>
      'اثنتا عشرة محطة على الهواء كل ساعة من كل يوم، تصل إلى العالم كله. الصوت بلا فقدان على HIFI هو أغلى ما نرسله، ونرسله مجانًا.';

  @override
  String get supportCostLibraryTitle => 'المكتبة';

  @override
  String get supportCostLibraryBody =>
      'عشرات الآلاف من الأغاني، مخزّنة ومصنّفة ومنظّمة، مع صور الألبومات والكلمات المتزامنة ومعالجة صوتية بجودة البث لكل واحدة منها.';

  @override
  String get supportCostWorkTitle => 'العمل';

  @override
  String get supportCostWorkBody =>
      'الموقع والتطبيقات والطلبات والجدار والدردشة، إضافة إلى التكلفة المستمرة لتراخيص الموسيقى. يبنيها ويديرها فريق صغير جدًا.';

  @override
  String get supportStaysTheSame => 'ما الذي لن يتغيّر';

  @override
  String get supportPromiseNoAds =>
      'لا إعلانات صوتية ولا لافتات. لا الآن ولا لاحقًا.';

  @override
  String get supportPromiseNothingLocked =>
      'لا شيء مقفل. كل محطة وكل طلب وكل ميزة تبقى مجانية للجميع.';

  @override
  String get supportPromiseOptional =>
      'الدعم اختياري ولا يغيّر شيئًا في طريقة استماعك.';

  @override
  String get supportBecome => 'كن داعمًا';

  @override
  String get supportBecomeBody =>
      'مرة واحدة أو شهريًا. تتم المدفوعات عبر App Store أو Google Play؛ ولا نرى بيانات بطاقتك أبدًا.';

  @override
  String get supportMonthly => 'داعم شهري';

  @override
  String get supportMonthlyBody =>
      'أبقِ محطة على الهواء كل شهر. يمكنك الإلغاء في أي وقت.';

  @override
  String supportPerMonth(String price) {
    return '⁨$price⁩ / شهريًا';
  }

  @override
  String get supportOnce => 'دعم لمرة واحدة';

  @override
  String get supportTipSmall => 'فنجان قهوة';

  @override
  String get supportTipMedium => 'وجبة غداء';

  @override
  String get supportTipLarge => 'سهرة في الخارج';

  @override
  String get supportRestore => 'استعادة المشتريات';

  @override
  String get supportUnavailable =>
      'الدعم عبر المتجر غير متاح حاليًا. حاول مجددًا لاحقًا.';

  @override
  String get supportThanksTitle => 'شكرًا لك';

  @override
  String get supportThanksBody => 'أنت تساعد في إبقاء SeoulFM مجانيًا للجميع.';

  @override
  String get supportYouAreSupporter => 'أنت داعم لنا. شكرًا لك.';

  @override
  String get supportFreeWays =>
      'لا تستطيع التبرّع؟ استماعك مهم. وكذلك طلب أغنية، أو ترك رسالة على الجدار، أو إرسال المحطة إلى صديق واحد سيحبها.';

  @override
  String get supportCardTitle => 'أبقِ SeoulFM مجانيًا';

  @override
  String get supportCardBody =>
      'بلا إعلانات وبلا اشتراك مدفوع — يبقى على الهواء بفضل مستمعين مثلك.';

  @override
  String get supportSubscriptionTerms =>
      'يتجدد الدعم الشهري تلقائيًا حتى تلغيه من إعدادات حسابك في المتجر.';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'استخدام لغة النظام';

  @override
  String get qualityAutoBody => 'أفضل جودة يتحملها اتصالك. تنخفض إذا تعثّر.';

  @override
  String get qualityVeryHigh => 'عالية جدًا';

  @override
  String get qualityHigh => 'عالية';

  @override
  String get qualityNormal => 'عادية';

  @override
  String get qualityDataSaver => 'توفير البيانات';

  @override
  String get qualityFixedBody => 'هذه الجودة دائمًا، حتى مع اتصال ضعيف.';

  @override
  String get qualityLosslessNote =>
      'يُشغّل HIFI ملفات FLAC بلا فقدان عند قبولك تنبيهه.';

  @override
  String get moreOptions => 'المزيد من الخيارات';

  @override
  String get reportDedication => 'إبلاغ';

  @override
  String hideDedicationsFrom(String name) {
    return 'إخفاء الإهداءات من ⁨$name⁩';
  }

  @override
  String get reportThanks => 'شكرًا لإبلاغنا. سنلقي نظرة.';

  @override
  String get showHiddenDedications => 'إظهار الإهداءات المخفية';

  @override
  String get verifyFailed => 'تعذّر التحقق. تحقّق من اتصالك وحاول مجددًا.';

  @override
  String get restoreDone => 'تمت استعادة مشترياتك.';

  @override
  String get restoreNothing => 'لا توجد مشتريات لاستعادتها.';

  @override
  String get playbackFailed =>
      'تعذّر الوصول إلى البث. تحقّق من اتصالك وحاول مجددًا.';

  @override
  String get audioOutput => 'مخرج الصوت';

  @override
  String get openPlayer => 'فتح المشغّل';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أغنية',
      many: '$count أغنية',
      few: '$count أغانٍ',
      two: 'أغنيتان',
      one: 'أغنية واحدة',
      zero: 'لا أغاني',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'المحطات';

  @override
  String get spatialAudioBody =>
      'تم مزج SeoulFM لسماعات الرأس باستخدام كروس فيد BS2B (Bauer stereophonic-to-binaural). يصل جزء بسيط من كل قناة إلى الأذن الأخرى كما لو كان من مكبرات صوت في غرفة، فيبدو الصوت أوسع وأكثر طبيعية ومريحًا للأذن لساعات طويلة.';
}
