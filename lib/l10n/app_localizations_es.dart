// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabRequest => 'Pedir';

  @override
  String get tabCharts => 'Listas';

  @override
  String get tabWall => 'Dedicatorias';

  @override
  String get tabMore => 'Más';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Fuera del aire';

  @override
  String get stationBreak => 'Pausa breve. Volvemos en un momento.';

  @override
  String get nowPlaying => 'Sonando ahora';

  @override
  String get upNext => 'A continuación';

  @override
  String get stations => 'Estaciones';

  @override
  String get recentlyPlayed => 'Sonó hace poco';

  @override
  String get requestASong => 'Pide una canción';

  @override
  String get requestHint => 'Elige una canción y sonará en vivo para todos.';

  @override
  String get searchHint => 'Canciones, artistas, álbumes';

  @override
  String searchEmpty(String query) {
    return 'No hay resultados para “$query”';
  }

  @override
  String get searchIntro =>
      'Busca en la biblioteca, lee la letra y pide una canción para que suene en vivo.';

  @override
  String get newSongs => 'Nuevo en SeoulFM';

  @override
  String get songs => 'Canciones';

  @override
  String get artists => 'Artistas';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get request => 'Pedir';

  @override
  String get requestTitle => 'Pedir esta canción';

  @override
  String get yourName => 'Tu nombre (opcional)';

  @override
  String get dedication => 'Dedicatoria (opcional)';

  @override
  String get sendRequest => 'Enviar petición';

  @override
  String get verifying => 'Verificando que eres humano…';

  @override
  String get requestAccepted => '¡Petición enviada!';

  @override
  String etaMinutes(int minutes) {
    return 'Suena en unos $minutes min';
  }

  @override
  String get etaSoon => 'Suena pronto';

  @override
  String requestQueued(String title) {
    return '“$title” está en la fila';
  }

  @override
  String requestScheduled(String title) {
    return '“$title” suena a continuación';
  }

  @override
  String requestPlayed(String title) {
    return '“$title” está al aire ahora';
  }

  @override
  String requestExpired(String title) {
    return '“$title” no pudo sonar esta vez';
  }

  @override
  String get notRequestable => 'No se puede pedir ahora mismo';

  @override
  String get errorGeneric => 'Algo salió mal. Vuelve a intentarlo.';

  @override
  String get offline => 'No se puede conectar con SeoulFM. Revisa tu conexión.';

  @override
  String get retry => 'Reintentar';

  @override
  String get chartsWeekly => 'Esta semana';

  @override
  String get chartsHot => 'Lo más hot';

  @override
  String get chartsRequested => 'Más pedidas';

  @override
  String get chartsTrending => 'Tendencia';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reproducciones',
      one: '1 reproducción',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peticiones',
      one: '1 petición',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NUEVA';

  @override
  String get dedicationsEmpty =>
      'Todavía no hay dedicatorias. Pide una canción y agrega una.';

  @override
  String dedicatedBy(String name) {
    return 'Dedicada por $name';
  }

  @override
  String get lyrics => 'Letra';

  @override
  String get lyricsNone => 'Esta canción todavía no tiene letra.';

  @override
  String get share => 'Compartir';

  @override
  String shareSong(String title, String artist) {
    return '$title de $artist, en vivo en SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: radio K-pop gratis 24/7';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get startListeningToRate => 'Empieza a escuchar para calificar';

  @override
  String get like => 'Me gusta';

  @override
  String get dislike => 'No es para mí';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Canciones más escuchadas';

  @override
  String get albums => 'Álbumes';

  @override
  String get related => 'También te puede gustar';

  @override
  String get settings => 'Configuración';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get sleepTimer => 'Temporizador';

  @override
  String get sleepOff => 'Apagado';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Se detiene en $minutes min';
  }

  @override
  String get inTheCar => 'En el auto';

  @override
  String get carBody =>
      'SeoulFM funciona con Android Auto. Conecta tu celular y elige una estación en la pantalla del auto; los botones para saltar del volante cambian de estación.';

  @override
  String get about => 'Acerca de SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM es radio K-pop gratis 24/7 y una plataforma de streaming de música coreana: doce estaciones en vivo y una biblioteca de canciones que crece cada día, cada una con su letra, que puedes buscar y pedir. Una canción pedida suena en vivo para todos. Al aire desde 2009, siempre gratis.';

  @override
  String get website => 'Sitio web';

  @override
  String get privacy => 'Privacidad';

  @override
  String get terms => 'Términos';

  @override
  String get contact => 'Contacto';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get losslessTitle => 'FLAC sin pérdidas';

  @override
  String losslessUses(int mb) {
    return 'Unos $mb MB por hora';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Calidad estándar: unos $mb MB por hora';
  }

  @override
  String get losslessFallbackNotice =>
      'El audio sin pérdidas usa muchos más datos que el stream estándar. Usa Wi-Fi o un plan de datos ilimitado.';

  @override
  String get losslessAccept => 'Escuchar sin pérdidas';

  @override
  String get losslessDecline => 'Usar calidad estándar';

  @override
  String get losslessFailed =>
      'El audio sin pérdidas no está sonando, así que activamos la calidad estándar.';

  @override
  String get retryFlac => 'Reintentar FLAC';

  @override
  String get marathonOnAir => 'Al aire esta hora';

  @override
  String get marathonQueue => 'A continuación';

  @override
  String get marathonNominations => 'Vota por ellos';

  @override
  String get marathonVote => 'Votar';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes de $required votos';
  }

  @override
  String get marathonNominate => 'Nomina a un artista';

  @override
  String get marathonNominateHint => 'Busca artistas';

  @override
  String get marathonVoted => 'Voto contado';

  @override
  String get marathonEmpty =>
      'No hay nominaciones abiertas. Nomina a un artista para la próxima hora libre.';

  @override
  String get marathonVotedIn => 'Votado';

  @override
  String get marathonIntro =>
      'Un grupo, una hora entera. Vota por un artista para la próxima hora libre.';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get justNow => 'justo ahora';

  @override
  String minutesAgo(int n) {
    return 'hace $n min';
  }

  @override
  String hoursAgo(int n) {
    return 'hace $n h';
  }

  @override
  String inMinutes(int n) {
    return 'en $n min';
  }

  @override
  String get requestBadge => 'Petición';

  @override
  String get artistPage => 'Página del artista';

  @override
  String get openSong => 'Página de la canción';

  @override
  String get nextStation => 'Siguiente estación';

  @override
  String get previousStation => 'Estación anterior';

  @override
  String get quality => 'Calidad';

  @override
  String get qualityAuto => 'Auto';

  @override
  String get comingSoon => 'Muy pronto';

  @override
  String get captchaFailed => 'No se pudo verificar. Vuelve a intentarlo.';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get featuredStations => 'Estaciones destacadas';

  @override
  String get genresAndEras => 'Géneros y épocas';

  @override
  String get playingFrom => 'Sonando en';

  @override
  String get chooseStation => 'Elige una estación';

  @override
  String get listenNow => 'Escuchar ahora';

  @override
  String get showLyrics => 'Ver letra';

  @override
  String get shareCardSong => 'Canción';

  @override
  String get editLyrics => 'Elegir versos';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Copiado';

  @override
  String get shareImage => 'Compartir imagen';

  @override
  String get done => 'Listo';

  @override
  String pickLines(int count) {
    return 'Elige hasta $count líneas';
  }

  @override
  String get goToSong => 'Ir a la canción';

  @override
  String get goToArtist => 'Ir al artista';

  @override
  String get swipeToRequest => 'Pedir';

  @override
  String get offlineTitle => 'No tienes conexión';

  @override
  String get serverErrorTitle => 'Algo salió mal';

  @override
  String get noResultsTitle => 'Sin resultados';

  @override
  String get noResultsBody =>
      'Prueba con otra ortografía, el título en inglés o coreano, o el nombre del artista.';

  @override
  String get wallEmptyTitle => 'Todavía no hay dedicatorias';

  @override
  String get requestTrackerQueued => 'Tu petición · en la fila';

  @override
  String requestTrackerEta(int minutes) {
    return 'Tu petición · suena en ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Tu petición suena a continuación';

  @override
  String get requestTrackerPlaying => '¡Tu petición está sonando!';

  @override
  String get welcomeTitle => 'Radio K-pop, en vivo y gratis';

  @override
  String get welcomeBody =>
      'Doce estaciones, 24/7, y una biblioteca de canciones con letra que crece cada día. Pide una canción y sonará en vivo para todos.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get pickStationsTitle => 'Elige tus estaciones';

  @override
  String get pickStationsBody =>
      'Las tendremos siempre a la mano. Puedes cambiarlas cuando quieras.';

  @override
  String get requestsTitle => 'Tú eliges lo que suena después';

  @override
  String get requestsBody =>
      'Busca cualquier canción y pídela. Cuando suene, todos los que están escuchando la oirán, y verán tu dedicatoria.';

  @override
  String get startListening => 'Empezar a escuchar';

  @override
  String get skip => 'Omitir';

  @override
  String get yourStations => 'Tus estaciones';

  @override
  String get support => 'Apoyar';

  @override
  String get supportEyebrow => 'Sostenida por sus oyentes';

  @override
  String get supportH1 => 'Sin anuncios. Sin muro de pago.';

  @override
  String get supportH1Sub => 'Al aire gracias a quienes la escuchan.';

  @override
  String get supportLead =>
      'SeoulFM es gratis y va a seguir siendo gratis. No hay nada que venderte ni nadie a quien venderte. Si la estación es parte de tu día, puedes ayudar a que siga funcionando.';

  @override
  String get supportWhereItGoes => 'A dónde va el dinero';

  @override
  String get supportCostStreamTitle => 'El stream';

  @override
  String get supportCostStreamBody =>
      'Doce estaciones, al aire a toda hora, todos los días, en todo el mundo. El audio sin pérdidas de HIFI es lo más caro que enviamos, y lo enviamos gratis.';

  @override
  String get supportCostLibraryTitle => 'La biblioteca';

  @override
  String get supportCostLibraryBody =>
      'Decenas de miles de canciones, almacenadas, etiquetadas y ordenadas, cada una con su portada, letra sincronizada y procesamiento de calidad radial.';

  @override
  String get supportCostWorkTitle => 'El trabajo';

  @override
  String get supportCostWorkBody =>
      'El sitio, las apps, las peticiones, el muro y el chat, más el costo continuo de las licencias musicales. Todo lo hace y lo mantiene un equipo muy pequeño.';

  @override
  String get supportStaysTheSame => 'Lo que no cambia';

  @override
  String get supportPromiseNoAds =>
      'Sin anuncios de audio ni banners. Ni ahora ni después.';

  @override
  String get supportPromiseNothingLocked =>
      'Nada está bloqueado. Todas las estaciones, peticiones y funciones siguen gratis para todos.';

  @override
  String get supportPromiseOptional =>
      'Apoyar es opcional y no cambia en nada cómo escuchas.';

  @override
  String get supportBecome => 'Hazte supporter';

  @override
  String get supportBecomeBody =>
      'Una vez o cada mes. Los pagos se hacen a través del App Store o Google Play; nunca vemos los datos de tu tarjeta.';

  @override
  String get supportMonthly => 'Supporter mensual';

  @override
  String get supportMonthlyBody =>
      'Mantén una estación al aire, cada mes. Cancela cuando quieras.';

  @override
  String supportPerMonth(String price) {
    return '$price / mes';
  }

  @override
  String get supportOnce => 'Aporte único';

  @override
  String get supportTipSmall => 'Un café';

  @override
  String get supportTipMedium => 'Una comida';

  @override
  String get supportTipLarge => 'Una salida de noche';

  @override
  String get supportRestore => 'Restaurar compras';

  @override
  String get supportUnavailable =>
      'El apoyo a través de la tienda no está disponible ahora. Inténtalo más tarde.';

  @override
  String get supportThanksTitle => 'Gracias';

  @override
  String get supportThanksBody =>
      'Nos ayudas a que SeoulFM siga siendo gratis para todos.';

  @override
  String get supportYouAreSupporter => 'Eres supporter. Gracias.';

  @override
  String get supportFreeWays =>
      '¿No puedes aportar dinero? Escuchar cuenta. También cuenta pedir una canción, dejar una nota en el muro o compartir la estación con un amigo al que le encantaría.';

  @override
  String get supportCardTitle => 'Mantén SeoulFM gratis';

  @override
  String get supportCardBody =>
      'Sin anuncios, sin muro de pago: al aire gracias a oyentes como tú.';

  @override
  String get supportSubscriptionTerms =>
      'El apoyo mensual se renueva automáticamente hasta que lo canceles en la configuración de tu cuenta de la tienda.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Usar el idioma del sistema';

  @override
  String get qualityAutoBody =>
      'La mejor calidad que aguante tu conexión. Baja si falla.';

  @override
  String get qualityVeryHigh => 'Muy alta';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get qualityNormal => 'Normal';

  @override
  String get qualityDataSaver => 'Ahorro de datos';

  @override
  String get qualityFixedBody =>
      'Siempre esta calidad, aunque la conexión sea débil.';

  @override
  String get qualityLosslessNote =>
      'HIFI reproduce FLAC sin pérdida cuando aceptas su aviso.';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get reportDedication => 'Denunciar';

  @override
  String hideDedicationsFrom(String name) {
    return 'Ocultar dedicatorias de $name';
  }

  @override
  String get reportThanks => 'Gracias por avisarnos. Lo revisaremos.';

  @override
  String get showHiddenDedications => 'Mostrar dedicatorias ocultas';

  @override
  String get verifyFailed =>
      'No se pudo verificar. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get restoreDone => 'Tus compras se restauraron.';

  @override
  String get restoreNothing => 'No hay compras para restaurar.';

  @override
  String get playbackFailed =>
      'No se puede conectar con el stream. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get audioOutput => 'Salida de audio';

  @override
  String get openPlayer => 'Abrir reproductor';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Estaciones';

  @override
  String get spatialAudioBody =>
      'SeoulFM está mezclado para auriculares con crossfeed BS2B (Bauer stereophonic-to-binaural). Un poco de cada canal llega también al otro oído, como ocurriría con altavoces en una habitación, así que el sonido resulta más amplio, más natural y más descansado para el oído durante horas.';

  @override
  String get requestNotificationChannel => 'Tus peticiones';

  @override
  String get requestNotificationChannelDescription =>
      'Te avisa cuando una canción que pediste está por sonar y cuando está al aire.';

  @override
  String get yourSongs => 'Tus canciones';

  @override
  String get favourite => 'Favorito';

  @override
  String get saveToYourSongs => 'Guardar en Tus canciones';

  @override
  String get removeFromYourSongs => 'Quitar de Tus canciones';

  @override
  String get savedToYourSongs => 'Se guardó en Tus canciones';

  @override
  String get removedFromYourSongs => 'Se quitó de Tus canciones';

  @override
  String get view => 'Ver';

  @override
  String get undo => 'Deshacer';

  @override
  String get yourSongsEmptyTitle => 'Guarda las canciones que te encantan';

  @override
  String get yourSongsEmptyBody =>
      'Toca el corazón en el reproductor o en la página de una canción, o elige Guardar en Tus canciones en el menú de una canción. Se quedan en este teléfono, sin necesidad de cuenta.';

  @override
  String get requestFromYourSongs => 'Pide una de ellas';

  @override
  String get quickSettingsAdd => 'Agregar a Configuración rápida';

  @override
  String get quickSettingsAdded =>
      'SeoulFM está en tu Configuración rápida: desliza hacia abajo para reproducir o pausar.';

  @override
  String get edit => 'Editar';

  @override
  String get moreStations => 'Más estaciones';

  @override
  String get addToYourStations => 'Añadir a tus estaciones';

  @override
  String get removeFromYourStations => 'Quitar de tus estaciones';

  @override
  String get addStations => 'Añadir';
}

