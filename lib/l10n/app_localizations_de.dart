// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Start';

  @override
  String get tabRequest => 'Wünschen';

  @override
  String get tabCharts => 'Charts';

  @override
  String get tabWall => 'Widmungen';

  @override
  String get tabMore => 'Mehr';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Nicht auf Sendung';

  @override
  String get stationBreak => 'Kurze Pause. Wir sind gleich zurück.';

  @override
  String get nowPlaying => 'Läuft gerade';

  @override
  String get upNext => 'Als Nächstes';

  @override
  String get stations => 'Sender';

  @override
  String get recentlyPlayed => 'Zuletzt gespielt';

  @override
  String get requestASong => 'Song wünschen';

  @override
  String get requestHint =>
      'Such dir einen Song aus, und er läuft live für alle.';

  @override
  String get searchHint => 'Songs, Artists, Alben';

  @override
  String searchEmpty(String query) {
    return 'Keine Treffer für „$query“';
  }

  @override
  String get searchIntro =>
      'Durchsuche über 58.000 Songs, lies die Songtexte mit und wünsch dir einen, der live läuft.';

  @override
  String get newSongs => 'Neu auf SeoulFM';

  @override
  String get songs => 'Songs';

  @override
  String get artists => 'Artists';

  @override
  String get play => 'Abspielen';

  @override
  String get pause => 'Pause';

  @override
  String get request => 'Wünschen';

  @override
  String get requestTitle => 'Diesen Song wünschen';

  @override
  String get yourName => 'Dein Name (optional)';

  @override
  String get dedication => 'Widmung (optional)';

  @override
  String get sendRequest => 'Wunsch senden';

  @override
  String get verifying => 'Überprüfung läuft…';

  @override
  String get requestAccepted => 'Wunsch gesendet!';

  @override
  String etaMinutes(int minutes) {
    return 'Läuft in etwa $minutes Min.';
  }

  @override
  String get etaSoon => 'Läuft gleich';

  @override
  String requestQueued(String title) {
    return '„$title“ ist in der Warteschlange';
  }

  @override
  String requestScheduled(String title) {
    return '„$title“ kommt als Nächstes';
  }

  @override
  String requestPlayed(String title) {
    return '„$title“ läuft jetzt';
  }

  @override
  String requestExpired(String title) {
    return '„$title“ konnte diesmal nicht laufen';
  }

  @override
  String get notRequestable => 'Gerade nicht wünschbar';

  @override
  String get errorGeneric => 'Etwas ist schiefgelaufen. Versuch es noch mal.';

  @override
  String get offline => 'SeoulFM ist nicht erreichbar. Prüf deine Verbindung.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get chartsWeekly => 'Diese Woche';

  @override
  String get chartsHot => 'Hot';

  @override
  String get chartsRequested => 'Meistgewünscht';

  @override
  String get chartsTrending => 'Im Trend';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-mal gespielt',
      one: '1-mal gespielt',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wünsche',
      one: '1 Wunsch',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NEU';

  @override
  String get dedicationsEmpty =>
      'Noch keine Widmungen. Wünsch dir einen Song und schreib eine dazu.';

  @override
  String dedicatedBy(String name) {
    return 'Gewidmet von $name';
  }

  @override
  String get lyrics => 'Songtext';

  @override
  String get lyricsNone => 'Für diesen Song gibt es noch keinen Songtext.';

  @override
  String get share => 'Teilen';

  @override
  String shareSong(String title, String artist) {
    return '$title von $artist, live auf SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: kostenloses K-Pop-Radio rund um die Uhr';
  }

  @override
  String get close => 'Schließen';

  @override
  String get startListeningToRate => 'Hör zu, um zu bewerten';

  @override
  String get like => 'Gefällt mir';

  @override
  String get dislike => 'Nicht mein Ding';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Top-Songs';

  @override
  String get albums => 'Alben';

  @override
  String get related => 'Das könnte dir auch gefallen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get sleepTimer => 'Sleep-Timer';

  @override
  String get sleepOff => 'Aus';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Stoppt in $minutes Min.';
  }

  @override
  String get inTheCar => 'Im Auto';

  @override
  String get carBody =>
      'SeoulFM funktioniert mit Apple CarPlay und Android Auto. Verbinde dein Handy und wähl einen Sender auf dem Display deines Autos; mit den Skip-Tasten am Lenkrad wechselst du den Sender.';

  @override
  String get about => 'Über SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM ist kostenloses K-Pop-Radio rund um die Uhr und eine Streaming-Plattform für koreanische Musik: zwölf Live-Sender und eine Bibliothek mit über 58.000 Songs, alle mit Songtext, die du durchsuchen und dir wünschen kannst. Ein gewünschter Song läuft live für alle. Auf Sendung seit 2009, immer kostenlos.';

  @override
  String get website => 'Website';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get terms => 'Nutzungsbedingungen';

  @override
  String get contact => 'Kontakt';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get losslessTitle => 'Verlustfreies FLAC';

  @override
  String losslessUses(int mb) {
    return 'Etwa $mb MB pro Stunde';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Standardqualität: etwa $mb MB pro Stunde';
  }

  @override
  String get losslessFallbackNotice =>
      'Verlustfreies Audio braucht viel mehr Daten als der normale Stream. Am besten im WLAN oder mit einer Flatrate.';

  @override
  String get losslessAccept => 'Verlustfrei abspielen';

  @override
  String get losslessDecline => 'Standardqualität nutzen';

  @override
  String get losslessFailed =>
      'Verlustfrei läuft gerade nicht, deshalb ist Standardqualität an.';

  @override
  String get retryFlac => 'FLAC erneut versuchen';

  @override
  String get marathonOnAir => 'Diese Stunde auf Sendung';

  @override
  String get marathonQueue => 'Demnächst';

  @override
  String get marathonNominations => 'Stimm sie rein';

  @override
  String get marathonVote => 'Abstimmen';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes von $required Stimmen';
  }

  @override
  String get marathonNominate => 'Act nominieren';

  @override
  String get marathonNominateHint => 'Artists suchen';

  @override
  String get marathonVoted => 'Stimme gezählt';

  @override
  String get marathonEmpty =>
      'Keine offenen Nominierungen. Nominier einen Act für die nächste freie Stunde.';

  @override
  String get marathonVotedIn => 'Gewählt';

  @override
  String get marathonIntro =>
      'Eine Gruppe, eine ganze Stunde. Stimm einen Act in die nächste freie Stunde.';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get justNow => 'gerade eben';

  @override
  String minutesAgo(int n) {
    return 'vor $n Min.';
  }

  @override
  String hoursAgo(int n) {
    return 'vor $n Std.';
  }

  @override
  String inMinutes(int n) {
    return 'in $n Min.';
  }

  @override
  String get requestBadge => 'Wunsch';

  @override
  String get artistPage => 'Artist-Seite';

  @override
  String get openSong => 'Song-Seite';

  @override
  String get nextStation => 'Nächster Sender';

  @override
  String get previousStation => 'Vorheriger Sender';

  @override
  String get quality => 'Qualität';

  @override
  String get qualityAuto => 'Auto (AAC)';

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get captchaFailed =>
      'Überprüfung fehlgeschlagen. Versuch es noch mal.';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get featuredStations => 'Empfohlene Sender';

  @override
  String get genresAndEras => 'Genres & Epochen';

  @override
  String get playingFrom => 'Läuft auf';

  @override
  String get chooseStation => 'Sender wählen';

  @override
  String get listenNow => 'Jetzt hören';

  @override
  String get showLyrics => 'Songtext zeigen';

  @override
  String get shareCardSong => 'Song';

  @override
  String get editLyrics => 'Zeilen wählen';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get linkCopied => 'Kopiert';

  @override
  String get shareImage => 'Bild teilen';

  @override
  String get done => 'Fertig';

  @override
  String pickLines(int count) {
    return 'Wähl bis zu $count Zeilen';
  }

  @override
  String get goToSong => 'Zum Song';

  @override
  String get goToArtist => 'Zum Artist';

  @override
  String get swipeToRequest => 'Wünschen';

  @override
  String get offlineTitle => 'Du bist offline';

  @override
  String get serverErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get noResultsTitle => 'Keine Ergebnisse';

  @override
  String get noResultsBody =>
      'Probier eine andere Schreibweise, einen englischen oder koreanischen Titel oder den Namen des Artists.';

  @override
  String get wallEmptyTitle => 'Noch keine Widmungen';

  @override
  String get requestTrackerQueued => 'Dein Wunsch · in der Warteschlange';

  @override
  String requestTrackerEta(int minutes) {
    return 'Dein Wunsch · läuft in ~$minutes Min.';
  }

  @override
  String get requestTrackerNext => 'Dein Wunsch kommt als Nächstes';

  @override
  String get requestTrackerPlaying => 'Dein Wunsch läuft gerade!';

  @override
  String get welcomeTitle => 'K-Pop-Radio, live und kostenlos';

  @override
  String get welcomeBody =>
      'Zwölf Sender, rund um die Uhr, und über 58.000 Songs mit Songtext. Wünsch dir einen Song, und er läuft live für alle.';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get pickStationsTitle => 'Wähl deine Sender';

  @override
  String get pickStationsBody =>
      'Wir zeigen sie dir ganz vorn. Du kannst sie jederzeit ändern.';

  @override
  String get requestsTitle => 'Du bestimmst, was als Nächstes läuft';

  @override
  String get requestsBody =>
      'Such dir einen Song und wünsch ihn dir. Wenn er läuft, hören ihn alle, die zuhören — und sehen deine Widmung.';

  @override
  String get startListening => 'Los geht’s';

  @override
  String get skip => 'Überspringen';

  @override
  String get yourStations => 'Deine Sender';

  @override
  String get support => 'Unterstützen';

  @override
  String get supportEyebrow => 'Von Hörern getragen';

  @override
  String get supportH1 => 'Keine Werbung. Keine Paywall.';

  @override
  String get supportH1Sub =>
      'Auf Sendung gehalten von den Leuten, die zuhören.';

  @override
  String get supportLead =>
      'SeoulFM ist kostenlos und bleibt kostenlos. Wir wollen dir nichts verkaufen und dich an niemanden verkaufen. Wenn der Sender zu deinem Tag gehört, kannst du helfen, ihn am Laufen zu halten.';

  @override
  String get supportWhereItGoes => 'Wofür das Geld ist';

  @override
  String get supportCostStreamTitle => 'Der Stream';

  @override
  String get supportCostStreamBody =>
      'Zwölf Sender, jede Stunde jedes Tages auf Sendung, weltweit ausgeliefert. Verlustfreies Audio auf HIFI ist das Teuerste, was wir senden, und wir senden es kostenlos.';

  @override
  String get supportCostLibraryTitle => 'Die Bibliothek';

  @override
  String get supportCostLibraryBody =>
      'Zehntausende Songs, gespeichert, getaggt und in Ordnung gehalten, jeder mit Cover, synchronem Songtext und Bearbeitung in Sendequalität.';

  @override
  String get supportCostWorkTitle => 'Die Arbeit';

  @override
  String get supportCostWorkBody =>
      'Die Website, die Apps, Wünsche, die Pinnwand und der Chat, dazu die laufenden Kosten für Musiklizenzen. Gebaut und betrieben von einem sehr kleinen Team.';

  @override
  String get supportStaysTheSame => 'Was gleich bleibt';

  @override
  String get supportPromiseNoAds =>
      'Keine Audiowerbung und keine Banner. Nicht jetzt, nicht später.';

  @override
  String get supportPromiseNothingLocked =>
      'Nichts ist gesperrt. Jeder Sender, jeder Wunsch und jede Funktion bleibt für alle kostenlos.';

  @override
  String get supportPromiseOptional =>
      'Unterstützen ist freiwillig und ändert nichts daran, wie du hörst.';

  @override
  String get supportBecome => 'Werde Unterstützer';

  @override
  String get supportBecomeBody =>
      'Einmalig oder monatlich. Die Zahlung läuft über den App Store oder Google Play; deine Kartendaten sehen wir nie.';

  @override
  String get supportMonthly => 'Monatlich unterstützen';

  @override
  String get supportMonthlyBody =>
      'Halte jeden Monat einen Sender auf Sendung. Jederzeit kündbar.';

  @override
  String supportPerMonth(String price) {
    return '$price / Monat';
  }

  @override
  String get supportOnce => 'Einmaliges Trinkgeld';

  @override
  String get supportTipSmall => 'Ein Kaffee';

  @override
  String get supportTipMedium => 'Ein Mittagessen';

  @override
  String get supportTipLarge => 'Ein Abend aus';

  @override
  String get supportRestore => 'Käufe wiederherstellen';

  @override
  String get supportUnavailable =>
      'Unterstützen über den Store ist bald möglich. Danke, dass du helfen willst.';

  @override
  String get supportThanksTitle => 'Danke';

  @override
  String get supportThanksBody =>
      'Du hilfst, SeoulFM für alle kostenlos zu halten.';

  @override
  String get supportYouAreSupporter => 'Du bist Unterstützer. Danke.';

  @override
  String get supportFreeWays =>
      'Gerade kein Geld übrig? Zuhören zählt. Genauso wie dir einen Song zu wünschen, eine Nachricht auf der Pinnwand zu hinterlassen oder den Sender einer Freundin oder einem Freund zu schicken, die ihn lieben würden.';

  @override
  String get supportCardTitle => 'Halte SeoulFM kostenlos';

  @override
  String get supportCardBody =>
      'Keine Werbung, keine Paywall — auf Sendung gehalten von Hörern wie dir.';

  @override
  String get supportSubscriptionTerms =>
      'Die monatliche Unterstützung verlängert sich automatisch, bis du sie in den Einstellungen deines Store-Kontos kündigst.';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache verwenden';
}
