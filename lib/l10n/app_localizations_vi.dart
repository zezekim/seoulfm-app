// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabRequest => 'Yêu cầu';

  @override
  String get tabCharts => 'BXH';

  @override
  String get tabWall => 'Lời nhắn';

  @override
  String get tabMore => 'Thêm';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Tạm ngừng phát';

  @override
  String get stationBreak => 'Kênh đang tạm nghỉ. Sẽ quay lại ngay.';

  @override
  String get nowPlaying => 'Đang phát';

  @override
  String get upNext => 'Tiếp theo';

  @override
  String get stations => 'Kênh';

  @override
  String get recentlyPlayed => 'Vừa phát';

  @override
  String get requestASong => 'Yêu cầu bài hát';

  @override
  String get requestHint =>
      'Chọn một bài và bài sẽ phát trực tiếp cho mọi người.';

  @override
  String get searchHint => 'Bài hát, nghệ sĩ, album';

  @override
  String searchEmpty(String query) {
    return 'Không có kết quả cho “$query”';
  }

  @override
  String get searchIntro =>
      'Tìm trong hơn 58.000 bài hát, đọc lời và yêu cầu một bài để phát trực tiếp.';

  @override
  String get newSongs => 'Mới trên SeoulFM';

  @override
  String get songs => 'Bài hát';

  @override
  String get artists => 'Nghệ sĩ';

  @override
  String get play => 'Phát';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get request => 'Yêu cầu';

  @override
  String get requestTitle => 'Yêu cầu bài này';

  @override
  String get yourName => 'Tên của bạn (không bắt buộc)';

  @override
  String get dedication => 'Lời nhắn (không bắt buộc)';

  @override
  String get sendRequest => 'Gửi yêu cầu';

  @override
  String get verifying => 'Đang xác minh bạn là người thật…';

  @override
  String get requestAccepted => 'Đã yêu cầu!';

  @override
  String etaMinutes(int minutes) {
    return 'Phát sau khoảng $minutes phút';
  }

  @override
  String get etaSoon => 'Sắp phát';

  @override
  String requestQueued(String title) {
    return '“$title” đã vào hàng chờ';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” sắp phát';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” đang lên sóng';
  }

  @override
  String requestExpired(String title) {
    return 'Lần này chưa phát được “$title”';
  }

  @override
  String get notRequestable => 'Hiện không thể yêu cầu';

  @override
  String get errorGeneric => 'Đã có lỗi xảy ra. Hãy thử lại.';

  @override
  String get offline => 'Không kết nối được SeoulFM. Hãy kiểm tra kết nối.';

  @override
  String get retry => 'Thử lại';

  @override
  String get chartsWeekly => 'Tuần này';

  @override
  String get chartsHot => 'Đang hot';

  @override
  String get chartsRequested => 'Được yêu cầu nhiều nhất';

  @override
  String get chartsTrending => 'Thịnh hành';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lượt phát',
      one: '1 lượt phát',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yêu cầu',
      one: '1 yêu cầu',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'MỚI';

  @override
  String get dedicationsEmpty =>
      'Chưa có lời nhắn nào. Hãy yêu cầu một bài và gửi kèm lời nhắn.';

  @override
  String dedicatedBy(String name) {
    return 'Lời nhắn từ $name';
  }

  @override
  String get lyrics => 'Lời bài hát';

  @override
  String get lyricsNone => 'Bài này chưa có lời.';

  @override
  String get share => 'Chia sẻ';

  @override
  String shareSong(String title, String artist) {
    return '$title của $artist, phát trực tiếp trên SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: radio K-pop miễn phí 24/7';
  }

  @override
  String get close => 'Đóng';

  @override
  String get startListeningToRate => 'Hãy bắt đầu nghe để đánh giá';

  @override
  String get like => 'Tôi thích bài này';

  @override
  String get dislike => 'Không hợp với tôi';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Bài hát nổi bật';

  @override
  String get albums => 'Album';

  @override
  String get related => 'Có thể bạn cũng thích';

  @override
  String get settings => 'Cài đặt';

  @override
  String get theme => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeLight => 'Sáng';

  @override
  String get sleepTimer => 'Hẹn giờ tắt';

  @override
  String get sleepOff => 'Tắt';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Dừng sau $minutes phút';
  }

  @override
  String get inTheCar => 'Trên xe';

  @override
  String get carBody =>
      'SeoulFM hoạt động với Apple CarPlay và Android Auto. Kết nối điện thoại và chọn kênh trên màn hình xe; nút chuyển bài trên vô lăng dùng để đổi kênh.';

  @override
  String get about => 'Về SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM là radio K-pop miễn phí 24/7 và nền tảng streaming nhạc Hàn Quốc: mười hai kênh phát trực tiếp, cùng thư viện hơn 58.000 bài hát, bài nào cũng có lời, để bạn tìm và yêu cầu. Bài được yêu cầu sẽ phát trực tiếp cho mọi người. Phát sóng từ năm 2009, luôn miễn phí.';

  @override
  String get website => 'Trang web';

  @override
  String get privacy => 'Quyền riêng tư';

  @override
  String get terms => 'Điều khoản';

  @override
  String get contact => 'Liên hệ';

  @override
  String version(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get losslessTitle => 'FLAC lossless';

  @override
  String losslessUses(int mb) {
    return 'Khoảng $mb MB mỗi giờ';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Chất lượng tiêu chuẩn: khoảng $mb MB mỗi giờ';
  }

  @override
  String get losslessFallbackNotice =>
      'Âm thanh lossless tốn dữ liệu hơn nhiều so với luồng tiêu chuẩn. Hãy dùng Wi-Fi hoặc gói data không giới hạn.';

  @override
  String get losslessAccept => 'Phát lossless';

  @override
  String get losslessDecline => 'Dùng chất lượng tiêu chuẩn';

  @override
  String get losslessFailed =>
      'Không phát được lossless, nên đã chuyển sang chất lượng tiêu chuẩn.';

  @override
  String get retryFlac => 'Thử lại FLAC';

  @override
  String get marathonOnAir => 'Đang phát giờ này';

  @override
  String get marathonQueue => 'Sắp tới';

  @override
  String get marathonNominations => 'Bình chọn để lên sóng';

  @override
  String get marathonVote => 'Bình chọn';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes/$required phiếu';
  }

  @override
  String get marathonNominate => 'Đề cử nghệ sĩ';

  @override
  String get marathonNominateHint => 'Tìm nghệ sĩ';

  @override
  String get marathonVoted => 'Đã ghi nhận phiếu';

  @override
  String get marathonEmpty =>
      'Chưa có đề cử nào. Hãy đề cử một nghệ sĩ cho giờ trống tiếp theo.';

  @override
  String get marathonVotedIn => 'Được bình chọn';

  @override
  String get marathonIntro =>
      'Một nhóm, trọn một giờ. Hãy bình chọn để nghệ sĩ nhận giờ trống tiếp theo.';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get justNow => 'vừa xong';

  @override
  String minutesAgo(int n) {
    return '$n phút trước';
  }

  @override
  String hoursAgo(int n) {
    return '$n giờ trước';
  }

  @override
  String inMinutes(int n) {
    return 'sau $n phút';
  }

  @override
  String get requestBadge => 'Yêu cầu';

  @override
  String get artistPage => 'Trang nghệ sĩ';

  @override
  String get openSong => 'Trang bài hát';

  @override
  String get nextStation => 'Kênh tiếp theo';

  @override
  String get previousStation => 'Kênh trước';

  @override
  String get quality => 'Chất lượng';

  @override
  String get qualityAuto => 'Tự động (AAC)';

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get captchaFailed => 'Không xác minh được. Hãy thử lại.';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String get featuredStations => 'Kênh nổi bật';

  @override
  String get genresAndEras => 'Thể loại & thời kỳ';

  @override
  String get playingFrom => 'Đang phát từ';

  @override
  String get chooseStation => 'Chọn kênh';

  @override
  String get listenNow => 'Nghe ngay';

  @override
  String get showLyrics => 'Hiện lời bài hát';

  @override
  String get shareCardSong => 'Bài hát';

  @override
  String get editLyrics => 'Chỉnh lời bài hát';

  @override
  String get copyLink => 'Sao chép liên kết';

  @override
  String get linkCopied => 'Đã sao chép';

  @override
  String get shareImage => 'Chia sẻ ảnh';

  @override
  String get done => 'Xong';

  @override
  String pickLines(int count) {
    return 'Chọn tối đa $count dòng';
  }

  @override
  String get goToSong => 'Đến bài hát';

  @override
  String get goToArtist => 'Đến nghệ sĩ';

  @override
  String get swipeToRequest => 'Yêu cầu';

  @override
  String get offlineTitle => 'Bạn đang offline';

  @override
  String get serverErrorTitle => 'Đã có lỗi xảy ra';

  @override
  String get noResultsTitle => 'Không có kết quả';

  @override
  String get noResultsBody =>
      'Hãy thử cách viết khác, tên bài bằng tiếng Anh hoặc tiếng Hàn, hoặc tên nghệ sĩ.';

  @override
  String get wallEmptyTitle => 'Chưa có lời nhắn nào';

  @override
  String get requestTrackerQueued => 'Yêu cầu của bạn · trong hàng chờ';

  @override
  String requestTrackerEta(int minutes) {
    return 'Yêu cầu của bạn · phát sau ~$minutes phút';
  }

  @override
  String get requestTrackerNext => 'Yêu cầu của bạn sẽ phát tiếp theo';

  @override
  String get requestTrackerPlaying => 'Bài bạn yêu cầu đang phát!';

  @override
  String get welcomeTitle => 'Radio K-pop trực tiếp, miễn phí';

  @override
  String get welcomeBody =>
      'Mười hai kênh, 24/7, và hơn 58.000 bài hát kèm lời. Yêu cầu một bài và bài sẽ phát trực tiếp cho mọi người.';

  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get pickStationsTitle => 'Chọn kênh của bạn';

  @override
  String get pickStationsBody =>
      'Chúng tôi sẽ đặt chúng lên đầu. Đổi bất cứ lúc nào.';

  @override
  String get requestsTitle => 'Bạn chọn bài phát tiếp theo';

  @override
  String get requestsBody =>
      'Tìm bất kỳ bài nào và yêu cầu. Khi bài phát, mọi người đang nghe đều nghe thấy — và thấy lời nhắn của bạn.';

  @override
  String get startListening => 'Bắt đầu nghe';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get yourStations => 'Kênh của bạn';

  @override
  String get support => 'Ủng hộ';

  @override
  String get supportEyebrow => 'Do người nghe ủng hộ';

  @override
  String get supportH1 => 'Không quảng cáo. Không thu phí.';

  @override
  String get supportH1Sub => 'Duy trì phát sóng nhờ chính những người nghe.';

  @override
  String get supportLead =>
      'SeoulFM miễn phí, và sẽ luôn miễn phí. Chúng tôi không có gì để bán cho bạn và cũng không bán bạn cho ai cả. Nếu kênh là một phần trong ngày của bạn, bạn có thể giúp duy trì nó.';

  @override
  String get supportWhereItGoes => 'Tiền ủng hộ đi đâu';

  @override
  String get supportCostStreamTitle => 'Luồng phát';

  @override
  String get supportCostStreamBody =>
      'Mười hai kênh, phát sóng mọi giờ mọi ngày, đến khắp thế giới. Âm thanh lossless trên HIFI là thứ tốn kém nhất mà chúng tôi truyền đi, và chúng tôi truyền miễn phí.';

  @override
  String get supportCostLibraryTitle => 'Thư viện';

  @override
  String get supportCostLibraryBody =>
      'Hàng chục nghìn bài hát, được lưu trữ, gắn thẻ và sắp xếp gọn gàng, kèm ảnh bìa, lời bài hát đồng bộ và xử lý âm thanh chuẩn phát sóng cho từng bài.';

  @override
  String get supportCostWorkTitle => 'Công việc';

  @override
  String get supportCostWorkBody =>
      'Trang web, ứng dụng, yêu cầu bài hát, bức tường và trò chuyện, cùng chi phí bản quyền âm nhạc thường xuyên. Được xây dựng và vận hành bởi một đội ngũ rất nhỏ.';

  @override
  String get supportStaysTheSame => 'Những gì không thay đổi';

  @override
  String get supportPromiseNoAds =>
      'Không quảng cáo âm thanh, không banner. Bây giờ không, sau này cũng không.';

  @override
  String get supportPromiseNothingLocked =>
      'Không có gì bị khóa. Mọi kênh, yêu cầu và tính năng đều miễn phí cho tất cả mọi người.';

  @override
  String get supportPromiseOptional =>
      'Ủng hộ là tùy bạn và không thay đổi gì trong cách bạn nghe nhạc.';

  @override
  String get supportBecome => 'Trở thành người ủng hộ';

  @override
  String get supportBecomeBody =>
      'Một lần hoặc hằng tháng. Thanh toán qua App Store hoặc Google Play; chúng tôi không bao giờ thấy thông tin thẻ của bạn.';

  @override
  String get supportMonthly => 'Ủng hộ hằng tháng';

  @override
  String get supportMonthlyBody =>
      'Giữ một kênh phát sóng mỗi tháng. Hủy bất cứ lúc nào.';

  @override
  String supportPerMonth(String price) {
    return '$price / tháng';
  }

  @override
  String get supportOnce => 'Ủng hộ một lần';

  @override
  String get supportTipSmall => 'Một ly cà phê';

  @override
  String get supportTipMedium => 'Một bữa trưa';

  @override
  String get supportTipLarge => 'Một buổi tối đi chơi';

  @override
  String get supportRestore => 'Khôi phục giao dịch mua';

  @override
  String get supportUnavailable =>
      'Tính năng ủng hộ qua cửa hàng sẽ sớm mở. Cảm ơn bạn đã muốn giúp đỡ.';

  @override
  String get supportThanksTitle => 'Cảm ơn bạn';

  @override
  String get supportThanksBody =>
      'Bạn đang giúp SeoulFM luôn miễn phí cho mọi người.';

  @override
  String get supportYouAreSupporter => 'Bạn là người ủng hộ. Cảm ơn bạn.';

  @override
  String get supportFreeWays =>
      'Chưa thể ủng hộ tiền? Nghe nhạc cũng là ủng hộ. Yêu cầu một bài hát, để lại lời nhắn trên bức tường, hay giới thiệu kênh cho một người bạn sẽ thích nó cũng vậy.';

  @override
  String get supportCardTitle => 'Giữ SeoulFM miễn phí';

  @override
  String get supportCardBody =>
      'Không quảng cáo, không thu phí — duy trì phát sóng nhờ những người nghe như bạn.';

  @override
  String get supportSubscriptionTerms =>
      'Gói ủng hộ hằng tháng tự động gia hạn cho đến khi bạn hủy trong cài đặt tài khoản cửa hàng.';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Dùng ngôn ngữ hệ thống';
}
