// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Home';

  @override
  String get tabRequest => 'Richiedi';

  @override
  String get tabCharts => 'Classifiche';

  @override
  String get tabWall => 'Dediche';

  @override
  String get tabMore => 'Altro';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Non in onda';

  @override
  String get stationBreak => 'Breve pausa. Torniamo subito.';

  @override
  String get nowPlaying => 'In onda ora';

  @override
  String get upNext => 'Tra poco';

  @override
  String get stations => 'Stazioni';

  @override
  String get recentlyPlayed => 'Trasmessi di recente';

  @override
  String get requestASong => 'Richiedi un brano';

  @override
  String get requestHint =>
      'Scegli un brano e va in onda in diretta per tutti.';

  @override
  String get searchHint => 'Brani, artisti, album';

  @override
  String searchEmpty(String query) {
    return 'Nessun risultato per «$query»';
  }

  @override
  String get searchIntro =>
      'Cerca nella libreria, leggi i testi e richiedi un brano da far andare in onda in diretta.';

  @override
  String get newSongs => 'Novità su SeoulFM';

  @override
  String get songs => 'Brani';

  @override
  String get artists => 'Artisti';

  @override
  String get play => 'Riproduci';

  @override
  String get pause => 'Pausa';

  @override
  String get request => 'Richiedi';

  @override
  String get requestTitle => 'Richiedi questo brano';

  @override
  String get yourName => 'Il tuo nome (facoltativo)';

  @override
  String get dedication => 'Dedica (facoltativa)';

  @override
  String get sendRequest => 'Invia richiesta';

  @override
  String get verifying => 'Verifica in corso…';

  @override
  String get requestAccepted => 'Richiesta inviata!';

  @override
  String etaMinutes(int minutes) {
    return 'In onda tra circa $minutes min';
  }

  @override
  String get etaSoon => 'In onda tra poco';

  @override
  String requestQueued(String title) {
    return '«$title» è in coda';
  }

  @override
  String requestScheduled(String title) {
    return '«$title» è il prossimo';
  }

  @override
  String requestPlayed(String title) {
    return '«$title» è in onda ora';
  }

  @override
  String requestExpired(String title) {
    return 'Questa volta «$title» non è potuto andare in onda';
  }

  @override
  String get notRequestable => 'Non richiedibile al momento';

  @override
  String get errorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get offline =>
      'Impossibile raggiungere SeoulFM. Controlla la connessione.';

  @override
  String get retry => 'Riprova';

  @override
  String get chartsWeekly => 'Questa settimana';

  @override
  String get chartsHot => 'Hot';

  @override
  String get chartsRequested => 'Più richiesti';

  @override
  String get chartsTrending => 'Di tendenza';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passaggi',
      one: '1 passaggio',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count richieste',
      one: '1 richiesta',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NUOVO';

  @override
  String get dedicationsEmpty =>
      'Ancora nessuna dedica. Richiedi un brano e aggiungine una.';

  @override
  String dedicatedBy(String name) {
    return 'Dedica di $name';
  }

  @override
  String get lyrics => 'Testo';

  @override
  String get lyricsNone => 'Ancora nessun testo per questo brano.';

  @override
  String get share => 'Condividi';

  @override
  String shareSong(String title, String artist) {
    return '$title di $artist, in diretta su SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: radio K-pop gratis 24/7';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get startListeningToRate => 'Inizia ad ascoltare per votare';

  @override
  String get like => 'Mi piace questo brano';

  @override
  String get dislike => 'Non fa per me';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Brani più ascoltati';

  @override
  String get albums => 'Album';

  @override
  String get related => 'Potrebbe piacerti anche';

  @override
  String get settings => 'Impostazioni';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get sleepTimer => 'Timer di spegnimento';

  @override
  String get sleepOff => 'Off';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Si ferma tra $minutes min';
  }

  @override
  String get inTheCar => 'In auto';

  @override
  String get carBody =>
      'SeoulFM funziona con Android Auto. Collega il telefono e scegli una stazione sullo schermo dell’auto; i tasti avanti/indietro sul volante cambiano stazione.';

  @override
  String get about => 'Informazioni su SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM è una radio K-pop gratis 24/7 e una piattaforma di streaming di musica coreana: dodici stazioni in diretta e una libreria di brani che cresce ogni giorno, ciascuno con il suo testo, che puoi cercare e richiedere. Un brano richiesto va in onda in diretta per tutti. In onda dal 2009, sempre gratis.';

  @override
  String get website => 'Sito web';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Termini';

  @override
  String get contact => 'Contatti';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get losslessTitle => 'FLAC lossless';

  @override
  String losslessUses(int mb) {
    return 'Circa $mb MB all’ora';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Qualità standard: circa $mb MB all’ora';
  }

  @override
  String get losslessFallbackNotice =>
      'L’audio lossless consuma molti più dati dello stream standard. Meglio usarlo con il Wi-Fi o un piano dati illimitato.';

  @override
  String get losslessAccept => 'Ascolta in lossless';

  @override
  String get losslessDecline => 'Usa la qualità standard';

  @override
  String get losslessFailed =>
      'Il lossless non funziona, quindi è attiva la qualità standard.';

  @override
  String get retryFlac => 'Riprova FLAC';

  @override
  String get marathonOnAir => 'In onda in quest’ora';

  @override
  String get marathonQueue => 'Prossimamente';

  @override
  String get marathonNominations => 'Votali';

  @override
  String get marathonVote => 'Vota';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes voti su $required';
  }

  @override
  String get marathonNominate => 'Proponi un artista';

  @override
  String get marathonNominateHint => 'Cerca artisti';

  @override
  String get marathonVoted => 'Voto registrato';

  @override
  String get marathonEmpty =>
      'Nessuna proposta aperta. Proponi un artista per la prossima ora libera.';

  @override
  String get marathonVotedIn => 'Votato';

  @override
  String get marathonIntro =>
      'Un gruppo, un’ora intera. Vota un artista per la prossima ora libera.';

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get justNow => 'proprio ora';

  @override
  String minutesAgo(int n) {
    return '$n min fa';
  }

  @override
  String hoursAgo(int n) {
    return '$n h fa';
  }

  @override
  String inMinutes(int n) {
    return 'tra $n min';
  }

  @override
  String get requestBadge => 'Richiesta';

  @override
  String get artistPage => 'Pagina artista';

  @override
  String get openSong => 'Pagina del brano';

  @override
  String get nextStation => 'Stazione successiva';

  @override
  String get previousStation => 'Stazione precedente';

  @override
  String get quality => 'Qualità';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get comingSoon => 'In arrivo';

  @override
  String get captchaFailed => 'Verifica non riuscita. Riprova.';

  @override
  String get goodMorning => 'Buongiorno';

  @override
  String get goodAfternoon => 'Buon pomeriggio';

  @override
  String get goodEvening => 'Buonasera';

  @override
  String get featuredStations => 'Stazioni in evidenza';

  @override
  String get genresAndEras => 'Generi ed epoche';

  @override
  String get playingFrom => 'In riproduzione da';

  @override
  String get chooseStation => 'Scegli una stazione';

  @override
  String get listenNow => 'Ascolta ora';

  @override
  String get showLyrics => 'Mostra il testo';

  @override
  String get shareCardSong => 'Brano';

  @override
  String get editLyrics => 'Scegli le righe';

  @override
  String get copyLink => 'Copia link';

  @override
  String get linkCopied => 'Copiato';

  @override
  String get shareImage => 'Condividi immagine';

  @override
  String get done => 'Fine';

  @override
  String pickLines(int count) {
    return 'Scegli fino a $count righe';
  }

  @override
  String get goToSong => 'Vai al brano';

  @override
  String get goToArtist => 'Vai all’artista';

  @override
  String get swipeToRequest => 'Richiedi';

  @override
  String get offlineTitle => 'Sei offline';

  @override
  String get serverErrorTitle => 'Qualcosa è andato storto';

  @override
  String get noResultsTitle => 'Nessun risultato';

  @override
  String get noResultsBody =>
      'Prova un’altra grafia, un titolo in inglese o in coreano, o il nome dell’artista.';

  @override
  String get wallEmptyTitle => 'Ancora nessuna dedica';

  @override
  String get requestTrackerQueued => 'La tua richiesta · in coda';

  @override
  String requestTrackerEta(int minutes) {
    return 'La tua richiesta · in onda tra ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'La tua richiesta è la prossima';

  @override
  String get requestTrackerPlaying => 'La tua richiesta è in onda ora!';

  @override
  String get welcomeTitle => 'Radio K-pop, in diretta e gratis';

  @override
  String get welcomeBody =>
      'Dodici stazioni, 24/7, e una libreria di brani con i testi che cresce ogni giorno. Richiedi un brano e va in onda in diretta per tutti.';

  @override
  String get continueLabel => 'Continua';

  @override
  String get pickStationsTitle => 'Scegli le tue stazioni';

  @override
  String get pickStationsBody =>
      'Le terremo in primo piano. Puoi cambiarle quando vuoi.';

  @override
  String get requestsTitle => 'Scegli tu cosa suona dopo';

  @override
  String get requestsBody =>
      'Trova qualsiasi brano e richiedilo. Quando va in onda, tutti gli ascoltatori lo sentono — e vedono la tua dedica.';

  @override
  String get startListening => 'Inizia ad ascoltare';

  @override
  String get skip => 'Salta';

  @override
  String get yourStations => 'Le tue stazioni';

  @override
  String get support => 'Sostienici';

  @override
  String get supportEyebrow => 'Sostenuta dagli ascoltatori';

  @override
  String get supportH1 => 'Niente pubblicità. Niente abbonamenti.';

  @override
  String get supportH1Sub => 'In onda grazie a chi ascolta.';

  @override
  String get supportLead =>
      'SeoulFM è gratis e resterà gratis. Non abbiamo niente da venderti e nessuno a cui venderti. Se la stazione fa parte delle tue giornate, puoi aiutarla a restare in onda.';

  @override
  String get supportWhereItGoes => 'Dove vanno i soldi';

  @override
  String get supportCostStreamTitle => 'Lo stream';

  @override
  String get supportCostStreamBody =>
      'Dodici canali, in onda ogni ora di ogni giorno, in tutto il mondo. L’audio lossless di HIFI è la cosa più costosa che trasmettiamo, e la trasmettiamo gratis.';

  @override
  String get supportCostLibraryTitle => 'La libreria';

  @override
  String get supportCostLibraryBody =>
      'Decine di migliaia di brani, archiviati, catalogati e tenuti in ordine, ciascuno con copertina, testo sincronizzato ed elaborazione audio da broadcast.';

  @override
  String get supportCostWorkTitle => 'Il lavoro';

  @override
  String get supportCostWorkBody =>
      'Il sito, le app, le richieste, la bacheca e la chat, più il costo continuo delle licenze musicali. Tutto costruito e gestito da un team molto piccolo.';

  @override
  String get supportStaysTheSame => 'Cosa non cambia';

  @override
  String get supportPromiseNoAds =>
      'Niente pubblicità audio e niente banner. Né ora né mai.';

  @override
  String get supportPromiseNothingLocked =>
      'Niente è bloccato. Ogni canale, richiesta e funzione resta gratis per tutti.';

  @override
  String get supportPromiseOptional =>
      'Sostenerci è facoltativo e non cambia nulla nel modo in cui ascolti.';

  @override
  String get supportBecome => 'Diventa sostenitore';

  @override
  String get supportBecomeBody =>
      'Una tantum o ogni mese. I pagamenti sono gestiti da App Store o Google Play; non vediamo mai i dati della tua carta.';

  @override
  String get supportMonthly => 'Sostenitore mensile';

  @override
  String get supportMonthlyBody =>
      'Tieni in onda un canale, ogni mese. Puoi disdire quando vuoi.';

  @override
  String supportPerMonth(String price) {
    return '$price / mese';
  }

  @override
  String get supportOnce => 'Contributo una tantum';

  @override
  String get supportTipSmall => 'Un caffè';

  @override
  String get supportTipMedium => 'Un pranzo';

  @override
  String get supportTipLarge => 'Una serata fuori';

  @override
  String get supportRestore => 'Ripristina acquisti';

  @override
  String get supportUnavailable =>
      'Il sostegno tramite store non è disponibile al momento. Riprova più tardi.';

  @override
  String get supportThanksTitle => 'Grazie';

  @override
  String get supportThanksBody =>
      'Stai aiutando SeoulFM a restare gratis per tutti.';

  @override
  String get supportYouAreSupporter => 'Sei un sostenitore. Grazie.';

  @override
  String get supportFreeWays =>
      'Non puoi contribuire? Anche ascoltare conta. E conta anche richiedere un brano, lasciare un messaggio sulla bacheca o far conoscere la stazione a un amico che la adorerebbe.';

  @override
  String get supportCardTitle => 'Mantieni SeoulFM gratis';

  @override
  String get supportCardBody =>
      'Niente pubblicità, niente abbonamenti — in onda grazie ad ascoltatori come te.';

  @override
  String get supportSubscriptionTerms =>
      'Il sostegno mensile si rinnova automaticamente finché non lo disdici nelle impostazioni del tuo account dello store.';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Usa la lingua del sistema';

  @override
  String get qualityAutoBody =>
      'Il massimo che regge la tua connessione. Scende se fa fatica.';

  @override
  String get qualityVeryHigh => 'Molto alta';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get qualityNormal => 'Normale';

  @override
  String get qualityDataSaver => 'Risparmio dati';

  @override
  String get qualityFixedBody =>
      'Sempre questa qualità, anche con una connessione debole.';

  @override
  String get qualityLosslessNote =>
      'HIFI riproduce FLAC senza perdita quando accetti il suo avviso.';

  @override
  String get moreOptions => 'Altre opzioni';

  @override
  String get reportDedication => 'Segnala';

  @override
  String hideDedicationsFrom(String name) {
    return 'Nascondi le dediche di $name';
  }

  @override
  String get reportThanks => 'Grazie per la segnalazione. Daremo un’occhiata.';

  @override
  String get showHiddenDedications => 'Mostra le dediche nascoste';

  @override
  String get verifyFailed =>
      'Verifica non riuscita. Controlla la connessione e riprova.';

  @override
  String get restoreDone => 'I tuoi acquisti sono stati ripristinati.';

  @override
  String get restoreNothing => 'Non ci sono acquisti da ripristinare.';

  @override
  String get playbackFailed =>
      'Impossibile raggiungere lo stream. Controlla la connessione e riprova.';

  @override
  String get audioOutput => 'Uscita audio';

  @override
  String get openPlayer => 'Apri il player';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count brani',
      one: '1 brano',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Stazioni';

  @override
  String get spatialAudioBody =>
      'SeoulFM è mixato per le cuffie con crossfeed BS2B (Bauer stereophonic-to-binaural). Un po\' di ogni canale raggiunge anche l\'altro orecchio, come con le casse in una stanza, così il suono risulta più ampio, più naturale e meno faticoso da ascoltare per ore.';

  @override
  String get yourSongs => 'Your songs';

  @override
  String get favourite => 'Favourite';

  @override
  String get saveToYourSongs => 'Save to Your songs';

  @override
  String get removeFromYourSongs => 'Remove from Your songs';

  @override
  String get savedToYourSongs => 'Saved to Your songs';

  @override
  String get removedFromYourSongs => 'Removed from Your songs';

  @override
  String get view => 'View';

  @override
  String get undo => 'Undo';

  @override
  String get yourSongsEmptyTitle => 'Keep the songs you love';

  @override
  String get yourSongsEmptyBody =>
      'Tap the heart on the player or on a song’s page, or choose Save to Your songs in a song’s menu. They stay on this phone, no account needed.';

  @override
  String get requestFromYourSongs => 'Request one of them';
}
