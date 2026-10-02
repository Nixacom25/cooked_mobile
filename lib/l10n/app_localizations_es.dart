// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Cooked';

  @override
  String get groceryInlineAddHint => 'p. ej. Ajo - 2, 2 Ajo o Ajo 2';

  @override
  String get groceryAddIngredientPlaceholder => 'Añadir un ingrediente...';

  @override
  String get groceryQuantityFormatError =>
      'Añade la cantidad con este formato, p. ej.: ajo - 2, 2 ajo o ajo 2.';

  @override
  String get commonSave => 'Guardar';

  @override
  String get groceryAddItemOrRecipe => 'Añade un artículo o elige una receta';

  @override
  String get groceryIngredientHint => 'Queso';

  @override
  String get commonIngredient => 'Ingrediente';

  @override
  String get groceryChooseRecipe => 'Elegir una receta';

  @override
  String get commonNoRecipesFound => 'No se encontraron recetas';

  @override
  String get commonRecipe => 'Receta';

  @override
  String get groceryAddSheetTitle => 'Añadir a la compra';

  @override
  String get groceryItemsSaved => 'Artículos guardados en la lista de compras';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String groceryDeleteItemMessage(String name) {
    return '¿Seguro que quieres eliminar \"$name\" de tu lista de compras?';
  }

  @override
  String get groceryDeleteItemTitle => 'Eliminar artículo';

  @override
  String get commonDismiss => 'Cerrar';

  @override
  String get groceryAddIngredients => 'Añadir ingredientes';

  @override
  String get groceryEmptySubtitle =>
      'Añade ingredientes desde una receta o una importación para empezar.';

  @override
  String get groceryEmptyTitle => 'Tu lista de compras está vacía';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get groceryListTitle => 'Lista de compras';

  @override
  String get commonTryAgain => 'Reintentar';

  @override
  String get commonCheckConnection =>
      'Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get groceryLoadErrorTitle => 'No se pudo cargar tu lista de compras';

  @override
  String get authMissingIdentifier =>
      'Faltan datos de identificación. Inténtalo de nuevo.';

  @override
  String get authVerifying => 'Verificando';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get authResendCode => 'Reenviar código';

  @override
  String get authResending => 'Reenviando';

  @override
  String get authDidntReceiveCode => '¿No recibiste el código? ';

  @override
  String authCodeSentTo(String target) {
    return 'Introduce el código que acabamos de enviar a\n$target';
  }

  @override
  String get authForgotPasswordTitle => 'Contraseña olvidada';

  @override
  String get authCodeResent => 'Código de verificación reenviado.';

  @override
  String get authEnterFullCode => 'Introduce el código completo de 6 dígitos.';

  @override
  String get commonEmail => 'Correo electrónico';

  @override
  String get commonSending => 'Enviando';

  @override
  String get commonSend => 'Enviar';

  @override
  String get commonPhoneNumber => 'Número de teléfono';

  @override
  String get authEnterPhoneForCode =>
      'Introduce tu número de teléfono\ny te enviaremos un código\nde verificación';

  @override
  String get authEnterEmailForCode =>
      'Introduce tu correo y te enviaremos\nun código de verificación';

  @override
  String get authSendToPhone => 'Enviar a tu teléfono';

  @override
  String get authSendToEmail => 'Enviar a tu correo';

  @override
  String get authSelectContactMethod =>
      'Elige qué datos de contacto usar\npara restablecer tu contraseña';

  @override
  String get authCodeSent => '¡Código enviado!';

  @override
  String get commonFieldRequired => 'Este campo es obligatorio';

  @override
  String get commonGetStarted => 'Empezar';

  @override
  String get authPasswordChangedMessage =>
      'Tu contraseña se cambió correctamente,\nya puedes volver a iniciar sesión.';

  @override
  String get authPasswordChanged => '¡Contraseña cambiada!';

  @override
  String get commonCongratulations => '¡Felicidades!';

  @override
  String get commonTermsOfUse => 'Términos de uso';

  @override
  String get commonPrivacyPolicy => 'Política de privacidad';

  @override
  String get authSignInWithApple => 'Iniciar sesión con Apple';

  @override
  String get authSignInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get commonSignUp => 'Registrarse';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authLoggingIn => 'Iniciando sesión';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authForgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get commonPassword => 'Contraseña';

  @override
  String get authSignInSubtitle => 'Inicia sesión en tu cuenta';

  @override
  String get commonSignIn => 'Iniciar sesión';

  @override
  String get authSocialLoginSuccess => '¡Inicio de sesión correcto!';

  @override
  String get authLoginSuccess => '¡Inicio de sesión correcto!';

  @override
  String get authVerificationCodeLabel => 'CÓDIGO DE VERIFICACIÓN';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonUpdating => 'Actualizando';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authNewPassword => 'Nueva contraseña';

  @override
  String get authCreateNewPassword => 'Crear nueva contraseña';

  @override
  String get authResetSuccess => '¡Restablecimiento correcto!';

  @override
  String get authPasswordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get authPasswordMinLength => 'Mínimo 6 caracteres';

  @override
  String get authAccountCreatedMessage =>
      'Tu cuenta está lista, disfruta\nde nuestras mejores recetas.';

  @override
  String get authAccountCreated => '¡Cuenta creada!';

  @override
  String get welcomeHaveAccount => '¿Ya tienes una cuenta? ';

  @override
  String get welcomeSubtitle =>
      'Escanea ingredientes. Guarda recetas.\nPlanifica sin esfuerzo.';

  @override
  String get welcomeTitle => 'Bienvenido a Cooked';

  @override
  String get authEmailOrPhoneFallback => 'correo/número de teléfono';

  @override
  String get authYourEmailFallback => 'tu correo';

  @override
  String get themeDarkOn => 'Activado';

  @override
  String get themeDarkOff => 'Desactivado';

  @override
  String get themeSystemSettings => 'Ajustes del sistema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeMatchPhone => 'Igual que el teléfono';

  @override
  String get themeAlwaysDark => 'Usar siempre el tema oscuro';

  @override
  String get themeAlwaysLight => 'Usar siempre el tema claro';

  @override
  String get themeSystemHint =>
      'Con «Ajustes del sistema», la apariencia de la app cambia automáticamente según tu dispositivo.';

  @override
  String get notifSecurityNote =>
      'Las alertas de cuenta y seguridad (nuevos inicios de sesión o problemas de pago) se envían siempre mientras las notificaciones push estén activadas.';

  @override
  String profileInviteMessage(String link) {
    return '¡Prueba Cooked! Convierte lo que tienes en la nevera en recetas en segundos y te ahorra dinero en comida para llevar. Únete aquí: $link';
  }

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get langSuggestRow => 'Sugerir un idioma…';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get langUpdateFailed => 'No se pudo cambiar el idioma';

  @override
  String get langSuggestionFailed =>
      'No se pudo enviar tu sugerencia. Inténtalo de nuevo.';

  @override
  String get langSuggestionThanks => '¡Gracias! Hemos recibido tu sugerencia.';

  @override
  String get langSendSuggestion => 'Enviar sugerencia';

  @override
  String get langSuggestHint => 'p. ej. italiano, wolof, portugués…';

  @override
  String get langSuggestMessage =>
      '¿En qué idioma te gustaría usar Cooked? Tus sugerencias nos ayudan a decidir los próximos.';

  @override
  String get langSuggestTitle => 'Sugerir un idioma';

  @override
  String get commonSaveChanges => 'Guardar cambios';

  @override
  String get commonName => 'Nombre';

  @override
  String get accountChangePicture => 'Cambiar foto';

  @override
  String get accountDefaultName => 'Chef';

  @override
  String get settingsMyAccount => 'Mi cuenta';

  @override
  String get accountProfileUpdated => '¡Perfil actualizado!';

  @override
  String get notifNewsSubtitle =>
      'Nuevas funciones, recetas y ofertas especiales';

  @override
  String get notifNews => 'Novedades, consejos y ofertas';

  @override
  String get notifRemindersSubtitle =>
      'Fin de la prueba y recordatorios de suscripción';

  @override
  String get notifReminders => 'Recordatorios';

  @override
  String get notifPushSubtitle => 'Recibir notificaciones en este dispositivo';

  @override
  String get notifPush => 'Notificaciones push';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsDeletePermanently => 'Eliminar definitivamente';

  @override
  String get settingsDeleteAccountConfirm =>
      '¿Seguro que quieres eliminar tu cuenta de forma permanente? Esta acción no se puede deshacer y perderás todos tus datos (recetarios, lista de la compra, etc.).';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirm =>
      '¿Seguro que quieres cerrar sesión? Tendrás que introducir tus credenciales para volver a entrar.';

  @override
  String get settingsContactSupport => 'Contactar con soporte';

  @override
  String get settingsGiftCooked => 'Regalar Cooked a un amigo';

  @override
  String get settingsInviteFriends => 'Invitar amigos';

  @override
  String get settingsManageSubscription =>
      'Gestionar suscripción y restaurar compras';

  @override
  String get settingsKitchenEquipment => 'Equipamiento de cocina';

  @override
  String get settingsCuisineFlavor => 'Cocinas y sabores';

  @override
  String get settingsAllergies => 'Alergias';

  @override
  String get settingsDietaryPreferences => 'Preferencias alimentarias';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get pwdCurrentPassword => 'Contraseña actual';

  @override
  String get pwdUpdated => 'Contraseña actualizada.';

  @override
  String get pwdNoMatch => 'Las nuevas contraseñas no coinciden.';

  @override
  String get pwdFillAllFields => 'Rellena todos los campos.';

  @override
  String get optTotalBeginner => 'Principiante total';

  @override
  String get optICanBarelyBoilWater => 'Apenas sé hervir agua';

  @override
  String get optHomeCook => 'Cocinero casero';

  @override
  String get optIFollowRecipesStepByStep => 'Sigo las recetas paso a paso';

  @override
  String get optConfidentCook => 'Cocinero seguro';

  @override
  String get optIImproviseAndExperiment => 'Improviso y experimento';

  @override
  String get optAdvancedSemiPro => 'Avanzado / Semiprofesional';

  @override
  String get optIWantChallengingRecipes => 'Quiero recetas desafiantes.';

  @override
  String get optUnder15Minutes => 'Menos de 15 minutos';

  @override
  String get optUltraFastMeals => 'Comidas ultrarrápidas';

  @override
  String get optForWhenYouNeedFoodInstantly =>
      'Para cuando necesitas comer ya.';

  @override
  String get opt_1530Minutes => '15–30 minutos';

  @override
  String get optQuickButNotRushed => 'Rápido pero sin prisas';

  @override
  String get optPerfectForQuickWeekdayMeals =>
      'Perfecto para comidas rápidas entre semana.';

  @override
  String get opt_3060Minutes => '30–60 minutos';

  @override
  String get optANormalCookingWindow => 'Un tiempo de cocina normal';

  @override
  String get optGreatForRelaxedDinners => 'Ideal para cenas tranquilas.';

  @override
  String get opt_12Hours => '1–2 horas';

  @override
  String get optIEnjoyTheCookingProcess => 'Disfruto del proceso de cocinar';

  @override
  String get optForWeekendCookingSessions =>
      'Para sesiones de cocina de fin de semana.';

  @override
  String get optAnyAmountOfTime => 'Cualquier tiempo';

  @override
  String get optShowMeEverything => 'Muéstramelo todo';

  @override
  String get optAllRecipesAreOnTheTable =>
      'Todas las recetas están sobre la mesa.';

  @override
  String get optWeeklyMealPlan => 'Plan semanal de comidas';

  @override
  String get optGetAFullPlanEveryWeek => 'Un plan completo cada semana';

  @override
  String get optDailySuggestions => 'Sugerencias diarias';

  @override
  String get optOneRecipeEachMorning => 'Una receta cada mañana';

  @override
  String get optILlPlanMyself => 'Lo planifico yo';

  @override
  String get optJustShowMeRecipes => 'Solo muéstrame recetas';

  @override
  String get optPlanByIngredients => 'Planificar según ingredientes';

  @override
  String get optScanMyFridgeGiveMeA => 'Escanea mi nevera y dame un plan';

  @override
  String get optJustMe => 'Solo yo';

  @override
  String get opt_1Person => '1 persona';

  @override
  String get optTwoPeople => 'Dos personas';

  @override
  String get optCoupleOrPair => 'En pareja o de dos';

  @override
  String get opt_34People => '3–4 personas';

  @override
  String get optSmallFamily => 'Familia pequeña';

  @override
  String get opt_56People => '5–6 personas';

  @override
  String get optLargerFamily => 'Familia grande';

  @override
  String get opt_7PlusPeople => '7 personas o más';

  @override
  String get optLargeFamilyOrGroup => 'Familia numerosa o grupo';

  @override
  String get optItVaries => 'Depende';

  @override
  String get optILlAdjustPerRecipe => 'Lo ajusto en cada receta';

  @override
  String get optSaveMoney => 'Ahorrar dinero';

  @override
  String get optEatHealthier => 'Comer más sano';

  @override
  String get optGainMuscle => 'Ganar músculo';

  @override
  String get optLoseWeight => 'Perder peso';

  @override
  String get optWasteLessFood => 'Desperdiciar menos comida';

  @override
  String get optLearnToCook => 'Aprender a cocinar';

  @override
  String get optDiscoverRecipes => 'Descubrir recetas';

  @override
  String get optMealPrepEasier => 'Preparar comidas más fácil';

  @override
  String get optNoRestrictions => 'Sin restricciones';

  @override
  String get optIEatEverything => 'Como de todo';

  @override
  String get optVegetarian => 'Vegetariano';

  @override
  String get optNoMeatOrFish => 'Sin carne ni pescado';

  @override
  String get optVegan => 'Vegano';

  @override
  String get optNoAnimalProducts => 'Sin productos animales';

  @override
  String get optPescatarian => 'Pescetariano';

  @override
  String get optFishOkNoOtherMeat => 'Pescado sí, otra carne no';

  @override
  String get optGlutenFree => 'Sin gluten';

  @override
  String get optNoWheatOrGluten => 'Sin trigo ni gluten';

  @override
  String get optDairyFree => 'Sin lácteos';

  @override
  String get optNoMilkOrDairy => 'Sin leche ni lácteos';

  @override
  String get optHalal => 'Halal';

  @override
  String get optIslamicDietaryLaws => 'Normas alimentarias islámicas';

  @override
  String get optKosher => 'Kosher';

  @override
  String get optJewishDietaryLaws => 'Normas alimentarias judías';

  @override
  String get optKetoLowCarb => 'Keto / bajo en carbohidratos';

  @override
  String get optHighFatLowCarb => 'Alto en grasas, bajo en carbohidratos';

  @override
  String get optHighProtein => 'Alto en proteínas';

  @override
  String get optHighProteinFoods => 'Alimentos ricos en proteínas';

  @override
  String get optTreeNuts => 'Frutos secos';

  @override
  String get optPeanuts => 'Cacahuetes';

  @override
  String get optShellfish => 'Mariscos';

  @override
  String get optFish => 'Pescado';

  @override
  String get optEggs => 'Huevos';

  @override
  String get optSoy => 'Soja';

  @override
  String get optDairyMilk => 'Leche';

  @override
  String get optWheatGluten => 'Trigo / gluten';

  @override
  String get optSesame => 'Sésamo';

  @override
  String get optNoAllergies => 'Sin alergias';

  @override
  String get optItalian => 'Italiana';

  @override
  String get optJapanese => 'Japonesa';

  @override
  String get optMexican => 'Mexicana';

  @override
  String get optChinese => 'China';

  @override
  String get optThai => 'Tailandesa';

  @override
  String get optMiddleEastern => 'De Oriente Medio';

  @override
  String get optWestAfrican => 'De África Occidental';

  @override
  String get optEastAfrican => 'De África Oriental';

  @override
  String get optCaribbean => 'Caribeña';

  @override
  String get optIndian => 'India';

  @override
  String get optSpanish => 'Española';

  @override
  String get optGreek => 'Griega';

  @override
  String get optFrench => 'Francesa';

  @override
  String get optKorean => 'Coreana';

  @override
  String get optMediterranean => 'Mediterránea';

  @override
  String get optOthers => 'Otras';

  @override
  String get optOven => 'Horno';

  @override
  String get optStovetopGasBurner => 'Placa / fogón de gas';

  @override
  String get optMicrowave => 'Microondas';

  @override
  String get optAirFryer => 'Freidora de aire';

  @override
  String get optBlenderLiquidizer => 'Batidora / licuadora';

  @override
  String get optFoodProcessor => 'Procesador de alimentos';

  @override
  String get optInstantPotPressureCooker => 'Instant Pot / olla a presión';

  @override
  String get optGrillBbq => 'Parrilla / barbacoa';

  @override
  String get optRiceCooker => 'Arrocera';

  @override
  String get optStandMixerHandMixer => 'Amasadora / batidora de mano';

  @override
  String get optSteamer => 'Vaporera';

  @override
  String get optOther => 'Otro';

  @override
  String get optScanIngredients => 'Escanear ingredientes';

  @override
  String get optTakeAPhotoAndGetRecipes =>
      'Haz una foto y obtén recetas con lo que ya tienes.';

  @override
  String get optMealPlanning => 'Planificación de comidas';

  @override
  String get optPlanYourMealsForTheWeek =>
      'Planifica tus comidas de la semana sin empezar de cero.';

  @override
  String get optImportRecipes => 'Importar recetas';

  @override
  String get optSaveRecipesFromTiktokInstagramYoutube =>
      'Guarda recetas de TikTok, Instagram, YouTube o sitios web.';

  @override
  String get optGroceryLists => 'Listas de la compra';

  @override
  String get optTurnRecipesIntoShoppingListsAutomatically =>
      'Convierte tus recetas en listas de la compra automáticamente.';

  @override
  String get optDailyRecipeInspiration => 'Inspiración diaria de recetas';

  @override
  String get optMorningSuggestion => 'Sugerencia matinal';

  @override
  String get optGroceryReminder => 'Recordatorio de compras';

  @override
  String get optRememberWhatToBuyBeforeIngredients =>
      'Recuerda qué comprar antes de quedarte sin ingredientes.';

  @override
  String get optMild => 'Suave';

  @override
  String get optNoHeatAtAll => 'Nada picante';

  @override
  String get optMedium => 'Medio';

  @override
  String get optJustAHintOfSpice => 'Solo un toque picante';

  @override
  String get optSpicy => 'Picante';

  @override
  String get optIEnjoySpice => 'Me gusta el picante';

  @override
  String get optHot => 'Muy picante';

  @override
  String get optTheSpicierTheBetter => 'Cuanto más picante, mejor';

  @override
  String get optInferno => 'Infernal';

  @override
  String get optIPutHotSauce => 'Le pongo salsa picante a todo';

  @override
  String get optUnder18 => 'Menos de 18';

  @override
  String get optUnder50 => 'Menos de 50 \$';

  @override
  String get optIDonTKnowWhatTo => 'No sé qué cocinar';

  @override
  String get optCookingTakesTooMuchTime => 'Cocinar lleva demasiado tiempo';

  @override
  String get optISpendTooMuchOnTakeout =>
      'Gasto demasiado en comida para llevar';

  @override
  String get optHealthyEatingFeelsDifficult => 'Comer sano me resulta difícil';

  @override
  String get optGroceryShoppingIsStressful => 'Hacer la compra es estresante';

  @override
  String get optAlmostNever => 'Casi nunca';

  @override
  String get optSometimes => 'A veces';

  @override
  String get optWeekly => 'Cada semana';

  @override
  String get optConstantly => 'Constantemente';

  @override
  String get optAnchovies => 'Anchoas';

  @override
  String get optBlackLicorice => 'Regaliz negro';

  @override
  String get optBrusselsSprouts => 'Coles de Bruselas';

  @override
  String get optBlueCheese => 'Queso azul';

  @override
  String get optOysters => 'Ostras';

  @override
  String get optSardines => 'Sardinas';

  @override
  String get optOlives => 'Aceitunas';

  @override
  String get optBeets => 'Remolacha';

  @override
  String get optCottageCheese => 'Requesón';

  @override
  String get optOkra => 'Okra';

  @override
  String get optSpam => 'Spam';

  @override
  String get optTofu => 'Tofu';

  @override
  String get optTurnips => 'Nabos';

  @override
  String get optKimchi => 'Kimchi';

  @override
  String get optEggplant => 'Berenjena';

  @override
  String get optCauliflower => 'Coliflor';

  @override
  String get optCilantro => 'Cilantro';

  @override
  String get optLimaBeans => 'Habas de Lima';

  @override
  String get optPickledHerring => 'Arenque en escabeche';

  @override
  String get optSauerkraut => 'Chucrut';

  @override
  String get optGoatCheese => 'Queso de cabra';

  @override
  String get optBitterMelon => 'Melón amargo';

  @override
  String get optMushrooms => 'Champiñones';

  @override
  String get optGrapefruit => 'Pomelo';

  @override
  String get opt_23TimesAWeek => '2–3 veces por semana';

  @override
  String get optMetric => 'Métrico';

  @override
  String get optImperial => 'Imperial';

  @override
  String get optLiver => 'Hígado';

  @override
  String get onbBestGuess => 'Haz una estimación. Nosotros hacemos las cuentas';

  @override
  String get onbEatingOutTitle => '¿Cuánto gastas comiendo fuera cada semana?';

  @override
  String get onbThatCouldBeOver => 'Podría superar';

  @override
  String get onbPotentialYearlySavings => 'Ahorro anual potencial';

  @override
  String get onbThanHome => 'Que cocinar en casa';

  @override
  String get onbNearlyB => ' más caro';

  @override
  String get onbNearlyA => 'Es casi ';

  @override
  String get onbMadeAtHome => 'Hecho en casa';

  @override
  String get onbHomeCooked => 'Casero';

  @override
  String get onbThreeMealsWeek => '3 comidas / semana';

  @override
  String get onbTakeout => 'Comida para llevar';

  @override
  String get onbCostingSubtitle =>
      'Las pequeñas decisiones se convierten\nen hábitos caros';

  @override
  String get onbCostingTitleD => 'tiempo';

  @override
  String get onbCostingTitleC => 'más que ';

  @override
  String get onbCostingTitleB => 'costando\n';

  @override
  String get onbCostingTitleA => 'Y te está ';

  @override
  String get onbDinnerSubtitle => 'Sin estrés. Sin improvisar';

  @override
  String get onbDinnerTitleB => 'resuelta';

  @override
  String get onbDinnerTitleA => 'Imagina la cena\nya ';

  @override
  String get onbViewOtherPlans => 'Ver otros planes';

  @override
  String get onbTrialReminder =>
      'Te enviaremos un recordatorio antes de que termine tu prueba.';

  @override
  String get onbTrialDay3 => 'Día 3';

  @override
  String get onbTrialDay2 => 'Día 2';

  @override
  String get onbTrialGuideToday =>
      'Desbloquea recetas personalizadas, sugerencias de comidas y escaneo de ingredientes.';

  @override
  String get commonToday => 'Hoy';

  @override
  String get onbTrialGuideSubtitle =>
      'Saca el máximo partido a tu prueba de Cooked.';

  @override
  String get onbTrialGuideTitle => 'Tu prueba gratuita';

  @override
  String get onbTryForZero => 'Empezar prueba gratuita de 3 días';

  @override
  String get onbKeepEverything =>
      'Crea tu cuenta para guardar tus recetas, planes de comidas, listas de la compra y tu registro de ahorro.';

  @override
  String get onbTryFreeB => 'gratis';

  @override
  String get onbTryFreeA => 'Queremos que pruebes\nCooked ';

  @override
  String get onbBenefitGrocery =>
      'Listas de la compra inteligentes que te ahorran dinero';

  @override
  String get onbBenefitPlans => 'Planes de comidas personalizados';

  @override
  String get onbBenefitRecipes =>
      'Acceso completo a más de 10.000 recetas seleccionadas por chefs';

  @override
  String get onbGroceriesUnusedTitle =>
      '¿Con qué frecuencia se te estropea la compra?';

  @override
  String get onbOver => 'más de ';

  @override
  String get onbHouseholdWastes => 'Un hogar medio desperdicia';

  @override
  String get onbHandlesSubtitle => 'Nosotros planificamos. Tú cocinas.';

  @override
  String get onbHandlesTitleB => 'comidas';

  @override
  String get onbHandlesTitleA => 'Cooked se encarga\nde todas tus ';

  @override
  String get onbHealthySubtitle => 'Recetas que de verdad\nte apetecerá comer.';

  @override
  String get onbHealthyTitleD => 'segundo trabajo';

  @override
  String get onbHealthyTitleC => ' un\n';

  @override
  String get onbHealthyTitleB => 'parecer';

  @override
  String get onbHealthyTitleA => 'Comer sano\nno debería ';

  @override
  String get onbMealsSubtitle =>
      'La cena no debería ser la decisión\nmás difícil de tu día';

  @override
  String get onbMealsTitleD => ' nunca más';

  @override
  String get onbMealsTitleC => 'cocinar';

  @override
  String get onbMealsTitleB => 'qué\n';

  @override
  String get onbMealsTitleA => 'No vuelvas a preguntarte ';

  @override
  String onbBuildingSystem(String dots) {
    return 'Creando tu\nsistema de cocina\npersonalizado$dots';
  }

  @override
  String get onbTaskPersonalizing => 'Personalizando recomendaciones';

  @override
  String get onbTaskFeed => 'Creando tu feed de comidas';

  @override
  String get onbTaskSavings => 'Calculando el ahorro';

  @override
  String get onbTaskFindRecipes => 'Buscando recetas que te encantarán';

  @override
  String get onbTaskTastes => 'Conociendo tus gustos';

  @override
  String get onbRepetitionSubtitle => 'Pensado para tus gustos.';

  @override
  String get onbRepetitionTitle => '¿Cansado de comer\nlo mismo cada\nsemana?';

  @override
  String get onbOfYourLife => 'de tu vida\ncada año';

  @override
  String get onbDays => 'Días';

  @override
  String get onbSpentDeciding => 'Dedicadas a decidir\nqué comer';

  @override
  String get onbHours => 'Horas';

  @override
  String get onbNotAloneSubtitle =>
      'La mayoría pasa más de 200 horas\nal año decidiendo qué comer';

  @override
  String get onbNotAloneB => 'solo';

  @override
  String get onbNotAloneA => 'No estás ';

  @override
  String get onbSkillSubtitle => 'Adaptaremos las recetas a tu experiencia.';

  @override
  String get onbSkillTitle => '¿Cuál es tu nivel\nen la cocina?';

  @override
  String get onbAvoidB => '.';

  @override
  String get onbAvoidA => 'Genial, evitaremos las recetas ';

  @override
  String get onbAvoidComplex => 'complejas';

  @override
  String get onbAvoidBasic => 'demasiado básicas';

  @override
  String get onbAvoidBoring => 'aburridas';

  @override
  String get onbAvoidUntested => 'no probadas';

  @override
  String get onbAvoidOverlyComplex => 'demasiado complejas';

  @override
  String get onbReview3 =>
      '«Las ideas de comidas son personalizadas,\nno aleatorias.»';

  @override
  String get onbReview2 => '«Por fin aprovecho la compra\nque ya tengo.»';

  @override
  String get onbReview1 =>
      '«Cooked me ayudó a dejar de\npedir la cena cada noche.»';

  @override
  String get onbStarsFromThousands =>
      'Estrellas de miles\nde amantes de la cocina';

  @override
  String get onbUnlock => 'Desbloquear';

  @override
  String get onbBadgeHealthier => 'Comidas más sanas,\nsin esfuerzo';

  @override
  String get onbBadgeRecipes => '1.847 recetas\nencontradas';

  @override
  String get onbBadgeSaveHours => 'Ahorra 180+ horas/\naño';

  @override
  String get onbBadgeSaveMoney => 'Ahorra 2.496 \$/\naño';

  @override
  String get onbRecipesCurated => 'recetas elegidas para tus gustos';

  @override
  String get onbPlanReadySubtitle =>
      'Pensado para tus objetivos, gustos,\nhorario y ahorro';

  @override
  String get onbPlanReady => 'Tu plan\npersonalizado está listo.';

  @override
  String get onbStartArrow => 'Empezar →';

  @override
  String get onbBuildProfileSubtitle =>
      'Cuanto más sabemos, mejores son tus recomendaciones';

  @override
  String get onbBuildProfileB => 'culinario';

  @override
  String get onbBuildProfileA => 'Creemos tu\nperfil ';

  @override
  String get onbTaskCuisines => 'Conociendo tus cocinas favoritas';

  @override
  String get onbTaskDietary => 'Analizando tus preferencias alimentarias';

  @override
  String get onbTaskPotentialSavings => 'Calculando tu ahorro potencial';

  @override
  String get onbTaskChallenges => 'Analizando tus retos en la cocina';

  @override
  String get onbCookingSmarter => 'Solo cocinando de forma más inteligente';

  @override
  String get onbEveryYear => 'Cada año';

  @override
  String get onbCouldSave => 'Podrías ahorrar\naproximadamente';

  @override
  String get optSweet => 'Dulce';

  @override
  String get optSavory => 'Salado';

  @override
  String get optCrunchyTextures => 'Texturas crujientes';

  @override
  String get optSoftCreamy => 'Suave y cremoso';

  @override
  String get flavorLeaningSweet => 'Tendencia dulce';

  @override
  String get flavorLeaningSavory => 'Tendencia salada';

  @override
  String get flavorLeaningBalanced => 'Equilibrado';

  @override
  String get flavorTextureCrunchy => 'Textura crujiente';

  @override
  String get flavorTextureCreamy => 'Textura cremosa';

  @override
  String get flavorTextureBalanced => 'Textura equilibrada';

  @override
  String get onbCreateAccount => 'Crear cuenta';

  @override
  String get onbEmailHint => 'juan@ejemplo.com';

  @override
  String get onbNameHint => 'Juan Pérez';

  @override
  String get commonFullName => 'Nombre completo';

  @override
  String get onbCreateAccountSubtitle => 'Protege tus recetas y preferencias';

  @override
  String get onbCreateAccountTitle => 'Crea tu cuenta';

  @override
  String get valPasswordMin => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get valEnterPassword => 'Introduce una contraseña';

  @override
  String get valValidEmail => 'Introduce un correo electrónico válido';

  @override
  String get valEnterEmail => 'Introduce tu correo electrónico';

  @override
  String get valEnterName => 'Introduce tu nombre';

  @override
  String get onbAgeSubtitle =>
      'Lo usaremos para personalizar tus recomendaciones';

  @override
  String get onbAgeTitle => '¿Cuántos años tienes?';

  @override
  String get onbAllergiesSubtitle =>
      'Filtraremos las recetas automáticamente por ti';

  @override
  String get onbAllergiesTitle =>
      '¿Tienes alguna\nrestricción alimentaria\no alergia?';

  @override
  String get onbMoreDietLater =>
      'Podrás actualizar otras preferencias alimentarias más tarde en Ajustes.';

  @override
  String get onbCommonAllergies => 'Alergias comunes';

  @override
  String get onbTypeCuisine => 'Escribe una cocina...';

  @override
  String get onbSpecifyCuisines => 'Indica otras cocinas';

  @override
  String get onbCuisinesSubtitle =>
      'Elige tus favoritas. Cuantas más elijas,\nmejores serán tus recomendaciones';

  @override
  String get onbCuisinesTitle => '¿Qué cocinas\nte encantan?';

  @override
  String get onbSelectOneCuisine => 'Elige al menos una cocina';

  @override
  String get commonSelectAllThatApply => 'Selecciona todo lo que corresponda.';

  @override
  String get onbDietTitle => '¿Cuál es tu perfil alimentario?';

  @override
  String get onbMorePrefsLater =>
      'Podrás actualizar más preferencias más tarde en Ajustes.';

  @override
  String get onbDislikeHint =>
      'Escribe un alimento (p. ej. cerdo, mayonesa)...';

  @override
  String get onbDislikesSubtitle => 'Los excluiremos de tus\nrecomendaciones';

  @override
  String get onbDislikesTitle => '¿Qué alimentos\nno te gustan?';

  @override
  String get onbFeaturesSubtitle => 'Elige las funciones que más usarás';

  @override
  String get onbFeaturesTitle => '¿Qué es lo que más\nte ilusiona?';

  @override
  String get onbProfilePreview => 'VISTA PREVIA DE TU PERFIL';

  @override
  String get onbSpiceTolerance => 'Tolerancia al picante';

  @override
  String get onbFlavorSubtitle => 'Mueve los controles según tus gustos';

  @override
  String get onbFlavorTitle => 'Tu perfil de sabores';

  @override
  String get onbFrustrationsSubtitle => 'Elige las que más te representen';

  @override
  String get onbFrustrationsTitle => '¿Qué te impide cocinar más?';

  @override
  String get onbGoalsSubtitle => 'Personalizaremos todo en torno a él';

  @override
  String get onbGoalsTitle => '¿Cuál es tu objetivo\nahora mismo?';

  @override
  String get onbEquipmentHint => 'Escribe un equipo y pulsa Intro';

  @override
  String get onbSpecifyEquipment => 'Indica otro equipamiento';

  @override
  String get onbKitchenSubtitle => 'Selecciona tu equipamiento';

  @override
  String get onbKitchenTitle => '¿Qué hay en tu cocina?';

  @override
  String get onbPlanningSubtitle => 'Personalizaremos la experiencia para ti';

  @override
  String get onbPlanningTitle => '¿Cómo te gusta planificar tus comidas?';

  @override
  String get onbNotifFooter => 'Puedes cambiarlo cuando quieras en tus ajustes';

  @override
  String get onbTurnOnAll => 'Activar todo';

  @override
  String get onbTurnOffAll => 'Desactivar todo';

  @override
  String get onbNotifSubtitle => 'Elige sobre qué quieres recibir avisos';

  @override
  String get onbNotifTitle => 'Inspírate con nuevas recetas';

  @override
  String get onbVerifyContinue => 'Verificar y continuar';

  @override
  String get onbNoCode => '¿No recibiste el código?';

  @override
  String onbOtpSentTo(String email) {
    return 'Introduce el código de 6 dígitos que enviamos a\n$email';
  }

  @override
  String get onbVerifyAccount => 'Verifica tu cuenta';

  @override
  String get onbStartCooking => '¡A cocinar!';

  @override
  String get onbUsesIngredients => 'Usa tus ingredientes';

  @override
  String get onbQuickDinner => 'Cena rápida';

  @override
  String get onbMatchesTaste => 'Encaja con tus gustos';

  @override
  String get onbWhyPicked => 'Por qué lo elegimos';

  @override
  String get onbPerfectMealSubtitle =>
      'Según tus objetivos, gustos y forma de cocinar';

  @override
  String get onbPerfectMeal => 'La comida perfecta para ti';

  @override
  String commonSoonSuffix(String label) {
    return '$label (próximamente)';
  }

  @override
  String get authSignInWithEmail => 'Iniciar sesión con correo';

  @override
  String get onbSavePlan => 'Guarda tu\nplan personalizado';

  @override
  String get onbTargetSubtitle =>
      'Así podemos recomendarte las porciones adecuadas';

  @override
  String get onbTargetTitle => '¿Para quién sueles\ncocinar?';

  @override
  String get onbCookingTime => 'Tiempo de cocina';

  @override
  String get onbTimeSubtitle =>
      'Priorizaremos recetas que encajen con tu horario';

  @override
  String get onbTimeTitle => '¿Cuánto tiempo sueles\ntener para cocinar?';

  @override
  String get priceBilledMonthly => 'Facturación mensual';

  @override
  String priceBilledPerMonth(String price) {
    return 'Se factura $price al mes';
  }

  @override
  String get commonProcessing => 'Procesando';

  @override
  String get commonContinuing => 'Cargando';

  @override
  String get onbStartTrial => 'Empezar mi prueba gratuita de 3 días';

  @override
  String get onbSkipEatMost => 'Omitir — como casi de todo';

  @override
  String get commonConnecting => 'Conectando';

  @override
  String onbGoogleSignupTip(String error) {
    return '$error\n\nConsejo: si el problema persiste con Google, regístrate con tu correo.';
  }

  @override
  String get onbCompleteAccountInfo =>
      'Completa los datos de la cuenta para guardar tu perfil';

  @override
  String get payCouldNotStart => 'No se pudo iniciar la compra';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get commonSubmit => 'Enviar';

  @override
  String get referralCodeHint => 'Código de referido';

  @override
  String get referralCanSkip => 'Puedes omitir este paso';

  @override
  String get referralEnterCode => 'Introduce un código de referido (opcional)';

  @override
  String giftUnlocked(String plan) {
    return '🎉 ¡$plan de Cooked Premium desbloqueado!';
  }

  @override
  String priceTrialThenYearly(String price) {
    return '3 días gratis, luego $price/año';
  }

  @override
  String get priceTrialThenBilledYearly =>
      '3 días gratis, luego facturación anual';

  @override
  String commonCancelAnytime(String text) {
    return '$text. Cancela cuando quieras.';
  }

  @override
  String get trialHaveReferralCode => '¿Tienes un código de referido?';

  @override
  String get trialMonthlyNoTrialNoPrice =>
      'Sin prueba gratuita. Se cobra ahora. Cancela cuando quieras.';

  @override
  String trialMonthlyNoTrial(String price) {
    return 'Sin prueba gratuita. Se cobra ahora $price/mes. Cancela cuando quieras.';
  }

  @override
  String get commonProcessingDots => 'Procesando...';

  @override
  String get trialTryFree => 'Empezar prueba gratuita de 3 días';

  @override
  String get trialSubscribeNow => 'Suscribirse';

  @override
  String get trialNoPaymentToday => 'Hoy no pagas nada';

  @override
  String get trialThreeDaysFree => '3 días gratis';

  @override
  String get planYearly => 'Anual';

  @override
  String get planMonthly => 'Mensual';

  @override
  String get trialSubtitle => 'Pensado para tus objetivos, horario y gustos.';

  @override
  String get trialTitle => 'Desbloquea tu\nsistema de cocina personalizado.';

  @override
  String pricePerYearShort(String price) {
    return '$price /año';
  }

  @override
  String pricePerMonthShort(String price) {
    return '$price /mes';
  }

  @override
  String get faqImportQ => '¿Cómo importo una receta?';

  @override
  String get faqImportA =>
      'Ve a la pestaña Importar, pega un enlace o usa la cámara para escanear una receta.';

  @override
  String get faqShareQ => '¿Puedo compartir mis recetas?';

  @override
  String get faqShareA =>
      '¡Sí! Abre una receta y toca el botón de compartir arriba a la derecha.';

  @override
  String get faqCookbookQ => '¿Cómo creo un recetario?';

  @override
  String get faqCookbookA =>
      'En la pestaña Inicio, toca el botón « + » junto a tus recetarios.';

  @override
  String get faqPasswordQ => '¿Cómo cambio mi contraseña?';

  @override
  String get faqPasswordA =>
      'Ve a Ajustes → Cambiar contraseña e introduce la nueva.';

  @override
  String get faqWebQ => '¿Hay una versión web?';

  @override
  String get faqWebA =>
      'No, por ahora Cooked solo está disponible como app móvil.';

  @override
  String get feedbackCatAccount => 'Cuenta';

  @override
  String get feedbackCatPayment => 'Pago';

  @override
  String get feedbackCatScan => 'Escaneo';

  @override
  String get feedbackCatImport => 'Importación';

  @override
  String get feedbackCatRecipe => 'Receta';

  @override
  String get feedbackCatShopping => 'Compras';

  @override
  String get feedbackCatOther => 'Otro';

  @override
  String prefsFlavorSummary(String spice, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preferencias',
      one: '1 preferencia',
    );
    return '$spice, $_temp0';
  }

  @override
  String savingsFromRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Con $count recetas guardadas',
      one: 'Con 1 receta guardada',
    );
    return '$_temp0';
  }

  @override
  String get activityEmpty =>
      'Aún no has importado ni escaneado ninguna receta.';

  @override
  String get activityRecentRecipes => 'Recetas recientes';

  @override
  String get prefsAllergiesUpdateFailed =>
      'No se pudieron actualizar las alergias';

  @override
  String get prefsFlavorSpice => 'Sabor y picante';

  @override
  String get commonNotSet => 'Sin definir';

  @override
  String get prefsFavoriteCuisines => 'Cocinas favoritas';

  @override
  String get prefsCuisineUpdateFailed =>
      'No se pudieron actualizar tus cocinas y sabores';

  @override
  String get feedbackHint => 'Describe tu problema...';

  @override
  String get feedbackMessage => 'Mensaje';

  @override
  String get feedbackCategory => 'Categoría';

  @override
  String get feedbackHeadline =>
      'Nos encantará saber de ti 💬\nDescribe tu problema y te ayudaremos lo antes posible.';

  @override
  String get feedbackFailed =>
      'No se pudo enviar tu mensaje. Inténtalo de nuevo.';

  @override
  String get feedbackSent => '¡Gracias! Tu mensaje se ha enviado.';

  @override
  String get feedbackNoEmail => 'No se encontró el correo de tu cuenta.';

  @override
  String get feedbackWriteFirst => 'Escribe un mensaje primero.';

  @override
  String get legalCookies => 'Política de cookies';

  @override
  String get legalRefundCancellation => 'Reembolso y cancelación';

  @override
  String get legalRefund => 'Política de reembolso';

  @override
  String get legalTerms => 'Términos y condiciones';

  @override
  String get helpLegal => 'Aviso legal y políticas';

  @override
  String get helpSendFeedbackSubtitle => 'Errores, ideas o lo que quieras';

  @override
  String get helpSendFeedback => 'Enviar comentarios';

  @override
  String get helpHeadline =>
      'Cuéntanos cómo podemos ayudarte 👋\n¡Nuestro equipo está aquí para ayudarte!';

  @override
  String get helpTitle => 'Centro de ayuda';

  @override
  String get prefsKitchenUpdateFailed =>
      'No se pudo actualizar el equipamiento';

  @override
  String get giftRedeeming => 'Canjeando...';

  @override
  String get giftRedeem => 'Canjear';

  @override
  String get giftRedeemSubtitle =>
      'Introduce tu código de regalo para desbloquear Cooked Premium en esta cuenta.';

  @override
  String get giftRedeemHeadline => '¿Te han regalado Cooked?';

  @override
  String get giftRedeemTitle => 'Canjear un regalo';

  @override
  String get savingsScannedAtHome => 'Escaneado en casa';

  @override
  String get savingsYourSaved => 'Has ahorrado';

  @override
  String get savingsEmpty => 'Aún no hay ahorros por escaneo';

  @override
  String get savingsTitle => 'Tus ahorros';

  @override
  String get subAmount => 'Importe';

  @override
  String get commonNotAvailable => 'N/D';

  @override
  String get subFreeTrial => 'Prueba gratuita';

  @override
  String get subPremiumPlan => 'Plan Premium';

  @override
  String get subNoPayments => 'No hay pagos';

  @override
  String get subPaymentHistory => 'Historial de pagos';

  @override
  String get subRestorePurchases => 'Restaurar compras';

  @override
  String get subActive => 'Suscripción activa';

  @override
  String get subRenew => 'Renovar o mejorar';

  @override
  String get subAlreadyPremium => '¡Ya eres miembro Premium!';

  @override
  String get subStatus => 'Estado';

  @override
  String get subEndDate => 'Fecha de fin';

  @override
  String get subStartDate => 'Fecha de inicio';

  @override
  String get subPlan => 'Plan';

  @override
  String get subDetails => 'Detalles de la suscripción';

  @override
  String get subTitle => 'Suscripción';

  @override
  String get subNothingToRestore =>
      'No hay suscripciones activas que restaurar.';

  @override
  String get subRestored => '¡Compras restauradas!';

  @override
  String get subExpiringSoon => 'Caduca pronto';

  @override
  String subHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count horas',
      one: 'Queda 1 hora',
    );
    return '$_temp0';
  }

  @override
  String subDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días',
      one: 'Queda 1 día',
    );
    return '$_temp0';
  }

  @override
  String get subExpired => 'Caducada';

  @override
  String get subNoActive => 'Ninguna suscripción activa';

  @override
  String get subLoadFailed => 'No se pudo cargar la suscripción';

  @override
  String get prefsGoals => 'Objetivos';

  @override
  String get prefsSectionOther => 'Otros';

  @override
  String get prefsCookingTarget => 'Número de personas';

  @override
  String get prefsPlanningStyle => 'Estilo de planificación';

  @override
  String get prefsSectionPlanning => 'Planificación y hábitos';

  @override
  String get prefsTimePreference => 'Tiempo de cocina';

  @override
  String get prefsCookingSkill => 'Nivel de cocina';

  @override
  String get prefsSectionCooking => 'Cocina y habilidades';

  @override
  String get prefsFoodDislikes => 'Alimentos que no te gustan';

  @override
  String get prefsDietaryProfile => 'Perfil alimentario';

  @override
  String get prefsSectionDiet => 'Alimentación';

  @override
  String get prefsUpdateFailed => 'No se pudieron actualizar las preferencias';

  @override
  String get prefsUpdated => '¡Preferencias actualizadas!';

  @override
  String get prefsLoadFailed => 'No se pudieron cargar las preferencias';

  @override
  String get giftPlanOneYear => '1 año';

  @override
  String get giftPlanThreeMonths => '3 meses';

  @override
  String get giftPlanOneYearDesc =>
      'Regala una suscripción Premium de Cooked de 1 año. Compra no reembolsable.';

  @override
  String get giftPlanThreeMonthsDesc =>
      'Regala una suscripción Premium de Cooked de 3 meses. Compra no reembolsable.';

  @override
  String giftShareMessage(String plan, String url, String code) {
    return '🎁 ¡Te regalo $plan de Cooked Premium! Canjéalo aquí: $url\n\nO abre Cooked e introduce este código: $code';
  }

  @override
  String get giftTapToCopy => 'Toca para copiar';

  @override
  String get giftRefunded => 'Reembolsado';

  @override
  String get giftRedeemed => 'Canjeado';

  @override
  String get giftNotUsed => 'Aún sin usar';

  @override
  String get giftBuy => 'Comprar regalo';

  @override
  String get giftBestValue => 'Mejor precio';

  @override
  String get giftYourGifts => 'Tus regalos';

  @override
  String get giftSubtitle =>
      'Compra un código de regalo y envíaselo a un amigo. Lo canjea en la app, sin necesidad de suscripción.';

  @override
  String get giftHeadline => 'Regala Cooked';

  @override
  String get giftTitle => 'Regalar Cooked';

  @override
  String get giftSendToFriend => 'Enviar a un amigo';

  @override
  String giftSendThisCode(String plan) {
    return 'Envía este código de $plan a un amigo. También te lo enviamos por correo.';
  }

  @override
  String get giftReady => '¡Tu regalo está listo!';

  @override
  String get giftCodeCopied => 'Código de regalo copiado';

  @override
  String get giftPurchaseFailed => 'La compra ha fallado. Inténtalo de nuevo.';

  @override
  String get giftPaymentReceived =>
      '¡Pago recibido! Te enviaremos el código de regalo por correo en un momento.';

  @override
  String shareRecipe(String name, String link) {
    return 'Mira $name en Cooked 🙌\n$link';
  }

  @override
  String shareRecipeByCreator(String creator, String name, String link) {
    return 'Mira $name de $creator en Cooked 🙌\n$link';
  }

  @override
  String get savingsComparedTakeout =>
      'Comparado con pedir comida a domicilio.';

  @override
  String get savingsThisMonth => 'Este mes';

  @override
  String get recipeAlreadySaved => 'Esta receta ya está en tus recetas';

  @override
  String get homeSuggestedRecipes => 'Recetas sugeridas';

  @override
  String get cookbookDeleteFailed => 'No se pudo eliminar el recetario';

  @override
  String get cookbookDeleted => 'Recetario eliminado';

  @override
  String get cookbookDelete => 'Eliminar recetario';

  @override
  String get commonOperationFailed => 'La operación ha fallado';

  @override
  String get cookbookUnpinned => 'Recetario desfijado';

  @override
  String get cookbookPinned => 'Recetario fijado';

  @override
  String get cookbookPin => 'Fijar recetario';

  @override
  String get cookbookUnpin => 'Desfijar recetario';

  @override
  String get cookbookEdit => 'Editar recetario';

  @override
  String get cookbookAddRecipes => 'Añadir recetas';

  @override
  String get cookbookNew => 'Nuevo recetario';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackThanks => '¡Gracias por tus comentarios!';

  @override
  String get feedbackTypeHere => 'Escribe tus comentarios aquí...';

  @override
  String get feedbackCardSubtitle =>
      'Comparte tus ideas o cualquier cosa que pueda mejorar tu experiencia.';

  @override
  String get feedbackCardTitle => 'Ayúdanos a mejorar Cooked';

  @override
  String get feedbackCardButton => 'Enviar comentarios';

  @override
  String get recipeDelete => 'Eliminar receta';

  @override
  String get recipeShare => 'Compartir receta';

  @override
  String get recipeAddToCookbook => 'Añadir al recetario';

  @override
  String get recipeRemoveFromCookbook => 'Quitar del recetario';

  @override
  String get recipeUnpin => 'Desfijar receta';

  @override
  String get recipePin => 'Fijar receta';

  @override
  String get recipeRemovedToast => 'Receta eliminada de guardadas';

  @override
  String get recipeSavedToast => '¡Receta guardada en favoritos!';

  @override
  String get navImport => 'Importar';

  @override
  String get navScan => 'Escanear';

  @override
  String get navExplore => 'Explorar';

  @override
  String get commonTryDifferentSearch => 'Prueba con otra búsqueda.';

  @override
  String get homeBrowseRecipes => 'Ver recetas';

  @override
  String get homeNoSavedSubtitle =>
      'Explora nuestras recetas y guarda tus favoritas\npara crear tu colección.';

  @override
  String get homeNoSavedTitle => 'Aún no hay recetas guardadas';

  @override
  String get homeAddCookbook => 'Añadir recetario';

  @override
  String get homeCookbookEmptySubtitle =>
      'Guarda tus recetas favoritas\ny tenlas todas en un solo lugar.';

  @override
  String get homeCookbookEmptyTitle => 'Empieza tu recetario';

  @override
  String get commonViewAll => 'Ver todo';

  @override
  String get homeSavedRecipes => 'Recetas guardadas';

  @override
  String get homeSuggested => 'Sugerencias para ti';

  @override
  String get homeRecentlyViewed => 'Vistas recientemente';

  @override
  String get homeCookbooks => 'Recetarios';

  @override
  String get homeYourCookbooks => 'Tus recetarios';

  @override
  String get homeSearchHint => 'Busca en tus recetas';

  @override
  String get homeHeadline => '¿Qué te apetece cocinar hoy?';

  @override
  String get navGrocery => 'Compras';

  @override
  String get navScanRecipe => 'Escanear receta';

  @override
  String get navHome => 'Inicio';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas',
      one: '1 receta',
    );
    return '$_temp0';
  }

  @override
  String recipeCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas',
      one: '1 receta',
    );
    return '$_temp0';
  }

  @override
  String get cookbookDefaultName => 'Recetario';

  @override
  String get recipePinned => 'Receta fijada';

  @override
  String get recipeUnpinned => 'Receta desfijada';

  @override
  String get recipePinFailed => 'No se pudo fijar la receta';

  @override
  String get recipeRemovedFromCookbook => 'Quitada del recetario';

  @override
  String get recipeDeleted => 'Receta eliminada';

  @override
  String get cookbookEmptyTitle => 'Aún no hay recetas';

  @override
  String get cookbookEmptySubtitle =>
      'Añade recetas a este recetario escaneando, importando o explorando.';

  @override
  String get recipeServings => 'Raciones';

  @override
  String get recipeQuantitiesAdjust =>
      'Las cantidades se ajustan automáticamente';

  @override
  String get commonLoadingDots => 'Cargando...';

  @override
  String get commonGoBack => 'Volver';

  @override
  String recipeServingsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$_temp0';
  }

  @override
  String get recipeAddToGrocery => 'Añadir a la compra';

  @override
  String get recipeSteps => 'Pasos';

  @override
  String get recipeIngredients => 'Ingredientes';

  @override
  String get recipeAlsoRemoveSaved =>
      '¿Quieres quitar también esta receta de tus recetas guardadas?';

  @override
  String get commonNo => 'No';

  @override
  String get commonYes => 'Sí';

  @override
  String get recipeRemovedBoth =>
      'Quitada del recetario y de tus recetas guardadas';

  @override
  String get recipeNoIngredients => 'No hay ingredientes';

  @override
  String get recipeNoIngredientsHint => 'Consulta la descripción de la receta.';

  @override
  String get recipeNoEquipment => 'No se necesita equipamiento especial';

  @override
  String get recipeNoEquipmentHint => 'Bastan los utensilios básicos.';

  @override
  String get recipeNoSteps => 'No hay pasos';

  @override
  String get recipeNoStepsHint => 'Sigue tu intuición o consulta la fuente.';

  @override
  String get recipeRequiredEquipment => 'Equipamiento necesario';

  @override
  String get recipeNotesTips => 'Notas / consejos';

  @override
  String get recipeTonightSaving => 'El ahorro de esta noche';

  @override
  String get recipeOrderingNearby => 'Pedir cerca';

  @override
  String get recipeMakingAtHome => 'Cocinar en casa';

  @override
  String get recipeEstimatedSavings => 'Ahorro estimado';

  @override
  String get viewAllCuisine => 'Cocina';

  @override
  String get viewAllSearchCuisine => 'Buscar cocina...';

  @override
  String get viewAllSearchCategory => 'Buscar categoría...';

  @override
  String viewAllSearchCuisineRecipes(String cuisine) {
    return 'Buscar recetas ($cuisine)...';
  }

  @override
  String get viewAllSearchRecent => 'Buscar en recetas vistas recientemente...';

  @override
  String get viewAllSearchAll => 'Buscar recetas, recetarios...';

  @override
  String get viewAllNoCookbooks => 'No hay recetarios.';

  @override
  String get viewAllNoCookbooksMatch =>
      'Ningún recetario coincide con tu búsqueda.';

  @override
  String get viewAllNoRecipesMatch =>
      'Ninguna receta coincide con tu búsqueda.';

  @override
  String get viewAllNoRecipes => 'No se encontraron recetas.';

  @override
  String get commonRecipes => 'Recetas';

  @override
  String get recipeDeleteFailed =>
      'No se pudo eliminar esta receta. Inténtalo de nuevo.';

  @override
  String get recipeAlreadyInYours => 'Ya está en tus recetas';

  @override
  String get viewAllNoCreatorsMatch =>
      'Ningún creador coincide con tu búsqueda.';

  @override
  String get viewAllNoItems => 'No hay elementos.';

  @override
  String get viewAllNoItemsMatch => 'Ningún elemento coincide con tu búsqueda.';

  @override
  String get cameraInitializing => 'Iniciando la cámara...';

  @override
  String get cameraOnHold => 'En pausa';

  @override
  String get cameraOff => 'Cámara apagada';

  @override
  String get cameraPermissionDenied => 'Permiso de cámara denegado';

  @override
  String get cameraFinding => 'Buscando cámaras...';

  @override
  String get cameraNotFound => 'No se encontró ninguna cámara';

  @override
  String get cameraReady => 'Lista';

  @override
  String get cameraError => 'Cámara no disponible';

  @override
  String get scanAddIngredientsFirst => 'Añade o selecciona ingredientes';

  @override
  String get scanTypeIngredient => 'Escribir ingrediente';

  @override
  String get scanSaved => 'Guardados';

  @override
  String get scanGetRecipes => 'Ver recetas';

  @override
  String get scanTypeIngredients => 'Escribir';

  @override
  String get scanEnterOneByOne => 'Escribe los ingredientes uno a uno';

  @override
  String get scanAddToFind =>
      'Añade ingredientes para encontrar recetas que puedas preparar';

  @override
  String get scanRecentlyUsed => 'Usados recientemente';

  @override
  String get scanUseAll => 'Usar todos';

  @override
  String get scanClearSelection => 'Borrar selección';

  @override
  String get scanNoSaved => 'Aún no hay ingredientes guardados.';

  @override
  String get scanResultsTitleA => 'Recetas que\n';

  @override
  String get scanResultsTitleB => 'puedes cocinar ya';

  @override
  String scanFoundRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hemos encontrado $count recetas para ti',
      one: 'Hemos encontrado 1 receta para ti',
    );
    return '$_temp0';
  }

  @override
  String get scanYourIngredients => 'Tus ingredientes';

  @override
  String scanFoundItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hemos encontrado $count productos en tu cocina',
      one: 'Hemos encontrado 1 producto en tu cocina',
    );
    return '$_temp0';
  }

  @override
  String get scanViewRecipe => 'Ver receta';

  @override
  String get importRecipePreview => 'Vista previa de la receta';

  @override
  String get importLinkUnavailable =>
      'Este enlace de receta no está disponible.';

  @override
  String get importInvalidLink =>
      'Introduce un enlace de receta válido (p. ej. https://ejemplo.com/receta)';

  @override
  String get importAlreadyExists => 'Esta receta ya está en tu colección';

  @override
  String get importExtractFailed =>
      'No pudimos extraer la receta de este enlace. La página no tenía suficiente información de la receta.';

  @override
  String get importSuccess => '¡Receta importada correctamente!';

  @override
  String get importManualSoon =>
      'La introducción manual de recetas llegará pronto';

  @override
  String get importRecipeLink => 'Enlace de la receta';

  @override
  String get importPasteHint => 'Pega un enlace de receta...';

  @override
  String get importImporting => 'Importando';

  @override
  String get importSearchWeb => 'Buscar en la web';

  @override
  String get importTrending => 'Tendencias';

  @override
  String get importRecent => 'Importaciones recientes';

  @override
  String get importNoRecent => 'Aún no hay importaciones recientes.';

  @override
  String get recipeEdit => 'Editar receta';

  @override
  String get importRecommended => 'Recomendado';

  @override
  String get importSuggestions => 'Sugerencias';

  @override
  String get importSearchRecipesHint => 'Buscar recetas...';

  @override
  String get importSearchResults => 'Resultados';

  @override
  String get commonClear => 'Borrar';

  @override
  String get importViewThisRecipe => 'Ver esta receta';

  @override
  String get importToCooked => 'Importar a Cooked';

  @override
  String get filterHighProtein => 'Alto en proteínas';

  @override
  String get filterUnder30Min => 'Menos de 30 min';

  @override
  String get filterBreakfast => 'Desayuno';

  @override
  String get filterLunch => 'Almuerzo';

  @override
  String get filterDinner => 'Cena';

  @override
  String get filterLowCalorie => 'Bajo en calorías';

  @override
  String get filterOnePot => 'En una olla';

  @override
  String get filterBudgetFriendly => 'Económico';

  @override
  String get filterVegetarian => 'Vegetariano';

  @override
  String get filterVegan => 'Vegano';

  @override
  String get filterNoCook => 'Sin cocción';

  @override
  String get filterDesserts => 'Postres';

  @override
  String get filterSnacks => 'Snacks';

  @override
  String get filterSmoothies => 'Batidos';

  @override
  String get filterSalads => 'Ensaladas';

  @override
  String get filterSoups => 'Sopas';

  @override
  String get filterPasta => 'Pasta';

  @override
  String get filterBowls => 'Bowls';

  @override
  String get filterSandwichesWraps => 'Sándwiches y wraps';

  @override
  String get filterChicken => 'Pollo';

  @override
  String get filterBeef => 'Ternera';

  @override
  String get filterSeafood => 'Marisco';

  @override
  String exploreNoFilterMatch(String filter) {
    return 'Aún no hay recetas de «$filter».';
  }

  @override
  String get exploreForYou => 'Para ti';

  @override
  String get explorePopularCategories => 'Categorías populares';

  @override
  String get exploreCategory => 'Categoría';

  @override
  String get exploreCuisines => 'Cocinas';

  @override
  String get explorePopularNow => 'Populares ahora';

  @override
  String get cookbookSelectRecipes => 'Seleccionar recetas';

  @override
  String get cookbookNameHint => 'Nombre del recetario';

  @override
  String get cookbookAddRecipesLower => 'Añadir recetas';

  @override
  String get cookbookSelectForThis => 'Selecciona recetas para este recetario';

  @override
  String get cookbookSelectedRecipes => 'Recetas seleccionadas';

  @override
  String get cookbookUpdated => '¡Recetario actualizado!';

  @override
  String get cookbookCreated => '¡Recetario creado!';

  @override
  String cookbookSaveFailed(String name, String error) {
    return 'No se pudo guardar «$name»: $error';
  }

  @override
  String cookbookNoMatch(String query) {
    return 'No hay recetas para «$query»';
  }

  @override
  String get cookbookExploreRecipes => 'Explorar recetas';

  @override
  String get payActivated => '¡Premium activado! Bienvenido al Chef Club.';

  @override
  String get paySpecialComeback => 'Oferta especial de regreso';

  @override
  String get payUnlockPremium => 'Desbloquear Premium';

  @override
  String get payUnlockToKeep =>
      'Desbloquea Cooked para seguir\ncreando recetas.';

  @override
  String get paySpecialOffer => 'Oferta especial';

  @override
  String get paySpecialOfferDesc =>
      'Desbloquea todas las funciones con este descuento limitado.';

  @override
  String get payUnlimitedAccess => 'Acceso ilimitado';

  @override
  String get payUnlimitedAccessDesc =>
      'Escanea tu nevera e importa recetas sin límites.';

  @override
  String get payExclusiveRecipes => 'Recetas exclusivas';

  @override
  String get payExclusiveRecipesDesc =>
      'Accede a recetas premium y recetarios temáticos.';

  @override
  String get payImmediateAccess => 'Acceso inmediato';

  @override
  String get payImmediateAccessDesc =>
      'Escanea tus ingredientes e importa recetas desde cualquier enlace.';

  @override
  String get payExclusiveContent => 'Contenido exclusivo';

  @override
  String get payExclusiveContentDesc =>
      'Accede a recetas generadas premium y recetarios temáticos.';

  @override
  String get payMasterChef => 'Estatus Master Chef';

  @override
  String get payMasterChefDesc =>
      'Disfruta de una experiencia sin anuncios con procesamiento de IA prioritario.';

  @override
  String get payPercentOff => '-33 %';

  @override
  String get payBestValue => 'MEJOR PRECIO';

  @override
  String get payImmediatePremium => 'Acceso Premium inmediato';

  @override
  String get paySubscribeNow => 'Suscribirse';

  @override
  String pricePerMonthLong(String price) {
    return '$price / mes';
  }

  @override
  String pricePerYearLong(String price) {
    return '$price / año';
  }

  @override
  String payDaysFree(String days) {
    return '$days días gratis';
  }

  @override
  String get payNoPaymentToday => 'hoy no pagas nada';

  @override
  String pricePerYearSentence(String price) {
    return '$price al año';
  }

  @override
  String get priceBilledYearly => 'facturación anual';

  @override
  String pricePerMonthSentence(String price) {
    return '$price al mes';
  }

  @override
  String get priceBilledMonthlyLower => 'facturación mensual';

  @override
  String get paySubscriptionsUnavailable =>
      'Las suscripciones no están disponibles ahora. Inténtalo más tarde.';

  @override
  String payPurchaseFailed(String error) {
    return 'La compra ha fallado: $error';
  }

  @override
  String payRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get tutImportTarget =>
      'Importa recetas de TikTok,\nInstagram o cualquier enlace';

  @override
  String get tutScanTarget => 'Escanea y obtén recetas al instante';

  @override
  String get tutCookbooksTarget => 'Guarda y organiza tus recetas aquí.';

  @override
  String get tutScanBestTitle => 'Para escanear mejor';

  @override
  String get tutScanSteady => 'Sujeta el teléfono firme';

  @override
  String get tutScanLighting => 'Usa buena iluminación';

  @override
  String get tutScanVisible =>
      'Asegúrate de que se vean todos los ingredientes';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get tutScanFindTitle => 'Encontramos tus ingredientes al instante';

  @override
  String get tutScanSnap => 'Haz una foto de tus ingredientes';

  @override
  String get tutScanDetect => 'Detectamos al instante lo que hay';

  @override
  String get tutScanEdit => 'Corrige lo que no esté bien';

  @override
  String get tutScanReadyTitle => 'Listo para escanear';

  @override
  String get tutScanFridge => 'Escanea tu nevera, despensa o ingredientes';

  @override
  String get tutScanAngles =>
      'Prueba distintos ángulos para mejores resultados';

  @override
  String get tutScanMoreVisible => 'Cuanto más se vea, mejores recetas';

  @override
  String get tutScanNow => 'Escanear ahora';

  @override
  String get tutImportTitle => 'Importa recetas desde cualquier sitio';

  @override
  String get tutImportPaste =>
      'Pega un enlace de TikTok, Instagram o cualquier web';

  @override
  String get tutImportShare =>
      'O comparte directamente desde tus redes para importar al instante';

  @override
  String get tutImportTurn =>
      'La convertimos automáticamente en una receta completa';

  @override
  String get tutImportSave => 'Guárdala en tu recetario';

  @override
  String get commonShare => 'Compartir';

  @override
  String get tutCookbookTitle1 => 'Tus recetas organizadas';

  @override
  String get tutCookbookItem1 => 'Explora todas las recetas de este recetario';

  @override
  String get tutCookbookItem2 => 'Navega rápido por categorías';

  @override
  String get tutCookbookItem3 => 'Accede a tus favoritos con un toque';

  @override
  String get tutCookbookTitle2 => 'Control total';

  @override
  String get tutCookbookItem4 => 'Edita tu recetario cuando quieras';

  @override
  String get tutCookbookItem5 => 'Añade recetas con el botón +';

  @override
  String get tutCookbookItem6 => 'Toca una receta para ver los detalles';

  @override
  String get tutExploreNow => 'Explorar ahora';

  @override
  String get tutIngredientsDetected => 'Ingredientes detectados';

  @override
  String get commonEdit => 'Editar';

  @override
  String cookbookAddedTo(String name) {
    return 'Añadida a $name';
  }

  @override
  String get cookbookAddedGeneric => 'Añadida al recetario';

  @override
  String get avatarChooseLibrary => 'Elegir de la galería';

  @override
  String get avatarTakePhoto => 'Hacer foto';

  @override
  String get avatarDeleting => 'Eliminando la foto...';

  @override
  String get avatarDeleted => 'Foto de perfil eliminada';

  @override
  String get avatarUpdating => 'Actualizando la foto...';

  @override
  String get avatarUpdated => '¡Foto de perfil actualizada!';

  @override
  String get clipRecipeDetected => 'Receta detectada';

  @override
  String get clipLinkFound => 'Enlace encontrado en el portapapeles';

  @override
  String get clipPaste => 'Pegar';

  @override
  String get fallbackTitle => 'Receta no encontrada';

  @override
  String get fallbackHeadline => 'No pudimos importar esta receta.';

  @override
  String get fallbackMessage =>
      'Este enlace no tenía suficiente información para que Cooked importara la receta correctamente.';

  @override
  String get fallbackFailedUrl => 'Enlace fallido';

  @override
  String get fallbackTryOther => 'Probar otro enlace';

  @override
  String get fallbackTryOtherDesc => 'Pega otro enlace de receta';

  @override
  String get fallbackManual => 'Añadir receta manualmente';

  @override
  String get fallbackManualDesc => 'Introduce tú los ingredientes y los pasos';

  @override
  String get groceryAlreadyTitle => 'Ya está en tu lista de la compra';

  @override
  String groceryAlreadyMessage(String name) {
    return '«$name» ya está en tu lista. ¿Añadirla otra vez? ';
  }

  @override
  String get groceryQuantitiesDoubled =>
      'Las cantidades de estos ingredientes se duplicarán.';

  @override
  String get groceryAddAgain => 'Añadir otra vez';

  @override
  String get groceryAddToList => 'Añadir a la lista de la compra';

  @override
  String get grocerySelectIngredients => 'Seleccionar ingredientes';

  @override
  String get grocerySaveLocation => 'Dónde guardar';

  @override
  String groceryDate(String date) {
    return 'Fecha: $date';
  }

  @override
  String get groceryGeneralList => 'Lista general';

  @override
  String get grocerySpecificDate => 'Fecha concreta';

  @override
  String get groceryAddSelected => 'Añadir ingredientes seleccionados';

  @override
  String get commonSaving => 'Guardando';

  @override
  String get recipeSavedInCookbook => 'Guardada en tu recetario';

  @override
  String headerGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get importGettingReady => 'Preparándola para Cooked';

  @override
  String get scanGeneratingRecipes => 'Generando recetas...';

  @override
  String get scanAnalyzingRecipe => 'Analizando la receta...';

  @override
  String get importStageReceiving => 'Recibiendo el enlace…';

  @override
  String get importStageFinding => 'Buscando la receta…';

  @override
  String get importStagePulling => 'Obteniendo ingredientes y pasos…';

  @override
  String get importStageReady => 'Receta lista';

  @override
  String get errRegistration => 'El registro ha fallado. Revisa tus datos.';

  @override
  String get authAccountExistsLoggedIn =>
      'Esta cuenta ya existe. Has iniciado sesión.';

  @override
  String get errInvalidCredentials => 'Credenciales no válidas';

  @override
  String get errInvalidCredentialsRetry =>
      'Credenciales no válidas, inténtalo de nuevo';

  @override
  String get errCodeExpired =>
      'Código de verificación no válido o caducado, inténtalo de nuevo';

  @override
  String get errResendCode =>
      'No se pudo reenviar el código. Inténtalo de nuevo.';

  @override
  String get errResetStart =>
      'No se pudo iniciar el restablecimiento de la contraseña.';

  @override
  String get errResetCodeExpired =>
      'Código de restablecimiento no válido o caducado, inténtalo de nuevo';

  @override
  String get errResetPassword =>
      'No se pudo restablecer la contraseña. Inténtalo de nuevo.';

  @override
  String get errDeleteAccount => 'No se pudo eliminar la cuenta.';

  @override
  String get errUnexpected => 'Se ha producido un error inesperado.';

  @override
  String errAi(String msg) {
    return '🤖 Error de IA: $msg';
  }

  @override
  String errServer(String msg) {
    return '⚙️ Error del servidor: $msg';
  }

  @override
  String errInput(String msg) {
    return '📝 Error de datos: $msg';
  }

  @override
  String errAuth(String msg) {
    return '🔒 Error de autenticación: $msg';
  }

  @override
  String get errPremiumRequired =>
      'Se requiere acceso Premium. Revisa tu suscripción.';

  @override
  String get errNotFound => 'No se encontró el elemento solicitado.';

  @override
  String get errSessionExpired =>
      'Sesión caducada o no válida. Vuelve a iniciar sesión.';

  @override
  String get errNoInternet =>
      'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errAccountExists => 'Esta cuenta ya existe. Inicia sesión.';

  @override
  String get errItemExists => 'Este elemento ya existe.';

  @override
  String get errInvalidCode =>
      'Código de verificación no válido. Inténtalo de nuevo.';

  @override
  String get errAccountNotFound => 'Cuenta no encontrada. Regístrate primero.';

  @override
  String get errServersBusy =>
      'Nuestros servidores están ocupados. Inténtalo en un momento.';

  @override
  String get errExtractFailed =>
      'No se pudo extraer la receta de este enlace. Revisa la URL o prueba con otra.';

  @override
  String get errSiteBlocking =>
      'El sitio bloquea el acceso. Prueba con otra fuente.';

  @override
  String get errGeneric => 'Algo salió mal. Inténtalo más tarde.';

  @override
  String get notifChannelShopping => 'Recordatorios de compra';

  @override
  String get notifChannelShoppingDesc => 'Recordatorios para ir a la compra';

  @override
  String get notifGroceryTitle => 'Compras';

  @override
  String get notifGroceryBody => '¡No olvides hacer la compra!';

  @override
  String get notifChannelPushDesc => 'Notificaciones del equipo de Cooked';

  @override
  String get errPurchaseNotActive =>
      'Compra realizada pero la suscripción no está activa';

  @override
  String get errPurchase => 'Se produjo un error en la compra';

  @override
  String get errIngredientDetection =>
      'La detección de ingredientes ha fallado. Inténtalo de nuevo.';

  @override
  String get errScan => 'El escaneo ha fallado. Inténtalo de nuevo.';

  @override
  String get errValidation => 'La validación ha fallado. Inténtalo de nuevo.';

  @override
  String get errGeneration => 'La generación ha fallado. Inténtalo de nuevo.';

  @override
  String get errGenerateRecipes =>
      'No se pudieron generar recetas. Inténtalo de nuevo.';

  @override
  String savingsCopyName(String name) {
    return '(Copia) $name';
  }

  @override
  String get errImport => 'La importación ha fallado';

  @override
  String get errWebSearch => 'La búsqueda web ha fallado';

  @override
  String get errPayment => 'El pago ha fallado';

  @override
  String get errVerification => 'La verificación ha fallado';

  @override
  String get errLoadProfile => 'No se pudo cargar el perfil.';

  @override
  String get errUpdateProfile => 'No se pudo actualizar el perfil.';

  @override
  String get errSavePreferences => 'No se pudieron guardar tus preferencias.';

  @override
  String get errChangePassword => 'No se pudo cambiar la contraseña.';

  @override
  String get errNotifSettings =>
      'No se pudieron actualizar las notificaciones.';

  @override
  String get errUploadPhoto => 'No se pudo subir la foto de perfil.';

  @override
  String get termsIntro =>
      'Antes de continuar con el inicio de sesión social, revisa y acepta nuestras condiciones para proteger tus datos.';

  @override
  String get termsAgreeA => 'He leído y acepto los ';

  @override
  String get termsAnd => ' y la ';

  @override
  String get termsConfirm => 'Confirmar y continuar';

  @override
  String get fallbackExtractTitle =>
      'No pudimos extraer una receta de este enlace.';

  @override
  String get fallbackExtractHint => 'Revisa la URL o prueba con otra.';

  @override
  String get fallbackLinkCopied => 'Enlace copiado';

  @override
  String get fallbackCopyLink => 'Copiar enlace';

  @override
  String get splashTagline => 'La cena empieza con lo que ya tienes.';
}
