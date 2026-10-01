// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Home';

  @override
  String get tabRequest => 'Request';

  @override
  String get tabCharts => 'Charts';

  @override
  String get tabWall => 'Dedications';

  @override
  String get tabMore => 'More';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Off air';

  @override
  String get stationBreak => 'Station break. Back in a moment.';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get upNext => 'Up next';

  @override
  String get stations => 'Stations';

  @override
  String get recentlyPlayed => 'Recently played';

  @override
  String get requestASong => 'Request a song';

  @override
  String get requestHint => 'Pick a song and it plays live for everyone.';

  @override
  String get searchHint => 'Songs, artists, albums';

  @override
  String searchEmpty(String query) {
    return 'No matches for “$query”';
  }

  @override
  String get searchIntro =>
      'Search 58,000+ songs, read the lyrics, and request one to play live.';

  @override
  String get newSongs => 'New on SeoulFM';

  @override
  String get songs => 'Songs';

  @override
  String get artists => 'Artists';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get request => 'Request';

  @override
  String get requestTitle => 'Request this song';

  @override
  String get yourName => 'Your name (optional)';

  @override
  String get dedication => 'Dedication (optional)';

  @override
  String get sendRequest => 'Send request';

  @override
  String get verifying => 'Checking you’re human…';

  @override
  String get requestAccepted => 'Requested!';

  @override
  String etaMinutes(int minutes) {
    return 'Plays in about $minutes min';
  }

  @override
  String get etaSoon => 'Plays soon';

  @override
  String requestQueued(String title) {
    return '“$title” is in the queue';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” is coming up';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” is on air now';
  }

  @override
  String requestExpired(String title) {
    return '“$title” couldn’t be played this time';
  }

  @override
  String get notRequestable => 'Not requestable right now';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get offline => 'Can’t reach SeoulFM. Check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get chartsWeekly => 'This week';

  @override
  String get chartsHot => 'Hot';

  @override
  String get chartsRequested => 'Most requested';

  @override
  String get chartsTrending => 'Trending';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plays',
      one: '1 play',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '1 request',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NEW';

  @override
  String get dedicationsEmpty =>
      'No dedications yet. Request a song and add one.';

  @override
  String dedicatedBy(String name) {
    return 'Dedicated by $name';
  }

  @override
  String get lyrics => 'Lyrics';

  @override
  String get lyricsNone => 'No lyrics for this song yet.';

  @override
  String get share => 'Share';

  @override
  String shareSong(String title, String artist) {
    return '$title by $artist, live on SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: free 24/7 K-pop radio';
  }

  @override
  String get close => 'Close';

  @override
  String get startListeningToRate => 'Start listening to rate';

  @override
  String get like => 'I like this';

  @override
  String get dislike => 'Not for me';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Top songs';

  @override
  String get albums => 'Albums';

  @override
  String get related => 'You might also like';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepOff => 'Off';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Stops in $minutes min';
  }

  @override
  String get inTheCar => 'In the car';

  @override
  String get carBody =>
      'SeoulFM works with Apple CarPlay and Android Auto. Connect your phone and pick a station on the car’s screen; the steering-wheel skip buttons change station.';

  @override
  String get about => 'About SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM is free 24/7 K-pop radio and a Korean music streaming platform: twelve live stations, and a library of 58,000+ songs, each with lyrics, that you can search and request. A requested song plays live for everyone. On air since 2009, always free.';

  @override
  String get website => 'Website';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Terms';

  @override
  String get contact => 'Contact';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get losslessTitle => 'Lossless FLAC';

  @override
  String losslessUses(int mb) {
    return 'About $mb MB an hour';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Standard quality: about $mb MB an hour';
  }

  @override
  String get losslessFallbackNotice =>
      'Lossless audio uses far more data than standard streaming. Use Wi-Fi or an unlimited data plan.';

  @override
  String get losslessAccept => 'Play lossless';

  @override
  String get losslessDecline => 'Use standard quality';

  @override
  String get losslessFailed =>
      'Lossless isn’t playing, so standard quality is on.';

  @override
  String get retryFlac => 'Retry FLAC';

  @override
  String get marathonOnAir => 'On air this hour';

  @override
  String get marathonQueue => 'Coming up';

  @override
  String get marathonNominations => 'Vote them in';

  @override
  String get marathonVote => 'Vote';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes of $required votes';
  }

  @override
  String get marathonNominate => 'Nominate an artist';

  @override
  String get marathonNominateHint => 'Search artists';

  @override
  String get marathonVoted => 'Vote counted';

  @override
  String get marathonEmpty =>
      'No open nominations. Nominate an artist for the next free hour.';

  @override
  String get marathonVotedIn => 'Voted in';

  @override
  String get marathonIntro =>
      'One group, one full hour. Vote an artist into the next free hour.';

  @override
  String get seeAll => 'See all';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String hoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String inMinutes(int n) {
    return 'in $n min';
  }

  @override
  String get requestBadge => 'Request';

  @override
  String get artistPage => 'Artist page';

  @override
  String get openSong => 'Song page';

  @override
  String get nextStation => 'Next station';

  @override
  String get previousStation => 'Previous station';

  @override
  String get quality => 'Quality';

  @override
  String get qualityAuto => 'Auto (AAC)';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get captchaFailed => 'Couldn’t verify. Try again.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get featuredStations => 'Featured stations';

  @override
  String get genresAndEras => 'Genres & eras';

  @override
  String get playingFrom => 'Playing from';

  @override
  String get chooseStation => 'Choose a station';

  @override
  String get listenNow => 'Listen now';

  @override
  String get showLyrics => 'Show lyrics';
}