/// The translations for Spanish Castilian, as used in Spain (`es_ES`).
class AppLocalizationsEsEs extends AppLocalizationsEs {
  AppLocalizationsEsEs() : super('es_ES');

  @override
  String get appTitle => 'SeoulFM';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabRequest => 'Pedir';

  @override
  String get tabCharts => 'Listas';

  @override
  String get tabWall => 'Dedicatorias';

  @override
  String get tabMore => 'Más';

  @override
  String get live => 'LIVE';

  @override
  String get offAir => 'Fuera de antena';

  @override
  String get stationBreak => 'Pequeña pausa. Volvemos enseguida.';

  @override
  String get nowPlaying => 'Sonando ahora';

  @override
  String get upNext => 'A continuación';

  @override
  String get stations => 'Emisoras';

  @override
  String get recentlyPlayed => 'Ha sonado hace poco';

  @override
  String get requestASong => 'Pide una canción';

  @override
  String get requestHint => 'Elige una canción y sonará en directo para todos.';

  @override
  String get searchHint => 'Canciones, artistas, álbumes';

  @override
  String searchEmpty(String query) {
    return 'No hay resultados para «$query»';
  }

  @override
  String get searchIntro =>
      'Busca en la biblioteca, lee la letra y pide una canción para que suene en directo.';

