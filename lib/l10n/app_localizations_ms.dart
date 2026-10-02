// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Utama';

  @override
  String get tabRequest => 'Minta';

  @override
  String get tabCharts => 'Carta';

  @override
  String get tabWall => 'Dedikasi';

  @override
  String get tabMore => 'Lagi';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Tidak bersiaran';

  @override
  String get stationBreak =>
      'Stesen berehat sebentar. Kami akan kembali sekejap lagi.';

  @override
  String get nowPlaying => 'Sedang dimainkan';

  @override
  String get upNext => 'Seterusnya';

  @override
  String get stations => 'Stesen';

  @override
  String get recentlyPlayed => 'Baru dimainkan';

  @override
  String get requestASong => 'Minta lagu';

  @override
  String get requestHint =>
      'Pilih lagu dan ia bersiaran secara langsung untuk semua.';

  @override
  String get searchHint => 'Lagu, artis, album';

  @override
  String searchEmpty(String query) {
    return 'Tiada padanan untuk “$query”';
  }

  @override
  String get searchIntro =>
      'Cari dalam koleksi, baca liriknya, dan minta satu lagu untuk dimainkan secara langsung.';

  @override
  String get newSongs => 'Baharu di SeoulFM';

  @override
  String get songs => 'Lagu';

  @override
  String get artists => 'Artis';

  @override
  String get play => 'Main';

  @override
  String get pause => 'Jeda';

  @override
  String get request => 'Minta';

  @override
  String get requestTitle => 'Minta lagu ini';

  @override
  String get yourName => 'Nama anda (pilihan)';

  @override
  String get dedication => 'Mesej dedikasi (pilihan)';

  @override
  String get sendRequest => 'Hantar permintaan';

  @override
  String get verifying => 'Mengesahkan anda manusia…';

  @override
  String get requestAccepted => 'Permintaan dihantar!';

  @override
  String etaMinutes(int minutes) {
    return 'Dimainkan dalam kira-kira $minutes min';
  }

  @override
  String get etaSoon => 'Dimainkan tidak lama lagi';

  @override
  String requestQueued(String title) {
    return '“$title” sudah dalam giliran';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” akan dimainkan seterusnya';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” sedang bersiaran sekarang';
  }

  @override
  String requestExpired(String title) {
    return '“$title” tidak dapat dimainkan kali ini';
  }

  @override
  String get notRequestable => 'Tidak boleh diminta buat masa ini';

  @override
  String get errorGeneric => 'Ada yang tidak kena. Sila cuba lagi.';

  @override
  String get offline =>
      'Tidak dapat menghubungi SeoulFM. Semak sambungan anda.';

  @override
  String get retry => 'Cuba lagi';

  @override
  String get chartsWeekly => 'Minggu ini';

  @override
  String get chartsHot => 'Hangat';

  @override
  String get chartsRequested => 'Paling Diminta';

  @override
  String get chartsTrending => 'Sohor Kini';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali dimainkan',
      one: '1 kali dimainkan',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count permintaan',
      one: '1 permintaan',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'BAHARU';

  @override
  String get dedicationsEmpty =>
      'Belum ada dedikasi. Minta lagu dan tambah satu.';

  @override
  String dedicatedBy(String name) {
    return 'Didedikasikan oleh $name';
  }

  @override
  String get lyrics => 'Lirik';

  @override
  String get lyricsNone => 'Belum ada lirik untuk lagu ini.';

  @override
  String get share => 'Kongsi';

  @override
  String shareSong(String title, String artist) {
    return '$title oleh $artist, secara langsung di SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: radio K-pop percuma 24/7';
  }

  @override
  String get close => 'Tutup';

  @override
  String get startListeningToRate => 'Mula mendengar untuk menilai';

  @override
  String get like => 'Saya suka lagu ini';

  @override
  String get dislike => 'Bukan citarasa saya';

  @override
  String get hot => 'Hangat';

  @override
  String get topTracks => 'Lagu teratas';

  @override
  String get albums => 'Album';

  @override
  String get related => 'Anda mungkin juga suka';

  @override
  String get settings => 'Tetapan';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeLight => 'Cerah';

  @override
  String get sleepTimer => 'Pemasa tidur';

  @override
  String get sleepOff => 'Mati';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Berhenti dalam $minutes min';
  }

  @override
  String get inTheCar => 'Dalam kereta';

  @override
  String get carBody =>
      'SeoulFM berfungsi dengan Android Auto. Sambungkan telefon anda dan pilih stesen pada skrin kereta; butang langkau pada stereng menukar stesen.';

  @override
  String get about => 'Tentang SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM ialah radio K-pop percuma 24/7 dan platform penstriman muzik Korea: dua belas stesen langsung, dan koleksi lagu yang bertambah setiap hari, setiap satu dengan lirik, yang boleh anda cari dan minta. Lagu yang diminta bersiaran secara langsung untuk semua. Bersiaran sejak 2009, sentiasa percuma.';

  @override
  String get website => 'Laman web';

  @override
  String get privacy => 'Privasi';

  @override
  String get terms => 'Terma';

  @override
  String get contact => 'Hubungi';

  @override
  String version(String version) {
    return 'Versi $version';
  }

  @override
  String get losslessTitle => 'FLAC tanpa kehilangan';

  @override
  String losslessUses(int mb) {
    return 'Kira-kira $mb MB sejam';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Kualiti standard: kira-kira $mb MB sejam';
  }

  @override
  String get losslessFallbackNotice =>
      'Audio lossless menggunakan jauh lebih banyak data daripada strim biasa. Gunakan Wi-Fi atau pelan data tanpa had.';

  @override
  String get losslessAccept => 'Main lossless';

  @override
  String get losslessDecline => 'Guna kualiti standard';

  @override
  String get losslessFailed =>
      'Lossless tidak dapat dimainkan, jadi kualiti standard digunakan.';

  @override
  String get retryFlac => 'Cuba FLAC lagi';

  @override
  String get marathonOnAir => 'Bersiaran jam ini';

  @override
  String get marathonQueue => 'Akan datang';

  @override
  String get marathonNominations => 'Undi mereka masuk';

  @override
  String get marathonVote => 'Undi';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes daripada $required undi';
  }

  @override
  String get marathonNominate => 'Calonkan artis';

  @override
  String get marathonNominateHint => 'Cari artis';

  @override
  String get marathonVoted => 'Undi dikira';

  @override
  String get marathonEmpty =>
      'Tiada pencalonan terbuka. Calonkan artis untuk jam kosong seterusnya.';

  @override
  String get marathonVotedIn => 'Terpilih melalui undian';

  @override
  String get marathonIntro =>
      'Satu kumpulan, sejam penuh. Undi artis untuk jam kosong seterusnya.';

  @override
  String get seeAll => 'Lihat semua';

  @override
  String get justNow => 'baru sahaja';

  @override
  String minutesAgo(int n) {
    return '$n min lalu';
  }

  @override
  String hoursAgo(int n) {
    return '$n j lalu';
  }

  @override
  String inMinutes(int n) {
    return 'dalam $n min';
  }

  @override
  String get requestBadge => 'Minta';

  @override
  String get artistPage => 'Halaman artis';

  @override
  String get openSong => 'Halaman lagu';

  @override
  String get nextStation => 'Stesen seterusnya';

  @override
  String get previousStation => 'Stesen sebelumnya';

  @override
  String get quality => 'Kualiti';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get comingSoon => 'Akan datang';

  @override
  String get captchaFailed => 'Pengesahan gagal. Cuba lagi.';

  @override
  String get goodMorning => 'Selamat pagi';

  @override
  String get goodAfternoon => 'Selamat petang';

  @override
  String get goodEvening => 'Selamat malam';

  @override
  String get featuredStations => 'Stesen pilihan';

  @override
  String get genresAndEras => 'Genre & era';

  @override
  String get playingFrom => 'Dimainkan dari';

  @override
  String get chooseStation => 'Pilih stesen';

  @override
  String get listenNow => 'Dengar sekarang';

  @override
  String get showLyrics => 'Tunjuk lirik';

  @override
  String get shareCardSong => 'Lagu';

  @override
  String get editLyrics => 'Sunting lirik';

  @override
  String get copyLink => 'Salin pautan';

  @override
  String get linkCopied => 'Disalin';

  @override
  String get shareImage => 'Kongsi imej';

  @override
  String get done => 'Selesai';

  @override
  String pickLines(int count) {
    return 'Pilih sehingga $count baris';
  }

  @override
  String get goToSong => 'Pergi ke lagu';

  @override
  String get goToArtist => 'Pergi ke artis';

  @override
  String get swipeToRequest => 'Minta';

  @override
  String get offlineTitle => 'Anda di luar talian';

  @override
  String get serverErrorTitle => 'Ada yang tidak kena';

  @override
  String get noResultsTitle => 'Tiada hasil';

  @override
  String get noResultsBody =>
      'Cuba ejaan lain, tajuk dalam bahasa Inggeris atau Korea, atau nama artis.';

  @override
  String get wallEmptyTitle => 'Belum ada dedikasi';

  @override
  String get requestTrackerQueued => 'Permintaan anda · dalam giliran';

  @override
  String requestTrackerEta(int minutes) {
    return 'Permintaan anda · dimainkan dalam ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Permintaan anda dimainkan seterusnya';

  @override
  String get requestTrackerPlaying => 'Permintaan anda sedang dimainkan!';

  @override
  String get welcomeTitle => 'Radio K-pop, langsung dan percuma';

  @override
  String get welcomeBody =>
      'Dua belas stesen, 24/7, dan koleksi lagu dengan lirik yang bertambah setiap hari. Minta lagu dan ia bersiaran secara langsung untuk semua.';

  @override
  String get continueLabel => 'Teruskan';

  @override
  String get pickStationsTitle => 'Pilih stesen anda';

  @override
  String get pickStationsBody =>
      'Kami akan letakkannya di hadapan. Tukar pada bila-bila masa.';

  @override
  String get requestsTitle => 'Anda pilih lagu seterusnya';

  @override
  String get requestsBody =>
      'Cari apa sahaja lagu dan mintanya. Apabila ia dimainkan, semua yang mendengar akan terdengar — dan melihat dedikasi anda.';

  @override
  String get startListening => 'Mula mendengar';

  @override
  String get skip => 'Langkau';

  @override
  String get yourStations => 'Stesen anda';

  @override
  String get support => 'Sokong';

  @override
  String get supportEyebrow => 'Disokong pendengar';

  @override
  String get supportH1 => 'Tanpa iklan. Tanpa tembok bayaran.';

  @override
  String get supportH1Sub => 'Terus bersiaran berkat mereka yang mendengar.';

  @override
  String get supportLead =>
      'SeoulFM percuma, dan akan kekal percuma. Tiada apa yang hendak dijual kepada anda dan tiada sesiapa untuk menjual anda. Jika stesen ini sebahagian daripada hari anda, anda boleh membantu memastikannya terus berjalan.';

  @override
  String get supportWhereItGoes => 'Ke mana ia pergi';

  @override
  String get supportCostStreamTitle => 'Strim';

  @override
  String get supportCostStreamBody =>
      'Dua belas saluran, bersiaran setiap jam setiap hari, disampaikan ke seluruh dunia. Audio lossless di HIFI ialah perkara paling mahal yang kami hantar, dan kami menghantarnya secara percuma.';

  @override
  String get supportCostLibraryTitle => 'Koleksi lagu';

  @override
  String get supportCostLibraryBody =>
      'Puluhan ribu lagu, disimpan, ditag dan disusun, dengan kulit album, lirik segerak dan pemprosesan bertaraf penyiaran pada setiap satunya.';

  @override
  String get supportCostWorkTitle => 'Kerja';

  @override
  String get supportCostWorkBody =>
      'Laman web, aplikasi, permintaan lagu, dinding dan sembang, serta kos berterusan pelesenan muzik. Dibina dan dikendalikan oleh pasukan yang sangat kecil.';

  @override
  String get supportStaysTheSame => 'Apa yang kekal sama';

  @override
  String get supportPromiseNoAds =>
      'Tiada iklan audio dan tiada sepanduk. Bukan sekarang, bukan kemudian.';

  @override
  String get supportPromiseNothingLocked =>
      'Tiada apa yang dikunci. Setiap saluran, permintaan lagu dan ciri kekal percuma untuk semua.';

  @override
  String get supportPromiseOptional =>
      'Menyokong adalah pilihan dan tidak mengubah apa-apa tentang cara anda mendengar.';

  @override
  String get supportBecome => 'Jadi penyokong';

  @override
  String get supportBecomeBody =>
      'Sekali, atau setiap bulan. Pembayaran dikendalikan oleh App Store atau Google Play; kami tidak pernah melihat butiran kad anda.';

  @override
  String get supportMonthly => 'Penyokong bulanan';

  @override
  String get supportMonthlyBody =>
      'Pastikan satu saluran terus bersiaran, setiap bulan. Batal pada bila-bila masa.';

  @override
  String supportPerMonth(String price) {
    return '$price / bulan';
  }

  @override
  String get supportOnce => 'Tip sekali';

  @override
  String get supportTipSmall => 'Secawan kopi';

  @override
  String get supportTipMedium => 'Makan tengah hari';

  @override
  String get supportTipLarge => 'Keluar malam';

  @override
  String get supportRestore => 'Pulihkan pembelian';

  @override
  String get supportUnavailable =>
      'Sokongan melalui kedai tidak tersedia buat masa ini. Cuba lagi kemudian.';

  @override
  String get supportThanksTitle => 'Terima kasih';

  @override
  String get supportThanksBody =>
      'Anda membantu memastikan SeoulFM kekal percuma untuk semua.';

  @override
  String get supportYouAreSupporter => 'Anda seorang penyokong. Terima kasih.';

  @override
  String get supportFreeWays =>
      'Tidak mampu memberi? Mendengar pun dikira. Begitu juga meminta lagu, meninggalkan nota di dinding, atau berkongsi stesen ini dengan seorang kawan yang pasti menyukainya.';

  @override
  String get supportCardTitle => 'Pastikan SeoulFM percuma';

  @override
  String get supportCardBody =>
      'Tanpa iklan, tanpa tembok bayaran — terus bersiaran berkat pendengar seperti anda.';

  @override
  String get supportSubscriptionTerms =>
      'Sokongan bulanan diperbaharui secara automatik sehingga dibatalkan dalam tetapan akaun kedai anda.';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Guna bahasa sistem';

  @override
  String get qualityAutoBody =>
      'Kualiti terbaik yang mampu ditampung sambungan anda. Diturunkan jika sambungan lemah.';

  @override
  String get qualityVeryHigh => 'Sangat tinggi';

  @override
  String get qualityHigh => 'Tinggi';

  @override
  String get qualityNormal => 'Biasa';

  @override
  String get qualityDataSaver => 'Penjimat data';

  @override
  String get qualityFixedBody =>
      'Sentiasa kualiti ini, walaupun sambungan lemah.';

  @override
  String get qualityLosslessNote =>
      'HIFI memainkan FLAC tanpa kehilangan apabila anda menerima notisnya.';

  @override
  String get moreOptions => 'Lebih banyak pilihan';

  @override
  String get reportDedication => 'Laporkan';

  @override
  String hideDedicationsFrom(String name) {
    return 'Sembunyikan dedikasi daripada $name';
  }

  @override
  String get reportThanks =>
      'Terima kasih kerana memberitahu kami. Kami akan menyemaknya.';

  @override
  String get showHiddenDedications => 'Tunjukkan dedikasi yang disembunyikan';

  @override
  String get verifyFailed =>
      'Pengesahan gagal. Semak sambungan anda dan cuba lagi.';

  @override
  String get restoreDone => 'Pembelian anda telah dipulihkan.';

  @override
  String get restoreNothing => 'Tiada pembelian untuk dipulihkan.';

  @override
  String get playbackFailed =>
      'Tidak dapat menghubungi strim. Semak sambungan anda dan cuba lagi.';

  @override
  String get audioOutput => 'Output audio';

  @override
  String get openPlayer => 'Buka pemain';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lagu',
      one: '1 lagu',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Stesen';

  @override
  String get spatialAudioBody =>
      'SeoulFM dicampur untuk fon kepala dengan crossfeed BS2B (Bauer stereophonic-to-binaural). Sedikit bunyi daripada setiap saluran sampai juga ke telinga sebelah, seperti daripada pembesar suara dalam bilik, jadi bunyi terasa lebih luas, lebih semula jadi dan selesa di telinga selama berjam-jam.';

  @override
  String get requestNotificationChannel => 'Permintaan anda';

  @override
  String get requestNotificationChannelDescription =>
      'Memaklumkan anda apabila lagu yang anda minta akan dimainkan dan apabila ia bersiaran.';

  @override
  String get yourSongs => 'Lagu anda';

  @override
  String get favourite => 'Kegemaran';

  @override
  String get saveToYourSongs => 'Simpan ke Lagu anda';

  @override
  String get removeFromYourSongs => 'Alih keluar daripada Lagu anda';

  @override
  String get savedToYourSongs => 'Disimpan ke Lagu anda';

  @override
  String get removedFromYourSongs => 'Dialih keluar daripada Lagu anda';

  @override
  String get view => 'Lihat';

  @override
  String get undo => 'Buat asal';

  @override
  String get yourSongsEmptyTitle => 'Simpan lagu yang anda suka';

  @override
  String get yourSongsEmptyBody =>
      'Ketik hati pada pemain atau pada halaman lagu, atau pilih Simpan ke Lagu anda dalam menu lagu. Lagu kekal pada telefon ini, tanpa perlu akaun.';

  @override
  String get requestFromYourSongs => 'Minta salah satu daripadanya';

  @override
  String get quickSettingsAdd => 'Tambah pada Tetapan Pantas';

  @override
  String get quickSettingsAdded =>
      'SeoulFM ada dalam Tetapan Pantas anda: leret ke bawah untuk main atau jeda.';

  @override
  String get edit => 'Edit';

  @override
  String get moreStations => 'Stesen lain';

  @override
  String get addToYourStations => 'Tambah ke Stesen anda';

  @override
  String get removeFromYourStations => 'Alih keluar daripada Stesen anda';

  @override
  String get addStations => 'Tambah';
}
