// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Start';

  @override
  String get tabRequest => 'Zamów';

  @override
  String get tabCharts => 'Listy';

  @override
  String get tabWall => 'Dedykacje';

  @override
  String get tabMore => 'Więcej';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Poza anteną';

  @override
  String get stationBreak => 'Stacja ma krótką przerwę. Zaraz wracamy.';

  @override
  String get nowPlaying => 'Teraz gra';

  @override
  String get upNext => 'Następne';

  @override
  String get stations => 'Stacje';

  @override
  String get recentlyPlayed => 'Ostatnio grane';

  @override
  String get requestASong => 'Zamów utwór';

  @override
  String get requestHint => 'Wybierz utwór, a zagra na żywo dla wszystkich.';

  @override
  String get searchHint => 'Utwory, artyści, albumy';

  @override
  String searchEmpty(String query) {
    return 'Brak wyników dla „$query”';
  }

  @override
  String get searchIntro =>
      'Przeszukaj bibliotekę, czytaj teksty i zamów utwór, który zagra na żywo.';

  @override
  String get newSongs => 'Nowości w SeoulFM';

  @override
  String get songs => 'Utwory';

  @override
  String get artists => 'Artyści';

  @override
  String get play => 'Odtwórz';

  @override
  String get pause => 'Pauza';

  @override
  String get request => 'Zamów';

  @override
  String get requestTitle => 'Zamów ten utwór';

  @override
  String get yourName => 'Twoje imię (opcjonalnie)';

  @override
  String get dedication => 'Dedykacja (opcjonalnie)';

  @override
  String get sendRequest => 'Wyślij zamówienie';

  @override
  String get verifying => 'Sprawdzamy, czy nie jesteś robotem…';

  @override
  String get requestAccepted => 'Zamówione!';

  @override
  String etaMinutes(int minutes) {
    return 'Zagra za około $minutes min';
  }

  @override
  String get etaSoon => 'Zagra wkrótce';

  @override
  String requestQueued(String title) {
    return '„$title” jest w kolejce';
  }

  @override
  String requestScheduled(String title) {
    return '„$title” zaraz zagra';
  }

  @override
  String requestPlayed(String title) {
    return '„$title” jest teraz na antenie';
  }

  @override
  String requestExpired(String title) {
    return 'Tym razem nie udało się zagrać „$title”';
  }

  @override
  String get notRequestable => 'Teraz nie do zamówienia';

  @override
  String get errorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get offline => 'Nie można połączyć się z SeoulFM. Sprawdź połączenie.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get chartsWeekly => 'Ten tydzień';

  @override
  String get chartsHot => 'Na topie';

  @override
  String get chartsRequested => 'Najczęściej zamawiane';

  @override
  String get chartsTrending => 'Zyskujące';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odtworzenia',
      many: '$count odtworzeń',
      few: '$count odtworzenia',
      one: '$count odtworzenie',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zamówienia',
      many: '$count zamówień',
      few: '$count zamówienia',
      one: '$count zamówienie',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NOWOŚĆ';

  @override
  String get dedicationsEmpty => 'Brak dedykacji. Zamów utwór i dodaj swoją.';

  @override
  String dedicatedBy(String name) {
    return 'Dedykacja od: $name';
  }

  @override
  String get lyrics => 'Tekst';

  @override
  String get lyricsNone => 'Ten utwór nie ma jeszcze tekstu.';

  @override
  String get share => 'Udostępnij';

  @override
  String shareSong(String title, String artist) {
    return '„$title” – $artist, na żywo w SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: darmowe radio K-pop 24/7';
  }

  @override
  String get close => 'Zamknij';

  @override
  String get startListeningToRate => 'Zacznij słuchać, aby ocenić';

  @override
  String get like => 'Lubię ten utwór';

  @override
  String get dislike => 'Nie dla mnie';

  @override
  String get hot => 'Na topie';

  @override
  String get topTracks => 'Top utwory';

  @override
  String get albums => 'Albumy';

  @override
  String get related => 'Może ci się spodobać';

  @override
  String get settings => 'Ustawienia';

  @override
  String get theme => 'Motyw';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeLight => 'Jasny';

  @override
  String get sleepTimer => 'Wyłącznik czasowy';

  @override
  String get sleepOff => 'Wyłączony';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Wyłączy się za $minutes min';
  }

  @override
  String get inTheCar => 'W samochodzie';

  @override
  String get carBody =>
      'SeoulFM działa z Android Auto. Połącz telefon i wybierz stację na ekranie samochodu; przyciski przewijania na kierownicy zmieniają stację.';

  @override
  String get about => 'O SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM to darmowe radio K-pop 24/7 i platforma do streamingu muzyki koreańskiej: dwanaście stacji na żywo i codziennie rosnąca biblioteka utworów, każdy z tekstem, które możesz wyszukiwać i zamawiać. Zamówiony utwór gra na żywo dla wszystkich. Na antenie od 2009 roku, zawsze za darmo.';

  @override
  String get website => 'Strona internetowa';

  @override
  String get privacy => 'Prywatność';

  @override
  String get terms => 'Regulamin';

  @override
  String get contact => 'Kontakt';

  @override
  String version(String version) {
    return 'Wersja $version';
  }

  @override
  String get losslessTitle => 'Bezstratny FLAC';

  @override
  String losslessUses(int mb) {
    return 'Około $mb MB na godzinę';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Standardowa jakość: około $mb MB na godzinę';
  }

  @override
  String get losslessFallbackNotice =>
      'Dźwięk bezstratny zużywa dużo więcej danych niż standardowy strumień. Słuchaj przez Wi-Fi albo z nielimitowanym pakietem.';

  @override
  String get losslessAccept => 'Graj bezstratnie';

  @override
  String get losslessDecline => 'Użyj standardowej jakości';

  @override
  String get losslessFailed =>
      'Dźwięk bezstratny nie gra, więc włączyliśmy standardową jakość.';

  @override
  String get retryFlac => 'Spróbuj FLAC ponownie';

  @override
  String get marathonOnAir => 'Na antenie w tej godzinie';

  @override
  String get marathonQueue => 'Wkrótce na antenie';

  @override
  String get marathonNominations => 'Zagłosuj';

  @override
  String get marathonVote => 'Głosuj';

  @override
  String marathonVotes(int votes, int required) {
    return 'Głosy: $votes z $required';
  }

  @override
  String get marathonNominate => 'Nominuj artystę';

  @override
  String get marathonNominateHint => 'Szukaj artystów';

  @override
  String get marathonVoted => 'Głos policzony';

  @override
  String get marathonEmpty =>
      'Brak otwartych nominacji. Nominuj artystę na najbliższą wolną godzinę.';

  @override
  String get marathonVotedIn => 'Wybór słuchaczy';

  @override
  String get marathonIntro =>
      'Jedna grupa, cała godzina. Wybierz głosami artystę na najbliższą wolną godzinę.';

  @override
  String get seeAll => 'Zobacz wszystkie';

  @override
  String get justNow => 'przed chwilą';

  @override
  String minutesAgo(int n) {
    return '$n min temu';
  }

  @override
  String hoursAgo(int n) {
    return '$n godz. temu';
  }

  @override
  String inMinutes(int n) {
    return 'za $n min';
  }

  @override
  String get requestBadge => 'Zamówienie';

  @override
  String get artistPage => 'Strona artysty';

  @override
  String get openSong => 'Strona utworu';

  @override
  String get nextStation => 'Następna stacja';

  @override
  String get previousStation => 'Poprzednia stacja';

  @override
  String get quality => 'Jakość';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get comingSoon => 'Już wkrótce';

  @override
  String get captchaFailed => 'Weryfikacja nie powiodła się. Spróbuj ponownie.';

  @override
  String get goodMorning => 'Dzień dobry';

  @override
  String get goodAfternoon => 'Dzień dobry';

  @override
  String get goodEvening => 'Dobry wieczór';

  @override
  String get featuredStations => 'Polecane stacje';

  @override
  String get genresAndEras => 'Gatunki i epoki';

  @override
  String get playingFrom => 'Gra ze stacji';

  @override
  String get chooseStation => 'Wybierz stację';

  @override
  String get listenNow => 'Słuchaj teraz';

  @override
  String get showLyrics => 'Pokaż tekst';

  @override
  String get shareCardSong => 'Utwór';

  @override
  String get editLyrics => 'Wybierz wersy';

  @override
  String get copyLink => 'Kopiuj link';

  @override
  String get linkCopied => 'Skopiowano';

  @override
  String get shareImage => 'Udostępnij obraz';

  @override
  String get done => 'Gotowe';

  @override
  String pickLines(int count) {
    return 'Możesz wybrać do $count wersów';
  }

  @override
  String get goToSong => 'Przejdź do utworu';

  @override
  String get goToArtist => 'Przejdź do artysty';

  @override
  String get swipeToRequest => 'Zamów';

  @override
  String get offlineTitle => 'Jesteś offline';

  @override
  String get serverErrorTitle => 'Coś poszło nie tak';

  @override
  String get noResultsTitle => 'Brak wyników';

  @override
  String get noResultsBody =>
      'Spróbuj innej pisowni, angielskiego lub koreańskiego tytułu albo nazwy artysty.';

  @override
  String get wallEmptyTitle => 'Brak dedykacji';

  @override
  String get requestTrackerQueued => 'Twoje zamówienie · w kolejce';

  @override
  String requestTrackerEta(int minutes) {
    return 'Twoje zamówienie · zagra za ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Twoje zamówienie zagra jako następne';

  @override
  String get requestTrackerPlaying => 'Twoje zamówienie właśnie gra!';

  @override
  String get welcomeTitle => 'Radio K-pop, na żywo i za darmo';

  @override
  String get welcomeBody =>
      'Dwanaście stacji 24/7 i codziennie rosnąca biblioteka utworów z tekstami. Zamów utwór, a zagra na żywo dla wszystkich.';

  @override
  String get continueLabel => 'Dalej';

  @override
  String get pickStationsTitle => 'Wybierz swoje stacje';

  @override
  String get pickStationsBody =>
      'Pokażemy je na początku. Możesz je zmienić w każdej chwili.';

  @override
  String get requestsTitle => 'Ty wybierasz, co zagra następne';

  @override
  String get requestsBody =>
      'Znajdź dowolny utwór i go zamów. Gdy zagra, usłyszą go wszyscy słuchacze — i zobaczą twoją dedykację.';

  @override
  String get startListening => 'Zacznij słuchać';

  @override
  String get skip => 'Pomiń';

  @override
  String get yourStations => 'Twoje stacje';

  @override
  String get support => 'Wsparcie';

  @override
  String get supportEyebrow => 'Wspierane przez słuchaczy';

  @override
  String get supportH1 => 'Bez reklam. Bez płatnego dostępu.';

  @override
  String get supportH1Sub => 'Na antenie dzięki tym, którzy słuchają.';

  @override
  String get supportLead =>
      'SeoulFM jest darmowe i takie zostanie. Nie mamy ci nic do sprzedania i nikomu cię nie sprzedajemy. Jeśli stacja jest częścią twojego dnia, możesz pomóc utrzymać ją na antenie.';

  @override
  String get supportWhereItGoes => 'Na co idą pieniądze';

  @override
  String get supportCostStreamTitle => 'Strumień';

  @override
  String get supportCostStreamBody =>
      'Dwanaście kanałów, na antenie o każdej godzinie każdego dnia, dostarczanych na cały świat. Bezstratny dźwięk na HIFI to najdroższe, co wysyłamy — a wysyłamy go za darmo.';

  @override
  String get supportCostLibraryTitle => 'Biblioteka';

  @override
  String get supportCostLibraryBody =>
      'Dziesiątki tysięcy utworów, przechowywanych, opisanych i uporządkowanych, z okładkami, zsynchronizowanymi tekstami i obróbką dźwięku na poziomie radiowym dla każdego z nich.';

  @override
  String get supportCostWorkTitle => 'Praca';

  @override
  String get supportCostWorkBody =>
      'Strona, aplikacje, zamówienia, ściana i czat, a do tego stałe koszty licencji muzycznych. Tworzone i prowadzone przez bardzo mały zespół.';

  @override
  String get supportStaysTheSame => 'Co się nie zmieni';

  @override
  String get supportPromiseNoAds =>
      'Żadnych reklam audio ani banerów. Ani teraz, ani później.';

  @override
  String get supportPromiseNothingLocked =>
      'Nic nie jest zablokowane. Każdy kanał, zamówienie i funkcja zostają darmowe dla wszystkich.';

  @override
  String get supportPromiseOptional =>
      'Wsparcie jest dobrowolne i niczego nie zmienia w tym, jak słuchasz.';

  @override
  String get supportBecome => 'Zostań wspierającym';

  @override
  String get supportBecomeBody =>
      'Jednorazowo lub co miesiąc. Płatności obsługuje App Store lub Google Play; nigdy nie widzimy danych twojej karty.';

  @override
  String get supportMonthly => 'Wsparcie co miesiąc';

  @override
  String get supportMonthlyBody =>
      'Utrzymuj kanał na antenie, co miesiąc. Anuluj w każdej chwili.';

  @override
  String supportPerMonth(String price) {
    return '$price / mies.';
  }

  @override
  String get supportOnce => 'Jednorazowe wsparcie';

  @override
  String get supportTipSmall => 'Kawa';

  @override
  String get supportTipMedium => 'Obiad';

  @override
  String get supportTipLarge => 'Wieczór na mieście';

  @override
  String get supportRestore => 'Przywróć zakupy';

  @override
  String get supportUnavailable =>
      'Wsparcie przez sklep jest teraz niedostępne. Spróbuj ponownie później.';

  @override
  String get supportThanksTitle => 'Dziękujemy';

  @override
  String get supportThanksBody =>
      'Pomagasz utrzymać SeoulFM za darmo dla wszystkich.';

  @override
  String get supportYouAreSupporter => 'Wspierasz SeoulFM. Dziękujemy.';

  @override
  String get supportFreeWays =>
      'Nie możesz teraz dać pieniędzy? Słuchanie też się liczy. Tak samo jak zamówienie utworu, wpis na ścianie albo polecenie stacji jednej osobie, której się spodoba.';

  @override
  String get supportCardTitle => 'Pomóż utrzymać SeoulFM za darmo';

  @override
  String get supportCardBody =>
      'Bez reklam i bez płatnego dostępu — na antenie dzięki słuchaczom takim jak ty.';

  @override
  String get supportSubscriptionTerms =>
      'Wsparcie co miesiąc odnawia się automatycznie, dopóki nie anulujesz go w ustawieniach konta w sklepie.';

  @override
  String get language => 'Język';

  @override
  String get languageSystem => 'Użyj języka systemu';

  @override
  String get qualityAutoBody =>
      'Najlepsza jakość, jaką utrzyma połączenie. Spada, gdy połączenie słabnie.';

  @override
  String get qualityVeryHigh => 'Bardzo wysoka';

  @override
  String get qualityHigh => 'Wysoka';

  @override
  String get qualityNormal => 'Normalna';

  @override
  String get qualityDataSaver => 'Oszczędzanie danych';

  @override
  String get qualityFixedBody =>
      'Zawsze ta jakość, nawet przy słabym połączeniu.';

  @override
  String get qualityLosslessNote =>
      'HIFI odtwarza bezstratny FLAC, gdy zaakceptujesz jego komunikat.';

  @override
  String get moreOptions => 'Więcej opcji';

  @override
  String get reportDedication => 'Zgłoś';

  @override
  String hideDedicationsFrom(String name) {
    return 'Ukryj dedykacje użytkownika $name';
  }

  @override
  String get reportThanks => 'Dziękujemy za zgłoszenie. Przyjrzymy się temu.';

  @override
  String get showHiddenDedications => 'Pokaż ukryte dedykacje';

  @override
  String get verifyFailed =>
      'Weryfikacja nie powiodła się. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get restoreDone => 'Twoje zakupy zostały przywrócone.';

  @override
  String get restoreNothing => 'Nie ma zakupów do przywrócenia.';

  @override
  String get playbackFailed =>
      'Nie można połączyć się ze strumieniem. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get audioOutput => 'Wyjście audio';

  @override
  String get openPlayer => 'Otwórz odtwarzacz';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utworu',
      many: '$count utworów',
      few: '$count utwory',
      one: '$count utwór',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Stacje';

  @override
  String get spatialAudioBody =>
      'SeoulFM jest zmiksowane pod słuchawki z crossfeedem BS2B (Bauer stereophonic-to-binaural). Odrobina każdego kanału trafia też do drugiego ucha, jak z głośników w pokoju, dzięki czemu dźwięk jest szerszy, bardziej naturalny i przez wiele godzin nie męczy uszu.';
}