  @override
  String get newSongs => 'Novedades en SeoulFM';

  @override
  String get songs => 'Canciones';

  @override
  String get artists => 'Artistas';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausa';

  @override
  String get request => 'Pedir';

  @override
  String get requestTitle => 'Pedir esta canción';

  @override
  String get yourName => 'Tu nombre (opcional)';

  @override
  String get dedication => 'Mensaje de dedicatoria (opcional)';

  @override
  String get sendRequest => 'Enviar petición';

  @override
  String get verifying => 'Comprobando que eres humano…';

  @override
  String get requestAccepted => '¡Petición enviada!';

  @override
  String etaMinutes(int minutes) {
    return 'Suena en unos $minutes min';
  }

  @override
  String get etaSoon => 'Suena en breve';

  @override
  String requestQueued(String title) {
    return '«$title» está en la cola';
  }

  @override
  String requestScheduled(String title) {
    return '«$title» es la siguiente';
  }

  @override
  String requestPlayed(String title) {
    return '«$title» está sonando ahora';
  }

  @override
  String requestExpired(String title) {
    return '«$title» no ha podido sonar esta vez';
  }

  @override
  String get notRequestable => 'No se puede pedir ahora mismo';

  @override
  String get errorGeneric => 'Algo ha fallado. Inténtalo de nuevo.';

