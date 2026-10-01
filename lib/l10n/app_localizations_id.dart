// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Beranda';

  @override
  String get tabRequest => 'Request';

  @override
  String get tabCharts => 'Tangga lagu';

  @override
  String get tabWall => 'Dedikasi';

  @override
  String get tabMore => 'Lainnya';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Tidak siaran';

  @override
  String get stationBreak =>
      'Stasiun sedang istirahat sebentar. Kami segera kembali.';

  @override
  String get nowPlaying => 'Sedang diputar';

  @override
  String get upNext => 'Berikutnya';

  @override
  String get stations => 'Stasiun';

  @override
  String get recentlyPlayed => 'Baru saja diputar';

  @override
  String get requestASong => 'Request lagu';

  @override
  String get requestHint => 'Pilih lagu dan lagunya diputar live untuk semua.';

  @override
  String get searchHint => 'Lagu, artis, album';

  @override
  String searchEmpty(String query) {
    return 'Tidak ada hasil untuk “$query”';
  }

  @override
  String get searchIntro =>
      'Cari di perpustakaan, baca liriknya, dan request lagu untuk diputar live.';

  @override
  String get newSongs => 'Baru di SeoulFM';

  @override
  String get songs => 'Lagu';

  @override
  String get artists => 'Artis';

  @override
  String get play => 'Putar';

  @override
  String get pause => 'Jeda';

  @override
  String get request => 'Request';

  @override
  String get requestTitle => 'Request lagu ini';

  @override
  String get yourName => 'Namamu (opsional)';

  @override
  String get dedication => 'Pesan dedikasi (opsional)';

  @override
  String get sendRequest => 'Kirim request';

  @override
  String get verifying => 'Memastikan kamu manusia…';

  @override
  String get requestAccepted => 'Request terkirim!';

  @override
  String etaMinutes(int minutes) {
    return 'Diputar sekitar $minutes menit lagi';
  }

  @override
  String get etaSoon => 'Segera diputar';

  @override
  String requestQueued(String title) {
    return '“$title” masuk antrean';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” segera diputar';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” sedang diputar';
  }

  @override
  String requestExpired(String title) {
    return '“$title” tidak bisa diputar kali ini';
  }

  @override
  String get notRequestable => 'Sedang tidak bisa di-request';

  @override
  String get errorGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get offline => 'Tidak bisa terhubung ke SeoulFM. Cek koneksimu.';

  @override
  String get retry => 'Coba lagi';

  @override
  String get chartsWeekly => 'Minggu ini';

  @override
  String get chartsHot => 'Lagi hot';

  @override
  String get chartsRequested => 'Paling banyak di-request';

  @override
  String get chartsTrending => 'Sedang tren';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kali diputar',
      one: '1 kali diputar',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count request',
      one: '1 request',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'BARU';

  @override
  String get dedicationsEmpty =>
      'Belum ada dedikasi. Request lagu dan tambahkan dedikasimu.';

  @override
  String dedicatedBy(String name) {
    return 'Dedikasi dari $name';
  }

  @override
  String get lyrics => 'Lirik';

  @override
  String get lyricsNone => 'Lirik untuk lagu ini belum tersedia.';

  @override
  String get share => 'Bagikan';

  @override
  String shareSong(String title, String artist) {
    return '$title dari $artist, live di SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: radio K-pop gratis 24/7';
  }

  @override
  String get close => 'Tutup';

  @override
  String get startListeningToRate => 'Mulai dengarkan untuk memberi rating';

  @override
  String get like => 'Aku suka lagu ini';

  @override
  String get dislike => 'Kurang cocok';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Lagu teratas';

  @override
  String get albums => 'Album';

  @override
  String get related => 'Mungkin kamu juga suka';

  @override
  String get settings => 'Pengaturan';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeLight => 'Terang';

  @override
  String get sleepTimer => 'Timer tidur';

  @override
  String get sleepOff => 'Mati';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes mnt';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Berhenti dalam $minutes mnt';
  }

  @override
  String get inTheCar => 'Di mobil';

  @override
  String get carBody =>
      'SeoulFM bisa dipakai dengan Android Auto. Sambungkan HP-mu dan pilih stasiun di layar mobil; tombol skip di setir untuk ganti stasiun.';

  @override
  String get about => 'Tentang SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM adalah radio K-pop gratis 24/7 sekaligus platform streaming musik Korea: dua belas stasiun live, dan perpustakaan lagu yang terus bertambah setiap hari, masing-masing lengkap dengan lirik, yang bisa kamu cari dan request. Lagu yang di-request diputar live untuk semua. Mengudara sejak 2009, selalu gratis.';

  @override
  String get website => 'Situs web';

  @override
  String get privacy => 'Privasi';

  @override
  String get terms => 'Ketentuan';

  @override
  String get contact => 'Kontak';

  @override
  String version(String version) {
    return 'Versi $version';
  }

  @override
  String get losslessTitle => 'FLAC Lossless';

  @override
  String losslessUses(int mb) {
    return 'Sekitar $mb MB per jam';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Kualitas standar: sekitar $mb MB per jam';
  }

  @override
  String get losslessFallbackNotice =>
      'Audio lossless memakai kuota jauh lebih banyak dari streaming standar. Pakai Wi-Fi atau paket unlimited.';

  @override
  String get losslessAccept => 'Putar lossless';

  @override
  String get losslessDecline => 'Pakai kualitas standar';

  @override
  String get losslessFailed =>
      'Lossless tidak bisa diputar, jadi kualitas standar dinyalakan.';

  @override
  String get retryFlac => 'Coba FLAC lagi';

  @override
  String get marathonOnAir => 'Siaran jam ini';

  @override
  String get marathonQueue => 'Berikutnya';

  @override
  String get marathonNominations => 'Vote mereka';

  @override
  String get marathonVote => 'Vote';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes dari $required vote';
  }

  @override
  String get marathonNominate => 'Nominasikan artis';

  @override
  String get marathonNominateHint => 'Cari artis';

  @override
  String get marathonVoted => 'Vote dihitung';

  @override
  String get marathonEmpty =>
      'Belum ada nominasi terbuka. Nominasikan artis untuk jam kosong berikutnya.';

  @override
  String get marathonVotedIn => 'Hasil vote';

  @override
  String get marathonIntro =>
      'Satu grup, satu jam penuh. Vote artis untuk mengisi jam kosong berikutnya.';

  @override
  String get seeAll => 'Lihat semua';

  @override
  String get justNow => 'baru saja';

  @override
  String minutesAgo(int n) {
    return '$n mnt lalu';
  }

  @override
  String hoursAgo(int n) {
    return '$n jam lalu';
  }

  @override
  String inMinutes(int n) {
    return '$n mnt lagi';
  }

  @override
  String get requestBadge => 'Request';

  @override
  String get artistPage => 'Halaman artis';

  @override
  String get openSong => 'Halaman lagu';

  @override
  String get nextStation => 'Stasiun berikutnya';

  @override
  String get previousStation => 'Stasiun sebelumnya';

  @override
  String get quality => 'Kualitas';

  @override
  String get qualityAuto => 'Otomatis';

  @override
  String get comingSoon => 'Segera hadir';

  @override
  String get captchaFailed => 'Verifikasi gagal. Coba lagi.';

  @override
  String get goodMorning => 'Selamat pagi';

  @override
  String get goodAfternoon => 'Selamat siang';

  @override
  String get goodEvening => 'Selamat malam';

  @override
  String get featuredStations => 'Stasiun pilihan';

  @override
  String get genresAndEras => 'Genre & era';

  @override
  String get playingFrom => 'Diputar dari';

  @override
  String get chooseStation => 'Pilih stasiun';

  @override
  String get listenNow => 'Dengarkan sekarang';

  @override
  String get showLyrics => 'Tampilkan lirik';

  @override
  String get shareCardSong => 'Lagu';

  @override
  String get editLyrics => 'Pilih baris';

  @override
  String get copyLink => 'Salin link';

  @override
  String get linkCopied => 'Tersalin';

  @override
  String get shareImage => 'Bagikan gambar';

  @override
  String get done => 'Selesai';

  @override
  String pickLines(int count) {
    return 'Pilih hingga $count baris';
  }

  @override
  String get goToSong => 'Buka lagu';

  @override
  String get goToArtist => 'Buka artis';

  @override
  String get swipeToRequest => 'Request';

  @override
  String get offlineTitle => 'Kamu sedang offline';

  @override
  String get serverErrorTitle => 'Terjadi kesalahan';

  @override
  String get noResultsTitle => 'Tidak ada hasil';

  @override
  String get noResultsBody =>
      'Coba ejaan lain, judul bahasa Inggris atau Korea, atau nama artisnya.';

  @override
  String get wallEmptyTitle => 'Belum ada dedikasi';

  @override
  String get requestTrackerQueued => 'Request-mu · dalam antrean';

  @override
  String requestTrackerEta(int minutes) {
    return 'Request-mu · diputar ~$minutes mnt lagi';
  }

  @override
  String get requestTrackerNext => 'Request-mu diputar berikutnya';

  @override
  String get requestTrackerPlaying => 'Request-mu sedang diputar!';

  @override
  String get welcomeTitle => 'Radio K-pop, live dan gratis';

  @override
  String get welcomeBody =>
      'Dua belas stasiun, 24/7, dan perpustakaan lagu lengkap dengan lirik yang bertambah setiap hari. Request lagu dan lagunya diputar live untuk semua.';

  @override
  String get continueLabel => 'Lanjut';

  @override
  String get pickStationsTitle => 'Pilih stasiunmu';

  @override
  String get pickStationsBody =>
      'Kami taruh di depan. Bisa diganti kapan saja.';

  @override
  String get requestsTitle => 'Kamu yang pilih lagu berikutnya';

  @override
  String get requestsBody =>
      'Cari lagu apa pun dan request. Saat diputar, semua yang mendengarkan ikut mendengarnya — dan melihat dedikasimu.';

  @override
  String get startListening => 'Mulai mendengarkan';

  @override
  String get skip => 'Lewati';

  @override
  String get yourStations => 'Stasiunmu';

  @override
  String get support => 'Dukung';

  @override
  String get supportEyebrow => 'Didukung pendengar';

  @override
  String get supportH1 => 'Tanpa iklan. Tanpa paywall.';

  @override
  String get supportH1Sub =>
      'Tetap siaran berkat orang-orang yang mendengarkan.';

  @override
  String get supportLead =>
      'SeoulFM gratis, dan akan tetap gratis. Tidak ada yang dijual kepadamu dan kamu tidak dijual ke siapa pun. Kalau stasiun ini jadi bagian dari harimu, kamu bisa membantu menjaganya tetap berjalan.';

  @override
  String get supportWhereItGoes => 'Ke mana uangnya pergi';

  @override
  String get supportCostStreamTitle => 'Stream';

  @override
  String get supportCostStreamBody =>
      'Dua belas stasiun, siaran setiap jam setiap hari, dikirim ke seluruh dunia. Audio lossless di HIFI adalah yang paling mahal yang kami kirim, dan kami mengirimnya gratis.';

  @override
  String get supportCostLibraryTitle => 'Perpustakaan';

  @override
  String get supportCostLibraryBody =>
      'Puluhan ribu lagu, disimpan, diberi tag dan ditata rapi, lengkap dengan cover album, lirik yang tersinkron dan pemrosesan kelas siaran di setiap lagu.';

  @override
  String get supportCostWorkTitle => 'Pekerjaannya';

  @override
  String get supportCostWorkBody =>
      'Situs, aplikasi, request, dinding dan obrolan, ditambah biaya lisensi musik yang terus berjalan. Dibangun dan dijalankan oleh tim yang sangat kecil.';

  @override
  String get supportStaysTheSame => 'Yang tidak akan berubah';

  @override
  String get supportPromiseNoAds =>
      'Tanpa iklan audio dan tanpa banner. Tidak sekarang, tidak nanti.';

  @override
  String get supportPromiseNothingLocked =>
      'Tidak ada yang dikunci. Setiap stasiun, request dan fitur tetap gratis untuk semua.';

  @override
  String get supportPromiseOptional =>
      'Mendukung itu opsional dan tidak mengubah apa pun dari cara kamu mendengarkan.';

  @override
  String get supportBecome => 'Jadi pendukung';

  @override
  String get supportBecomeBody =>
      'Sekali, atau bulanan. Pembayaran lewat App Store atau Google Play; kami tidak pernah melihat detail kartumu.';

  @override
  String get supportMonthly => 'Pendukung bulanan';

  @override
  String get supportMonthlyBody =>
      'Jaga satu stasiun tetap siaran, setiap bulan. Batalkan kapan saja.';

  @override
  String supportPerMonth(String price) {
    return '$price / bulan';
  }

  @override
  String get supportOnce => 'Tip sekali';

  @override
  String get supportTipSmall => 'Secangkir kopi';

  @override
  String get supportTipMedium => 'Makan siang';

  @override
  String get supportTipLarge => 'Malam di luar';

  @override
  String get supportRestore => 'Pulihkan pembelian';

  @override
  String get supportUnavailable =>
      'Dukungan lewat store segera dibuka. Terima kasih sudah ingin membantu.';

  @override
  String get supportThanksTitle => 'Terima kasih';

  @override
  String get supportThanksBody =>
      'Kamu membantu SeoulFM tetap gratis untuk semua.';

  @override
  String get supportYouAreSupporter => 'Kamu seorang pendukung. Terima kasih.';

  @override
  String get supportFreeWays =>
      'Belum bisa memberi? Mendengarkan juga berarti. Begitu juga request lagu, meninggalkan pesan di dinding, atau mengenalkan stasiun ini ke satu teman yang pasti suka.';

  @override
  String get supportCardTitle => 'Jaga SeoulFM tetap gratis';

  @override
  String get supportCardBody =>
      'Tanpa iklan, tanpa paywall — tetap siaran berkat pendengar sepertimu.';

  @override
  String get supportSubscriptionTerms =>
      'Dukungan bulanan diperpanjang otomatis sampai dibatalkan di pengaturan akun store-mu.';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Gunakan bahasa sistem';

  @override
  String get qualityAutoBody =>
      'Kualitas terbaik yang sanggup ditahan koneksimu. Turun kalau koneksi tersendat.';

  @override
  String get qualityVeryHigh => 'Sangat tinggi';

  @override
  String get qualityHigh => 'Tinggi';

  @override
  String get qualityNormal => 'Normal';

  @override
  String get qualityDataSaver => 'Hemat data';

  @override
  String get qualityFixedBody => 'Selalu kualitas ini, meski koneksi lemah.';

  @override
  String get qualityLosslessNote =>
      'HIFI memutar FLAC lossless setelah kamu menyetujui pemberitahuannya.';

  @override
  String get moreOptions => 'Opsi lainnya';

  @override
  String get reportDedication => 'Laporkan';

  @override
  String hideDedicationsFrom(String name) {
    return 'Sembunyikan dedikasi dari $name';
  }

  @override
  String get reportThanks =>
      'Terima kasih sudah memberi tahu kami. Kami akan memeriksanya.';

  @override
  String get showHiddenDedications => 'Tampilkan dedikasi tersembunyi';
}
