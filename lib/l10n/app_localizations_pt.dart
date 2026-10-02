// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Início';

  @override
  String get tabRequest => 'Pedir';

  @override
  String get tabCharts => 'Paradas';

  @override
  String get tabWall => 'Dedicatórias';

  @override
  String get tabMore => 'Mais';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Fora do ar';

  @override
  String get stationBreak => 'Pausa rápida. Voltamos já.';

  @override
  String get nowPlaying => 'Tocando agora';

  @override
  String get upNext => 'A seguir';

  @override
  String get stations => 'Estações';

  @override
  String get recentlyPlayed => 'Tocadas recentemente';

  @override
  String get requestASong => 'Peça uma música';

  @override
  String get requestHint =>
      'Escolha uma música e ela toca ao vivo para todo mundo.';

  @override
  String get searchHint => 'Músicas, artistas, álbuns';

  @override
  String searchEmpty(String query) {
    return 'Nenhum resultado para “$query”';
  }

  @override
  String get searchIntro =>
      'Busque na biblioteca, leia a letra e peça uma música para tocar ao vivo.';

  @override
  String get newSongs => 'Novidades na SeoulFM';

  @override
  String get songs => 'Músicas';

  @override
  String get artists => 'Artistas';

  @override
  String get play => 'Ouvir';

  @override
  String get pause => 'Pausar';

  @override
  String get request => 'Pedir';

  @override
  String get requestTitle => 'Pedir esta música';

  @override
  String get yourName => 'Seu nome (opcional)';

  @override
  String get dedication => 'Dedicatória (opcional)';

  @override
  String get sendRequest => 'Enviar pedido';

  @override
  String get verifying => 'Verificando se você é humano…';

  @override
  String get requestAccepted => 'Pedido enviado!';

  @override
  String etaMinutes(int minutes) {
    return 'Toca em cerca de $minutes min';
  }

  @override
  String get etaSoon => 'Toca em breve';

  @override
  String requestQueued(String title) {
    return '“$title” está na fila';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” é a próxima';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” está no ar agora';
  }

  @override
  String requestExpired(String title) {
    return '“$title” não pôde tocar desta vez';
  }

  @override
  String get notRequestable => 'Não dá para pedir agora';

  @override
  String get errorGeneric => 'Algo deu errado. Tente de novo.';

  @override
  String get offline =>
      'Não foi possível conectar à SeoulFM. Verifique sua conexão.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get chartsWeekly => 'Esta semana';

  @override
  String get chartsHot => 'Em alta';

  @override
  String get chartsRequested => 'Mais pedidas';

  @override
  String get chartsTrending => 'Tendências';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count execuções',
      one: '1 execução',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NOVA';

  @override
  String get dedicationsEmpty =>
      'Ainda não há dedicatórias. Peça uma música e deixe a sua.';

  @override
  String dedicatedBy(String name) {
    return 'Dedicada por $name';
  }

  @override
  String get lyrics => 'Letra';

  @override
  String get lyricsNone => 'Esta música ainda não tem letra.';

  @override
  String get share => 'Compartilhar';

  @override
  String shareSong(String title, String artist) {
    return '$title, de $artist, ao vivo na SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: rádio K-pop grátis 24/7';
  }

  @override
  String get close => 'Fechar';

  @override
  String get startListeningToRate => 'Comece a ouvir para avaliar';

  @override
  String get like => 'Gostei';

  @override
  String get dislike => 'Não é pra mim';

  @override
  String get hot => 'Em alta';

  @override
  String get topTracks => 'Mais tocadas';

  @override
  String get albums => 'Álbuns';

  @override
  String get related => 'Você também pode gostar';

  @override
  String get settings => 'Configurações';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get sleepTimer => 'Timer para dormir';

  @override
  String get sleepOff => 'Desligado';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Para em $minutes min';
  }

  @override
  String get inTheCar => 'No carro';

  @override
  String get carBody =>
      'A SeoulFM funciona com Android Auto. Conecte o celular e escolha uma estação na tela do carro; os botões de avançar e voltar no volante trocam de estação.';

  @override
  String get about => 'Sobre a SeoulFM';

  @override
  String get aboutBody =>
      'A SeoulFM é uma rádio K-pop grátis 24/7 e uma plataforma de streaming de música coreana: doze estações ao vivo e uma biblioteca de músicas que cresce todo dia, todas com letra, que você pode buscar e pedir. Uma música pedida toca ao vivo para todo mundo. No ar desde 2009, sempre grátis.';

  @override
  String get website => 'Site';

  @override
  String get privacy => 'Privacidade';

  @override
  String get terms => 'Termos';

  @override
  String get contact => 'Contato';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get losslessTitle => 'FLAC sem perdas';

  @override
  String losslessUses(int mb) {
    return 'Cerca de $mb MB por hora';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Qualidade padrão: cerca de $mb MB por hora';
  }

  @override
  String get losslessFallbackNotice =>
      'O áudio sem perdas consome muito mais dados do que a transmissão padrão. Use Wi-Fi ou um plano de dados ilimitado.';

  @override
  String get losslessAccept => 'Ouvir sem perdas';

  @override
  String get losslessDecline => 'Usar qualidade padrão';

  @override
  String get losslessFailed =>
      'O modo sem perdas não está tocando, então ativamos a qualidade padrão.';

  @override
  String get retryFlac => 'Tentar FLAC de novo';

  @override
  String get marathonOnAir => 'No ar nesta hora';

  @override
  String get marathonQueue => 'A seguir';

  @override
  String get marathonNominations => 'Vote neles';

  @override
  String get marathonVote => 'Votar';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes de $required votos';
  }

  @override
  String get marathonNominate => 'Indique um artista';

  @override
  String get marathonNominateHint => 'Procure artistas';

  @override
  String get marathonVoted => 'Voto contado';

  @override
  String get marathonEmpty =>
      'Nenhuma indicação aberta. Indique um artista para a próxima hora livre.';

  @override
  String get marathonVotedIn => 'Votado';

  @override
  String get marathonIntro =>
      'Um grupo, uma hora inteira. Vote em um artista para a próxima hora livre.';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get justNow => 'agora mesmo';

  @override
  String minutesAgo(int n) {
    return 'há $n min';
  }

  @override
  String hoursAgo(int n) {
    return 'há $n h';
  }

  @override
  String inMinutes(int n) {
    return 'em $n min';
  }

  @override
  String get requestBadge => 'Pedido';

  @override
  String get artistPage => 'Página do artista';

  @override
  String get openSong => 'Página da música';

  @override
  String get nextStation => 'Próxima estação';

  @override
  String get previousStation => 'Estação anterior';

  @override
  String get quality => 'Qualidade';

  @override
  String get qualityAuto => 'Automática';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get captchaFailed => 'Não foi possível verificar. Tente de novo.';

  @override
  String get goodMorning => 'Bom dia';

  @override
  String get goodAfternoon => 'Boa tarde';

  @override
  String get goodEvening => 'Boa noite';

  @override
  String get featuredStations => 'Estações em destaque';

  @override
  String get genresAndEras => 'Gêneros e épocas';

  @override
  String get playingFrom => 'Tocando na';

  @override
  String get chooseStation => 'Escolha uma estação';

  @override
  String get listenNow => 'Ouvir agora';

  @override
  String get showLyrics => 'Ver letra';

  @override
  String get shareCardSong => 'Música';

  @override
  String get editLyrics => 'Escolher trechos';

  @override
  String get copyLink => 'Copiar link';

  @override
  String get linkCopied => 'Copiado';

  @override
  String get shareImage => 'Compartilhar imagem';

  @override
  String get done => 'Concluído';

  @override
  String pickLines(int count) {
    return 'Escolha até $count linhas';
  }

  @override
  String get goToSong => 'Ir para a música';

  @override
  String get goToArtist => 'Ir para o artista';

  @override
  String get swipeToRequest => 'Pedir';

  @override
  String get offlineTitle => 'Você está offline';

  @override
  String get serverErrorTitle => 'Algo deu errado';

  @override
  String get noResultsTitle => 'Nenhum resultado';

  @override
  String get noResultsBody =>
      'Tente outra grafia, o título em inglês ou coreano, ou o nome do artista.';

  @override
  String get wallEmptyTitle => 'Ainda não há dedicatórias';

  @override
  String get requestTrackerQueued => 'Seu pedido · na fila';

  @override
  String requestTrackerEta(int minutes) {
    return 'Seu pedido · toca em ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Seu pedido é o próximo';

  @override
  String get requestTrackerPlaying => 'Seu pedido está tocando agora!';

  @override
  String get welcomeTitle => 'Rádio K-pop, ao vivo e grátis';

  @override
  String get welcomeBody =>
      'Doze estações, 24/7, e uma biblioteca de músicas com letra que cresce todo dia. Peça uma música e ela toca ao vivo para todo mundo.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get pickStationsTitle => 'Escolha suas estações';

  @override
  String get pickStationsBody =>
      'Elas vão ficar sempre à mão. Mude quando quiser.';

  @override
  String get requestsTitle => 'Você escolhe o que toca depois';

  @override
  String get requestsBody =>
      'Encontre qualquer música e peça. Quando ela tocar, todo mundo que estiver ouvindo vai escutar — e ver a sua dedicatória.';

  @override
  String get startListening => 'Começar a ouvir';

  @override
  String get skip => 'Pular';

  @override
  String get yourStations => 'Suas estações';

  @override
  String get support => 'Apoiar';

  @override
  String get supportEyebrow => 'Mantida pelos ouvintes';

  @override
  String get supportH1 => 'Sem anúncios. Sem paywall.';

  @override
  String get supportH1Sub => 'Mantida no ar por quem ouve.';

  @override
  String get supportLead =>
      'A SeoulFM é grátis e vai continuar grátis. Não há nada para vender a você e ninguém para quem vender você. Se a rádio faz parte do seu dia, você pode ajudar a mantê-la funcionando.';

  @override
  String get supportWhereItGoes => 'Para onde vai o dinheiro';

  @override
  String get supportCostStreamTitle => 'A transmissão';

  @override
  String get supportCostStreamBody =>
      'Doze estações, no ar a toda hora, todos os dias, para o mundo inteiro. O áudio sem perdas da HIFI é o mais caro que transmitimos, e transmitimos de graça.';

  @override
  String get supportCostLibraryTitle => 'A biblioteca';

  @override
  String get supportCostLibraryBody =>
      'Dezenas de milhares de músicas armazenadas, catalogadas e organizadas, com capa, letra sincronizada e processamento com qualidade de broadcast em cada uma.';

  @override
  String get supportCostWorkTitle => 'O trabalho';

  @override
  String get supportCostWorkBody =>
      'O site, os apps, os pedidos, o mural e o chat, além do custo contínuo de licenciamento musical. Tudo criado e mantido por uma equipe bem pequena.';

  @override
  String get supportStaysTheSame => 'O que não muda';

  @override
  String get supportPromiseNoAds =>
      'Sem anúncios em áudio e sem banners. Nem agora, nem depois.';

  @override
  String get supportPromiseNothingLocked =>
      'Nada fica bloqueado. Todas as estações, pedidos e recursos continuam grátis para todo mundo.';

  @override
  String get supportPromiseOptional =>
      'Apoiar é opcional e não muda nada na forma como você ouve.';

  @override
  String get supportBecome => 'Torne-se apoiador';

  @override
  String get supportBecomeBody =>
      'Uma vez ou todo mês. Os pagamentos são feitos pela App Store ou pelo Google Play; nunca vemos os dados do seu cartão.';

  @override
  String get supportMonthly => 'Apoiador mensal';

  @override
  String get supportMonthlyBody =>
      'Mantenha uma estação no ar, todo mês. Cancele quando quiser.';

  @override
  String supportPerMonth(String price) {
    return '$price / mês';
  }

  @override
  String get supportOnce => 'Apoio único';

  @override
  String get supportTipSmall => 'Um café';

  @override
  String get supportTipMedium => 'Um almoço';

  @override
  String get supportTipLarge => 'Uma noite fora';

  @override
  String get supportRestore => 'Restaurar compras';

  @override
  String get supportUnavailable =>
      'O apoio pela loja não está disponível agora. Tente de novo mais tarde.';

  @override
  String get supportThanksTitle => 'Obrigado';

  @override
  String get supportThanksBody =>
      'Você está ajudando a manter a SeoulFM grátis para todo mundo.';

  @override
  String get supportYouAreSupporter => 'Você é apoiador. Obrigado.';

  @override
  String get supportFreeWays =>
      'Não dá para contribuir agora? Ouvir já conta. Assim como pedir uma música, deixar um recado no mural ou mostrar a rádio para um amigo que vai adorar.';

  @override
  String get supportCardTitle => 'Mantenha a SeoulFM grátis';

  @override
  String get supportCardBody =>
      'Sem anúncios, sem paywall — mantida no ar por ouvintes como você.';

  @override
  String get supportSubscriptionTerms =>
      'O apoio mensal é renovado automaticamente até ser cancelado nas configurações da sua conta na loja.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Usar o idioma do sistema';

  @override
  String get qualityAutoBody =>
      'A melhor que sua conexão aguenta. Diminui se ela oscilar.';

  @override
  String get qualityVeryHigh => 'Muito alta';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get qualityNormal => 'Normal';

  @override
  String get qualityDataSaver => 'Economia de dados';

  @override
  String get qualityFixedBody =>
      'Sempre nesta qualidade, mesmo com conexão fraca.';

  @override
  String get qualityLosslessNote =>
      'O HIFI toca FLAC sem perdas quando você aceita o aviso dele.';

  @override
  String get moreOptions => 'Mais opções';

  @override
  String get reportDedication => 'Denunciar';

  @override
  String hideDedicationsFrom(String name) {
    return 'Ocultar dedicatórias de $name';
  }

  @override
  String get reportThanks => 'Obrigado por nos avisar. Vamos dar uma olhada.';

  @override
  String get showHiddenDedications => 'Mostrar dedicatórias ocultas';

  @override
  String get verifyFailed =>
      'Não foi possível verificar. Verifique sua conexão e tente de novo.';

  @override
  String get restoreDone => 'Suas compras foram restauradas.';

  @override
  String get restoreNothing => 'Não há compras para restaurar.';

  @override
  String get playbackFailed =>
      'Não foi possível conectar à transmissão. Verifique sua conexão e tente de novo.';

  @override
  String get audioOutput => 'Saída de áudio';

  @override
  String get openPlayer => 'Abrir player';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count músicas',
      one: '1 música',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Estações';

  @override
  String get spatialAudioBody =>
      'O SeoulFM é mixado para fones de ouvido com crossfeed BS2B (Bauer stereophonic-to-binaural). Um pouco de cada canal chega também ao outro ouvido, como aconteceria com caixas de som numa sala, e o som fica mais amplo, mais natural e mais confortável para ouvir por horas.';

  @override
  String get requestNotificationChannel => 'Your requests';

  @override
  String get requestNotificationChannelDescription =>
      'Tells you when a song you requested is coming up and when it’s on air.';
}
