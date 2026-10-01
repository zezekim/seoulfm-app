import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SeoulFM'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get tabCharts;

  /// No description provided for @tabWall.
  ///
  /// In en, this message translates to:
  /// **'Dedications'**
  String get tabWall;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @offAir.
  ///
  /// In en, this message translates to:
  /// **'Off air'**
  String get offAir;

  /// No description provided for @stationBreak.
  ///
  /// In en, this message translates to:
  /// **'Station break. Back in a moment.'**
  String get stationBreak;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get upNext;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get recentlyPlayed;

  /// No description provided for @requestASong.
  ///
  /// In en, this message translates to:
  /// **'Request a song'**
  String get requestASong;

  /// No description provided for @requestHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a song and it plays live for everyone.'**
  String get requestHint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Songs, artists, albums'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matches for “{query}”'**
  String searchEmpty(String query);

  /// No description provided for @searchIntro.
  ///
  /// In en, this message translates to:
  /// **'Search 58,000+ songs, read the lyrics, and request one to play live.'**
  String get searchIntro;

  /// No description provided for @newSongs.
  ///
  /// In en, this message translates to:
  /// **'New on SeoulFM'**
  String get newSongs;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artists;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @requestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request this song'**
  String get requestTitle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get yourName;

  /// No description provided for @dedication.
  ///
  /// In en, this message translates to:
  /// **'Dedication (optional)'**
  String get dedication;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Checking you’re human…'**
  String get verifying;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Requested!'**
  String get requestAccepted;

  /// No description provided for @etaMinutes.
  ///
  /// In en, this message translates to:
  /// **'Plays in about {minutes} min'**
  String etaMinutes(int minutes);

  /// No description provided for @etaSoon.
  ///
  /// In en, this message translates to:
  /// **'Plays soon'**
  String get etaSoon;

  /// No description provided for @requestQueued.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is in the queue'**
  String requestQueued(String title);

  /// No description provided for @requestScheduled.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is coming up'**
  String requestScheduled(String title);

  /// No description provided for @requestPlayed.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is on air now'**
  String requestPlayed(String title);

  /// No description provided for @requestExpired.
  ///
  /// In en, this message translates to:
  /// **'“{title}” couldn’t be played this time'**
  String requestExpired(String title);

  /// No description provided for @notRequestable.
  ///
  /// In en, this message translates to:
  /// **'Not requestable right now'**
  String get notRequestable;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Can’t reach SeoulFM. Check your connection.'**
  String get offline;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @chartsWeekly.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get chartsWeekly;

  /// No description provided for @chartsHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get chartsHot;

  /// No description provided for @chartsRequested.
  ///
  /// In en, this message translates to:
  /// **'Most requested'**
  String get chartsRequested;

  /// No description provided for @chartsTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get chartsTrending;

  /// No description provided for @plays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 play} other{{count} plays}}'**
  String plays(int count);

  /// No description provided for @requestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request} other{{count} requests}}'**
  String requestsCount(int count);

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newEntry;

  /// No description provided for @dedicationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dedications yet. Request a song and add one.'**
  String get dedicationsEmpty;

  /// No description provided for @dedicatedBy.
  ///
  /// In en, this message translates to:
  /// **'Dedicated by {name}'**
  String dedicatedBy(String name);

  /// No description provided for @lyrics.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyrics;

  /// No description provided for @lyricsNone.
  ///
  /// In en, this message translates to:
  /// **'No lyrics for this song yet.'**
  String get lyricsNone;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareSong.
  ///
  /// In en, this message translates to:
  /// **'{title} by {artist}, live on SeoulFM'**
  String shareSong(String title, String artist);

  /// No description provided for @shareStation.
  ///
  /// In en, this message translates to:
  /// **'SeoulFM {name}: free 24/7 K-pop radio'**
  String shareStation(String name);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @startListeningToRate.
  ///
  /// In en, this message translates to:
  /// **'Start listening to rate'**
  String get startListeningToRate;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'I like this'**
  String get like;

  /// No description provided for @dislike.
  ///
  /// In en, this message translates to:
  /// **'Not for me'**
  String get dislike;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @topTracks.
  ///
  /// In en, this message translates to:
  /// **'Top songs'**
  String get topTracks;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @related.
  ///
  /// In en, this message translates to:
  /// **'You might also like'**
  String get related;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepOff;

  /// No description provided for @sleepMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepMinutes(int minutes);

  /// No description provided for @sleepStopsIn.
  ///
  /// In en, this message translates to:
  /// **'Stops in {minutes} min'**
  String sleepStopsIn(int minutes);

  /// No description provided for @inTheCar.
  ///
  /// In en, this message translates to:
  /// **'In the car'**
  String get inTheCar;

  /// No description provided for @carBody.
  ///
  /// In en, this message translates to:
  /// **'SeoulFM works with Apple CarPlay and Android Auto. Connect your phone and pick a station on the car’s screen; the steering-wheel skip buttons change station.'**
  String get carBody;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About SeoulFM'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'SeoulFM is free 24/7 K-pop radio and a Korean music streaming platform: twelve live stations, and a library of 58,000+ songs, each with lyrics, that you can search and request. A requested song plays live for everyone. On air since 2009, always free.'**
  String get aboutBody;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @losslessTitle.
  ///
  /// In en, this message translates to:
  /// **'Lossless FLAC'**
  String get losslessTitle;

  /// No description provided for @losslessUses.
  ///
  /// In en, this message translates to:
  /// **'About {mb} MB an hour'**
  String losslessUses(int mb);

  /// No description provided for @losslessUsesAac.
  ///
  /// In en, this message translates to:
  /// **'Standard quality: about {mb} MB an hour'**
  String losslessUsesAac(int mb);

  /// No description provided for @losslessFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'Lossless audio uses far more data than standard streaming. Use Wi-Fi or an unlimited data plan.'**
  String get losslessFallbackNotice;

  /// No description provided for @losslessAccept.
  ///
  /// In en, this message translates to:
  /// **'Play lossless'**
  String get losslessAccept;

  /// No description provided for @losslessDecline.
  ///
  /// In en, this message translates to:
  /// **'Use standard quality'**
  String get losslessDecline;

  /// No description provided for @losslessFailed.
  ///
  /// In en, this message translates to:
  /// **'Lossless isn’t playing, so standard quality is on.'**
  String get losslessFailed;

  /// No description provided for @retryFlac.
  ///
  /// In en, this message translates to:
  /// **'Retry FLAC'**
  String get retryFlac;

  /// No description provided for @marathonOnAir.
  ///
  /// In en, this message translates to:
  /// **'On air this hour'**
  String get marathonOnAir;

  /// No description provided for @marathonQueue.
  ///
  /// In en, this message translates to:
  /// **'Coming up'**
  String get marathonQueue;

  /// No description provided for @marathonNominations.
  ///
  /// In en, this message translates to:
  /// **'Vote them in'**
  String get marathonNominations;

  /// No description provided for @marathonVote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get marathonVote;

  /// No description provided for @marathonVotes.
  ///
  /// In en, this message translates to:
  /// **'{votes} of {required} votes'**
  String marathonVotes(int votes, int required);

  /// No description provided for @marathonNominate.
  ///
  /// In en, this message translates to:
  /// **'Nominate an artist'**
  String get marathonNominate;

  /// No description provided for @marathonNominateHint.
  ///
  /// In en, this message translates to:
  /// **'Search artists'**
  String get marathonNominateHint;

  /// No description provided for @marathonVoted.
  ///
  /// In en, this message translates to:
  /// **'Vote counted'**
  String get marathonVoted;

  /// No description provided for @marathonEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open nominations. Nominate an artist for the next free hour.'**
  String get marathonEmpty;

  /// No description provided for @marathonVotedIn.
  ///
  /// In en, this message translates to:
  /// **'Voted in'**
  String get marathonVotedIn;

  /// No description provided for @marathonIntro.
  ///
  /// In en, this message translates to:
  /// **'One group, one full hour. Vote an artist into the next free hour.'**
  String get marathonIntro;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String hoursAgo(int n);

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {n} min'**
  String inMinutes(int n);

  /// No description provided for @requestBadge.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestBadge;

  /// No description provided for @artistPage.
  ///
  /// In en, this message translates to:
  /// **'Artist page'**
  String get artistPage;

  /// No description provided for @openSong.
  ///
  /// In en, this message translates to:
  /// **'Song page'**
  String get openSong;

  /// No description provided for @nextStation.
  ///
  /// In en, this message translates to:
  /// **'Next station'**
  String get nextStation;

  /// No description provided for @previousStation.
  ///
  /// In en, this message translates to:
  /// **'Previous station'**
  String get previousStation;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @qualityAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (AAC)'**
  String get qualityAuto;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @captchaFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t verify. Try again.'**
  String get captchaFailed;

  /// No description provided for @tabNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get tabNowPlaying;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @featuredStations.
  ///
  /// In en, this message translates to:
  /// **'Featured stations'**
  String get featuredStations;

  /// No description provided for @genresAndEras.
  ///
  /// In en, this message translates to:
  /// **'Genres & eras'**
  String get genresAndEras;

  /// No description provided for @playingFrom.
  ///
  /// In en, this message translates to:
  /// **'Playing from'**
  String get playingFrom;

  /// No description provided for @chooseStation.
  ///
  /// In en, this message translates to:
  /// **'Choose a station'**
  String get chooseStation;

  /// No description provided for @listenNow.
  ///
  /// In en, this message translates to:
  /// **'Listen now'**
  String get listenNow;

  /// No description provided for @showLyrics.
  ///
  /// In en, this message translates to:
  /// **'Show lyrics'**
  String get showLyrics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
