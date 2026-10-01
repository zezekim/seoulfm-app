// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Ana Sayfa';

  @override
  String get tabRequest => 'İstek';

  @override
  String get tabCharts => 'Listeler';

  @override
  String get tabWall => 'İthaflar';

  @override
  String get tabMore => 'Daha fazla';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Yayın dışı';

  @override
  String get stationBreak =>
      'İstasyon kısa bir mola veriyor. Birazdan döneceğiz.';

  @override
  String get nowPlaying => 'Şimdi çalıyor';

  @override
  String get upNext => 'Sıradaki';

  @override
  String get stations => 'İstasyonlar';

  @override
  String get recentlyPlayed => 'Son çalınanlar';

  @override
  String get requestASong => 'Şarkı iste';

  @override
  String get requestHint => 'Bir şarkı seç, herkes için canlı çalsın.';

  @override
  String get searchHint => 'Şarkılar, sanatçılar, albümler';

  @override
  String searchEmpty(String query) {
    return '“$query” için sonuç bulunamadı';
  }

  @override
  String get searchIntro =>
      'Kütüphanede ara, sözleri oku ve canlı çalması için bir şarkı iste.';

  @override
  String get newSongs => 'SeoulFM’de yeni';

  @override
  String get songs => 'Şarkılar';

  @override
  String get artists => 'Sanatçılar';

  @override
  String get play => 'Oynat';

  @override
  String get pause => 'Duraklat';

  @override
  String get request => 'İste';

  @override
  String get requestTitle => 'Bu şarkıyı iste';

  @override
  String get yourName => 'Adın (isteğe bağlı)';

  @override
  String get dedication => 'İthaf mesajı (isteğe bağlı)';

  @override
  String get sendRequest => 'İsteği gönder';

  @override
  String get verifying => 'İnsan olduğun doğrulanıyor…';

  @override
  String get requestAccepted => 'İsteğin alındı!';

  @override
  String etaMinutes(int minutes) {
    return 'Yaklaşık $minutes dk sonra çalacak';
  }

  @override
  String get etaSoon => 'Birazdan çalacak';

  @override
  String requestQueued(String title) {
    return '“$title” sırada';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” birazdan çalacak';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” şu an yayında';
  }

  @override
  String requestExpired(String title) {
    return '“$title” bu sefer çalınamadı';
  }

  @override
  String get notRequestable => 'Şu an istenemez';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Tekrar dene.';

  @override
  String get offline => 'SeoulFM’e ulaşılamıyor. Bağlantını kontrol et.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get chartsWeekly => 'Bu hafta';

  @override
  String get chartsHot => 'Gündemde';

  @override
  String get chartsRequested => 'En çok istenen';

  @override
  String get chartsTrending => 'Yükselenler';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kez çalındı',
      one: '$count kez çalındı',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count istek',
      one: '$count istek',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'YENİ';

  @override
  String get dedicationsEmpty =>
      'Henüz ithaf yok. Bir şarkı iste ve ithaf ekle.';

  @override
  String dedicatedBy(String name) {
    return 'İthaf eden: $name';
  }

  @override
  String get lyrics => 'Şarkı sözleri';

  @override
  String get lyricsNone => 'Bu şarkının sözleri henüz yok.';

  @override
  String get share => 'Paylaş';

  @override
  String shareSong(String title, String artist) {
    return '$artist – $title, SeoulFM’de canlı';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: ücretsiz 7/24 K-pop radyosu';
  }

  @override
  String get close => 'Kapat';

  @override
  String get startListeningToRate => 'Puan vermek için dinlemeye başla';

  @override
  String get like => 'Bu şarkıyı sevdim';

  @override
  String get dislike => 'Bana göre değil';

  @override
  String get hot => 'Gündemde';

  @override
  String get topTracks => 'En iyi şarkılar';

  @override
  String get albums => 'Albümler';

  @override
  String get related => 'Bunları da sevebilirsin';

  @override
  String get settings => 'Ayarlar';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeLight => 'Açık';

  @override
  String get sleepTimer => 'Uyku zamanlayıcısı';

  @override
  String get sleepOff => 'Kapalı';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String sleepStopsIn(int minutes) {
    return '$minutes dk sonra durur';
  }

  @override
  String get inTheCar => 'Araçta';

  @override
  String get carBody =>
      'SeoulFM, Android Auto ile çalışır. Telefonunu bağla ve aracının ekranından bir istasyon seç; direksiyondaki ileri/geri tuşları istasyonu değiştirir.';

  @override
  String get about => 'SeoulFM hakkında';

  @override
  String get aboutBody =>
      'SeoulFM, ücretsiz 7/24 K-pop radyosu ve bir Kore müziği streaming platformu: on iki canlı istasyon ve her biri şarkı sözleriyle birlikte, arayıp isteyebileceğin, her gün büyüyen bir şarkı kütüphanesi. İstenen şarkı herkes için canlı çalar. 2009’dan beri yayında, her zaman ücretsiz.';

  @override
  String get website => 'Web sitesi';

  @override
  String get privacy => 'Gizlilik';

  @override
  String get terms => 'Kullanım Koşulları';

  @override
  String get contact => 'İletişim';

  @override
  String version(String version) {
    return 'Sürüm $version';
  }

  @override
  String get losslessTitle => 'Kayıpsız FLAC';

  @override
  String losslessUses(int mb) {
    return 'Saatte yaklaşık $mb MB';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Standart kalite: saatte yaklaşık $mb MB';
  }

  @override
  String get losslessFallbackNotice =>
      'Kayıpsız ses, standart yayından çok daha fazla veri kullanır. Wi-Fi’da ya da sınırsız pakette dinle.';

  @override
  String get losslessAccept => 'Kayıpsız çal';

  @override
  String get losslessDecline => 'Standart kaliteyi kullan';

  @override
  String get losslessFailed =>
      'Kayıpsız çalmıyor, bu yüzden standart kaliteye geçildi.';

  @override
  String get retryFlac => 'FLAC’ı tekrar dene';

  @override
  String get marathonOnAir => 'Bu saat yayında';

  @override
  String get marathonQueue => 'Sıradakiler';

  @override
  String get marathonNominations => 'Oy ver, seçilsin';

  @override
  String get marathonVote => 'Oy ver';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes/$required oy';
  }

  @override
  String get marathonNominate => 'Bir sanatçıyı aday göster';

  @override
  String get marathonNominateHint => 'Sanatçı ara';

  @override
  String get marathonVoted => 'Oy sayıldı';

  @override
  String get marathonEmpty =>
      'Açık aday yok. Bir sonraki boş saat için bir sanatçıyı aday göster.';

  @override
  String get marathonVotedIn => 'Oylarla seçildi';

  @override
  String get marathonIntro =>
      'Tek grup, tam bir saat. Bir sonraki boş saat için bir sanatçıya oy ver.';

  @override
  String get seeAll => 'Tümünü gör';

  @override
  String get justNow => 'az önce';

  @override
  String minutesAgo(int n) {
    return '$n dk önce';
  }

  @override
  String hoursAgo(int n) {
    return '$n sa önce';
  }

  @override
  String inMinutes(int n) {
    return '$n dk sonra';
  }

  @override
  String get requestBadge => 'İstek';

  @override
  String get artistPage => 'Sanatçı sayfası';

  @override
  String get openSong => 'Şarkı sayfası';

  @override
  String get nextStation => 'Sonraki istasyon';

  @override
  String get previousStation => 'Önceki istasyon';

  @override
  String get quality => 'Kalite';

  @override
  String get qualityAuto => 'Otomatik';

  @override
  String get comingSoon => 'Çok yakında';

  @override
  String get captchaFailed => 'Doğrulanamadı. Tekrar dene.';

  @override
  String get goodMorning => 'Günaydın';

  @override
  String get goodAfternoon => 'İyi günler';

  @override
  String get goodEvening => 'İyi akşamlar';

  @override
  String get featuredStations => 'Öne çıkan istasyonlar';

  @override
  String get genresAndEras => 'Türler ve dönemler';

  @override
  String get playingFrom => 'Çalan istasyon';

  @override
  String get chooseStation => 'İstasyon seç';

  @override
  String get listenNow => 'Şimdi dinle';

  @override
  String get showLyrics => 'Sözleri göster';

  @override
  String get shareCardSong => 'Şarkı';

  @override
  String get editLyrics => 'Satırları seç';

  @override
  String get copyLink => 'Bağlantıyı kopyala';

  @override
  String get linkCopied => 'Kopyalandı';

  @override
  String get shareImage => 'Görseli paylaş';

  @override
  String get done => 'Tamam';

  @override
  String pickLines(int count) {
    return 'En fazla $count satır seç';
  }

  @override
  String get goToSong => 'Şarkıya git';

  @override
  String get goToArtist => 'Sanatçıya git';

  @override
  String get swipeToRequest => 'İste';

  @override
  String get offlineTitle => 'Çevrimdışısın';

  @override
  String get serverErrorTitle => 'Bir şeyler ters gitti';

  @override
  String get noResultsTitle => 'Sonuç yok';

  @override
  String get noResultsBody =>
      'Farklı bir yazım, İngilizce ya da Korece bir şarkı adı veya sanatçının adını dene.';

  @override
  String get wallEmptyTitle => 'Henüz ithaf yok';

  @override
  String get requestTrackerQueued => 'İsteğin · sırada';

  @override
  String requestTrackerEta(int minutes) {
    return 'İsteğin · yaklaşık $minutes dk sonra çalacak';
  }

  @override
  String get requestTrackerNext => 'Sıradaki şarkı senin isteğin';

  @override
  String get requestTrackerPlaying => 'İsteğin şimdi çalıyor!';

  @override
  String get welcomeTitle => 'K-pop radyosu, canlı ve ücretsiz';

  @override
  String get welcomeBody =>
      'On iki istasyon, 7/24 yayında ve sözleriyle birlikte her gün büyüyen bir şarkı kütüphanesi. Bir şarkı iste, herkes için canlı çalsın.';

  @override
  String get continueLabel => 'Devam';

  @override
  String get pickStationsTitle => 'İstasyonlarını seç';

  @override
  String get pickStationsBody =>
      'Onları en önde tutacağız. İstediğin zaman değiştirebilirsin.';

  @override
  String get requestsTitle => 'Sırada ne çalacağını sen seçersin';

  @override
  String get requestsBody =>
      'İstediğin şarkıyı bul ve iste. Çaldığında dinleyen herkes duyar ve ithafını görür.';

  @override
  String get startListening => 'Dinlemeye başla';

  @override
  String get skip => 'Atla';

  @override
  String get yourStations => 'İstasyonların';

  @override
  String get support => 'Destek Ol';

  @override
  String get supportEyebrow => 'Dinleyici destekli';

  @override
  String get supportH1 => 'Reklam yok. Ücret duvarı yok.';

  @override
  String get supportH1Sub => 'Yayını dinleyenler sürdürüyor.';

  @override
  String get supportLead =>
      'SeoulFM ücretsiz ve ücretsiz kalacak. Sana satacağımız bir şey yok, seni satacağımız kimse de yok. İstasyon gününün bir parçasıysa, yayında kalmasına yardım edebilirsin.';

  @override
  String get supportWhereItGoes => 'Destek nereye gidiyor';

  @override
  String get supportCostStreamTitle => 'Yayın';

  @override
  String get supportCostStreamBody =>
      'On iki kanal, günün her saati yayında, tüm dünyaya ulaşıyor. HIFI’daki kayıpsız ses gönderdiğimiz en pahalı şey ve onu ücretsiz gönderiyoruz.';

  @override
  String get supportCostLibraryTitle => 'Kütüphane';

  @override
  String get supportCostLibraryBody =>
      'On binlerce şarkı; saklanıyor, etiketleniyor ve düzenli tutuluyor. Her birinde albüm kapağı, senkronize şarkı sözleri ve yayın kalitesinde işleme var.';

  @override
  String get supportCostWorkTitle => 'Emek';

  @override
  String get supportCostWorkBody =>
      'Site, uygulamalar, istekler, duvar ve sohbet; bir de süregelen müzik lisansı masrafı. Hepsini çok küçük bir ekip kurup yürütüyor.';

  @override
  String get supportStaysTheSame => 'Değişmeyecek olanlar';

  @override
  String get supportPromiseNoAds =>
      'Sesli reklam yok, banner yok. Ne şimdi ne de sonra.';

  @override
  String get supportPromiseNothingLocked =>
      'Hiçbir şey kilitli değil. Her kanal, istek ve özellik herkes için ücretsiz kalır.';

  @override
  String get supportPromiseOptional =>
      'Destek olmak isteğe bağlıdır ve dinleme şeklinde hiçbir şeyi değiştirmez.';

  @override
  String get supportBecome => 'Destekçi ol';

  @override
  String get supportBecomeBody =>
      'Bir kez ya da aylık. Ödemeler App Store veya Google Play üzerinden yapılır; kart bilgilerini asla görmeyiz.';

  @override
  String get supportMonthly => 'Aylık destekçi';

  @override
  String get supportMonthlyBody =>
      'Her ay bir kanalı yayında tut. İstediğin zaman iptal et.';

  @override
  String supportPerMonth(String price) {
    return '$price / ay';
  }

  @override
  String get supportOnce => 'Tek seferlik destek';

  @override
  String get supportTipSmall => 'Bir kahve';

  @override
  String get supportTipMedium => 'Bir öğle yemeği';

  @override
  String get supportTipLarge => 'Dışarıda bir akşam';

  @override
  String get supportRestore => 'Satın alımları geri yükle';

  @override
  String get supportUnavailable =>
      'Mağaza üzerinden destek şu anda kullanılamıyor. Daha sonra tekrar dene.';

  @override
  String get supportThanksTitle => 'Teşekkürler';

  @override
  String get supportThanksBody =>
      'SeoulFM’in herkes için ücretsiz kalmasına yardım ediyorsun.';

  @override
  String get supportYouAreSupporter => 'Destekçisin. Teşekkürler.';

  @override
  String get supportFreeWays =>
      'Maddi destek veremiyor musun? Dinlemek de sayılır. Şarkı istemek, duvara not bırakmak ya da istasyonu seveceğini bildiğin bir arkadaşına göndermek de öyle.';

  @override
  String get supportCardTitle => 'SeoulFM’i ücretsiz tut';

  @override
  String get supportCardBody =>
      'Reklam yok, ücret duvarı yok — yayını senin gibi dinleyiciler sürdürüyor.';

  @override
  String get supportSubscriptionTerms =>
      'Aylık destek, mağaza hesap ayarlarından iptal edilene kadar otomatik olarak yenilenir.';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem dilini kullan';

  @override
  String get qualityAutoBody =>
      'Bağlantının kaldırabildiği en iyi kalite. Zorlanırsa düşer.';

  @override
  String get qualityVeryHigh => 'Çok yüksek';

  @override
  String get qualityHigh => 'Yüksek';

  @override
  String get qualityNormal => 'Normal';

  @override
  String get qualityDataSaver => 'Veri tasarrufu';

  @override
  String get qualityFixedBody => 'Bağlantı zayıf olsa bile hep bu kalite.';

  @override
  String get qualityLosslessNote =>
      'HIFI, uyarısını kabul ettiğinde kayıpsız FLAC çalar.';

  @override
  String get moreOptions => 'Diğer seçenekler';

  @override
  String get reportDedication => 'Bildir';

  @override
  String hideDedicationsFrom(String name) {
    return '$name kişisinin ithaflarını gizle';
  }

  @override
  String get reportThanks => 'Bildirdiğin için teşekkürler. Bir göz atacağız.';

  @override
  String get showHiddenDedications => 'Gizlenen ithafları göster';

  @override
  String get verifyFailed =>
      'Doğrulanamadı. Bağlantını kontrol edip tekrar dene.';

  @override
  String get restoreDone => 'Satın alımların geri yüklendi.';

  @override
  String get restoreNothing => 'Geri yüklenecek satın alım yok.';

  @override
  String get playbackFailed =>
      'Yayına ulaşılamıyor. Bağlantını kontrol edip tekrar dene.';

  @override
  String get audioOutput => 'Ses çıkışı';

  @override
  String get openPlayer => 'Oynatıcıyı aç';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count şarkı',
      one: '$count şarkı',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'İstasyonlar';
}