  @override
  String get offline =>
      'No se puede conectar con SeoulFM. Comprueba tu conexión.';

  @override
  String get retry => 'Reintentar';

  @override
  String get chartsWeekly => 'Esta semana';

  @override
  String get chartsHot => 'Lo más hot';

  @override
  String get chartsRequested => 'Más pedidas';

  @override
  String get chartsTrending => 'Tendencia';

  @override
  String plays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reproducciones',
      one: '1 reproducción',
    );
    return '$_temp0';
  }

  @override
  String requestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peticiones',
      one: '1 petición',
    );
    return '$_temp0';
  }

  @override
  String get newEntry => 'NUEVA';

  @override
  String get dedicationsEmpty =>
      'Todavía no hay dedicatorias. Pide una canción y añade una.';

  @override
  String dedicatedBy(String name) {
    return 'Dedicada por $name';
  }

  @override
  String get lyrics => 'Letra';

  @override
  String get lyricsNone => 'Esta canción aún no tiene letra.';

  @override
  String get share => 'Compartir';

  @override
  String shareSong(String title, String artist) {
    return '$title de $artist, en directo en SeoulFM';
  }

  @override
  String shareStation(String name) {
    return 'SeoulFM $name: radio K-pop gratis 24/7';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get startListeningToRate => 'Empieza a escuchar para valorar';

  @override
  String get like => 'Me gusta';

  @override
  String get dislike => 'No es para mí';

  @override
  String get hot => 'Hot';

  @override
  String get topTracks => 'Canciones más escuchadas';

  @override
  String get albums => 'Álbumes';

  @override
  String get related => 'También te puede gustar';

  @override
  String get settings => 'Ajustes';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get sleepTimer => 'Temporizador';

  @override
  String get sleepOff => 'Desactivado';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String sleepStopsIn(int minutes) {
    return 'Se detiene en $minutes min';
  }

  @override
  String get inTheCar => 'En el coche';

  @override
  String get carBody =>
      'SeoulFM funciona con Android Auto. Conecta tu móvil y elige una emisora en la pantalla del coche; los botones de salto del volante cambian de emisora.';

  @override
  String get about => 'Acerca de SeoulFM';

  @override
  String get aboutBody =>
      'SeoulFM es radio K-pop gratis 24/7 y una plataforma de streaming de música coreana: doce emisoras en directo y una biblioteca de canciones que crece cada día, todas con letra, que puedes buscar y pedir. Una canción pedida suena en directo para todos. En antena desde 2009, siempre gratis.';

  @override
  String get website => 'Web';

  @override
  String get privacy => 'Privacidad';

  @override
  String get terms => 'Términos';

  @override
  String get contact => 'Contacto';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get losslessTitle => 'FLAC sin pérdidas';

  @override
  String losslessUses(int mb) {
    return 'Unos $mb MB por hora';
  }

  @override
  String losslessUsesAac(int mb) {
    return 'Calidad estándar: unos $mb MB por hora';
  }

  @override
  String get losslessFallbackNotice =>
      'El audio sin pérdidas consume muchos más datos que la emisión estándar. Usa wifi o una tarifa de datos ilimitada.';

  @override
  String get losslessAccept => 'Escuchar sin pérdidas';

  @override
  String get losslessDecline => 'Usar calidad estándar';

  @override
  String get losslessFailed =>
      'El audio sin pérdidas no se está reproduciendo, así que hemos activado la calidad estándar.';

  @override
  String get retryFlac => 'Reintentar FLAC';

  @override
  String get marathonOnAir => 'En antena esta hora';

  @override
  String get marathonQueue => 'A continuación';

  @override
  String get marathonNominations => 'Vótalos';

  @override
  String get marathonVote => 'Votar';

  @override
  String marathonVotes(int votes, int required) {
    return '$votes de $required votos';
  }

  @override
  String get marathonNominate => 'Nomina a un artista';

  @override
  String get marathonNominateHint => 'Busca artistas';

  @override
  String get marathonVoted => 'Voto contado';

  @override
  String get marathonEmpty =>
      'No hay nominaciones abiertas. Nomina a un artista para la próxima hora libre.';

  @override
  String get marathonVotedIn => 'Votado';

  @override
  String get marathonIntro =>
      'Un grupo, una hora entera. Vota a un artista para la próxima hora libre.';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get justNow => 'ahora mismo';

  @override
  String minutesAgo(int n) {
    return 'hace $n min';
  }

  @override
  String hoursAgo(int n) {
    return 'hace $n h';
  }

  @override
  String inMinutes(int n) {
    return 'en $n min';
  }

  @override
  String get requestBadge => 'Petición';

  @override
  String get artistPage => 'Página del artista';

  @override
  String get openSong => 'Página de la canción';

  @override
  String get nextStation => 'Emisora siguiente';

  @override
  String get previousStation => 'Emisora anterior';

  @override
  String get quality => 'Calidad';

  @override
  String get qualityAuto => 'Automática';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get captchaFailed => 'No se ha podido verificar. Inténtalo de nuevo.';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get featuredStations => 'Emisoras destacadas';

  @override
  String get genresAndEras => 'Géneros y épocas';

  @override
  String get playingFrom => 'Sonando en';

  @override
  String get chooseStation => 'Elige una emisora';

  @override
  String get listenNow => 'Escuchar ahora';

  @override
  String get showLyrics => 'Ver letra';

  @override
  String get shareCardSong => 'Canción';

  @override
  String get editLyrics => 'Elegir versos';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Copiado';

  @override
  String get shareImage => 'Compartir imagen';

  @override
  String get done => 'Hecho';

  @override
  String pickLines(int count) {
    return 'Elige hasta $count líneas';
  }

  @override
  String get goToSong => 'Ir a la canción';

  @override
  String get goToArtist => 'Ir al artista';

  @override
  String get swipeToRequest => 'Pedir';

  @override
  String get offlineTitle => 'No tienes conexión';

  @override
  String get serverErrorTitle => 'Algo ha fallado';

  @override
  String get noResultsTitle => 'Sin resultados';

  @override
  String get noResultsBody =>
      'Prueba con otra forma de escribirlo, el título en inglés o coreano, o el nombre del artista.';

  @override
  String get wallEmptyTitle => 'Todavía no hay dedicatorias';

  @override
  String get requestTrackerQueued => 'Tu petición · en la cola';

  @override
  String requestTrackerEta(int minutes) {
    return 'Tu petición · suena en ~$minutes min';
  }

  @override
  String get requestTrackerNext => 'Tu petición es la siguiente';

  @override
  String get requestTrackerPlaying => '¡Tu petición está sonando!';

  @override
  String get welcomeTitle => 'Radio K-pop, en directo y gratis';

  @override
  String get welcomeBody =>
      'Doce emisoras, 24/7, y una biblioteca de canciones con letra que crece cada día. Pide una canción y sonará en directo para todos.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get pickStationsTitle => 'Elige tus emisoras';

  @override
  String get pickStationsBody =>
      'Las tendrás siempre a mano. Puedes cambiarlas cuando quieras.';

  @override
  String get requestsTitle => 'Tú eliges lo que suena después';

  @override
  String get requestsBody =>
      'Busca cualquier canción y pídela. Cuando suene, todos los que estén escuchando la oirán, y verán tu dedicatoria.';

  @override
  String get startListening => 'Empezar a escuchar';

  @override
  String get skip => 'Omitir';

  @override
  String get yourStations => 'Tus emisoras';

  @override
  String get support => 'Apoyar';

  @override
  String get supportEyebrow => 'Financiada por sus oyentes';

  @override
  String get supportH1 => 'Sin anuncios. Sin muro de pago.';

  @override
  String get supportH1Sub => 'En antena gracias a quienes la escuchan.';

  @override
  String get supportLead =>
      'SeoulFM es gratis y va a seguir siéndolo. No hay nada que venderte ni nadie a quien venderte. Si la emisora forma parte de tu día, puedes ayudar a que siga funcionando.';

  @override
  String get supportWhereItGoes => 'A qué se destina';

  @override
  String get supportCostStreamTitle => 'La emisión';

  @override
  String get supportCostStreamBody =>
      'Doce emisoras, en antena todas las horas de todos los días, para todo el mundo. El audio sin pérdidas de HIFI es lo más caro que enviamos, y lo enviamos gratis.';

  @override
  String get supportCostLibraryTitle => 'La biblioteca';

  @override
  String get supportCostLibraryBody =>
      'Decenas de miles de temas almacenados, etiquetados y ordenados, con portada, letra sincronizada y procesamiento de nivel profesional en cada uno.';

  @override
  String get supportCostWorkTitle => 'El trabajo';

  @override
  String get supportCostWorkBody =>
      'La web, las apps, las peticiones, el muro y el chat, además del coste continuo de las licencias musicales. Todo lo crea y lo gestiona un equipo muy pequeño.';

  @override
  String get supportStaysTheSame => 'Lo que no cambia';

  @override
  String get supportPromiseNoAds =>
      'Ni anuncios de audio ni banners. Ni ahora ni más adelante.';

  @override
  String get supportPromiseNothingLocked =>
      'No hay nada bloqueado. Todas las emisoras, peticiones y funciones siguen siendo gratis para todos.';

  @override
  String get supportPromiseOptional =>
      'Apoyar es opcional y no cambia nada en tu forma de escuchar.';

  @override
  String get supportBecome => 'Hazte mecenas';

  @override
  String get supportBecomeBody =>
      'Una vez o cada mes. Los pagos se gestionan a través del App Store o Google Play; nunca vemos los datos de tu tarjeta.';

  @override
  String get supportMonthly => 'Mecenas mensual';

  @override
  String get supportMonthlyBody =>
      'Mantén una emisora en antena, cada mes. Cancela cuando quieras.';

  @override
  String supportPerMonth(String price) {
    return '$price / mes';
  }

  @override
  String get supportOnce => 'Aportación única';

  @override
  String get supportTipSmall => 'Un café';

  @override
  String get supportTipMedium => 'Una comida';

  @override
  String get supportTipLarge => 'Una noche de fiesta';

  @override
  String get supportRestore => 'Restaurar compras';

  @override
  String get supportUnavailable =>
      'El apoyo a través de la tienda no está disponible ahora mismo. Inténtalo más tarde.';

  @override
  String get supportThanksTitle => 'Gracias';

  @override
  String get supportThanksBody =>
      'Nos ayudas a que SeoulFM siga siendo gratis para todos.';

  @override
  String get supportYouAreSupporter => 'Eres mecenas. Gracias.';

  @override
  String get supportFreeWays =>
      '¿No puedes aportar dinero? Escuchar ya cuenta. También pedir una canción, dejar una nota en el muro o recomendar la emisora a un amigo al que le vaya a encantar.';

  @override
  String get supportCardTitle => 'Mantén SeoulFM gratis';

  @override
  String get supportCardBody =>
      'Sin anuncios ni muro de pago: en antena gracias a oyentes como tú.';

  @override
  String get supportSubscriptionTerms =>
      'El apoyo mensual se renueva automáticamente hasta que lo canceles en los ajustes de tu cuenta de la tienda.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Usar el idioma del sistema';

  @override
  String get qualityAutoBody =>
      'La mejor calidad que aguante tu conexión. Baja si falla.';

  @override
  String get qualityVeryHigh => 'Muy alta';

  @override
  String get qualityHigh => 'Alta';

  @override
  String get qualityNormal => 'Normal';

  @override
  String get qualityDataSaver => 'Ahorro de datos';

  @override
  String get qualityFixedBody =>
      'Siempre esta calidad, aunque la conexión sea débil.';

  @override
  String get qualityLosslessNote =>
      'HIFI reproduce FLAC sin pérdidas cuando aceptas su aviso.';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get reportDedication => 'Denunciar';

  @override
  String hideDedicationsFrom(String name) {
    return 'Ocultar dedicatorias de $name';
  }

  @override
  String get reportThanks => 'Gracias por avisarnos. Lo revisaremos.';

  @override
  String get showHiddenDedications => 'Mostrar dedicatorias ocultas';

  @override
  String get verifyFailed =>
      'No se ha podido verificar. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get restoreDone => 'Se han restaurado tus compras.';

  @override
  String get restoreNothing => 'No hay compras que restaurar.';

  @override
  String get playbackFailed =>
      'No se puede conectar con la emisión. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get audioOutput => 'Salida de audio';

  @override
  String get openPlayer => 'Abrir reproductor';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String get stationsFolder => 'Emisoras';

  @override
  String get spatialAudioBody =>
      'SeoulFM está mezclado para auriculares con crossfeed BS2B (Bauer stereophonic-to-binaural). Un poco de cada canal llega también al otro oído, como ocurriría con altavoces en una habitación, así que el sonido resulta más amplio, más natural y más descansado para el oído durante horas.';

  @override
  String get requestNotificationChannel => 'Tus peticiones';

  @override
  String get requestNotificationChannelDescription =>
      'Te avisa cuando una canción que has pedido está a punto de sonar y cuando está en antena.';

  @override
  String get yourSongs => 'Tus canciones';

  @override
  String get favourite => 'Favorito';

  @override
  String get saveToYourSongs => 'Guardar en Tus canciones';

  @override
  String get removeFromYourSongs => 'Quitar de Tus canciones';

  @override
  String get savedToYourSongs => 'Guardada en Tus canciones';

  @override
  String get removedFromYourSongs => 'Quitada de Tus canciones';

  @override
  String get view => 'Ver';

  @override
  String get undo => 'Deshacer';

  @override
  String get yourSongsEmptyTitle => 'Guarda las canciones que te encantan';

  @override
  String get yourSongsEmptyBody =>
      'Toca el corazón en el reproductor o en la página de una canción, o elige Guardar en Tus canciones en el menú de una canción. Se quedan en este móvil, sin necesidad de cuenta.';

  @override
  String get requestFromYourSongs => 'Pide una de ellas';

  @override
  String get quickSettingsAdd => 'Añadir a Ajustes rápidos';

  @override
  String get quickSettingsAdded =>
      'SeoulFM está en tus Ajustes rápidos: desliza hacia abajo para reproducir o pausar.';

  @override
  String get edit => 'Editar';

  @override
  String get moreStations => 'Más emisoras';

  @override
  String get addToYourStations => 'Añadir a tus emisoras';

  @override
  String get removeFromYourStations => 'Quitar de tus emisoras';

  @override
  String get addStations => 'Añadir';
}
