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
  String get searchIntro => '58,000곡 이상을 검색하고, 가사를 보고, 신청해서 라이브로 들어 보세요.';

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
      'SeoulFM은 Apple CarPlay와 Android Auto를 지원해요. 휴대폰을 연결하고 차량 화면에서 채널을 고르세요. 핸들의 다음/이전 버튼으로 채널을 바꿀 수 있어요.';

  @override
  String get about => 'SeoulFM 소개';

  @override
  String get aboutBody =>
      'SeoulFM은 무료 24시간 K-pop 라디오이자 한국 음악 스트리밍 플랫폼이에요. 12개의 라이브 채널과, 가사와 함께 검색하고 신청할 수 있는 58,000곡 이상의 라이브러리가 있어요. 신청한 곡은 모두에게 라이브로 재생돼요. 2009년부터 방송 중이며 언제나 무료예요.';

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
  String get qualityAuto => '자동 (AAC)';

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
}
