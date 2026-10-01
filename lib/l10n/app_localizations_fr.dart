// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabRequest => 'Demander';

  @override
  String get tabCharts => 'Classements';

  @override
  String get tabWall => 'Dédicaces';

  @override
  String get tabMore => 'Plus';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Hors antenne';

  @override
  String get stationBreak => 'Courte pause. On revient vite.';

  @override
  String get nowPlaying => 'En cours de lecture';

  @override
  String get upNext => 'Ensuite';

  @override
  String get stations => 'Stations';

  @override
  String get recentlyPlayed => 'Diffusées récemment';

  @override
  String get requestASong => 'Demander une chanson';

  @override
  String get requestHint =>
      'Choisissez une chanson : elle passe en direct pour tous.';

  @override
  String get searchHint => 'Chansons, artistes, albums';

  @override
  String searchEmpty(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get searchIntro =>
      'Cherchez dans la bibliothèque, lisez les paroles et demandez une chanson pour qu’elle passe en direct.';

  @override
  String get newSongs => 'Nouveautés sur SeoulFM';

  @override
  String get songs => 'Chansons';

  @override
  String get artists => 'Artistes';

  @override
  String get play => 'Lecture';

  @override
  String get pause => 'Pause';

  @override
  String get request => 'Demander';

  @override
  String get requestTitle => 'Demander cette chanson';

  @override
  String get yourName => 'Votre nom (facultatif)';

  @override
  String get dedication => 'Dédicace (facultatif)';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get verifying => 'Vérification…';

  @override
  String get requestAccepted => 'Demande envoyée !';

  @override
  String etaMinutes(int minutes) {
    return 'Passe dans $minutes min environ';
  }

  @override
  String get etaSoon => 'Passe bientôt';

  @override
  String requestQueued(String title) {
    return '« $title » est dans la file';
  }

  @override
  String requestScheduled(String title) {
    return '« $title » passe juste après';
  }

  @override
  String requestPlayed(String title) {
    return '« $title » est à l’antenne';
  }

  @override
  String requestExpired(String title) {
    return '« $title » n’a pas pu être diffusée cette fois';
  }

  @override
  String get notRequestable => 'Indisponible pour le moment';

  @override
  String get errorGeneric => 'Un problème est survenu. Veuillez réessayer.';

  @override
  String get offline =>
      'Impossible de joindre SeoulFM. Vérifiez votre connexion.';

  @override
  String get retry => 'Réessayer';

  @override
  String get chartsWeekly => 'Cette semaine';

  @override
  String get chartsHot => 'Hot';

  @override
  String get chartsRequested => 'Les plus demandées';

  @override
  String get chartsTrending => 'Tendances';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count diffusions',
      one: '1 diffusion',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count demandes',
      one: '1 demande',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NOUVEAU';

  @override
  String get dedicationsEmpty =>
      'Pas encore de dédicace. Demandez une chanson et ajoutez-en une.';

  @override
  String dedicatedBy(String name) {
    return 'Dédicace de $name';
  }

  @override
  String get lyrics => 'Paroles';

  @override
  String get lyricsNone => 'Pas encore de paroles pour cette chanson.';

  @override
  String get share => 'Partager';

  @override
  String shareSong(String title, String artist) {
    return '$title de $artist, en direct sur SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name : radio K-pop gratuite 24h/24';
  }

  @override
  String get close => 'Fermer';

  @override
  String get startListeningToRate => 'Écoutez pour noter';

  @override
  String get like => 'J’aime cette chanson';

  @override
  String get dislike => 'Pas pour moi';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Top des chansons';

  @override
  String get albums => 'Albums';

  @override
  String get related => 'Vous aimerez aussi';

  @override
  String get settings => 'Réglages';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get sleepTimer => 'Minuteur de sommeil';

  @override
  String get sleepOff => 'Désactivé';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Arrêt dans $minutes min';
  }

  @override
  String get inTheCar => 'En voiture';

  @override
  String get carBody =>
      'SeoulFM fonctionne avec Android Auto. Connectez votre téléphone et choisissez une station sur l’écran de la voiture ; les boutons suivant/précédent du volant changent de station.';

  @override
  String get about => 'À propos de SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM est une radio K-pop gratuite 24h/24 et une plateforme de streaming de musique coréenne : douze stations en direct et une bibliothèque de chansons qui s’agrandit chaque jour, toutes avec leurs paroles, que vous pouvez chercher et demander. Une chanson demandée passe en direct pour tous. À l’antenne depuis 2009, toujours gratuit.';

  @override
  String get website => 'Site web';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get terms => 'Conditions';

  @override
  String get contact => 'Contact';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get losslessTitle => 'FLAC lossless';

  @override
  String losslessUses(int mb) {
    return 'Environ $mb Mo par heure';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Qualité standard : environ $mb Mo par heure';
  }

  @override
  String get losslessFallbackNotice =>
      'L’audio lossless consomme beaucoup plus de données que le flux standard. Mieux vaut être en Wi-Fi ou avoir un forfait illimité.';

  @override
  String get losslessAccept => 'Écouter en lossless';

  @override
  String get losslessDecline => 'Qualité standard';

  @override
  String get losslessFailed =>
      'Le lossless ne fonctionne pas : lecture en qualité standard.';

  @override
  String get retryFlac => 'Réessayer le FLAC';

  @override
  String get marathonOnAir => 'À l’antenne cette heure-ci';

  @override
  String get marathonQueue => 'À venir';

  @override
  String get marathonNominations => 'Votez pour eux';

  @override
  String get marathonVote => 'Voter';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes sur $required votes';
  }

  @override
  String get marathonNominate => 'Proposer un artiste';

  @override
  String get marathonNominateHint => 'Chercher des artistes';

  @override
  String get marathonVoted => 'Vote pris en compte';

  @override
  String get marathonEmpty =>
      'Aucune proposition en cours. Proposez un artiste pour la prochaine heure libre.';

  @override
  String get marathonVotedIn => 'Élu par les votes';

  @override
  String get marathonIntro =>
      'Un groupe, une heure entière. Votez pour l’artiste qui prendra la prochaine heure libre.';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get justNow => 'à l’instant';

  @override
  String minutesAgo(int n) {
    return 'il y a $n min';
  }

  @override
  String hoursAgo(int n) {
    return 'il y a $n h';
  }

  @override
  String inMinutes(int n) {
    return 'dans $n min';
  }

  @override
  String get requestBadge => 'Demande';

  @override
  String get artistPage => 'Page de l’artiste';

  @override
  String get openSong => 'Page de la chanson';

  @override
  String get nextStation => 'Station suivante';

  @override
  String get previousStation => 'Station précédente';

  @override
  String get quality => 'Qualité';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get comingSoon => 'Bientôt';

  @override
  String get captchaFailed => 'La vérification a échoué. Réessayez.';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get featuredStations => 'Stations à la une';

  @override
  String get genresAndEras => 'Genres et époques';

  @override
  String get playingFrom => 'Lecture depuis';

  @override
  String get chooseStation => 'Choisir une station';

  @override
  String get listenNow => 'Écouter';

  @override
  String get showLyrics => 'Afficher les paroles';

  @override
  String get shareCardSong => 'Chanson';

  @override
  String get editLyrics => 'Choisir les paroles';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get linkCopied => 'Copié';

  @override
  String get shareImage => 'Partager l’image';

  @override
  String get done => 'OK';

  @override
  String pickLines(int count) {
    return 'Choisissez jusqu’à $count lignes';
  }

  @override
  String get goToSong => 'Voir la chanson';

  @override
  String get goToArtist => 'Voir l’artiste';

  @override
  String get swipeToRequest => 'Demander';

  @override
  String get offlineTitle => 'Vous êtes hors ligne';

  @override
  String get serverErrorTitle => 'Un problème est survenu';

  @override
  String get noResultsTitle => 'Aucun résultat';

  @override
  String get noResultsBody =>
      'Essayez une autre orthographe, un titre en anglais ou en coréen, ou le nom de l’artiste.';

  @override
  String get wallEmptyTitle => 'Pas encore de dédicace';

  @override
  String get requestTrackerQueued => 'Votre demande · dans la file';

  @override
  String requestTrackerEta(int minutes) {
    return 'Votre demande · passe dans ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Votre demande passe juste après';

  @override
  String get requestTrackerPlaying => 'Votre demande passe en ce moment !';

  @override
  String get welcomeTitle => 'La radio K-pop, en direct et gratuite';

  @override
  String get welcomeBody =>
      'Douze stations, 24h/24, et une bibliothèque de chansons avec paroles qui s’agrandit chaque jour. Demandez une chanson : elle passe en direct pour tous.';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get pickStationsTitle => 'Choisissez vos stations';

  @override
  String get pickStationsBody =>
      'Elles resteront en tête. Modifiables à tout moment.';

  @override
  String get requestsTitle => 'C’est vous qui choisissez la suite';

  @override
  String get requestsBody =>
      'Trouvez n’importe quelle chanson et demandez-la. Quand elle passe, tous les auditeurs l’entendent — et voient votre dédicace.';

  @override
  String get startListening => 'Commencer l’écoute';

  @override
  String get skip => 'Passer';

  @override
  String get yourStations => 'Vos stations';

  @override
  String get support => 'Soutenir';

  @override
  String get supportEyebrow => 'Soutenue par les auditeurs';

  @override
  String get supportH1 => 'Sans pub. Sans paywall.';

  @override
  String get supportH1Sub => 'Maintenue à l’antenne par ceux qui l’écoutent.';

  @override
  String get supportLead =>
      'SeoulFM est gratuit, et le restera. Nous n’avons rien à vous vendre et personne à qui vous vendre. Si la station fait partie de votre quotidien, vous pouvez aider à la faire vivre.';

  @override
  String get supportWhereItGoes => 'À quoi ça sert';

  @override
  String get supportCostStreamTitle => 'Le flux';

  @override
  String get supportCostStreamBody =>
      'Douze stations, à l’antenne à toute heure, chaque jour, diffusées dans le monde entier. L’audio lossless de HIFI est ce qui nous coûte le plus cher à envoyer, et nous l’envoyons gratuitement.';

  @override
  String get supportCostLibraryTitle => 'La bibliothèque';

  @override
  String get supportCostLibraryBody =>
      'Des dizaines de milliers de titres, stockés, étiquetés et bien rangés, avec pochettes, paroles synchronisées et traitement de qualité broadcast pour chacun.';

  @override
  String get supportCostWorkTitle => 'Le travail';

  @override
  String get supportCostWorkBody =>
      'Le site, les applis, les demandes, le mur et le chat, plus le coût permanent des licences musicales. Conçu et géré par une toute petite équipe.';

  @override
  String get supportStaysTheSame => 'Ce qui ne change pas';

  @override
  String get supportPromiseNoAds =>
      'Pas de pub audio ni de bannières. Ni maintenant, ni plus tard.';

  @override
  String get supportPromiseNothingLocked =>
      'Rien n’est verrouillé. Chaque station, chaque demande et chaque fonctionnalité restent gratuites pour tous.';

  @override
  String get supportPromiseOptional =>
      'Le soutien est facultatif et ne change rien à votre façon d’écouter.';

  @override
  String get supportBecome => 'Devenir soutien';

  @override
  String get supportBecomeBody =>
      'Une fois ou chaque mois. Les paiements passent par l’App Store ou Google Play ; nous ne voyons jamais vos coordonnées bancaires.';

  @override
  String get supportMonthly => 'Soutien mensuel';

  @override
  String get supportMonthlyBody =>
      'Gardez une station à l’antenne, chaque mois. Résiliable à tout moment.';

  @override
  String supportPerMonth(String price) {
    return '$price / mois';
  }

  @override
  String get supportOnce => 'Don ponctuel';

  @override
  String get supportTipSmall => 'Un café';

  @override
  String get supportTipMedium => 'Un déjeuner';

  @override
  String get supportTipLarge => 'Une soirée';

  @override
  String get supportRestore => 'Restaurer les achats';

  @override
  String get supportUnavailable =>
      'Le soutien via les stores arrive bientôt. Merci de vouloir nous aider.';

  @override
  String get supportThanksTitle => 'Merci';

  @override
  String get supportThanksBody =>
      'Vous aidez SeoulFM à rester gratuit pour tous.';

  @override
  String get supportYouAreSupporter => 'Vous nous soutenez. Merci.';

  @override
  String get supportFreeWays =>
      'Pas en mesure de donner ? Écouter, ça compte. Tout comme demander une chanson, laisser un mot sur le mur, ou faire découvrir la station à un ami qui l’adorerait.';

  @override
  String get supportCardTitle => 'Gardez SeoulFM gratuit';

  @override
  String get supportCardBody =>
      'Sans pub, sans paywall — maintenue à l’antenne par des auditeurs comme vous.';

  @override
  String get supportSubscriptionTerms =>
      'Le soutien mensuel se renouvelle automatiquement jusqu’à sa résiliation dans les réglages de votre compte du store.';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Utiliser la langue du système';

  @override
  String get qualityAutoBody =>
      'La meilleure qualité que tient votre connexion. Baisse si elle faiblit.';

  @override
  String get qualityVeryHigh => 'Très haute';

  @override
  String get qualityHigh => 'Haute';

  @override
  String get qualityNormal => 'Normale';

  @override
  String get qualityDataSaver => 'Économie de données';

  @override
  String get qualityFixedBody =>
      'Toujours cette qualité, même avec une connexion faible.';

  @override
  String get qualityLosslessNote =>
      'HIFI diffuse en FLAC sans perte quand vous acceptez son avertissement.';

  @override
  String get moreOptions => 'Plus d’options';

  @override
  String get reportDedication => 'Signaler';

  @override
  String hideDedicationsFrom(String name) {
    return 'Masquer les dédicaces de $name';
  }

  @override
  String get reportThanks =>
      'Merci de nous l’avoir signalé. Nous allons y jeter un œil.';

  @override
  String get showHiddenDedications => 'Afficher les dédicaces masquées';
}
