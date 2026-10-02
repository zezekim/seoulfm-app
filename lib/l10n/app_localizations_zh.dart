// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => '首页';

  @override
  String get tabRequest => '点歌';

  @override
  String get tabCharts => '排行榜';

  @override
  String get tabWall => '留言';

  @override
  String get tabMore => '更多';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => '暂停播出';

  @override
  String get stationBreak => '电台正在短暂休息，马上回来。';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get upNext => '接下来';

  @override
  String get stations => '电台';

  @override
  String get recentlyPlayed => '最近播放';

  @override
  String get requestASong => '点一首歌';

  @override
  String get requestHint => '选一首歌，它会直播给所有人听。';

  @override
  String get searchHint => '歌曲、歌手、专辑';

  @override
  String searchEmpty(String query) {
    return '没有找到“$query”的结果';
  }

  @override
  String get searchIntro => '搜索曲库，查看歌词，点一首歌直播给所有人听。';

  @override
  String get newSongs => 'SeoulFM新歌';

  @override
  String get songs => '歌曲';

  @override
  String get artists => '歌手';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get request => '点歌';

  @override
  String get requestTitle => '点这首歌';

  @override
  String get yourName => '你的名字（选填）';

  @override
  String get dedication => '留言（选填）';

  @override
  String get sendRequest => '发送点歌';

  @override
  String get verifying => '正在验证你不是机器人……';

  @override
  String get requestAccepted => '点歌成功！';

  @override
  String etaMinutes(int minutes) {
    return '约$minutes分钟后播出';
  }

  @override
  String get etaSoon => '即将播出';

  @override
  String requestQueued(String title) {
    return '《$title》已进入队列';
  }

  @override
  String requestScheduled(String title) {
    return '《$title》即将播出';
  }

  @override
  String requestPlayed(String title) {
    return '《$title》正在播出';
  }

  @override
  String requestExpired(String title) {
    return '《$title》这次没能播出';
  }

  @override
  String get notRequestable => '目前不能点歌';

  @override
  String get errorGeneric => '出错了，请重试。';

  @override
  String get offline => '无法连接SeoulFM，请检查网络连接。';

  @override
  String get retry => '重试';

  @override
  String get chartsWeekly => '本周';

  @override
  String get chartsHot => '正在火热';

  @override
  String get chartsRequested => '点歌最多';

  @override
  String get chartsTrending => '飙升';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '播放$count次',
      one: '播放$count次',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count次点歌',
      one: '$count次点歌',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NEW';

  @override
  String get dedicationsEmpty => '还没有留言。点一首歌，顺便留句话吧。';

  @override
  String dedicatedBy(String name) {
    return '$name的留言';
  }

  @override
  String get lyrics => '歌词';

  @override
  String get lyricsNone => '这首歌暂无歌词。';

  @override
  String get share => '分享';

  @override
  String shareSong(String title, String artist) {
    return '$artist的《$title》，正在SeoulFM直播';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name：免费的24小时K-POP电台';
  }

  @override
  String get close => '关闭';

  @override
  String get startListeningToRate => '开始收听后才能评分';

  @override
  String get like => '我喜欢这首歌';

  @override
  String get dislike => '不是我的菜';

  @override
  String get hot => '热门';

  @override
  String get topTracks => '热门歌曲';

  @override
  String get albums => '专辑';

  @override
  String get related => '你可能也喜欢';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get sleepTimer => '睡眠定时';

  @override
  String get sleepOff => '关闭';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String sleepStopsIn(int minutes) {
    return '$minutes分钟后停止';
  }

  @override
  String get inTheCar => '车载收听';

  @override
  String get carBody =>
      'SeoulFM支持Android Auto。连接手机后，在车载屏幕上选择电台；方向盘上的切歌键可以切换电台。';

  @override
  String get about => '关于SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM是免费的24小时K-POP电台，也是韩国音乐流媒体平台：十二个直播电台，加上每天都在增长的曲库，每首都配有歌词，可以搜索和点播。被点的歌会直播给所有人听。自2009年开播，一直免费。';

  @override
  String get website => '官网';

  @override
  String get privacy => '隐私政策';

  @override
  String get terms => '服务条款';

  @override
  String get contact => '联系我们';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get losslessTitle => '无损FLAC';

  @override
  String losslessUses(int mb) {
    return '每小时约$mb MB';
  }

  @override
  String losslessUsesAac(int mb) {
    return '标准音质：每小时约$mb MB';
  }

  @override
  String get losslessFallbackNotice => '无损音频的流量消耗远高于标准音频流，建议在Wi-Fi或不限流量套餐下收听。';

  @override
  String get losslessAccept => '以无损音质播放';

  @override
  String get losslessDecline => '使用标准音质';

  @override
  String get losslessFailed => '无损音质无法播放，已切换为标准音质。';

  @override
  String get retryFlac => '重试FLAC';

  @override
  String get marathonOnAir => '本小时播出';

  @override
  String get marathonQueue => '即将播出';

  @override
  String get marathonNominations => '投票选出';

  @override
  String get marathonVote => '投票';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes/$required票';
  }

  @override
  String get marathonNominate => '提名歌手';

  @override
  String get marathonNominateHint => '搜索歌手';

  @override
  String get marathonVoted => '投票成功';

  @override
  String get marathonEmpty => '目前没有进行中的提名。为下一个空档提名一位歌手吧。';

  @override
  String get marathonVotedIn => '投票选出';

  @override
  String get marathonIntro => '一个组合，整整一小时。投票让歌手拿下下一个空档。';

  @override
  String get seeAll => '查看全部';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int n) {
    return '$n分钟前';
  }

  @override
  String hoursAgo(int n) {
    return '$n小时前';
  }

  @override
  String inMinutes(int n) {
    return '$n分钟后';
  }

  @override
  String get requestBadge => '点播';

  @override
  String get artistPage => '歌手主页';

  @override
  String get openSong => '歌曲页面';

  @override
  String get nextStation => '下一个电台';

  @override
  String get previousStation => '上一个电台';

  @override
  String get quality => '音质';

  @override
  String get qualityAuto => '自动';

  @override
  String get comingSoon => '即将推出';

  @override
  String get captchaFailed => '验证失败，请重试。';

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get featuredStations => '精选电台';

  @override
  String get genresAndEras => '曲风与年代';

  @override
  String get playingFrom => '正在播放';

  @override
  String get chooseStation => '选择电台';

  @override
  String get listenNow => '立即收听';

  @override
  String get showLyrics => '显示歌词';

  @override
  String get shareCardSong => '歌曲';

  @override
  String get editLyrics => '编辑歌词';

  @override
  String get copyLink => '复制链接';

  @override
  String get linkCopied => '已复制';

  @override
  String get shareImage => '分享图片';

  @override
  String get done => '完成';

  @override
  String pickLines(int count) {
    return '最多选择$count行';
  }

  @override
  String get goToSong => '前往歌曲';

  @override
  String get goToArtist => '前往歌手';

  @override
  String get swipeToRequest => '点歌';

  @override
  String get offlineTitle => '你已离线';

  @override
  String get serverErrorTitle => '出错了';

  @override
  String get noResultsTitle => '没有结果';

  @override
  String get noResultsBody => '试试其他拼写、英文或韩文歌名，或者歌手的名字。';

  @override
  String get wallEmptyTitle => '还没有留言';

  @override
  String get requestTrackerQueued => '你的点歌 · 排队中';

  @override
  String requestTrackerEta(int minutes) {
    return '你的点歌 · 约$minutes分钟后播出';
  }

  @override
  String get requestTrackerNext => '下一首就是你点的歌';

  @override
  String get requestTrackerPlaying => '你点的歌正在播放！';

  @override
  String get welcomeTitle => 'K-POP电台，免费直播';

  @override
  String get welcomeBody => '十二个电台，24小时不间断，带歌词的曲库每天都在增长。点一首歌，它会直播给所有人听。';

  @override
  String get continueLabel => '继续';

  @override
  String get pickStationsTitle => '选择你的电台';

  @override
  String get pickStationsBody => '我们会把它们放在最前面，随时可以更改。';

  @override
  String get requestsTitle => '下一首放什么，由你决定';

  @override
  String get requestsBody => '找到任何一首歌都可以点。播出时，所有正在收听的人都会听到，也会看到你的留言。';

  @override
  String get startListening => '开始收听';

  @override
  String get skip => '跳过';

  @override
  String get yourStations => '我的电台';

  @override
  String get support => '支持我们';

  @override
  String get supportEyebrow => '由听众支持';

  @override
  String get supportH1 => '没有广告，没有付费墙。';

  @override
  String get supportH1Sub => '靠听众的支持持续播出。';

  @override
  String get supportLead =>
      'SeoulFM是免费的，而且会一直免费。我们没有东西要卖给你，也不会把你卖给任何人。如果这个电台已经是你日常的一部分，你可以帮它继续播下去。';

  @override
  String get supportWhereItGoes => '钱花在哪里';

  @override
  String get supportCostStreamTitle => '直播流';

  @override
  String get supportCostStreamBody =>
      '十二个频道，全年无休、每时每刻都在播出，传送到全世界。HIFI的无损音频是我们传送成本最高的内容，而我们免费提供。';

  @override
  String get supportCostLibraryTitle => '曲库';

  @override
  String get supportCostLibraryBody =>
      '数万首歌曲的存储、标注和整理，每一首都配有专辑封面、同步歌词和广播级音频处理。';

  @override
  String get supportCostWorkTitle => '运营';

  @override
  String get supportCostWorkBody =>
      '网站、App、点歌、留言墙和聊天室，加上持续的音乐版权费用。全部由一个很小的团队搭建和运营。';

  @override
  String get supportStaysTheSame => '不会改变的事';

  @override
  String get supportPromiseNoAds => '没有音频广告，也没有横幅广告。现在没有，以后也不会有。';

  @override
  String get supportPromiseNothingLocked => '没有任何功能上锁。每个频道、点歌和功能，对所有人都免费。';

  @override
  String get supportPromiseOptional => '支持完全自愿，不会改变你的任何收听体验。';

  @override
  String get supportBecome => '成为支持者';

  @override
  String get supportBecomeBody =>
      '一次性或按月支持。付款通过App Store或Google Play完成，我们永远看不到你的银行卡信息。';

  @override
  String get supportMonthly => '月度支持者';

  @override
  String get supportMonthlyBody => '每个月帮一个频道持续播出。随时可以取消。';

  @override
  String supportPerMonth(String price) {
    return '$price/月';
  }

  @override
  String get supportOnce => '一次性打赏';

  @override
  String get supportTipSmall => '一杯咖啡';

  @override
  String get supportTipMedium => '一顿午饭';

  @override
  String get supportTipLarge => '一次聚餐';

  @override
  String get supportRestore => '恢复购买';

  @override
  String get supportUnavailable => '暂时无法通过应用商店支持，请稍后再试。';

  @override
  String get supportThanksTitle => '谢谢你';

  @override
  String get supportThanksBody => '你正在帮助SeoulFM对所有人保持免费。';

  @override
  String get supportYouAreSupporter => '你已成为支持者，谢谢你。';

  @override
  String get supportFreeWays =>
      '暂时不方便赞助？收听本身就是支持。点一首歌、在留言墙上留言，或者把电台分享给一个会喜欢它的朋友，也都算。';

  @override
  String get supportCardTitle => '让SeoulFM保持免费';

  @override
  String get supportCardBody => '没有广告，没有付费墙——靠像你一样的听众持续播出。';

  @override
  String get supportSubscriptionTerms => '月度支持会自动续订，直到你在应用商店的账户设置中取消。';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '使用系统语言';

  @override
  String get qualityAutoBody => '以网络能承受的最佳音质播放，网络不稳时自动降低。';

  @override
  String get qualityVeryHigh => '极高';

  @override
  String get qualityHigh => '高';

  @override
  String get qualityNormal => '标准';

  @override
  String get qualityDataSaver => '省流量';

  @override
  String get qualityFixedBody => '始终使用此音质，即使网络较弱。';

  @override
  String get qualityLosslessNote => '接受HIFI的提示后，即可播放无损FLAC。';

  @override
  String get moreOptions => '更多选项';

  @override
  String get reportDedication => '举报';

  @override
  String hideDedicationsFrom(String name) {
    return '隐藏$name的留言';
  }

  @override
  String get reportThanks => '感谢反馈，我们会去看看。';

  @override
  String get showHiddenDedications => '显示已隐藏的留言';

  @override
  String get verifyFailed => '验证失败，请检查网络连接后重试。';

  @override
  String get restoreDone => '购买项目已恢复。';

  @override
  String get restoreNothing => '没有可恢复的购买项目。';

  @override
  String get playbackFailed => '无法连接直播流，请检查网络连接后重试。';

  @override
  String get audioOutput => '音频输出';

  @override
  String get openPlayer => '打开播放器';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count首歌',
      one: '$count首歌',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => '电台';

  @override
  String get spatialAudioBody =>
      'SeoulFM 针对耳机采用 BS2B（Bauer stereophonic-to-binaural）串音混合。每个声道的少量声音会传到另一只耳朵，就像在房间里听音箱一样，因此声音更开阔、更自然，长时间聆听也不易疲劳。';

  @override
  String get requestNotificationChannel => 'Your requests';

  @override
  String get requestNotificationChannelDescription =>
      'Tells you when a song you requested is coming up and when it’s on air.';

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

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => '首頁';

  @override
  String get tabRequest => '點歌';

  @override
  String get tabCharts => '排行榜';

  @override
  String get tabWall => '留言';

  @override
  String get tabMore => '更多';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => '暫停播出';

  @override
  String get stationBreak => '電台短暫休息中，很快回來。';

  @override
  String get nowPlaying => '正在播放';

  @override
  String get upNext => '接下來';

  @override
  String get stations => '電台';

  @override
  String get recentlyPlayed => '最近播放';

  @override
  String get requestASong => '點一首歌';

  @override
  String get requestHint => '選一首歌，它就會直播給所有人聽。';

  @override
  String get searchHint => '歌曲、歌手、專輯';

  @override
  String searchEmpty(String query) {
    return '找不到「$query」的結果';
  }

  @override
  String get searchIntro => '搜尋曲庫，看歌詞，點一首歌直播給所有人聽。';

  @override
  String get newSongs => 'SeoulFM新歌';

  @override
  String get songs => '歌曲';

  @override
  String get artists => '歌手';

  @override
  String get play => '播放';

  @override
  String get pause => '暫停';

  @override
  String get request => '點歌';

  @override
  String get requestTitle => '點這首歌';

  @override
  String get yourName => '你的名字（選填）';

  @override
  String get dedication => '留言（選填）';

  @override
  String get sendRequest => '送出點歌';

  @override
  String get verifying => '正在確認你不是機器人…';

  @override
  String get requestAccepted => '點歌成功！';

  @override
  String etaMinutes(int minutes) {
    return '約$minutes分鐘後播出';
  }

  @override
  String get etaSoon => '即將播出';

  @override
  String requestQueued(String title) {
    return '「$title」已加入佇列';
  }

  @override
  String requestScheduled(String title) {
    return '「$title」即將播出';
  }

  @override
  String requestPlayed(String title) {
    return '「$title」正在播出';
  }

  @override
  String requestExpired(String title) {
    return '「$title」這次沒能播出';
  }

  @override
  String get notRequestable => '目前無法點播';

  @override
  String get errorGeneric => '發生錯誤，請再試一次。';

  @override
  String get offline => '無法連上SeoulFM，請檢查網路連線。';

  @override
  String get retry => '重試';

  @override
  String get chartsWeekly => '本週';

  @override
  String get chartsHot => '現正熱門';

  @override
  String get chartsRequested => '最多點播';

  @override
  String get chartsTrending => '熱門上升';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '播放$count次',
      one: '播放$count次',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count次點播',
      one: '$count次點播',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NEW';

  @override
  String get dedicationsEmpty => '還沒有留言。點一首歌，順便留句話吧。';

  @override
  String dedicatedBy(String name) {
    return '$name的留言';
  }

  @override
  String get lyrics => '歌詞';

  @override
  String get lyricsNone => '這首歌暫無歌詞。';

  @override
  String get share => '分享';

  @override
  String shareSong(String title, String artist) {
    return '$artist的「$title」，正在SeoulFM直播';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name：免費的24小時K-POP電台';
  }

  @override
  String get close => '關閉';

  @override
  String get startListeningToRate => '開始收聽後才能評分';

  @override
  String get like => '我喜歡這首歌';

  @override
  String get dislike => '不是我的菜';

  @override
  String get hot => '熱門';

  @override
  String get topTracks => '熱門歌曲';

  @override
  String get albums => '專輯';

  @override
  String get related => '你可能也會喜歡';

  @override
  String get settings => '設定';

  @override
  String get theme => '主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '淺色';

  @override
  String get sleepTimer => '睡眠計時器';

  @override
  String get sleepOff => '關閉';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes分鐘';
  }

  @override
  String sleepStopsIn(int minutes) {
    return '$minutes分鐘後停止';
  }

  @override
  String get inTheCar => '在車上聽';

  @override
  String get carBody =>
      'SeoulFM支援Android Auto。連接手機後，在車上的螢幕選擇電台；方向盤上的跳轉鍵可以切換電台。';

  @override
  String get about => '關於SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM是免費的24小時K-POP電台，也是韓國音樂串流平台：十二個直播電台，加上每天持續增加的曲庫，每首都有歌詞，可以搜尋和點播。被點播的歌會直播給所有人聽。2009年開播至今，永遠免費。';

  @override
  String get website => '官方網站';

  @override
  String get privacy => '隱私權政策';

  @override
  String get terms => '服務條款';

  @override
  String get contact => '聯絡我們';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get losslessTitle => '無損FLAC';

  @override
  String losslessUses(int mb) {
    return '每小時約$mb MB';
  }

  @override
  String losslessUsesAac(int mb) {
    return '標準音質：每小時約$mb MB';
  }

  @override
  String get losslessFallbackNotice => '無損音訊的數據用量遠高於標準串流，建議在Wi-Fi或吃到飽方案下收聽。';

  @override
  String get losslessAccept => '以無損音質播放';

  @override
  String get losslessDecline => '使用標準音質';

  @override
  String get losslessFailed => '無損音質無法播放，已改以標準音質播放。';

  @override
  String get retryFlac => '重試FLAC';

  @override
  String get marathonOnAir => '本小時播出';

  @override
  String get marathonQueue => '即將播出';

  @override
  String get marathonNominations => '投票選出';

  @override
  String get marathonVote => '投票';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes/$required票';
  }

  @override
  String get marathonNominate => '提名藝人';

  @override
  String get marathonNominateHint => '搜尋藝人';

  @override
  String get marathonVoted => '已投票';

  @override
  String get marathonEmpty => '目前沒有進行中的提名。為下一個空檔提名一組藝人吧。';

  @override
  String get marathonVotedIn => '投票選出';

  @override
  String get marathonIntro => '一個團體，整整一小時。投票讓藝人拿下下一個空檔。';

  @override
  String get seeAll => '查看全部';

  @override
  String get justNow => '剛剛';

  @override
  String minutesAgo(int n) {
    return '$n分鐘前';
  }

  @override
  String hoursAgo(int n) {
    return '$n小時前';
  }

  @override
  String inMinutes(int n) {
    return '$n分鐘後';
  }

  @override
  String get requestBadge => '點播';

  @override
  String get artistPage => '歌手頁面';

  @override
  String get openSong => '歌曲頁面';

  @override
  String get nextStation => '下一個電台';

  @override
  String get previousStation => '上一個電台';

  @override
  String get quality => '音質';

  @override
  String get qualityAuto => '自動';

  @override
  String get comingSoon => '即將推出';

  @override
  String get captchaFailed => '驗證失敗，請再試一次。';

  @override
  String get goodMorning => '早安';

  @override
  String get goodAfternoon => '午安';

  @override
  String get goodEvening => '晚上好';

  @override
  String get featuredStations => '精選電台';

  @override
  String get genresAndEras => '曲風與年代';

  @override
  String get playingFrom => '正在播放';

  @override
  String get chooseStation => '選擇電台';

  @override
  String get listenNow => '立即收聽';

  @override
  String get showLyrics => '顯示歌詞';

  @override
  String get shareCardSong => '歌曲';

  @override
  String get editLyrics => '編輯歌詞';

  @override
  String get copyLink => '複製連結';

  @override
  String get linkCopied => '已複製';

  @override
  String get shareImage => '分享圖片';

  @override
  String get done => '完成';

  @override
  String pickLines(int count) {
    return '最多選擇$count行';
  }

  @override
  String get goToSong => '前往歌曲';

  @override
  String get goToArtist => '前往歌手';

  @override
  String get swipeToRequest => '點歌';

  @override
  String get offlineTitle => '你已離線';

  @override
  String get serverErrorTitle => '發生錯誤';

  @override
  String get noResultsTitle => '沒有結果';

  @override
  String get noResultsBody => '試試其他拼法、英文或韓文歌名，或是歌手的名字。';

  @override
  String get wallEmptyTitle => '還沒有留言';

  @override
  String get requestTrackerQueued => '你的點歌 · 排隊中';

  @override
  String requestTrackerEta(int minutes) {
    return '你的點歌 · 約$minutes分鐘後播出';
  }

  @override
  String get requestTrackerNext => '下一首就是你點的歌';

  @override
  String get requestTrackerPlaying => '你點的歌正在播放！';

  @override
  String get welcomeTitle => 'K-POP電台，免費直播';

  @override
  String get welcomeBody => '十二個電台，24小時不間斷，附歌詞的曲庫每天持續增加。點一首歌，它就會直播給所有人聽。';

  @override
  String get continueLabel => '繼續';

  @override
  String get pickStationsTitle => '選擇你的電台';

  @override
  String get pickStationsBody => '我們會把它們放在最前面，隨時都可以更改。';

  @override
  String get requestsTitle => '下一首播什麼，由你決定';

  @override
  String get requestsBody => '找到任何一首歌都可以點。播出時，所有正在收聽的人都會聽到，也會看到你的留言。';

  @override
  String get startListening => '開始收聽';

  @override
  String get skip => '略過';

  @override
  String get yourStations => '我的電台';

  @override
  String get support => '支持我們';

  @override
  String get supportEyebrow => '由聽眾支持';

  @override
  String get supportH1 => '沒有廣告，沒有付費牆。';

  @override
  String get supportH1Sub => '靠聽眾支持播出。';

  @override
  String get supportLead =>
      'SeoulFM是免費的，而且會一直免費。我們沒有東西要賣你，也不會把你賣給誰。如果電台是你生活的一部分，你可以幫忙讓它繼續播下去。';

  @override
  String get supportWhereItGoes => '錢用在哪裡';

  @override
  String get supportCostStreamTitle => '串流';

  @override
  String get supportCostStreamBody =>
      '十二個電台，全年無休、每小時都在播出，傳送到全世界。HIFI的無損音訊是我們傳送成本最高的東西，而我們免費提供。';

  @override
  String get supportCostLibraryTitle => '曲庫';

  @override
  String get supportCostLibraryBody =>
      '數萬首歌曲的儲存、標記和整理，每一首都有專輯封面、同步歌詞和廣播等級的音訊處理。';

  @override
  String get supportCostWorkTitle => '營運';

  @override
  String get supportCostWorkBody =>
      '網站、App、點歌、留言牆和聊天室，加上持續的音樂授權費用。全部由一個很小的團隊打造和營運。';

  @override
  String get supportStaysTheSame => '不會改變的事';

  @override
  String get supportPromiseNoAds => '沒有語音廣告，也沒有橫幅廣告。現在沒有，以後也不會有。';

  @override
  String get supportPromiseNothingLocked => '沒有任何功能上鎖。每個電台、點歌和功能，對所有人都是免費的。';

  @override
  String get supportPromiseOptional => '支持完全自由，不會改變你收聽的任何體驗。';

  @override
  String get supportBecome => '成為支持者';

  @override
  String get supportBecomeBody =>
      '單次或每月。付款透過App Store或Google Play處理，我們不會看到你的卡片資料。';

  @override
  String get supportMonthly => '每月支持者';

  @override
  String get supportMonthlyBody => '每個月幫一個電台持續播出。隨時可以取消。';

  @override
  String supportPerMonth(String price) {
    return '$price／月';
  }

  @override
  String get supportOnce => '單次贊助';

  @override
  String get supportTipSmall => '一杯咖啡';

  @override
  String get supportTipMedium => '一頓午餐';

  @override
  String get supportTipLarge => '一次聚餐';

  @override
  String get supportRestore => '回復購買';

  @override
  String get supportUnavailable => '目前無法透過商店支持，請稍後再試。';

  @override
  String get supportThanksTitle => '謝謝你';

  @override
  String get supportThanksBody => '你正在幫助SeoulFM對所有人保持免費。';

  @override
  String get supportYouAreSupporter => '你已經是支持者了，謝謝你。';

  @override
  String get supportFreeWays =>
      '現在不方便贊助？收聽本身就是支持。點一首歌、在留言牆留言，或把電台分享給一個會喜歡的朋友，也都是。';

  @override
  String get supportCardTitle => '讓SeoulFM保持免費';

  @override
  String get supportCardBody => '沒有廣告，沒有付費牆——靠像你一樣的聽眾支持播出。';

  @override
  String get supportSubscriptionTerms => '每月支持會自動續訂，直到你在商店帳號設定中取消為止。';

  @override
  String get language => '語言';

  @override
  String get languageSystem => '使用系統語言';

  @override
  String get qualityAutoBody => '以連線能承受的最佳音質播放，連線不穩時自動調降。';

  @override
  String get qualityVeryHigh => '極高';

  @override
  String get qualityHigh => '高';

  @override
  String get qualityNormal => '標準';

  @override
  String get qualityDataSaver => '節省數據';

  @override
  String get qualityFixedBody => '一律使用此音質，即使連線不佳。';

  @override
  String get qualityLosslessNote => '接受HIFI的提示後，即可播放無損FLAC。';

  @override
  String get moreOptions => '更多選項';

  @override
  String get reportDedication => '檢舉';

  @override
  String hideDedicationsFrom(String name) {
    return '隱藏$name的留言';
  }

  @override
  String get reportThanks => '感謝回報，我們會去看看。';

  @override
  String get showHiddenDedications => '顯示已隱藏的留言';

  @override
  String get verifyFailed => '驗證失敗，請檢查網路連線後再試一次。';

  @override
  String get restoreDone => '購買項目已回復。';

  @override
  String get restoreNothing => '沒有可回復的購買項目。';

  @override
  String get playbackFailed => '無法連上串流，請檢查網路連線後再試一次。';

  @override
  String get audioOutput => '音訊輸出';

  @override
  String get openPlayer => '開啟播放器';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count首歌',
      one: '$count首歌',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => '電台';

  @override
  String get spatialAudioBody =>
      'SeoulFM 針對耳機採用 BS2B（Bauer stereophonic-to-binaural）串音混合。每個聲道的少量聲音會傳到另一隻耳朵，就像在房間裡聽喇叭一樣，因此聲音更開闊、更自然，長時間聆聽也不易疲勞。';
}
