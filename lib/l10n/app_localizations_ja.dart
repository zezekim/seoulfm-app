// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabRequest => 'リクエスト';

  @override
  String get tabCharts => 'チャート';

  @override
  String get tabWall => 'メッセージ';

  @override
  String get tabMore => 'その他';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => '休止中';

  @override
  String get stationBreak => 'ステーションは少しの間お休みしています。まもなく再開します。';

  @override
  String get nowPlaying => '再生中';

  @override
  String get upNext => '次の曲';

  @override
  String get stations => 'ステーション';

  @override
  String get recentlyPlayed => '最近流れた曲';

  @override
  String get requestASong => '曲をリクエスト';

  @override
  String get requestHint => '曲を選ぶと、全員に向けてライブで流れます。';

  @override
  String get searchHint => '曲名・アーティスト・アルバム';

  @override
  String searchEmpty(String query) {
    return '「$query」に一致する結果はありません';
  }

  @override
  String get searchIntro => 'ライブラリを検索して、歌詞を読んで、ライブで流したい曲をリクエストしよう。';

  @override
  String get newSongs => 'SeoulFMの新着';

  @override
  String get songs => '曲';

  @override
  String get artists => 'アーティスト';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get request => 'リクエスト';

  @override
  String get requestTitle => 'この曲をリクエスト';

  @override
  String get yourName => '名前（任意）';

  @override
  String get dedication => 'メッセージ（任意）';

  @override
  String get sendRequest => 'リクエストを送る';

  @override
  String get verifying => 'ロボットでないことを確認中…';

  @override
  String get requestAccepted => 'リクエストしました！';

  @override
  String etaMinutes(int minutes) {
    return '約$minutes分後に再生';
  }

  @override
  String get etaSoon => 'まもなく再生';

  @override
  String requestQueued(String title) {
    return '「$title」がキューに入りました';
  }

  @override
  String requestScheduled(String title) {
    return '「$title」がまもなく流れます';
  }

  @override
  String requestPlayed(String title) {
    return '「$title」がいま放送中です';
  }

  @override
  String requestExpired(String title) {
    return '「$title」は今回は再生できませんでした';
  }

  @override
  String get notRequestable => 'いまはリクエストできません';

  @override
  String get errorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get offline => 'SeoulFMに接続できません。接続を確認してください。';

  @override
  String get retry => '再試行';

  @override
  String get chartsWeekly => '今週';

  @override
  String get chartsHot => 'いまホット';

  @override
  String get chartsRequested => 'リクエスト上位';

  @override
  String get chartsTrending => '急上昇';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回再生',
      one: '$count回再生',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'リクエスト$count件',
      one: 'リクエスト$count件',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NEW';

  @override
  String get dedicationsEmpty => 'まだメッセージはありません。曲をリクエストして、メッセージを添えよう。';

  @override
  String dedicatedBy(String name) {
    return '$nameさんからのメッセージ';
  }

  @override
  String get lyrics => '歌詞';

  @override
  String get lyricsNone => 'この曲の歌詞はまだありません。';

  @override
  String get share => 'シェア';

  @override
  String shareSong(String title, String artist) {
    return '$artistの「$title」をSeoulFMでライブ配信中';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name：無料の24時間K-POPラジオ';
  }

  @override
  String get close => '閉じる';

  @override
  String get startListeningToRate => '聴き始めると評価できます';

  @override
  String get like => 'この曲が好き';

  @override
  String get dislike => '好みじゃない';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => '人気曲';

  @override
  String get albums => 'アルバム';

  @override
  String get related => 'こちらもおすすめ';

  @override
  String get settings => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeLight => 'ライト';

  @override
  String get sleepTimer => 'スリープタイマー';

  @override
  String get sleepOff => 'オフ';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String sleepStopsIn(int minutes) {
    return '$minutes分後に停止';
  }

  @override
  String get inTheCar => '車で聴く';

  @override
  String get carBody =>
      'SeoulFMはAndroid Autoに対応しています。スマホを接続して、車の画面でステーションを選んでください。ハンドルのスキップボタンでステーションを切り替えられます。';

  @override
  String get about => 'SeoulFMについて';

  @override
  String get aboutBody =>
      'SeoulFMは無料の24時間K-POPラジオで、韓国音楽のストリーミングプラットフォームです。12のライブステーションと、すべて歌詞付きの曲が毎日増え続けるライブラリがあり、検索もリクエストもできます。リクエストされた曲は全員に向けてライブで流れます。2009年から放送中、いつでも無料です。';

  @override
  String get website => 'ウェブサイト';

  @override
  String get privacy => 'プライバシー';

  @override
  String get terms => '利用規約';

  @override
  String get contact => 'お問い合わせ';

  @override
  String version(String version) {
    return 'バージョン $version';
  }

  @override
  String get losslessTitle => 'ロスレスFLAC';

  @override
  String losslessUses(int mb) {
    return '1時間あたり約${mb}MB';
  }

  @override
  String losslessUsesAac(int mb) {
    return '標準音質：1時間あたり約${mb}MB';
  }

  @override
  String get losslessFallbackNotice =>
      'ロスレス音声は標準の配信よりデータ通信量がかなり多くなります。Wi-Fiか使い放題プランでの利用がおすすめです。';

  @override
  String get losslessAccept => 'ロスレスで再生';

  @override
  String get losslessDecline => '標準音質にする';

  @override
  String get losslessFailed => 'ロスレスを再生できないため、標準音質で再生しています。';

  @override
  String get retryFlac => 'FLACを再試行';

  @override
  String get marathonOnAir => 'この1時間の放送';

  @override
  String get marathonQueue => '放送予定';

  @override
  String get marathonNominations => '投票で決めよう';

  @override
  String get marathonVote => '投票';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes/$required票';
  }

  @override
  String get marathonNominate => 'アーティストを推薦';

  @override
  String get marathonNominateHint => 'アーティストを検索';

  @override
  String get marathonVoted => '投票しました';

  @override
  String get marathonEmpty => '受付中の推薦はありません。次の空き枠の1時間にアーティストを推薦しよう。';

  @override
  String get marathonVotedIn => '投票で決定';

  @override
  String get marathonIntro => '1組のグループを丸1時間。投票で次の空き枠にアーティストを送り込もう。';

  @override
  String get seeAll => 'すべて見る';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int n) {
    return '$n分前';
  }

  @override
  String hoursAgo(int n) {
    return '$n時間前';
  }

  @override
  String inMinutes(int n) {
    return '$n分後';
  }

  @override
  String get requestBadge => 'リクエスト';

  @override
  String get artistPage => 'アーティストページ';

  @override
  String get openSong => '曲のページ';

  @override
  String get nextStation => '次のステーション';

  @override
  String get previousStation => '前のステーション';

  @override
  String get quality => '音質';

  @override
  String get qualityAuto => '自動';

  @override
  String get comingSoon => '近日公開';

  @override
  String get captchaFailed => '認証できませんでした。もう一度お試しください。';

  @override
  String get goodMorning => 'おはようございます';

  @override
  String get goodAfternoon => 'こんにちは';

  @override
  String get goodEvening => 'こんばんは';

  @override
  String get featuredStations => 'おすすめステーション';

  @override
  String get genresAndEras => 'ジャンルと年代';

  @override
  String get playingFrom => '再生元';

  @override
  String get chooseStation => 'ステーションを選ぶ';

  @override
  String get listenNow => '今すぐ聴く';

  @override
  String get showLyrics => '歌詞を表示';

  @override
  String get shareCardSong => '曲';

  @override
  String get editLyrics => '歌詞を編集';

  @override
  String get copyLink => 'リンクをコピー';

  @override
  String get linkCopied => 'コピーしました';

  @override
  String get shareImage => '画像をシェア';

  @override
  String get done => '完了';

  @override
  String pickLines(int count) {
    return '最大$count行まで選べます';
  }

  @override
  String get goToSong => '曲へ移動';

  @override
  String get goToArtist => 'アーティストへ移動';

  @override
  String get swipeToRequest => 'リクエスト';

  @override
  String get offlineTitle => 'オフラインです';

  @override
  String get serverErrorTitle => '問題が発生しました';

  @override
  String get noResultsTitle => '結果がありません';

  @override
  String get noResultsBody => '別のつづり、英語や韓国語の曲名、アーティスト名で試してみてください。';

  @override
  String get wallEmptyTitle => 'まだメッセージはありません';

  @override
  String get requestTrackerQueued => 'あなたのリクエスト · キューに追加済み';

  @override
  String requestTrackerEta(int minutes) {
    return 'あなたのリクエスト · 約$minutes分後に再生';
  }

  @override
  String get requestTrackerNext => 'あなたのリクエストは次に流れます';

  @override
  String get requestTrackerPlaying => 'あなたのリクエストが再生中！';

  @override
  String get welcomeTitle => 'K-POPラジオを、ライブで無料で';

  @override
  String get welcomeBody =>
      '12のステーションを24時間、歌詞付きの曲が毎日増えるライブラリ。曲をリクエストすると、全員に向けてライブで流れます。';

  @override
  String get continueLabel => '続ける';

  @override
  String get pickStationsTitle => 'ステーションを選ぼう';

  @override
  String get pickStationsBody => '選んだステーションは先頭に表示します。いつでも変更できます。';

  @override
  String get requestsTitle => '次に流れる曲は、あなたが決める';

  @override
  String get requestsBody =>
      'どの曲でも探してリクエストできます。曲が流れると、聴いている全員に届き、あなたのメッセージも表示されます。';

  @override
  String get startListening => '聴きはじめる';

  @override
  String get skip => 'スキップ';

  @override
  String get yourStations => 'あなたのステーション';

  @override
  String get support => '応援する';

  @override
  String get supportEyebrow => 'リスナーが支えるラジオ';

  @override
  String get supportH1 => '広告なし。課金の壁なし。';

  @override
  String get supportH1Sub => '聴いている人たちが放送を支えています。';

  @override
  String get supportLead =>
      'SeoulFMは無料で、これからも無料のままです。あなたに売りつけるものも、あなたを売る相手もありません。このステーションが毎日の一部になっているなら、運営を続ける手助けをしてもらえるとうれしいです。';

  @override
  String get supportWhereItGoes => '応援の使い道';

  @override
  String get supportCostStreamTitle => '配信';

  @override
  String get supportCostStreamBody =>
      '12のステーションを毎日24時間、世界中に配信しています。HIFIのロスレス音声はいちばんコストのかかる配信ですが、無料でお届けしています。';

  @override
  String get supportCostLibraryTitle => 'ライブラリ';

  @override
  String get supportCostLibraryBody =>
      '何万曲もの楽曲を保存・タグ付け・整理し、すべての曲にジャケット写真、同期歌詞、放送品質の音声処理を用意しています。';

  @override
  String get supportCostWorkTitle => '運営';

  @override
  String get supportCostWorkBody =>
      'サイト、アプリ、リクエスト、ウォール、チャット、そして継続的にかかる音楽の使用料。ごく小さなチームで作り、運営しています。';

  @override
  String get supportStaysTheSame => '変わらないこと';

  @override
  String get supportPromiseNoAds => '音声広告もバナーもなし。今も、これからも。';

  @override
  String get supportPromiseNothingLocked =>
      '制限される機能はありません。すべてのステーション、リクエスト、機能は誰でも無料のままです。';

  @override
  String get supportPromiseOptional => '応援は任意で、聴き方は何も変わりません。';

  @override
  String get supportBecome => 'サポーターになる';

  @override
  String get supportBecomeBody =>
      '1回だけでも毎月でも。支払いはApp StoreまたはGoogle Playを通じて行われるので、私たちがカード情報を見ることはありません。';

  @override
  String get supportMonthly => '月額サポーター';

  @override
  String get supportMonthlyBody => '毎月、ステーションの放送を支えます。いつでも解約できます。';

  @override
  String supportPerMonth(String price) {
    return '$price／月';
  }

  @override
  String get supportOnce => '1回だけ応援する';

  @override
  String get supportTipSmall => 'コーヒー1杯';

  @override
  String get supportTipMedium => 'ランチ1回';

  @override
  String get supportTipLarge => 'ちょっといいディナー';

  @override
  String get supportRestore => '購入を復元';

  @override
  String get supportUnavailable => '現在、ストアでの応援はご利用いただけません。しばらくしてからもう一度お試しください。';

  @override
  String get supportThanksTitle => 'ありがとうございます';

  @override
  String get supportThanksBody => 'SeoulFMを誰でも無料で聴けるように支えてくれています。';

  @override
  String get supportYouAreSupporter => 'あなたはサポーターです。ありがとうございます。';

  @override
  String get supportFreeWays =>
      'お金での応援は難しい？聴いてくれるだけでも力になります。曲をリクエストする、ウォールにメッセージを残す、気に入ってくれそうな友だちにステーションを教える、それも立派な応援です。';

  @override
  String get supportCardTitle => 'SeoulFMを無料のままに';

  @override
  String get supportCardBody => '広告なし、課金の壁なし。あなたのようなリスナーが放送を支えています。';

  @override
  String get supportSubscriptionTerms => '毎月の応援は、ストアのアカウント設定で解約するまで自動的に更新されます。';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システムの言語を使用';

  @override
  String get qualityAutoBody => '接続が保てる最高の音質。不安定なときは下げます。';

  @override
  String get qualityVeryHigh => '非常に高い';

  @override
  String get qualityHigh => '高い';

  @override
  String get qualityNormal => '標準';

  @override
  String get qualityDataSaver => 'データ節約';

  @override
  String get qualityFixedBody => '接続が弱くても、常にこの音質で再生します。';

  @override
  String get qualityLosslessNote => 'HIFIは、注意事項に同意するとロスレスFLACで再生されます。';

  @override
  String get moreOptions => 'その他';

  @override
  String get reportDedication => '報告する';

  @override
  String hideDedicationsFrom(String name) {
    return '$nameさんのメッセージを非表示';
  }

  @override
  String get reportThanks => 'お知らせありがとうございます。確認しますね。';

  @override
  String get showHiddenDedications => '非表示にしたメッセージを再表示';

  @override
  String get verifyFailed => '認証できませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get restoreDone => '購入を復元しました。';

  @override
  String get restoreNothing => '復元できる購入はありません。';

  @override
  String get playbackFailed => '配信に接続できません。接続を確認して、もう一度お試しください。';

  @override
  String get audioOutput => 'オーディオ出力';

  @override
  String get openPlayer => 'プレーヤーを開く';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count曲',
      one: '$count曲',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'ステーション';

  @override
  String get spatialAudioBody =>
      'SeoulFMは、BS2B（Bauer stereophonic-to-binaural）クロスフィードでヘッドホン向けにミックスされています。部屋のスピーカーで聴くように、左右それぞれの音がわずかに反対の耳にも届くため、より広く自然に聞こえ、長時間聴いても耳が疲れにくくなります。';
}
