// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => '홈';

  @override
  String get tabRequest => '신청';

  @override
  String get tabCharts => '차트';

  @override
  String get tabWall => '사연';

  @override
  String get tabMore => '더보기';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => '방송 휴식';

  @override
  String get stationBreak => '잠시 쉬어 갑니다. 곧 돌아올게요.';

  @override
  String get nowPlaying => '지금 재생 중';

  @override
  String get upNext => '다음 곡';

  @override
  String get stations => '채널';

  @override
  String get recentlyPlayed => '최근 재생';

  @override
  String get requestASong => '곡 신청하기';

  @override
  String get requestHint => '곡을 고르면 모두에게 라이브로 재생돼요.';

  @override
  String get searchHint => '곡, 아티스트, 앨범';

  @override
  String searchEmpty(String query) {
    return '“$query” 검색 결과가 없어요';
  }

  @override
  String get searchIntro => '라이브러리를 검색하고, 가사를 보고, 곡을 신청해 라이브로 들어 보세요.';

  @override
  String get newSongs => 'SeoulFM 신곡';

  @override
  String get songs => '곡';

  @override
  String get artists => '아티스트';

  @override
  String get play => '재생';

  @override
  String get pause => '일시정지';

  @override
  String get request => '신청';

  @override
  String get requestTitle => '이 곡 신청하기';

  @override
  String get yourName => '이름 (선택)';

  @override
  String get dedication => '사연 (선택)';

  @override
  String get sendRequest => '신청 보내기';

  @override
  String get verifying => '확인 중…';

  @override
  String get requestAccepted => '신청 완료!';

  @override
  String etaMinutes(int minutes) {
    return '약 $minutes분 후 재생';
  }

  @override
  String get etaSoon => '곧 재생돼요';

  @override
  String requestQueued(String title) {
    return '“$title” 대기열에 들어갔어요';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” 곧 재생돼요';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” 지금 방송 중';
  }

  @override
  String requestExpired(String title) {
    return '이번에는 “$title”을(를) 재생하지 못했어요';
  }

  @override
  String get notRequestable => '지금은 신청할 수 없어요';

  @override
  String get errorGeneric => '문제가 생겼어요. 다시 시도해 주세요.';

  @override
  String get offline => 'SeoulFM에 연결할 수 없어요. 연결을 확인해 주세요.';

  @override
  String get retry => '다시 시도';

  @override
  String get chartsWeekly => '이번 주';

  @override
  String get chartsHot => '핫';

  @override
  String get chartsRequested => '신청 많은 곡';

  @override
  String get chartsTrending => '트렌딩';

  @override
  String plays(int count) {
    return '$count회 재생';
  }

  @override
  String requestsCount(int count) {
    return '신청 $count회';
  }

  @override
  String get newEntry => 'NEW';

  @override
  String get dedicationsEmpty => '아직 사연이 없어요. 곡을 신청하고 사연을 남겨 보세요.';

  @override
  String dedicatedBy(String name) {
    return '$name님의 사연';
  }

  @override
  String get lyrics => '가사';

  @override
  String get lyricsNone => '아직 이 곡의 가사가 없어요.';

  @override
  String get share => '공유';

  @override
  String shareSong(String title, String artist) {
    return 'SeoulFM 라이브: $artist의 $title';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: 무료 24시간 K-pop 라디오';
  }

  @override
  String get close => '닫기';

  @override
  String get startListeningToRate => '듣는 중에 평가할 수 있어요';

  @override
  String get like => '좋아요';

  @override
  String get dislike => '별로예요';

  @override
  String get hot => '핫';

  @override
  String get topTracks => '인기곡';

  @override
  String get albums => '앨범';

  @override
  String get related => '비슷한 곡';

  @override
  String get settings => '설정';

  @override
  String get theme => '테마';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeDark => '다크';

  @override
  String get themeLight => '라이트';

  @override
  String get sleepTimer => '취침 타이머';

  @override
  String get sleepOff => '끄기';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String sleepStopsIn(int minutes) {
    return '$minutes분 후 정지';
  }

  @override
  String get inTheCar => '차에서 듣기';

  @override
  String get carBody =>
      'SeoulFM은 Android Auto를 지원해요. 휴대폰을 연결하고 차량 화면에서 채널을 고르세요. 핸들의 다음/이전 버튼으로 채널을 바꿀 수 있어요.';

  @override
  String get about => 'SeoulFM 소개';

  @override
  String get aboutBody =>
      'SeoulFM은 24시간 무료 K-pop 라디오이자 한국 음악 스트리밍 플랫폼이에요. 열두 개의 라이브 채널과 매일 늘어나는 가사 포함 곡 라이브러리에서 곡을 찾아 신청할 수 있어요. 신청한 곡은 모두에게 라이브로 재생돼요. 2009년부터 방송, 언제나 무료.';

  @override
  String get website => '웹사이트';

  @override
  String get privacy => '개인정보처리방침';

  @override
  String get terms => '이용약관';

  @override
  String get contact => '문의';

  @override
  String version(String version) {
    return '버전 $version';
  }

  @override
  String get losslessTitle => '무손실 FLAC';

  @override
  String losslessUses(int mb) {
    return '시간당 약 ${mb}MB';
  }

  @override
  String losslessUsesAac(int mb) {
    return '일반 음질: 시간당 약 ${mb}MB';
  }

  @override
  String get losslessFallbackNotice =>
      '무손실 음원은 일반 스트리밍보다 데이터를 훨씬 많이 사용해요. Wi-Fi나 무제한 요금제에서 들어 주세요.';

  @override
  String get losslessAccept => '무손실로 듣기';

  @override
  String get losslessDecline => '일반 음질로 듣기';

  @override
  String get losslessFailed => '무손실 재생이 되지 않아 일반 음질로 재생 중이에요.';

  @override
  String get retryFlac => 'FLAC 다시 시도';

  @override
  String get marathonOnAir => '이번 시간 방송 중';

  @override
  String get marathonQueue => '다음 순서';

  @override
  String get marathonNominations => '투표하기';

  @override
  String get marathonVote => '투표';

  @override
  String marathonVotes(int votes, int required) {
    return '$required표 중 $votes표';
  }

  @override
  String get marathonNominate => '아티스트 추천하기';

  @override
  String get marathonNominateHint => '아티스트 검색';

  @override
  String get marathonVoted => '투표했어요';

  @override
  String get marathonEmpty => '진행 중인 추천이 없어요. 다음 빈 시간에 들을 아티스트를 추천해 보세요.';

  @override
  String get marathonVotedIn => '투표로 선정';

  @override
  String get marathonIntro => '한 그룹, 한 시간. 다음 빈 시간에 들을 아티스트에 투표하세요.';

  @override
  String get seeAll => '전체 보기';

  @override
  String get justNow => '방금';

  @override
  String minutesAgo(int n) {
    return '$n분 전';
  }

  @override
  String hoursAgo(int n) {
    return '$n시간 전';
  }

  @override
  String inMinutes(int n) {
    return '$n분 후';
  }

  @override
  String get requestBadge => '신청곡';

  @override
  String get artistPage => '아티스트 페이지';

  @override
  String get openSong => '곡 페이지';

  @override
  String get nextStation => '다음 채널';

  @override
  String get previousStation => '이전 채널';

  @override
  String get quality => '음질';

  @override
  String get qualityAuto => '자동';

  @override
  String get comingSoon => '곧 공개';

  @override
  String get captchaFailed => '확인하지 못했어요. 다시 시도해 주세요.';

  @override
  String get goodMorning => '좋은 아침이에요';

  @override
  String get goodAfternoon => '좋은 오후예요';

  @override
  String get goodEvening => '좋은 저녁이에요';

  @override
  String get featuredStations => '추천 채널';

  @override
  String get genresAndEras => '장르와 시대';

  @override
  String get playingFrom => '재생 중인 채널';

  @override
  String get chooseStation => '채널 선택';

  @override
  String get listenNow => '지금 듣기';

  @override
  String get showLyrics => '가사 보기';

  @override
  String get shareCardSong => '곡';

  @override
  String get editLyrics => '가사 고르기';

  @override
  String get copyLink => '링크 복사';

  @override
  String get linkCopied => '복사됨';

  @override
  String get shareImage => '이미지 공유';

  @override
  String get done => '완료';

  @override
  String pickLines(int count) {
    return '최대 $count줄까지 고를 수 있어요';
  }

  @override
  String get goToSong => '곡 보기';

  @override
  String get goToArtist => '아티스트 보기';

  @override
  String get swipeToRequest => '신청';

  @override
  String get offlineTitle => '오프라인 상태예요';

  @override
  String get serverErrorTitle => '문제가 생겼어요';

  @override
  String get noResultsTitle => '결과가 없어요';

  @override
  String get noResultsBody => '다른 철자나 영어·한국어 제목, 아티스트 이름으로 찾아보세요.';

  @override
  String get wallEmptyTitle => '아직 사연이 없어요';

  @override
  String get requestTrackerQueued => '내 신청곡 · 대기 중';

  @override
  String requestTrackerEta(int minutes) {
    return '내 신청곡 · 약 $minutes분 후 재생';
  }

  @override
  String get requestTrackerNext => '내 신청곡이 다음 차례예요';

  @override
  String get requestTrackerPlaying => '내 신청곡이 지금 나오고 있어요!';

  @override
  String get welcomeTitle => '라이브로, 무료로 듣는 K-pop 라디오';

  @override
  String get welcomeBody =>
      '열두 개의 채널이 24시간, 가사가 있는 곡 라이브러리는 매일 늘어나요. 곡을 신청하면 모두에게 라이브로 재생돼요.';

  @override
  String get continueLabel => '계속';

  @override
  String get pickStationsTitle => '좋아하는 채널을 골라 주세요';

  @override
  String get pickStationsBody => '맨 앞에 보여 드릴게요. 언제든 바꿀 수 있어요.';

  @override
  String get requestsTitle => '다음 곡은 여러분이 골라요';

  @override
  String get requestsBody =>
      '어떤 곡이든 찾아서 신청하세요. 재생되면 듣고 있는 모두가 함께 듣고, 사연도 보게 돼요.';

  @override
  String get startListening => '듣기 시작';

  @override
  String get skip => '건너뛰기';

  @override
  String get yourStations => '내 채널';

  @override
  String get support => '후원';

  @override
  String get supportEyebrow => '청취자 후원';

  @override
  String get supportH1 => '광고 없이. 유료 결제 없이.';

  @override
  String get supportH1Sub => '듣는 분들 덕분에 방송을 이어 갑니다.';

  @override
  String get supportLead =>
      'SeoulFM은 무료이고, 앞으로도 무료입니다. 여러분에게 팔 것도 없고, 여러분을 팔아넘길 곳도 없습니다. SeoulFM이 하루의 일부라면, 방송이 계속되도록 힘을 보태 주세요.';

  @override
  String get supportWhereItGoes => '후원금이 쓰이는 곳';

  @override
  String get supportCostStreamTitle => '스트림';

  @override
  String get supportCostStreamBody =>
      '열두 개 채널이 하루도 빠짐없이 매시간 방송되며 전 세계로 전달됩니다. HIFI의 무손실 오디오는 저희가 보내는 것 중 가장 비용이 많이 들지만, 무료로 보내 드립니다.';

  @override
  String get supportCostLibraryTitle => '라이브러리';

  @override
  String get supportCostLibraryBody =>
      '수만 곡을 저장하고, 태그를 달고, 정리해 둡니다. 곡마다 앨범 아트, 싱크 가사, 방송 품질의 음향 처리가 적용됩니다.';

  @override
  String get supportCostWorkTitle => '운영';

  @override
  String get supportCostWorkBody =>
      '사이트, 앱, 신청곡, 사연 월, 채팅, 그리고 계속 드는 음악 라이선스 비용까지. 아주 작은 팀이 만들고 운영합니다.';

  @override
  String get supportStaysTheSame => '변하지 않는 것';

  @override
  String get supportPromiseNoAds => '오디오 광고도, 배너도 없습니다. 지금도, 앞으로도.';

  @override
  String get supportPromiseNothingLocked =>
      '잠긴 기능은 없습니다. 모든 채널, 신청곡, 기능은 누구에게나 계속 무료입니다.';

  @override
  String get supportPromiseOptional => '후원은 선택이며, 듣는 방식은 아무것도 달라지지 않습니다.';

  @override
  String get supportBecome => '후원자 되기';

  @override
  String get supportBecomeBody =>
      '한 번, 또는 매월. 결제는 App Store나 Google Play를 통해 이루어지며, 저희는 카드 정보를 볼 수 없습니다.';

  @override
  String get supportMonthly => '월간 후원자';

  @override
  String get supportMonthlyBody => '매달 한 채널의 방송을 지켜 주세요. 언제든 해지할 수 있어요.';

  @override
  String supportPerMonth(String price) {
    return '월 $price';
  }

  @override
  String get supportOnce => '일회성 후원';

  @override
  String get supportTipSmall => '커피 한 잔';

  @override
  String get supportTipMedium => '점심 한 끼';

  @override
  String get supportTipLarge => '근사한 저녁';

  @override
  String get supportRestore => '구매 복원';

  @override
  String get supportUnavailable => '스토어를 통한 후원이 곧 열립니다. 도와주시려는 마음에 감사드려요.';

  @override
  String get supportThanksTitle => '감사합니다';

  @override
  String get supportThanksBody => '모두를 위해 SeoulFM이 무료로 남을 수 있도록 도와주셨어요.';

  @override
  String get supportYouAreSupporter => '후원자이시네요. 감사합니다.';

  @override
  String get supportFreeWays =>
      '후원이 어려우신가요? 듣는 것만으로도 힘이 됩니다. 곡을 신청하고, 사연을 남기고, 좋아할 친구 한 명에게 SeoulFM을 알려 주세요.';

  @override
  String get supportCardTitle => 'SeoulFM을 무료로 지켜 주세요';

  @override
  String get supportCardBody => '광고도, 유료 결제도 없이 — 여러분 같은 청취자 덕분에 방송합니다.';

  @override
  String get supportSubscriptionTerms =>
      '월간 후원은 스토어 계정 설정에서 해지할 때까지 자동으로 갱신됩니다.';

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템 언어 사용';

  @override
  String get qualityAutoBody => '연결 상태에 맞는 최고 음질. 불안정하면 낮춰요.';

  @override
  String get qualityVeryHigh => '매우 높음';

  @override
  String get qualityHigh => '높음';

  @override
  String get qualityNormal => '보통';

  @override
  String get qualityDataSaver => '데이터 절약';

  @override
  String get qualityFixedBody => '연결이 약해도 항상 이 음질로 재생해요.';

  @override
  String get qualityLosslessNote => 'HIFI는 안내에 동의하면 무손실 FLAC으로 재생돼요.';
}
