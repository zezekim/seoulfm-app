// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'หน้าแรก';

  @override
  String get tabRequest => 'ขอเพลง';

  @override
  String get tabCharts => 'ชาร์ต';

  @override
  String get tabWall => 'ข้อความถึง';

  @override
  String get tabMore => 'เพิ่มเติม';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'ไม่ได้ออนแอร์';

  @override
  String get stationBreak => 'สถานีพักสักครู่ แล้วจะกลับมาเร็วๆ นี้';

  @override
  String get nowPlaying => 'กำลังเล่น';

  @override
  String get upNext => 'ถัดไป';

  @override
  String get stations => 'สถานี';

  @override
  String get recentlyPlayed => 'เพิ่งเล่นไป';

  @override
  String get requestASong => 'ขอเพลง';

  @override
  String get requestHint => 'เลือกเพลง แล้วเพลงจะเล่นสดให้ทุกคนฟัง';

  @override
  String get searchHint => 'เพลง ศิลปิน อัลบั้ม';

  @override
  String searchEmpty(String query) {
    return 'ไม่พบผลลัพธ์สำหรับ “$query”';
  }

  @override
  String get searchIntro => 'ค้นหาในคลังเพลง อ่านเนื้อเพลง และขอเพลงให้เล่นสด';

  @override
  String get newSongs => 'ใหม่บน SeoulFM';

  @override
  String get songs => 'เพลง';

  @override
  String get artists => 'ศิลปิน';

  @override
  String get play => 'เล่น';

  @override
  String get pause => 'หยุดชั่วคราว';

  @override
  String get request => 'ขอเพลง';

  @override
  String get requestTitle => 'ขอเพลงนี้';

  @override
  String get yourName => 'ชื่อของคุณ (ไม่บังคับ)';

  @override
  String get dedication => 'ข้อความถึง (ไม่บังคับ)';

  @override
  String get sendRequest => 'ส่งคำขอเพลง';

  @override
  String get verifying => 'กำลังตรวจสอบว่าคุณเป็นมนุษย์…';

  @override
  String get requestAccepted => 'ขอเพลงแล้ว!';

  @override
  String etaMinutes(int minutes) {
    return 'จะเล่นในอีกประมาณ $minutes นาที';
  }

  @override
  String get etaSoon => 'จะเล่นเร็วๆ นี้';

  @override
  String requestQueued(String title) {
    return '“$title” อยู่ในคิวแล้ว';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” จะเล่นถัดไป';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” ออนแอร์อยู่ตอนนี้';
  }

  @override
  String requestExpired(String title) {
    return 'ครั้งนี้เล่น “$title” ไม่ได้';
  }

  @override
  String get notRequestable => 'ตอนนี้ขอเพลงนี้ไม่ได้';

  @override
  String get errorGeneric => 'เกิดข้อผิดพลาด ลองใหม่อีกครั้ง';

  @override
  String get offline => 'เชื่อมต่อ SeoulFM ไม่ได้ ตรวจสอบการเชื่อมต่อของคุณ';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get chartsWeekly => 'สัปดาห์นี้';

  @override
  String get chartsHot => 'ฮอต';

  @override
  String get chartsRequested => 'ขอมากที่สุด';

  @override
  String get chartsTrending => 'มาแรง';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เล่น $count ครั้ง',
      one: 'เล่น 1 ครั้ง',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count คำขอ',
      one: '1 คำขอ',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'ใหม่';

  @override
  String get dedicationsEmpty =>
      'ยังไม่มีข้อความถึง ขอเพลงแล้วเขียนข้อความถึงได้เลย';

  @override
  String dedicatedBy(String name) {
    return 'ข้อความจาก $name';
  }

  @override
  String get lyrics => 'เนื้อเพลง';

  @override
  String get lyricsNone => 'เพลงนี้ยังไม่มีเนื้อเพลง';

  @override
  String get share => 'แชร์';

  @override
  String shareSong(String title, String artist) {
    return '$title ของ $artist สดทาง SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: วิทยุ K-pop ฟรี 24/7';
  }

  @override
  String get close => 'ปิด';

  @override
  String get startListeningToRate => 'เริ่มฟังก่อนจึงจะให้คะแนนได้';

  @override
  String get like => 'ชอบเพลงนี้';

  @override
  String get dislike => 'ไม่ใช่แนว';

  @override
  String get hot => 'ฮอต';

  @override
  String get topTracks => 'เพลงยอดนิยม';

  @override
  String get albums => 'อัลบั้ม';

  @override
  String get related => 'คุณอาจจะชอบ';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get theme => 'ธีม';

  @override
  String get themeSystem => 'ตามระบบ';

  @override
  String get themeDark => 'มืด';

  @override
  String get themeLight => 'สว่าง';

  @override
  String get sleepTimer => 'ตั้งเวลาปิด';

  @override
  String get sleepOff => 'ปิด';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes นาที';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'หยุดในอีก $minutes นาที';
  }

  @override
  String get inTheCar => 'ในรถ';

  @override
  String get carBody =>
      'SeoulFM ใช้งานได้กับ Android Auto เชื่อมต่อโทรศัพท์แล้วเลือกสถานีบนหน้าจอรถ ปุ่มข้ามเพลงบนพวงมาลัยใช้เปลี่ยนสถานี';

  @override
  String get about => 'เกี่ยวกับ SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM คือวิทยุ K-pop ฟรี 24/7 และแพลตฟอร์มสตรีมมิงเพลงเกาหลี มีสิบสองสถานีสด และคลังเพลงที่เพิ่มขึ้นทุกวัน พร้อมเนื้อเพลงทุกเพลง ที่คุณค้นหาและขอได้ เพลงที่ขอจะเล่นสดให้ทุกคนฟัง ออนแอร์มาตั้งแต่ปี 2009 และฟรีเสมอ';

  @override
  String get website => 'เว็บไซต์';

  @override
  String get privacy => 'ความเป็นส่วนตัว';

  @override
  String get terms => 'ข้อกำหนด';

  @override
  String get contact => 'ติดต่อ';

  @override
  String version(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get losslessTitle => 'FLAC แบบ lossless';

  @override
  String losslessUses(int mb) {
    return 'ประมาณ $mb MB ต่อชั่วโมง';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'คุณภาพมาตรฐาน: ประมาณ $mb MB ต่อชั่วโมง';
  }

  @override
  String get losslessFallbackNotice =>
      'เสียง lossless ใช้ดาต้ามากกว่าสตรีมปกติหลายเท่า ควรใช้ Wi-Fi หรือแพ็กเกจเน็ตไม่จำกัด';

  @override
  String get losslessAccept => 'เล่นแบบ lossless';

  @override
  String get losslessDecline => 'ใช้คุณภาพมาตรฐาน';

  @override
  String get losslessFailed =>
      'เล่น lossless ไม่ได้ จึงเปลี่ยนเป็นคุณภาพมาตรฐาน';

  @override
  String get retryFlac => 'ลอง FLAC อีกครั้ง';

  @override
  String get marathonOnAir => 'ออนแอร์ชั่วโมงนี้';

  @override
  String get marathonQueue => 'กำลังจะมา';

  @override
  String get marathonNominations => 'ช่วยโหวตให้ผ่าน';

  @override
  String get marathonVote => 'โหวต';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes จาก $required โหวต';
  }

  @override
  String get marathonNominate => 'เสนอชื่อศิลปิน';

  @override
  String get marathonNominateHint => 'ค้นหาศิลปิน';

  @override
  String get marathonVoted => 'นับโหวตแล้ว';

  @override
  String get marathonEmpty =>
      'ยังไม่มีการเสนอชื่อ เสนอชื่อศิลปินสำหรับชั่วโมงว่างถัดไปได้เลย';

  @override
  String get marathonVotedIn => 'โหวตผ่าน';

  @override
  String get marathonIntro =>
      'หนึ่งวง เต็มหนึ่งชั่วโมง โหวตศิลปินให้ได้ชั่วโมงว่างถัดไป';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get justNow => 'เมื่อสักครู่';

  @override
  String minutesAgo(int n) {
    return '$n นาทีที่แล้ว';
  }

  @override
  String hoursAgo(int n) {
    return '$n ชม. ที่แล้ว';
  }

  @override
  String inMinutes(int n) {
    return 'ในอีก $n นาที';
  }

  @override
  String get requestBadge => 'ขอเพลง';

  @override
  String get artistPage => 'หน้าศิลปิน';

  @override
  String get openSong => 'หน้าเพลง';

  @override
  String get nextStation => 'สถานีถัดไป';

  @override
  String get previousStation => 'สถานีก่อนหน้า';

  @override
  String get quality => 'คุณภาพเสียง';

  @override
  String get qualityAuto => 'อัตโนมัติ';

  @override
  String get comingSoon => 'เร็วๆ นี้';

  @override
  String get captchaFailed => 'ยืนยันไม่สำเร็จ ลองใหม่อีกครั้ง';

  @override
  String get goodMorning => 'อรุณสวัสดิ์';

  @override
  String get goodAfternoon => 'สวัสดีตอนบ่าย';

  @override
  String get goodEvening => 'สวัสดีตอนเย็น';

  @override
  String get featuredStations => 'สถานีแนะนำ';

  @override
  String get genresAndEras => 'แนวเพลงและยุค';

  @override
  String get playingFrom => 'กำลังเล่นจาก';

  @override
  String get chooseStation => 'เลือกสถานี';

  @override
  String get listenNow => 'ฟังเลย';

  @override
  String get showLyrics => 'แสดงเนื้อเพลง';

  @override
  String get shareCardSong => 'เพลง';

  @override
  String get editLyrics => 'แก้ไขเนื้อเพลง';

  @override
  String get copyLink => 'คัดลอกลิงก์';

  @override
  String get linkCopied => 'คัดลอกแล้ว';

  @override
  String get shareImage => 'แชร์รูป';

  @override
  String get done => 'เสร็จ';

  @override
  String pickLines(int count) {
    return 'เลือกได้สูงสุด $count บรรทัด';
  }

  @override
  String get goToSong => 'ไปที่เพลง';

  @override
  String get goToArtist => 'ไปที่ศิลปิน';

  @override
  String get swipeToRequest => 'ขอเพลง';

  @override
  String get offlineTitle => 'คุณออฟไลน์อยู่';

  @override
  String get serverErrorTitle => 'เกิดข้อผิดพลาด';

  @override
  String get noResultsTitle => 'ไม่พบผลลัพธ์';

  @override
  String get noResultsBody =>
      'ลองสะกดแบบอื่น ใช้ชื่อเพลงภาษาอังกฤษหรือเกาหลี หรือชื่อศิลปิน';

  @override
  String get wallEmptyTitle => 'ยังไม่มีข้อความถึง';

  @override
  String get requestTrackerQueued => 'เพลงที่คุณขอ · อยู่ในคิว';

  @override
  String requestTrackerEta(int minutes) {
    return 'เพลงที่คุณขอ · จะเล่นในอีก ~$minutes นาที';
  }

  @override
  String get requestTrackerNext => 'เพลงที่คุณขอจะเล่นถัดไป';

  @override
  String get requestTrackerPlaying => 'เพลงที่คุณขอกำลังเล่นอยู่!';

  @override
  String get welcomeTitle => 'วิทยุ K-pop สดและฟรี';

  @override
  String get welcomeBody =>
      'สิบสองสถานี 24/7 และคลังเพลงพร้อมเนื้อเพลงที่เพิ่มขึ้นทุกวัน ขอเพลงแล้วเพลงจะเล่นสดให้ทุกคนฟัง';

  @override
  String get continueLabel => 'ต่อไป';

  @override
  String get pickStationsTitle => 'เลือกสถานีของคุณ';

  @override
  String get pickStationsBody => 'เราจะวางไว้ด้านหน้าให้ เปลี่ยนได้ทุกเมื่อ';

  @override
  String get requestsTitle => 'คุณเลือกเพลงถัดไปได้';

  @override
  String get requestsBody =>
      'ค้นหาเพลงไหนก็ได้แล้วขอเลย เมื่อเพลงเล่น ทุกคนที่ฟังอยู่จะได้ยิน — และเห็นข้อความถึงของคุณ';

  @override
  String get startListening => 'เริ่มฟัง';

  @override
  String get skip => 'ข้าม';

  @override
  String get yourStations => 'สถานีของคุณ';

  @override
  String get support => 'สนับสนุน';

  @override
  String get supportEyebrow => 'อยู่ได้ด้วยผู้ฟัง';

  @override
  String get supportH1 => 'ไม่มีโฆษณา ไม่ต้องจ่ายเงิน';

  @override
  String get supportH1Sub => 'ออนแอร์อยู่ได้ด้วยคนที่ฟัง';

  @override
  String get supportLead =>
      'SeoulFM ฟรี และจะฟรีต่อไป เราไม่มีอะไรจะขายคุณ และไม่มีใครให้เราขายข้อมูลคุณให้ ถ้าสถานีนี้เป็นส่วนหนึ่งในวันของคุณ คุณช่วยให้มันอยู่ต่อได้';

  @override
  String get supportWhereItGoes => 'เงินไปไหน';

  @override
  String get supportCostStreamTitle => 'สตรีม';

  @override
  String get supportCostStreamBody =>
      'สิบสองสถานี ออนแอร์ทุกชั่วโมงทุกวัน ส่งไปทั่วโลก เสียง lossless บน HIFI คือสิ่งที่แพงที่สุดที่เราส่ง และเราส่งให้ฟรี';

  @override
  String get supportCostLibraryTitle => 'คลังเพลง';

  @override
  String get supportCostLibraryBody =>
      'หลายหมื่นเพลงที่จัดเก็บ ติดแท็ก และจัดระเบียบไว้ พร้อมภาพปก เนื้อเพลงที่ซิงก์ และการปรับเสียงระดับสถานีออกอากาศในทุกเพลง';

  @override
  String get supportCostWorkTitle => 'งาน';

  @override
  String get supportCostWorkBody =>
      'เว็บไซต์ แอป การขอเพลง กำแพง และแชท รวมถึงค่าลิขสิทธิ์เพลงที่ต้องจ่ายต่อเนื่อง สร้างและดูแลโดยทีมเล็กมากๆ';

  @override
  String get supportStaysTheSame => 'สิ่งที่ไม่มีวันเปลี่ยน';

  @override
  String get supportPromiseNoAds =>
      'ไม่มีโฆษณาเสียงและไม่มีแบนเนอร์ ไม่ใช่ตอนนี้ และไม่ใช่ในอนาคต';

  @override
  String get supportPromiseNothingLocked =>
      'ไม่มีอะไรถูกล็อก ทุกสถานี ทุกการขอเพลง และทุกฟีเจอร์ฟรีสำหรับทุกคน';

  @override
  String get supportPromiseOptional =>
      'การสนับสนุนเป็นทางเลือก และไม่เปลี่ยนอะไรในการฟังของคุณ';

  @override
  String get supportBecome => 'มาเป็นผู้สนับสนุน';

  @override
  String get supportBecomeBody =>
      'ครั้งเดียวหรือรายเดือน การชำระเงินดำเนินการผ่าน App Store หรือ Google Play เราไม่เคยเห็นข้อมูลบัตรของคุณ';

  @override
  String get supportMonthly => 'ผู้สนับสนุนรายเดือน';

  @override
  String get supportMonthlyBody =>
      'ช่วยให้สถานีหนึ่งออนแอร์ต่อไปทุกเดือน ยกเลิกได้ทุกเมื่อ';

  @override
  String supportPerMonth(String price) {
    return '$price / เดือน';
  }

  @override
  String get supportOnce => 'ทิปครั้งเดียว';

  @override
  String get supportTipSmall => 'กาแฟสักแก้ว';

  @override
  String get supportTipMedium => 'มื้อกลางวัน';

  @override
  String get supportTipLarge => 'ออกไปเที่ยวสักคืน';

  @override
  String get supportRestore => 'กู้คืนการซื้อ';

  @override
  String get supportUnavailable =>
      'การสนับสนุนผ่านสโตร์ยังใช้ไม่ได้ในขณะนี้ ลองใหม่ภายหลัง';

  @override
  String get supportThanksTitle => 'ขอบคุณ';

  @override
  String get supportThanksBody => 'คุณกำลังช่วยให้ SeoulFM ฟรีสำหรับทุกคน';

  @override
  String get supportYouAreSupporter => 'คุณเป็นผู้สนับสนุนแล้ว ขอบคุณ';

  @override
  String get supportFreeWays =>
      'ยังไม่สะดวกให้เงินใช่ไหม การฟังก็มีความหมาย เช่นเดียวกับการขอเพลง การฝากข้อความไว้บนกำแพง หรือการส่งสถานีนี้ให้เพื่อนสักคนที่น่าจะชอบ';

  @override
  String get supportCardTitle => 'ช่วยให้ SeoulFM ฟรีต่อไป';

  @override
  String get supportCardBody =>
      'ไม่มีโฆษณา ไม่ต้องจ่ายเงิน — ออนแอร์อยู่ได้ด้วยผู้ฟังอย่างคุณ';

  @override
  String get supportSubscriptionTerms =>
      'การสนับสนุนรายเดือนจะต่ออายุอัตโนมัติจนกว่าคุณจะยกเลิกในการตั้งค่าบัญชีสโตร์';

  @override
  String get language => 'ภาษา';

  @override
  String get languageSystem => 'ใช้ภาษาของระบบ';

  @override
  String get qualityAutoBody =>
      'คุณภาพดีที่สุดที่การเชื่อมต่อรองรับได้ ลดลงเมื่อสัญญาณไม่ดี';

  @override
  String get qualityVeryHigh => 'สูงมาก';

  @override
  String get qualityHigh => 'สูง';

  @override
  String get qualityNormal => 'ปกติ';

  @override
  String get qualityDataSaver => 'ประหยัดดาต้า';

  @override
  String get qualityFixedBody => 'ใช้คุณภาพนี้เสมอ แม้สัญญาณจะอ่อน';

  @override
  String get qualityLosslessNote =>
      'HIFI เล่น FLAC แบบไม่สูญเสียคุณภาพเมื่อคุณยอมรับประกาศ';

  @override
  String get moreOptions => 'ตัวเลือกเพิ่มเติม';

  @override
  String get reportDedication => 'รายงาน';

  @override
  String hideDedicationsFrom(String name) {
    return 'ซ่อนข้อความถึงของ $name';
  }

  @override
  String get reportThanks => 'ขอบคุณที่แจ้งให้เรารู้ เราจะตรวจสอบ';

  @override
  String get showHiddenDedications => 'แสดงข้อความถึงที่ซ่อนไว้';

  @override
  String get verifyFailed =>
      'ยืนยันไม่สำเร็จ ตรวจสอบการเชื่อมต่อแล้วลองใหม่อีกครั้ง';

  @override
  String get restoreDone => 'กู้คืนการซื้อของคุณแล้ว';

  @override
  String get restoreNothing => 'ไม่มีการซื้อที่จะกู้คืน';

  @override
  String get playbackFailed =>
      'เชื่อมต่อสตรีมไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองใหม่อีกครั้ง';

  @override
  String get audioOutput => 'เอาต์พุตเสียง';

  @override
  String get openPlayer => 'เปิดเครื่องเล่น';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เพลง',
      one: '1 เพลง',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'สถานี';
}
