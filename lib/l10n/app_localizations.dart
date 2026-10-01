import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('es', 'ES'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kk'),
    Locale('ko'),
    Locale('ms'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
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

  /// No description provided for @tabRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get tabRequest;

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
  /// **'Search the library, read the lyrics, and request a song to play live.'**
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
  /// **'SeoulFM works with Android Auto. Connect your phone and pick a station on the car’s screen; the steering-wheel skip buttons change station.'**
  String get carBody;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About SeoulFM'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'SeoulFM is free 24/7 K-pop radio and a Korean music streaming platform: twelve live stations, and a library of songs that grows every day, each with lyrics, that you can search and request. A requested song plays live for everyone. On air since 2009, always free.'**
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
  /// **'Auto'**
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

  /// No description provided for @shareCardSong.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get shareCardSong;

  /// No description provided for @editLyrics.
  ///
  /// In en, this message translates to:
  /// **'Edit lyrics'**
  String get editLyrics;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get linkCopied;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareImage;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pickLines.
  ///
  /// In en, this message translates to:
  /// **'Pick up to {count} lines'**
  String pickLines(int count);

  /// No description provided for @goToSong.
  ///
  /// In en, this message translates to:
  /// **'Go to song'**
  String get goToSong;

  /// No description provided for @goToArtist.
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// No description provided for @swipeToRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get swipeToRequest;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get offlineTitle;

  /// No description provided for @serverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get serverErrorTitle;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResultsTitle;

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another spelling, an English or Korean title, or the artist’s name.'**
  String get noResultsBody;

  /// No description provided for @wallEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No dedications yet'**
  String get wallEmptyTitle;

  /// No description provided for @requestTrackerQueued.
  ///
  /// In en, this message translates to:
  /// **'Your request · in the queue'**
  String get requestTrackerQueued;

  /// No description provided for @requestTrackerEta.
  ///
  /// In en, this message translates to:
  /// **'Your request · plays in ~{minutes} min'**
  String requestTrackerEta(int minutes);

  /// No description provided for @requestTrackerNext.
  ///
  /// In en, this message translates to:
  /// **'Your request is up next'**
  String get requestTrackerNext;

  /// No description provided for @requestTrackerPlaying.
  ///
  /// In en, this message translates to:
  /// **'Your request is playing now!'**
  String get requestTrackerPlaying;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'K-pop radio, live and free'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Twelve stations, 24/7, and a library of songs with lyrics that grows every day. Request a song and it plays live for everyone.'**
  String get welcomeBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @pickStationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your stations'**
  String get pickStationsTitle;

  /// No description provided for @pickStationsBody.
  ///
  /// In en, this message translates to:
  /// **'We’ll keep them up front. Change them any time.'**
  String get pickStationsBody;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'You choose what plays next'**
  String get requestsTitle;

  /// No description provided for @requestsBody.
  ///
  /// In en, this message translates to:
  /// **'Find any song and request it. When it plays, everyone listening hears it — and sees your dedication.'**
  String get requestsBody;

  /// No description provided for @startListening.
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get startListening;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @yourStations.
  ///
  /// In en, this message translates to:
  /// **'Your stations'**
  String get yourStations;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Listener-supported'**
  String get supportEyebrow;

  /// No description provided for @supportH1.
  ///
  /// In en, this message translates to:
  /// **'No ads. No paywall.'**
  String get supportH1;

  /// No description provided for @supportH1Sub.
  ///
  /// In en, this message translates to:
  /// **'Kept on air by the people who listen.'**
  String get supportH1Sub;

  /// No description provided for @supportLead.
  ///
  /// In en, this message translates to:
  /// **'SeoulFM is free, and it is going to stay free. There is nothing to sell you and nobody to sell you to. If the station is part of your day, you can help keep it running.'**
  String get supportLead;

  /// No description provided for @supportWhereItGoes.
  ///
  /// In en, this message translates to:
  /// **'Where it goes'**
  String get supportWhereItGoes;

  /// No description provided for @supportCostStreamTitle.
  ///
  /// In en, this message translates to:
  /// **'The stream'**
  String get supportCostStreamTitle;

  /// No description provided for @supportCostStreamBody.
  ///
  /// In en, this message translates to:
  /// **'Twelve channels, on air every hour of every day, delivered worldwide. Lossless audio on HIFI is the most expensive thing we send, and we send it free.'**
  String get supportCostStreamBody;

  /// No description provided for @supportCostLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'The library'**
  String get supportCostLibraryTitle;

  /// No description provided for @supportCostLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Tens of thousands of tracks, stored, tagged and kept in order, with artwork, synced lyrics and broadcast-grade processing on every one.'**
  String get supportCostLibraryBody;

  /// No description provided for @supportCostWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'The work'**
  String get supportCostWorkTitle;

  /// No description provided for @supportCostWorkBody.
  ///
  /// In en, this message translates to:
  /// **'The site, the apps, requests, the wall and the chat, plus the ongoing cost of music licensing. Built and run by a very small team.'**
  String get supportCostWorkBody;

  /// No description provided for @supportStaysTheSame.
  ///
  /// In en, this message translates to:
  /// **'What stays the same'**
  String get supportStaysTheSame;

  /// No description provided for @supportPromiseNoAds.
  ///
  /// In en, this message translates to:
  /// **'No audio ads and no banners. Not now, not later.'**
  String get supportPromiseNoAds;

  /// No description provided for @supportPromiseNothingLocked.
  ///
  /// In en, this message translates to:
  /// **'Nothing is locked. Every channel, request and feature stays free for everyone.'**
  String get supportPromiseNothingLocked;

  /// No description provided for @supportPromiseOptional.
  ///
  /// In en, this message translates to:
  /// **'Supporting is optional and changes nothing about how you listen.'**
  String get supportPromiseOptional;

  /// No description provided for @supportBecome.
  ///
  /// In en, this message translates to:
  /// **'Become a supporter'**
  String get supportBecome;

  /// No description provided for @supportBecomeBody.
  ///
  /// In en, this message translates to:
  /// **'Once, or monthly. Payments go through the App Store or Google Play; we never see your card details.'**
  String get supportBecomeBody;

  /// No description provided for @supportMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly supporter'**
  String get supportMonthly;

  /// No description provided for @supportMonthlyBody.
  ///
  /// In en, this message translates to:
  /// **'Keep a channel on air, every month. Cancel any time.'**
  String get supportMonthlyBody;

  /// No description provided for @supportPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String supportPerMonth(String price);

  /// No description provided for @supportOnce.
  ///
  /// In en, this message translates to:
  /// **'One-time tip'**
  String get supportOnce;

  /// No description provided for @supportTipSmall.
  ///
  /// In en, this message translates to:
  /// **'A coffee'**
  String get supportTipSmall;

  /// No description provided for @supportTipMedium.
  ///
  /// In en, this message translates to:
  /// **'A lunch'**
  String get supportTipMedium;

  /// No description provided for @supportTipLarge.
  ///
  /// In en, this message translates to:
  /// **'A night out'**
  String get supportTipLarge;

  /// No description provided for @supportRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get supportRestore;

  /// No description provided for @supportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Support through the store isn’t available right now. Try again later.'**
  String get supportUnavailable;

  /// No description provided for @supportThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get supportThanksTitle;

  /// No description provided for @supportThanksBody.
  ///
  /// In en, this message translates to:
  /// **'You’re helping keep SeoulFM free for everyone.'**
  String get supportThanksBody;

  /// No description provided for @supportYouAreSupporter.
  ///
  /// In en, this message translates to:
  /// **'You’re a supporter. Thank you.'**
  String get supportYouAreSupporter;

  /// No description provided for @supportFreeWays.
  ///
  /// In en, this message translates to:
  /// **'Not in a position to give? Listening counts. So does requesting a song, leaving a note on the wall, or sending the station to one friend who would love it.'**
  String get supportFreeWays;

  /// No description provided for @supportCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep SeoulFM free'**
  String get supportCardTitle;

  /// No description provided for @supportCardBody.
  ///
  /// In en, this message translates to:
  /// **'No ads, no paywall — kept on air by listeners like you.'**
  String get supportCardBody;

  /// No description provided for @supportSubscriptionTerms.
  ///
  /// In en, this message translates to:
  /// **'Monthly support renews automatically until cancelled in your store account settings.'**
  String get supportSubscriptionTerms;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use system language'**
  String get languageSystem;

  /// No description provided for @qualityAutoBody.
  ///
  /// In en, this message translates to:
  /// **'The best your connection holds. Steps down if it struggles.'**
  String get qualityAutoBody;

  /// No description provided for @qualityVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get qualityVeryHigh;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get qualityHigh;

  /// No description provided for @qualityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get qualityNormal;

  /// No description provided for @qualityDataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data saver'**
  String get qualityDataSaver;

  /// No description provided for @qualityFixedBody.
  ///
  /// In en, this message translates to:
  /// **'Always this quality, even on a weak connection.'**
  String get qualityFixedBody;

  /// No description provided for @qualityLosslessNote.
  ///
  /// In en, this message translates to:
  /// **'HIFI plays lossless FLAC when you accept its notice.'**
  String get qualityLosslessNote;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @reportDedication.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportDedication;

  /// No description provided for @hideDedicationsFrom.
  ///
  /// In en, this message translates to:
  /// **'Hide dedications from {name}'**
  String hideDedicationsFrom(String name);

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for telling us. We’ll take a look.'**
  String get reportThanks;

  /// No description provided for @showHiddenDedications.
  ///
  /// In en, this message translates to:
  /// **'Show hidden dedications'**
  String get showHiddenDedications;

  /// No description provided for @verifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t verify. Check your connection and try again.'**
  String get verifyFailed;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Your purchases are restored.'**
  String get restoreDone;

  /// No description provided for @restoreNothing.
  ///
  /// In en, this message translates to:
  /// **'There are no purchases to restore.'**
  String get restoreNothing;

  /// No description provided for @playbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Can’t reach the stream. Check your connection and try again.'**
  String get playbackFailed;

  /// No description provided for @audioOutput.
  ///
  /// In en, this message translates to:
  /// **'Audio output'**
  String get audioOutput;

  /// No description provided for @openPlayer.
  ///
  /// In en, this message translates to:
  /// **'Open player'**
  String get openPlayer;

  /// No description provided for @songsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 song} other{{count} songs}}'**
  String songsCount(int count);

  /// No description provided for @stationsFolder.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stationsFolder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'kk',
    'ko',
    'ms',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case 'ES':
            return AppLocalizationsEsEs();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kk':
      return AppLocalizationsKk();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
