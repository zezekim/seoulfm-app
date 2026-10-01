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
      'Search the library, read the lyrics, and request a song to play live.';

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
      'SeoulFM works with Android Auto. Connect your phone and pick a station on the car’s screen; the steering-wheel skip buttons change station.';

  @override
  String get about => 'About SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM is free 24/7 K-pop radio and a Korean music streaming platform: twelve live stations, and a library of songs that grows every day, each with lyrics, that you can search and request. A requested song plays live for everyone. On air since 2009, always free.';

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
  String get qualityAuto => 'Auto';

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

  @override
  String get shareCardSong => 'Song';

  @override
  String get editLyrics => 'Edit lyrics';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Copied';

  @override
  String get shareImage => 'Share image';

  @override
  String get done => 'Done';

  @override
  String pickLines(int count) {
    return 'Pick up to $count lines';
  }

  @override
  String get goToSong => 'Go to song';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get swipeToRequest => 'Request';

  @override
  String get offlineTitle => 'You’re offline';

  @override
  String get serverErrorTitle => 'Something went wrong';

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsBody =>
      'Try another spelling, an English or Korean title, or the artist’s name.';

  @override
  String get wallEmptyTitle => 'No dedications yet';

  @override
  String get requestTrackerQueued => 'Your request · in the queue';

  @override
  String requestTrackerEta(int minutes) {
    return 'Your request · plays in ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Your request is up next';

  @override
  String get requestTrackerPlaying => 'Your request is playing now!';

  @override
  String get welcomeTitle => 'K-pop radio, live and free';

  @override
  String get welcomeBody =>
      'Twelve stations, 24/7, and a library of songs with lyrics that grows every day. Request a song and it plays live for everyone.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get pickStationsTitle => 'Pick your stations';

  @override
  String get pickStationsBody =>
      'We’ll keep them up front. Change them any time.';

  @override
  String get requestsTitle => 'You choose what plays next';

  @override
  String get requestsBody =>
      'Find any song and request it. When it plays, everyone listening hears it — and sees your dedication.';

  @override
  String get startListening => 'Start listening';

  @override
  String get skip => 'Skip';

  @override
  String get yourStations => 'Your stations';

  @override
  String get support => 'Support';

  @override
  String get supportEyebrow => 'Listener-supported';

  @override
  String get supportH1 => 'No ads. No paywall.';

  @override
  String get supportH1Sub => 'Kept on air by the people who listen.';

  @override
  String get supportLead =>
      'SeoulFM is free, and it is going to stay free. There is nothing to sell you and nobody to sell you to. If the station is part of your day, you can help keep it running.';

  @override
  String get supportWhereItGoes => 'Where it goes';

  @override
  String get supportCostStreamTitle => 'The stream';

  @override
  String get supportCostStreamBody =>
      'Twelve channels, on air every hour of every day, delivered worldwide. Lossless audio on HIFI is the most expensive thing we send, and we send it free.';

  @override
  String get supportCostLibraryTitle => 'The library';

  @override
  String get supportCostLibraryBody =>
      'Tens of thousands of tracks, stored, tagged and kept in order, with artwork, synced lyrics and broadcast-grade processing on every one.';

  @override
  String get supportCostWorkTitle => 'The work';

  @override
  String get supportCostWorkBody =>
      'The site, the apps, requests, the wall and the chat, plus the ongoing cost of music licensing. Built and run by a very small team.';

  @override
  String get supportStaysTheSame => 'What stays the same';

  @override
  String get supportPromiseNoAds =>
      'No audio ads and no banners. Not now, not later.';

  @override
  String get supportPromiseNothingLocked =>
      'Nothing is locked. Every channel, request and feature stays free for everyone.';

  @override
  String get supportPromiseOptional =>
      'Supporting is optional and changes nothing about how you listen.';

  @override
  String get supportBecome => 'Become a supporter';

  @override
  String get supportBecomeBody =>
      'Once, or monthly. Payments go through the App Store or Google Play; we never see your card details.';

  @override
  String get supportMonthly => 'Monthly supporter';

  @override
  String get supportMonthlyBody =>
      'Keep a channel on air, every month. Cancel any time.';

  @override
  String supportPerMonth(String price) {
    return '$price / month';
  }

  @override
  String get supportOnce => 'One-time tip';

  @override
  String get supportTipSmall => 'A coffee';

  @override
  String get supportTipMedium => 'A lunch';

  @override
  String get supportTipLarge => 'A night out';

  @override
  String get supportRestore => 'Restore purchases';

  @override
  String get supportUnavailable =>
      'Support through the store isn’t available right now. Try again later.';

  @override
  String get supportThanksTitle => 'Thank you';

  @override
  String get supportThanksBody =>
      'You’re helping keep SeoulFM free for everyone.';

  @override
  String get supportYouAreSupporter => 'You’re a supporter. Thank you.';

  @override
  String get supportFreeWays =>
      'Not in a position to give? Listening counts. So does requesting a song, leaving a note on the wall, or sending the station to one friend who would love it.';

  @override
  String get supportCardTitle => 'Keep SeoulFM free';

  @override
  String get supportCardBody =>
      'No ads, no paywall — kept on air by listeners like you.';

  @override
  String get supportSubscriptionTerms =>
      'Monthly support renews automatically until cancelled in your store account settings.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Use system language';

  @override
  String get qualityAutoBody =>
      'The best your connection holds. Steps down if it struggles.';

  @override
  String get qualityVeryHigh => 'Very high';

  @override
  String get qualityHigh => 'High';

  @override
  String get qualityNormal => 'Normal';

  @override
  String get qualityDataSaver => 'Data saver';

  @override
  String get qualityFixedBody =>
      'Always this quality, even on a weak connection.';

  @override
  String get qualityLosslessNote =>
      'HIFI plays lossless FLAC when you accept its notice.';

  @override
  String get moreOptions => 'More options';

  @override
  String get reportDedication => 'Report';

  @override
  String hideDedicationsFrom(String name) {
    return 'Hide dedications from $name';
  }

  @override
  String get reportThanks => 'Thanks for telling us. We’ll take a look.';

  @override
  String get showHiddenDedications => 'Show hidden dedications';

  @override
  String get verifyFailed =>
      'Couldn’t verify. Check your connection and try again.';

  @override
  String get restoreDone => 'Your purchases are restored.';

  @override
  String get restoreNothing => 'There are no purchases to restore.';

  @override
  String get playbackFailed =>
      'Can’t reach the stream. Check your connection and try again.';

  @override
  String get audioOutput => 'Audio output';

  @override
  String get openPlayer => 'Open player';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Stations';

  @override
  String get spatialAudioBody =>
      'SeoulFM is mixed for headphones with BS2B (Bauer stereophonic-to-binaural) crossfeed. A little of each channel reaches the other ear, as it would from speakers in a room, so the sound feels wider, more natural and easier on the ears for hours.';
}
