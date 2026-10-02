// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Cooked';

  @override
  String get groceryInlineAddHint => 'ex. Ail - 2, 2 Ail ou Ail 2';

  @override
  String get groceryAddIngredientPlaceholder => 'Ajouter un ingrédient...';

  @override
  String get groceryQuantityFormatError =>
      'Ajoutez la quantité au format suivant, par ex. : ail - 2, 2 ail ou ail 2.';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get groceryAddItemOrRecipe =>
      'Ajoutez un article ou choisissez une recette';

  @override
  String get groceryIngredientHint => 'Fromage';

  @override
  String get commonIngredient => 'Ingrédient';

  @override
  String get groceryChooseRecipe => 'Choisir une recette';

  @override
  String get commonNoRecipesFound => 'Aucune recette trouvée';

  @override
  String get commonRecipe => 'Recette';

  @override
  String get groceryAddSheetTitle => 'Ajouter aux courses';

  @override
  String get groceryItemsSaved =>
      'Articles enregistrés dans la liste de courses';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String groceryDeleteItemMessage(String name) {
    return 'Voulez-vous vraiment supprimer « $name » de votre liste de courses ?';
  }

  @override
  String get groceryDeleteItemTitle => 'Supprimer l\'article';

  @override
  String get commonDismiss => 'Fermer';

  @override
  String get groceryAddIngredients => 'Ajouter des ingrédients';

  @override
  String get groceryEmptySubtitle =>
      'Ajoutez des ingrédients depuis une recette ou un import pour commencer.';

  @override
  String get groceryEmptyTitle => 'Votre liste de courses est vide';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get groceryListTitle => 'Liste de courses';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get commonCheckConnection => 'Vérifiez votre connexion et réessayez.';

  @override
  String get groceryLoadErrorTitle =>
      'Impossible de charger votre liste de courses';

  @override
  String get authMissingIdentifier =>
      'Informations de connexion manquantes. Veuillez réessayer.';

  @override
  String get authVerifying => 'Vérification';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get authResendCode => 'Renvoyer le code';

  @override
  String get authResending => 'Renvoi';

  @override
  String get authDidntReceiveCode => 'Vous n\'avez pas reçu de code ? ';

  @override
  String authCodeSentTo(String target) {
    return 'Saisissez le code que nous venons d\'envoyer à\n$target';
  }

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authCodeResent => 'Code de vérification renvoyé.';

  @override
  String get authEnterFullCode =>
      'Veuillez saisir le code complet à 6 chiffres.';

  @override
  String get commonEmail => 'E-mail';

  @override
  String get commonSending => 'Envoi';

  @override
  String get commonSend => 'Envoyer';

  @override
  String get commonPhoneNumber => 'Numéro de téléphone';

  @override
  String get authEnterPhoneForCode =>
      'Saisissez votre numéro de téléphone,\nnous vous enverrons un code\nde vérification par SMS';

  @override
  String get authEnterEmailForCode =>
      'Saisissez votre e-mail, nous vous enverrons\nun code de vérification';

  @override
  String get authSendToPhone => 'Envoyer sur votre téléphone';

  @override
  String get authSendToEmail => 'Envoyer sur votre e-mail';

  @override
  String get authSelectContactMethod =>
      'Choisissez les coordonnées à utiliser\npour réinitialiser votre mot de passe';

  @override
  String get authCodeSent => 'Code envoyé !';

  @override
  String get commonFieldRequired => 'Ce champ est requis';

  @override
  String get commonGetStarted => 'Commencer';

  @override
  String get authPasswordChangedMessage =>
      'Votre mot de passe a bien été modifié,\nvous pouvez vous reconnecter.';

  @override
  String get authPasswordChanged => 'Mot de passe modifié !';

  @override
  String get commonCongratulations => 'Félicitations !';

  @override
  String get commonTermsOfUse => 'Conditions d\'utilisation';

  @override
  String get commonPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get authSignInWithApple => 'Se connecter avec Apple';

  @override
  String get authSignInWithGoogle => 'Se connecter avec Google';

  @override
  String get commonSignUp => 'S\'inscrire';

  @override
  String get authNoAccount => 'Pas encore de compte ? ';

  @override
  String get authLoggingIn => 'Connexion';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get authForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get commonPassword => 'Mot de passe';

  @override
  String get authSignInSubtitle => 'Connectez-vous à votre compte';

  @override
  String get commonSignIn => 'Se connecter';

  @override
  String get authSocialLoginSuccess => 'Connexion réussie !';

  @override
  String get authLoginSuccess => 'Connexion réussie !';

  @override
  String get authVerificationCodeLabel => 'CODE DE VÉRIFICATION';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonUpdating => 'Mise à jour';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authNewPassword => 'Nouveau mot de passe';

  @override
  String get authCreateNewPassword => 'Créer un nouveau mot de passe';

  @override
  String get authResetSuccess => 'Réinitialisation réussie !';

  @override
  String get authPasswordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authPasswordMinLength => 'Minimum 6 caractères';

  @override
  String get authAccountCreatedMessage =>
      'Votre compte est prêt, profitez\nde nos meilleures recettes.';

  @override
  String get authAccountCreated => 'Compte créé !';

  @override
  String get welcomeHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get welcomeSubtitle =>
      'Scannez vos ingrédients. Enregistrez vos recettes.\nPlanifiez sans effort.';

  @override
  String get welcomeTitle => 'Bienvenue sur Cooked';

  @override
  String get authEmailOrPhoneFallback => 'e-mail/numéro de téléphone';

  @override
  String get authYourEmailFallback => 'votre e-mail';

  @override
  String get themeDarkOn => 'Activé';

  @override
  String get themeDarkOff => 'Désactivé';

  @override
  String get themeSystemSettings => 'Réglages du système';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeMatchPhone => 'Suivre le réglage du téléphone';

  @override
  String get themeAlwaysDark => 'Toujours utiliser le thème sombre';

  @override
  String get themeAlwaysLight => 'Toujours utiliser le thème clair';

  @override
  String get themeSystemHint =>
      'Avec « Réglages du système », l\'apparence de l\'app suit automatiquement celle de votre appareil.';

  @override
  String get notifSecurityNote =>
      'Les alertes de compte et de sécurité (nouvelle connexion, problème de paiement…) sont toujours envoyées tant que les notifications push sont activées.';

  @override
  String profileInviteMessage(String link) {
    return 'Essaie Cooked ! L\'app transforme le contenu de ton frigo en recettes en quelques secondes et te fait économiser sur les plats à emporter. Rejoins-nous ici : $link';
  }

  @override
  String get appearanceTitle => 'Apparence';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get langSuggestRow => 'Suggérer une langue…';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get langUpdateFailed => 'Impossible de changer la langue';

  @override
  String get langSuggestionFailed =>
      'Impossible d\'envoyer votre suggestion. Veuillez réessayer.';

  @override
  String get langSuggestionThanks =>
      'Merci ! Nous avons bien reçu votre suggestion.';

  @override
  String get langSendSuggestion => 'Envoyer la suggestion';

  @override
  String get langSuggestHint => 'ex. italien, wolof, portugais…';

  @override
  String get langSuggestMessage =>
      'Dans quelle langue aimeriez-vous utiliser Cooked ? Vos suggestions nous aident à choisir les prochaines.';

  @override
  String get langSuggestTitle => 'Suggérer une langue';

  @override
  String get commonSaveChanges => 'Enregistrer';

  @override
  String get commonName => 'Nom';

  @override
  String get accountChangePicture => 'Changer la photo';

  @override
  String get accountDefaultName => 'Chef';

  @override
  String get settingsMyAccount => 'Mon compte';

  @override
  String get accountProfileUpdated => 'Profil mis à jour !';

  @override
  String get notifNewsSubtitle => 'Nouveautés, recettes et offres spéciales';

  @override
  String get notifNews => 'Actualités, astuces et offres';

  @override
  String get notifRemindersSubtitle => 'Fin d\'essai et rappels d\'abonnement';

  @override
  String get notifReminders => 'Rappels';

  @override
  String get notifPushSubtitle => 'Recevoir des notifications sur cet appareil';

  @override
  String get notifPush => 'Notifications push';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDeletePermanently => 'Supprimer définitivement';

  @override
  String get settingsDeleteAccountConfirm =>
      'Voulez-vous vraiment supprimer définitivement votre compte ? Cette action est irréversible et toutes vos données seront perdues (livres de recettes, liste de courses, etc.).';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutConfirm =>
      'Voulez-vous vraiment vous déconnecter ? Vous devrez saisir vos identifiants pour vous reconnecter.';

  @override
  String get settingsContactSupport => 'Contacter le support';

  @override
  String get settingsGiftCooked => 'Offrir Cooked à un ami';

  @override
  String get settingsInviteFriends => 'Inviter des amis';

  @override
  String get settingsManageSubscription =>
      'Gérer l\'abonnement et restaurer les achats';

  @override
  String get settingsKitchenEquipment => 'Équipement de cuisine';

  @override
  String get settingsCuisineFlavor => 'Cuisines et saveurs';

  @override
  String get settingsAllergies => 'Allergies';

  @override
  String get settingsDietaryPreferences => 'Préférences alimentaires';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get pwdCurrentPassword => 'Mot de passe actuel';

  @override
  String get pwdUpdated => 'Mot de passe mis à jour.';

  @override
  String get pwdNoMatch => 'Les nouveaux mots de passe ne correspondent pas.';

  @override
  String get pwdFillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get optTotalBeginner => 'Débutant total';

  @override
  String get optICanBarelyBoilWater =>
      'Je sais à peine faire bouillir de l\'eau';

  @override
  String get optHomeCook => 'Cuisinier amateur';

  @override
  String get optIFollowRecipesStepByStep => 'Je suis les recettes pas à pas';

  @override
  String get optConfidentCook => 'Cuisinier confirmé';

  @override
  String get optIImproviseAndExperiment => 'J\'improvise et j\'expérimente';

  @override
  String get optAdvancedSemiPro => 'Avancé / Semi-pro';

  @override
  String get optIWantChallengingRecipes => 'Je veux des recettes ambitieuses.';

  @override
  String get optUnder15Minutes => 'Moins de 15 minutes';

  @override
  String get optUltraFastMeals => 'Repas ultra-rapides';

  @override
  String get optForWhenYouNeedFoodInstantly =>
      'Pour quand vous avez faim tout de suite.';

  @override
  String get opt_1530Minutes => '15–30 minutes';

  @override
  String get optQuickButNotRushed => 'Rapide sans se presser';

  @override
  String get optPerfectForQuickWeekdayMeals =>
      'Parfait pour les repas rapides en semaine.';

  @override
  String get opt_3060Minutes => '30–60 minutes';

  @override
  String get optANormalCookingWindow => 'Un temps de cuisine normal';

  @override
  String get optGreatForRelaxedDinners => 'Idéal pour des dîners tranquilles.';

  @override
  String get opt_12Hours => '1–2 heures';

  @override
  String get optIEnjoyTheCookingProcess =>
      'J\'aime prendre le temps de cuisiner';

  @override
  String get optForWeekendCookingSessions =>
      'Pour les sessions cuisine du week-end.';

  @override
  String get optAnyAmountOfTime => 'Peu importe le temps';

  @override
  String get optShowMeEverything => 'Montrez-moi tout';

  @override
  String get optAllRecipesAreOnTheTable =>
      'Toutes les recettes sont possibles.';

  @override
  String get optWeeklyMealPlan => 'Menu de la semaine';

  @override
  String get optGetAFullPlanEveryWeek => 'Un menu complet chaque semaine';

  @override
  String get optDailySuggestions => 'Suggestions quotidiennes';

  @override
  String get optOneRecipeEachMorning => 'Une recette chaque matin';

  @override
  String get optILlPlanMyself => 'Je planifie moi-même';

  @override
  String get optJustShowMeRecipes => 'Montrez-moi juste des recettes';

  @override
  String get optPlanByIngredients => 'Planifier selon mes ingrédients';

  @override
  String get optScanMyFridgeGiveMeA =>
      'Scannez mon frigo, proposez-moi un menu';

  @override
  String get optJustMe => 'Juste moi';

  @override
  String get opt_1Person => '1 personne';

  @override
  String get optTwoPeople => 'Deux personnes';

  @override
  String get optCoupleOrPair => 'En couple ou à deux';

  @override
  String get opt_34People => '3–4 personnes';

  @override
  String get optSmallFamily => 'Petite famille';

  @override
  String get opt_56People => '5–6 personnes';

  @override
  String get optLargerFamily => 'Famille nombreuse';

  @override
  String get opt_7PlusPeople => '7 personnes et plus';

  @override
  String get optLargeFamilyOrGroup => 'Grande famille ou groupe';

  @override
  String get optItVaries => 'Ça dépend';

  @override
  String get optILlAdjustPerRecipe => 'J\'ajuste selon la recette';

  @override
  String get optSaveMoney => 'Économiser';

  @override
  String get optEatHealthier => 'Manger plus sainement';

  @override
  String get optGainMuscle => 'Prendre du muscle';

  @override
  String get optLoseWeight => 'Perdre du poids';

  @override
  String get optWasteLessFood => 'Moins gaspiller';

  @override
  String get optLearnToCook => 'Apprendre à cuisiner';

  @override
  String get optDiscoverRecipes => 'Découvrir des recettes';

  @override
  String get optMealPrepEasier => 'Préparer ses repas plus facilement';

  @override
  String get optNoRestrictions => 'Aucune restriction';

  @override
  String get optIEatEverything => 'Je mange de tout';

  @override
  String get optVegetarian => 'Végétarien';

  @override
  String get optNoMeatOrFish => 'Ni viande ni poisson';

  @override
  String get optVegan => 'Végan';

  @override
  String get optNoAnimalProducts => 'Aucun produit animal';

  @override
  String get optPescatarian => 'Pescétarien';

  @override
  String get optFishOkNoOtherMeat => 'Poisson oui, pas d\'autre viande';

  @override
  String get optGlutenFree => 'Sans gluten';

  @override
  String get optNoWheatOrGluten => 'Ni blé ni gluten';

  @override
  String get optDairyFree => 'Sans lactose';

  @override
  String get optNoMilkOrDairy => 'Ni lait ni produits laitiers';

  @override
  String get optHalal => 'Halal';

  @override
  String get optIslamicDietaryLaws => 'Règles alimentaires islamiques';

  @override
  String get optKosher => 'Casher';

  @override
  String get optJewishDietaryLaws => 'Règles alimentaires juives';

  @override
  String get optKetoLowCarb => 'Céto / pauvre en glucides';

  @override
  String get optHighFatLowCarb => 'Riche en graisses, pauvre en glucides';

  @override
  String get optHighProtein => 'Riche en protéines';

  @override
  String get optHighProteinFoods => 'Aliments riches en protéines';

  @override
  String get optTreeNuts => 'Fruits à coque';

  @override
  String get optPeanuts => 'Arachides';

  @override
  String get optShellfish => 'Fruits de mer';

  @override
  String get optFish => 'Poisson';

  @override
  String get optEggs => 'Œufs';

  @override
  String get optSoy => 'Soja';

  @override
  String get optDairyMilk => 'Lait';

  @override
  String get optWheatGluten => 'Blé / gluten';

  @override
  String get optSesame => 'Sésame';

  @override
  String get optNoAllergies => 'Aucune allergie';

  @override
  String get optItalian => 'Italienne';

  @override
  String get optJapanese => 'Japonaise';

  @override
  String get optMexican => 'Mexicaine';

  @override
  String get optChinese => 'Chinoise';

  @override
  String get optThai => 'Thaïlandaise';

  @override
  String get optMiddleEastern => 'Moyen-orientale';

  @override
  String get optWestAfrican => 'Ouest-africaine';

  @override
  String get optEastAfrican => 'Est-africaine';

  @override
  String get optCaribbean => 'Caribéenne';

  @override
  String get optIndian => 'Indienne';

  @override
  String get optSpanish => 'Espagnole';

  @override
  String get optGreek => 'Grecque';

  @override
  String get optFrench => 'Française';

  @override
  String get optKorean => 'Coréenne';

  @override
  String get optMediterranean => 'Méditerranéenne';

  @override
  String get optOthers => 'Autres';

  @override
  String get optOven => 'Four';

  @override
  String get optStovetopGasBurner => 'Plaques / gazinière';

  @override
  String get optMicrowave => 'Micro-ondes';

  @override
  String get optAirFryer => 'Friteuse à air';

  @override
  String get optBlenderLiquidizer => 'Blender / mixeur';

  @override
  String get optFoodProcessor => 'Robot culinaire';

  @override
  String get optInstantPotPressureCooker => 'Instant Pot / autocuiseur';

  @override
  String get optGrillBbq => 'Grill / barbecue';

  @override
  String get optRiceCooker => 'Cuiseur à riz';

  @override
  String get optStandMixerHandMixer => 'Robot pâtissier / batteur';

  @override
  String get optSteamer => 'Cuit-vapeur';

  @override
  String get optOther => 'Autre';

  @override
  String get optScanIngredients => 'Scanner des ingrédients';

  @override
  String get optTakeAPhotoAndGetRecipes =>
      'Prenez une photo et obtenez des recettes avec ce que vous avez déjà.';

  @override
  String get optMealPlanning => 'Planification des repas';

  @override
  String get optPlanYourMealsForTheWeek =>
      'Planifiez vos repas de la semaine sans partir de zéro.';

  @override
  String get optImportRecipes => 'Importer des recettes';

  @override
  String get optSaveRecipesFromTiktokInstagramYoutube =>
      'Enregistrez des recettes depuis TikTok, Instagram, YouTube ou des sites web.';

  @override
  String get optGroceryLists => 'Listes de courses';

  @override
  String get optTurnRecipesIntoShoppingListsAutomatically =>
      'Transformez automatiquement vos recettes en listes de courses.';

  @override
  String get optDailyRecipeInspiration => 'Inspiration recette du jour';

  @override
  String get optMorningSuggestion => 'Suggestion du matin';

  @override
  String get optGroceryReminder => 'Rappel de courses';

  @override
  String get optRememberWhatToBuyBeforeIngredients =>
      'Pensez à racheter vos ingrédients avant d\'en manquer.';

  @override
  String get optMild => 'Doux';

  @override
  String get optNoHeatAtAll => 'Pas du tout piquant';

  @override
  String get optMedium => 'Moyen';

  @override
  String get optJustAHintOfSpice => 'Juste une pointe de piquant';

  @override
  String get optSpicy => 'Épicé';

  @override
  String get optIEnjoySpice => 'J\'aime le piquant';

  @override
  String get optHot => 'Très épicé';

  @override
  String get optTheSpicierTheBetter => 'Plus c\'est piquant, mieux c\'est';

  @override
  String get optInferno => 'Brûlant';

  @override
  String get optIPutHotSauce => 'Je mets de la sauce piquante partout';

  @override
  String get optUnder18 => 'Moins de 18 ans';

  @override
  String get optUnder50 => 'Moins de 50 \$';

  @override
  String get optIDonTKnowWhatTo => 'Je ne sais pas quoi cuisiner';

  @override
  String get optCookingTakesTooMuchTime => 'Cuisiner prend trop de temps';

  @override
  String get optISpendTooMuchOnTakeout => 'Je dépense trop en plats à emporter';

  @override
  String get optHealthyEatingFeelsDifficult =>
      'Manger sainement me paraît difficile';

  @override
  String get optGroceryShoppingIsStressful => 'Faire les courses est stressant';

  @override
  String get optAlmostNever => 'Presque jamais';

  @override
  String get optSometimes => 'Parfois';

  @override
  String get optWeekly => 'Chaque semaine';

  @override
  String get optConstantly => 'Constamment';

  @override
  String get optAnchovies => 'Anchois';

  @override
  String get optBlackLicorice => 'Réglisse';

  @override
  String get optBrusselsSprouts => 'Choux de Bruxelles';

  @override
  String get optBlueCheese => 'Fromage bleu';

  @override
  String get optOysters => 'Huîtres';

  @override
  String get optSardines => 'Sardines';

  @override
  String get optOlives => 'Olives';

  @override
  String get optBeets => 'Betteraves';

  @override
  String get optCottageCheese => 'Cottage cheese';

  @override
  String get optOkra => 'Gombo';

  @override
  String get optSpam => 'Spam';

  @override
  String get optTofu => 'Tofu';

  @override
  String get optTurnips => 'Navets';

  @override
  String get optKimchi => 'Kimchi';

  @override
  String get optEggplant => 'Aubergine';

  @override
  String get optCauliflower => 'Chou-fleur';

  @override
  String get optCilantro => 'Coriandre';

  @override
  String get optLimaBeans => 'Haricots de Lima';

  @override
  String get optPickledHerring => 'Hareng mariné';

  @override
  String get optSauerkraut => 'Choucroute';

  @override
  String get optGoatCheese => 'Fromage de chèvre';

  @override
  String get optBitterMelon => 'Melon amer';

  @override
  String get optMushrooms => 'Champignons';

  @override
  String get optGrapefruit => 'Pamplemousse';

  @override
  String get opt_23TimesAWeek => '2–3 fois par semaine';

  @override
  String get optMetric => 'Métrique';

  @override
  String get optImperial => 'Impérial';

  @override
  String get optLiver => 'Foie';

  @override
  String get onbBestGuess => 'Donnez une estimation. On s\'occupe du calcul';

  @override
  String get onbEatingOutTitle =>
      'Combien dépensez-vous au restaurant chaque semaine ?';

  @override
  String get onbThatCouldBeOver => 'Cela pourrait dépasser';

  @override
  String get onbPotentialYearlySavings => 'Économies annuelles potentielles';

  @override
  String get onbThanHome => 'Que de cuisiner chez soi';

  @override
  String get onbNearlyB => ' plus cher';

  @override
  String get onbNearlyA => 'C\'est presque ';

  @override
  String get onbMadeAtHome => 'Cuisiné à la maison';

  @override
  String get onbHomeCooked => 'Fait maison';

  @override
  String get onbThreeMealsWeek => '3 repas / semaine';

  @override
  String get onbTakeout => 'Plats à emporter';

  @override
  String get onbCostingSubtitle =>
      'Les petites décisions deviennent\ndes habitudes coûteuses';

  @override
  String get onbCostingTitleD => 'temps';

  @override
  String get onbCostingTitleC => 'plus que du ';

  @override
  String get onbCostingTitleB => 'coûte\n';

  @override
  String get onbCostingTitleA => 'Et ça vous ';

  @override
  String get onbDinnerSubtitle => 'Sans stress. Sans prise de tête';

  @override
  String get onbDinnerTitleB => 'tout trouvé';

  @override
  String get onbDinnerTitleA => 'Imaginez le dîner\ndéjà ';

  @override
  String get onbViewOtherPlans => 'Voir les autres formules';

  @override
  String get onbTrialReminder =>
      'Nous vous enverrons un rappel avant la fin de votre essai.';

  @override
  String get onbTrialDay3 => 'Jour 3';

  @override
  String get onbTrialDay2 => 'Jour 2';

  @override
  String get onbTrialGuideToday =>
      'Débloquez les recettes personnalisées, les suggestions de repas et le scan d\'ingrédients.';

  @override
  String get commonToday => 'Aujourd\'hui';

  @override
  String get onbTrialGuideSubtitle =>
      'Profitez au maximum de votre essai Cooked.';

  @override
  String get onbTrialGuideTitle => 'Votre essai gratuit';

  @override
  String get onbTryForZero => 'Commencer l’essai gratuit de 3 jours';

  @override
  String get onbKeepEverything =>
      'Créez votre compte pour garder vos recettes, menus, listes de courses et votre suivi d\'économies.';

  @override
  String get onbTryFreeB => 'gratuitement';

  @override
  String get onbTryFreeA => 'Essayez\nCooked ';

  @override
  String get onbBenefitGrocery =>
      'Des listes de courses intelligentes qui vous font économiser';

  @override
  String get onbBenefitPlans => 'Menus personnalisés';

  @override
  String get onbBenefitRecipes =>
      'Accès complet à plus de 10 000 recettes sélectionnées par des chefs';

  @override
  String get onbGroceriesUnusedTitle =>
      'À quelle fréquence vos courses finissent-elles inutilisées ?';

  @override
  String get onbOver => 'plus de ';

  @override
  String get onbHouseholdWastes => 'Un foyer moyen gaspille';

  @override
  String get onbHandlesSubtitle => 'On planifie. Vous cuisinez.';

  @override
  String get onbHandlesTitleB => 'repas';

  @override
  String get onbHandlesTitleA => 'Cooked s\'occupe\nde tous vos ';

  @override
  String get onbHealthySubtitle =>
      'Des recettes que vous aurez vraiment\nenvie de manger.';

  @override
  String get onbHealthyTitleD => 'second travail';

  @override
  String get onbHealthyTitleC => ' à un\n';

  @override
  String get onbHealthyTitleB => 'ressembler';

  @override
  String get onbHealthyTitleA => 'Manger sainement\nne devrait pas ';

  @override
  String get onbMealsSubtitle =>
      'Le dîner ne devrait pas être la décision\nla plus difficile de votre journée';

  @override
  String get onbMealsTitleD => '';

  @override
  String get onbMealsTitleC => 'cuisiner';

  @override
  String get onbMealsTitleB => 'quoi\n';

  @override
  String get onbMealsTitleA => 'Ne vous demandez plus ';

  @override
  String onbBuildingSystem(String dots) {
    return 'Création de votre\nsystème culinaire\npersonnalisé$dots';
  }

  @override
  String get onbTaskPersonalizing => 'Personnalisation des recommandations';

  @override
  String get onbTaskFeed => 'Création de votre fil de repas';

  @override
  String get onbTaskSavings => 'Calcul des économies';

  @override
  String get onbTaskFindRecipes => 'Recherche de recettes qui vous plairont';

  @override
  String get onbTaskTastes => 'Découverte de vos goûts';

  @override
  String get onbRepetitionSubtitle => 'Pensé pour vos goûts.';

  @override
  String get onbRepetitionTitle =>
      'Marre de manger\nla même chose chaque\nsemaine ?';

  @override
  String get onbOfYourLife => 'de votre vie\nchaque année';

  @override
  String get onbDays => 'Jours';

  @override
  String get onbSpentDeciding => 'Passées à choisir\nquoi manger';

  @override
  String get onbHours => 'Heures';

  @override
  String get onbNotAloneSubtitle =>
      'La plupart des gens passent plus de 200 heures\npar an à décider quoi manger';

  @override
  String get onbNotAloneB => 'pas seul';

  @override
  String get onbNotAloneA => 'Vous n\'êtes ';

  @override
  String get onbSkillSubtitle =>
      'Nous adapterons les recettes à votre expérience.';

  @override
  String get onbSkillTitle => 'Quel est votre niveau\nen cuisine ?';

  @override
  String get onbAvoidB => '.';

  @override
  String get onbAvoidA => 'Parfait, nous éviterons les recettes ';

  @override
  String get onbAvoidComplex => 'complexes';

  @override
  String get onbAvoidBasic => 'trop simples';

  @override
  String get onbAvoidBoring => 'ennuyeuses';

  @override
  String get onbAvoidUntested => 'non testées';

  @override
  String get onbAvoidOverlyComplex => 'trop complexes';

  @override
  String get onbReview3 =>
      '« Les idées de repas sont personnalisées,\npas aléatoires. »';

  @override
  String get onbReview2 => '« J\'utilise enfin les courses\nque j\'ai déjà. »';

  @override
  String get onbReview1 =>
      '« Grâce à Cooked, j\'ai arrêté\nde commander à dîner tous les soirs. »';

  @override
  String get onbStarsFromThousands =>
      'Étoiles de milliers\nde passionnés de cuisine';

  @override
  String get onbUnlock => 'Débloquer';

  @override
  String get onbBadgeHealthier => 'Des repas plus sains,\nfacilement';

  @override
  String get onbBadgeRecipes => '1 847 recettes\nadaptées';

  @override
  String get onbBadgeSaveHours => 'Gagnez 180+ heures/\nan';

  @override
  String get onbBadgeSaveMoney => 'Économisez 2 496 \$/\nan';

  @override
  String get onbRecipesCurated => 'recettes choisies pour vos goûts';

  @override
  String get onbPlanReadySubtitle =>
      'Pensé pour vos objectifs, vos goûts,\nvotre emploi du temps et vos économies';

  @override
  String get onbPlanReady => 'Votre programme\npersonnalisé est prêt.';

  @override
  String get onbStartArrow => 'Commencer →';

  @override
  String get onbBuildProfileSubtitle =>
      'Plus nous en apprenons, meilleures sont vos recommandations';

  @override
  String get onbBuildProfileB => 'culinaire';

  @override
  String get onbBuildProfileA => 'Créons votre\nprofil ';

  @override
  String get onbTaskCuisines => 'Découverte de vos cuisines préférées';

  @override
  String get onbTaskDietary => 'Analyse de vos préférences alimentaires';

  @override
  String get onbTaskPotentialSavings => 'Calcul de vos économies potentielles';

  @override
  String get onbTaskChallenges => 'Analyse de vos difficultés en cuisine';

  @override
  String get onbCookingSmarter => 'Simplement en cuisinant plus malin';

  @override
  String get onbEveryYear => 'Chaque année';

  @override
  String get onbCouldSave => 'Vous pourriez économiser\nenviron';

  @override
  String get optSweet => 'Sucré';

  @override
  String get optSavory => 'Salé';

  @override
  String get optCrunchyTextures => 'Textures croquantes';

  @override
  String get optSoftCreamy => 'Doux et crémeux';

  @override
  String get flavorLeaningSweet => 'Plutôt sucré';

  @override
  String get flavorLeaningSavory => 'Plutôt salé';

  @override
  String get flavorLeaningBalanced => 'Plutôt équilibré';

  @override
  String get flavorTextureCrunchy => 'Texture croquante';

  @override
  String get flavorTextureCreamy => 'Texture crémeuse';

  @override
  String get flavorTextureBalanced => 'Texture équilibrée';

  @override
  String get onbCreateAccount => 'Créer mon compte';

  @override
  String get onbEmailHint => 'jean@exemple.com';

  @override
  String get onbNameHint => 'Jean Dupont';

  @override
  String get commonFullName => 'Nom complet';

  @override
  String get onbCreateAccountSubtitle =>
      'Sécurisez vos recettes et vos préférences';

  @override
  String get onbCreateAccountTitle => 'Créez votre compte';

  @override
  String get valPasswordMin =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get valEnterPassword => 'Veuillez saisir un mot de passe';

  @override
  String get valValidEmail => 'Veuillez saisir une adresse e-mail valide';

  @override
  String get valEnterEmail => 'Veuillez saisir votre e-mail';

  @override
  String get valEnterName => 'Veuillez saisir votre nom';

  @override
  String get onbAgeSubtitle =>
      'Cela nous aide à personnaliser vos recommandations';

  @override
  String get onbAgeTitle => 'Quel âge avez-vous ?';

  @override
  String get onbAllergiesSubtitle =>
      'Nous filtrerons automatiquement les recettes pour vous';

  @override
  String get onbAllergiesTitle =>
      'Avez-vous des\nrestrictions alimentaires\nou des allergies ?';

  @override
  String get onbMoreDietLater =>
      'Vous pourrez modifier vos autres préférences alimentaires plus tard dans les Paramètres.';

  @override
  String get onbCommonAllergies => 'Allergies courantes';

  @override
  String get onbTypeCuisine => 'Saisissez une cuisine…';

  @override
  String get onbSpecifyCuisines => 'Précisez d\'autres cuisines';

  @override
  String get onbCuisinesSubtitle =>
      'Choisissez vos préférées. Plus vous en choisissez,\nmeilleures sont vos recommandations';

  @override
  String get onbCuisinesTitle => 'Quelles cuisines\naimez-vous ?';

  @override
  String get onbSelectOneCuisine => 'Veuillez choisir au moins une cuisine';

  @override
  String get commonSelectAllThatApply =>
      'Sélectionnez tout ce qui s\'applique.';

  @override
  String get onbDietTitle => 'Quel est votre profil alimentaire ?';

  @override
  String get onbMorePrefsLater =>
      'Vous pourrez modifier d\'autres préférences plus tard dans les Paramètres.';

  @override
  String get onbDislikeHint => 'Saisissez un aliment (ex. porc, mayo)…';

  @override
  String get onbDislikesSubtitle =>
      'Nous les écarterons de\nvos recommandations';

  @override
  String get onbDislikesTitle => 'Quels aliments\nn\'aimez-vous pas ?';

  @override
  String get onbFeaturesSubtitle =>
      'Choisissez les fonctionnalités que vous utiliserez le plus';

  @override
  String get onbFeaturesTitle => 'Qu\'est-ce qui vous\nenthousiasme le plus ?';

  @override
  String get onbProfilePreview => 'APERÇU DE VOTRE PROFIL';

  @override
  String get onbSpiceTolerance => 'Tolérance au piquant';

  @override
  String get onbFlavorSubtitle => 'Ajustez les curseurs selon vos goûts';

  @override
  String get onbFlavorTitle => 'Votre profil de saveurs';

  @override
  String get onbFrustrationsSubtitle =>
      'Choisissez ce qui vous correspond le plus';

  @override
  String get onbFrustrationsTitle =>
      'Qu\'est-ce qui vous empêche de cuisiner plus ?';

  @override
  String get onbGoalsSubtitle => 'Nous personnaliserons tout autour de lui';

  @override
  String get onbGoalsTitle => 'Quel est votre objectif\nen ce moment ?';

  @override
  String get onbEquipmentHint => 'Saisissez un équipement puis validez';

  @override
  String get onbSpecifyEquipment => 'Précisez d\'autres équipements';

  @override
  String get onbKitchenSubtitle => 'Sélectionnez votre équipement';

  @override
  String get onbKitchenTitle => 'Qu\'avez-vous dans votre cuisine ?';

  @override
  String get onbPlanningSubtitle => 'Nous adapterons l\'expérience pour vous';

  @override
  String get onbPlanningTitle => 'Comment aimez-vous planifier vos repas ?';

  @override
  String get onbNotifFooter =>
      'Vous pouvez les modifier à tout moment dans vos paramètres';

  @override
  String get onbTurnOnAll => 'Tout activer';

  @override
  String get onbTurnOffAll => 'Tout désactiver';

  @override
  String get onbNotifSubtitle => 'Choisissez ce dont vous voulez être informé';

  @override
  String get onbNotifTitle => 'Restez inspiré avec de nouvelles recettes';

  @override
  String get onbVerifyContinue => 'Vérifier et continuer';

  @override
  String get onbNoCode => 'Vous n\'avez pas reçu de code ?';

  @override
  String onbOtpSentTo(String email) {
    return 'Saisissez le code à 6 chiffres envoyé à\n$email';
  }

  @override
  String get onbVerifyAccount => 'Vérifiez votre compte';

  @override
  String get onbStartCooking => 'À vos fourneaux';

  @override
  String get onbUsesIngredients => 'Utilise vos ingrédients';

  @override
  String get onbQuickDinner => 'Dîner rapide';

  @override
  String get onbMatchesTaste => 'Correspond à vos goûts';

  @override
  String get onbWhyPicked => 'Pourquoi ce choix';

  @override
  String get onbPerfectMealSubtitle =>
      'Selon vos objectifs, vos goûts et votre cuisine';

  @override
  String get onbPerfectMeal => 'Le repas parfait pour vous';

  @override
  String commonSoonSuffix(String label) {
    return '$label (bientôt)';
  }

  @override
  String get authSignInWithEmail => 'Se connecter avec l\'e-mail';

  @override
  String get onbSavePlan => 'Enregistrez votre\nprogramme personnalisé';

  @override
  String get onbTargetSubtitle =>
      'Cela nous aide à recommander les bonnes portions';

  @override
  String get onbTargetTitle => 'Pour qui cuisinez-vous\nhabituellement ?';

  @override
  String get onbCookingTime => 'Temps de cuisine';

  @override
  String get onbTimeSubtitle =>
      'Nous privilégierons les recettes adaptées à votre emploi du temps';

  @override
  String get onbTimeTitle =>
      'Combien de temps avez-vous\nen général pour cuisiner ?';

  @override
  String get priceBilledMonthly => 'Facturé mensuellement';

  @override
  String priceBilledPerMonth(String price) {
    return 'Facturé $price par mois';
  }

  @override
  String get commonProcessing => 'Traitement';

  @override
  String get commonContinuing => 'Chargement';

  @override
  String get onbStartTrial => 'Commencer mon essai gratuit de 3 jours';

  @override
  String get onbSkipEatMost => 'Passer — je mange de presque tout';

  @override
  String get commonConnecting => 'Connexion';

  @override
  String onbGoogleSignupTip(String error) {
    return '$error\n\nAstuce : si le problème persiste avec Google, inscrivez-vous par e-mail.';
  }

  @override
  String get onbCompleteAccountInfo =>
      'Complétez les informations du compte pour enregistrer votre profil';

  @override
  String get payCouldNotStart => 'Impossible de lancer l\'achat';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonSubmit => 'Valider';

  @override
  String get referralCodeHint => 'Code de parrainage';

  @override
  String get referralCanSkip => 'Vous pouvez passer cette étape';

  @override
  String get referralEnterCode =>
      'Saisissez un code de parrainage (facultatif)';

  @override
  String giftUnlocked(String plan) {
    return '🎉 $plan de Cooked Premium débloqué !';
  }

  @override
  String priceTrialThenYearly(String price) {
    return '3 jours offerts, puis $price/an';
  }

  @override
  String get priceTrialThenBilledYearly =>
      '3 jours offerts, puis facturation annuelle';

  @override
  String commonCancelAnytime(String text) {
    return '$text. Résiliable à tout moment.';
  }

  @override
  String get trialHaveReferralCode => 'Vous avez un code de parrainage ?';

  @override
  String get trialMonthlyNoTrialNoPrice =>
      'Sans essai gratuit. Facturé immédiatement. Résiliable à tout moment.';

  @override
  String trialMonthlyNoTrial(String price) {
    return 'Sans essai gratuit. Facturé immédiatement $price/mois. Résiliable à tout moment.';
  }

  @override
  String get commonProcessingDots => 'Traitement…';

  @override
  String get trialTryFree => 'Commencer l’essai gratuit de 3 jours';

  @override
  String get trialSubscribeNow => 'S\'abonner';

  @override
  String get trialNoPaymentToday => 'Aucun paiement aujourd\'hui';

  @override
  String get trialThreeDaysFree => '3 jours offerts';

  @override
  String get planYearly => 'Annuel';

  @override
  String get planMonthly => 'Mensuel';

  @override
  String get trialSubtitle =>
      'Pensé pour vos objectifs, votre emploi du temps et vos goûts.';

  @override
  String get trialTitle => 'Débloquez votre\nsystème culinaire personnalisé.';

  @override
  String pricePerYearShort(String price) {
    return '$price /an';
  }

  @override
  String pricePerMonthShort(String price) {
    return '$price /mois';
  }

  @override
  String get faqImportQ => 'Comment importer une recette ?';

  @override
  String get faqImportA =>
      'Allez dans l\'onglet Importer, collez un lien ou utilisez l\'appareil photo pour scanner une recette.';

  @override
  String get faqShareQ => 'Puis-je partager mes recettes ?';

  @override
  String get faqShareA =>
      'Oui ! Ouvrez une recette et touchez le bouton de partage en haut à droite.';

  @override
  String get faqCookbookQ => 'Comment créer un livre de recettes ?';

  @override
  String get faqCookbookA =>
      'Depuis l\'onglet Accueil, touchez le bouton « + » à côté de vos livres de recettes.';

  @override
  String get faqPasswordQ => 'Comment changer mon mot de passe ?';

  @override
  String get faqPasswordA =>
      'Allez dans Paramètres → Changer le mot de passe et saisissez le nouveau.';

  @override
  String get faqWebQ => 'Existe-t-il une version web ?';

  @override
  String get faqWebA =>
      'Non, Cooked est pour l\'instant disponible uniquement sur mobile.';

  @override
  String get feedbackCatAccount => 'Compte';

  @override
  String get feedbackCatPayment => 'Paiement';

  @override
  String get feedbackCatScan => 'Scan';

  @override
  String get feedbackCatImport => 'Import';

  @override
  String get feedbackCatRecipe => 'Recette';

  @override
  String get feedbackCatShopping => 'Courses';

  @override
  String get feedbackCatOther => 'Autre';

  @override
  String prefsFlavorSummary(String spice, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count préférences',
      one: '1 préférence',
    );
    return '$spice, $_temp0';
  }

  @override
  String savingsFromRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Grâce à $count recettes enregistrées',
      one: 'Grâce à 1 recette enregistrée',
    );
    return '$_temp0';
  }

  @override
  String get activityEmpty =>
      'Vous n\'avez encore importé ni scanné aucune recette.';

  @override
  String get activityRecentRecipes => 'Recettes récentes';

  @override
  String get prefsAllergiesUpdateFailed =>
      'Impossible de mettre à jour les allergies';

  @override
  String get prefsFlavorSpice => 'Saveurs et piquant';

  @override
  String get commonNotSet => 'Non défini';

  @override
  String get prefsFavoriteCuisines => 'Cuisines préférées';

  @override
  String get prefsCuisineUpdateFailed =>
      'Impossible de mettre à jour vos cuisines et saveurs';

  @override
  String get feedbackHint => 'Décrivez votre problème…';

  @override
  String get feedbackMessage => 'Message';

  @override
  String get feedbackCategory => 'Catégorie';

  @override
  String get feedbackHeadline =>
      'Nous sommes à votre écoute 💬\nDécrivez votre problème et nous vous aiderons au plus vite.';

  @override
  String get feedbackFailed =>
      'Impossible d\'envoyer votre message. Veuillez réessayer.';

  @override
  String get feedbackSent => 'Merci ! Votre message a bien été envoyé.';

  @override
  String get feedbackNoEmail =>
      'Impossible de trouver l\'e-mail de votre compte.';

  @override
  String get feedbackWriteFirst => 'Veuillez d\'abord écrire un message.';

  @override
  String get legalCookies => 'Politique relative aux cookies';

  @override
  String get legalRefundCancellation => 'Remboursement et annulation';

  @override
  String get legalRefund => 'Politique de remboursement';

  @override
  String get legalTerms => 'Conditions générales';

  @override
  String get helpLegal => 'Mentions légales';

  @override
  String get helpSendFeedbackSubtitle => 'Bugs, idées ou autre';

  @override
  String get helpSendFeedback => 'Envoyer un avis';

  @override
  String get helpHeadline =>
      'Dites-nous comment vous aider 👋\nNotre équipe est là pour vous accompagner !';

  @override
  String get helpTitle => 'Centre d\'aide';

  @override
  String get prefsKitchenUpdateFailed =>
      'Impossible de mettre à jour l\'équipement';

  @override
  String get giftRedeeming => 'Validation…';

  @override
  String get giftRedeem => 'Utiliser';

  @override
  String get giftRedeemSubtitle =>
      'Saisissez votre code cadeau pour débloquer Cooked Premium sur ce compte.';

  @override
  String get giftRedeemHeadline => 'On vous a offert Cooked ?';

  @override
  String get giftRedeemTitle => 'Utiliser un cadeau';

  @override
  String get savingsScannedAtHome => 'Scanné à la maison';

  @override
  String get savingsYourSaved => 'Vous avez économisé';

  @override
  String get savingsEmpty => 'Pas encore d\'économies grâce au scan';

  @override
  String get savingsTitle => 'Vos économies';

  @override
  String get subAmount => 'Montant';

  @override
  String get commonNotAvailable => 'N/D';

  @override
  String get subFreeTrial => 'Essai gratuit';

  @override
  String get subPremiumPlan => 'Formule Premium';

  @override
  String get subNoPayments => 'Aucun paiement';

  @override
  String get subPaymentHistory => 'Historique des paiements';

  @override
  String get subRestorePurchases => 'Restaurer les achats';

  @override
  String get subActive => 'Abonnement actif';

  @override
  String get subRenew => 'Renouveler ou changer de formule';

  @override
  String get subAlreadyPremium => 'Vous êtes déjà membre Premium !';

  @override
  String get subStatus => 'Statut';

  @override
  String get subEndDate => 'Date de fin';

  @override
  String get subStartDate => 'Date de début';

  @override
  String get subPlan => 'Formule';

  @override
  String get subDetails => 'Détails de l\'abonnement';

  @override
  String get subTitle => 'Abonnement';

  @override
  String get subNothingToRestore => 'Aucun abonnement actif à restaurer.';

  @override
  String get subRestored => 'Achats restaurés !';

  @override
  String get subExpiringSoon => 'Expire bientôt';

  @override
  String subHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures restantes',
      one: '1 heure restante',
    );
    return '$_temp0';
  }

  @override
  String subDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants',
      one: '1 jour restant',
    );
    return '$_temp0';
  }

  @override
  String get subExpired => 'Expiré';

  @override
  String get subNoActive => 'Aucun abonnement actif';

  @override
  String get subLoadFailed => 'Impossible de charger l\'abonnement';

  @override
  String get prefsGoals => 'Objectifs';

  @override
  String get prefsSectionOther => 'Autres';

  @override
  String get prefsCookingTarget => 'Nombre de personnes';

  @override
  String get prefsPlanningStyle => 'Style de planification';

  @override
  String get prefsSectionPlanning => 'Planification et habitudes';

  @override
  String get prefsTimePreference => 'Temps de cuisine';

  @override
  String get prefsCookingSkill => 'Niveau en cuisine';

  @override
  String get prefsSectionCooking => 'Cuisine et compétences';

  @override
  String get prefsFoodDislikes => 'Aliments non aimés';

  @override
  String get prefsDietaryProfile => 'Profil alimentaire';

  @override
  String get prefsSectionDiet => 'Alimentation';

  @override
  String get prefsUpdateFailed => 'Impossible de mettre à jour les préférences';

  @override
  String get prefsUpdated => 'Préférences mises à jour !';

  @override
  String get prefsLoadFailed => 'Impossible de charger les préférences';

  @override
  String get giftPlanOneYear => '1 an';

  @override
  String get giftPlanThreeMonths => '3 mois';

  @override
  String get giftPlanOneYearDesc =>
      'Offrez un abonnement Premium Cooked d\'un an. Achat non remboursable.';

  @override
  String get giftPlanThreeMonthsDesc =>
      'Offrez un abonnement Premium Cooked de 3 mois. Achat non remboursable.';

  @override
  String giftShareMessage(String plan, String url, String code) {
    return '🎁 Je t\'offre $plan de Cooked Premium ! Utilise-le ici : $url\n\nOu ouvre Cooked et saisis ce code : $code';
  }

  @override
  String get giftTapToCopy => 'Touchez pour copier';

  @override
  String get giftRefunded => 'Remboursé';

  @override
  String get giftRedeemed => 'Utilisé';

  @override
  String get giftNotUsed => 'Pas encore utilisé';

  @override
  String get giftBuy => 'Acheter le cadeau';

  @override
  String get giftBestValue => 'Meilleure offre';

  @override
  String get giftYourGifts => 'Vos cadeaux';

  @override
  String get giftSubtitle =>
      'Achetez un code cadeau et envoyez-le à un ami. Il l\'utilise dans l\'app, sans abonnement de son côté.';

  @override
  String get giftHeadline => 'Offrez Cooked';

  @override
  String get giftTitle => 'Offrir Cooked';

  @override
  String get giftSendToFriend => 'Envoyer à un ami';

  @override
  String giftSendThisCode(String plan) {
    return 'Envoyez ce code $plan à un ami. Nous vous l\'avons aussi envoyé par e-mail.';
  }

  @override
  String get giftReady => 'Votre cadeau est prêt !';

  @override
  String get giftCodeCopied => 'Code cadeau copié';

  @override
  String get giftPurchaseFailed => 'L\'achat a échoué. Veuillez réessayer.';

  @override
  String get giftPaymentReceived =>
      'Paiement reçu ! Nous vous envoyons le code cadeau par e-mail dans un instant.';

  @override
  String shareRecipe(String name, String link) {
    return 'Découvre $name sur Cooked 🙌\n$link';
  }

  @override
  String shareRecipeByCreator(String creator, String name, String link) {
    return 'Découvre $name de $creator sur Cooked 🙌\n$link';
  }

  @override
  String get savingsComparedTakeout => 'Par rapport aux plats commandés.';

  @override
  String get savingsThisMonth => 'Ce mois-ci';

  @override
  String get recipeAlreadySaved => 'Cette recette est déjà dans vos recettes';

  @override
  String get homeSuggestedRecipes => 'Recettes suggérées';

  @override
  String get cookbookDeleteFailed => 'Impossible de supprimer le livre';

  @override
  String get cookbookDeleted => 'Livre supprimé';

  @override
  String get cookbookDelete => 'Supprimer le livre';

  @override
  String get commonOperationFailed => 'L\'opération a échoué';

  @override
  String get cookbookUnpinned => 'Livre désépinglé';

  @override
  String get cookbookPinned => 'Livre épinglé';

  @override
  String get cookbookPin => 'Épingler le livre';

  @override
  String get cookbookUnpin => 'Désépingler le livre';

  @override
  String get cookbookEdit => 'Modifier le livre';

  @override
  String get cookbookAddRecipes => 'Ajouter des recettes';

  @override
  String get cookbookNew => 'Nouveau livre';

  @override
  String get feedbackSubmit => 'Envoyer';

  @override
  String get feedbackThanks => 'Merci pour votre avis !';

  @override
  String get feedbackTypeHere => 'Écrivez votre avis ici…';

  @override
  String get feedbackCardSubtitle =>
      'Partagez vos idées ou tout ce qui pourrait améliorer votre expérience.';

  @override
  String get feedbackCardTitle => 'Aidez-nous à améliorer Cooked';

  @override
  String get feedbackCardButton => 'Donner mon avis';

  @override
  String get recipeDelete => 'Supprimer la recette';

  @override
  String get recipeShare => 'Partager la recette';

  @override
  String get recipeAddToCookbook => 'Ajouter à un livre';

  @override
  String get recipeRemoveFromCookbook => 'Retirer du livre';

  @override
  String get recipeUnpin => 'Désépingler la recette';

  @override
  String get recipePin => 'Épingler la recette';

  @override
  String get recipeRemovedToast => 'Recette retirée des favoris';

  @override
  String get recipeSavedToast => 'Recette ajoutée aux favoris !';

  @override
  String get navImport => 'Importer';

  @override
  String get navScan => 'Scanner';

  @override
  String get navExplore => 'Explorer';

  @override
  String get commonTryDifferentSearch => 'Essayez un autre mot-clé.';

  @override
  String get homeBrowseRecipes => 'Parcourir les recettes';

  @override
  String get homeNoSavedSubtitle =>
      'Explorez nos recettes et enregistrez vos préférées\npour créer votre collection.';

  @override
  String get homeNoSavedTitle => 'Aucune recette enregistrée';

  @override
  String get homeAddCookbook => 'Ajouter un livre';

  @override
  String get homeCookbookEmptySubtitle =>
      'Enregistrez vos recettes préférées\net gardez-les au même endroit.';

  @override
  String get homeCookbookEmptyTitle => 'Créez votre livre de recettes';

  @override
  String get commonViewAll => 'Tout voir';

  @override
  String get homeSavedRecipes => 'Recettes enregistrées';

  @override
  String get homeSuggested => 'Suggestions pour vous';

  @override
  String get homeRecentlyViewed => 'Vus récemment';

  @override
  String get homeCookbooks => 'Livres de recettes';

  @override
  String get homeYourCookbooks => 'Vos livres de recettes';

  @override
  String get homeSearchHint => 'Rechercher dans vos recettes';

  @override
  String get homeHeadline => 'Que voulez-vous cuisiner aujourd\'hui ?';

  @override
  String get navGrocery => 'Courses';

  @override
  String get navScanRecipe => 'Scanner une recette';

  @override
  String get navHome => 'Accueil';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
      zero: '0 recette',
    );
    return '$_temp0';
  }

  @override
  String recipeCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
      zero: '0 recette',
    );
    return '$_temp0';
  }

  @override
  String get cookbookDefaultName => 'Livre de recettes';

  @override
  String get recipePinned => 'Recette épinglée';

  @override
  String get recipeUnpinned => 'Recette désépinglée';

  @override
  String get recipePinFailed => 'Impossible d\'épingler la recette';

  @override
  String get recipeRemovedFromCookbook => 'Retirée du livre';

  @override
  String get recipeDeleted => 'Recette supprimée';

  @override
  String get cookbookEmptyTitle => 'Pas encore de recettes';

  @override
  String get cookbookEmptySubtitle =>
      'Ajoutez des recettes à ce livre en scannant, en important ou en explorant.';

  @override
  String get recipeServings => 'Portions';

  @override
  String get recipeQuantitiesAdjust =>
      'Les quantités s\'ajustent automatiquement';

  @override
  String get commonLoadingDots => 'Chargement…';

  @override
  String get commonGoBack => 'Retour';

  @override
  String recipeServingsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get recipeAddToGrocery => 'Ajouter aux courses';

  @override
  String get recipeSteps => 'Étapes';

  @override
  String get recipeIngredients => 'Ingrédients';

  @override
  String get recipeAlsoRemoveSaved =>
      'Voulez-vous aussi retirer cette recette de vos recettes enregistrées ?';

  @override
  String get commonNo => 'Non';

  @override
  String get commonYes => 'Oui';

  @override
  String get recipeRemovedBoth =>
      'Retirée du livre et des recettes enregistrées';

  @override
  String get recipeNoIngredients => 'Aucun ingrédient indiqué';

  @override
  String get recipeNoIngredientsHint =>
      'Consultez la description de la recette.';

  @override
  String get recipeNoEquipment => 'Aucun équipement particulier';

  @override
  String get recipeNoEquipmentHint => 'Les ustensiles de base suffisent.';

  @override
  String get recipeNoSteps => 'Aucune étape indiquée';

  @override
  String get recipeNoStepsHint =>
      'Suivez votre intuition ou consultez la source.';

  @override
  String get recipeRequiredEquipment => 'Équipement nécessaire';

  @override
  String get recipeNotesTips => 'Notes / astuces';

  @override
  String get recipeTonightSaving => 'L\'économie de ce soir';

  @override
  String get recipeOrderingNearby => 'Commander à côté';

  @override
  String get recipeMakingAtHome => 'Cuisiner à la maison';

  @override
  String get recipeEstimatedSavings => 'Économies estimées';

  @override
  String get viewAllCuisine => 'Cuisine';

  @override
  String get viewAllSearchCuisine => 'Rechercher une cuisine…';

  @override
  String get viewAllSearchCategory => 'Rechercher une catégorie…';

  @override
  String viewAllSearchCuisineRecipes(String cuisine) {
    return 'Rechercher des recettes ($cuisine)…';
  }

  @override
  String get viewAllSearchRecent =>
      'Rechercher dans les recettes vues récemment…';

  @override
  String get viewAllSearchAll => 'Rechercher des recettes, des livres…';

  @override
  String get viewAllNoCookbooks => 'Aucun livre de recettes.';

  @override
  String get viewAllNoCookbooksMatch =>
      'Aucun livre ne correspond à votre recherche.';

  @override
  String get viewAllNoRecipesMatch =>
      'Aucune recette ne correspond à votre recherche.';

  @override
  String get viewAllNoRecipes => 'Aucune recette trouvée.';

  @override
  String get commonRecipes => 'Recettes';

  @override
  String get recipeDeleteFailed =>
      'Impossible de supprimer cette recette. Veuillez réessayer.';

  @override
  String get recipeAlreadyInYours => 'Déjà dans vos recettes';

  @override
  String get viewAllNoCreatorsMatch =>
      'Aucun créateur ne correspond à votre recherche.';

  @override
  String get viewAllNoItems => 'Aucun élément.';

  @override
  String get viewAllNoItemsMatch =>
      'Aucun élément ne correspond à votre recherche.';

  @override
  String get cameraInitializing => 'Démarrage de l\'appareil photo…';

  @override
  String get cameraOnHold => 'En pause';

  @override
  String get cameraOff => 'Appareil photo désactivé';

  @override
  String get cameraPermissionDenied => 'Accès à l\'appareil photo refusé';

  @override
  String get cameraFinding => 'Recherche de l\'appareil photo…';

  @override
  String get cameraNotFound => 'Aucun appareil photo trouvé';

  @override
  String get cameraReady => 'Prêt';

  @override
  String get cameraError => 'Appareil photo indisponible';

  @override
  String get scanAddIngredientsFirst =>
      'Ajoutez ou sélectionnez des ingrédients';

  @override
  String get scanTypeIngredient => 'Saisir un ingrédient';

  @override
  String get scanSaved => 'Enregistrés';

  @override
  String get scanGetRecipes => 'Trouver des recettes';

  @override
  String get scanTypeIngredients => 'Saisir';

  @override
  String get scanEnterOneByOne => 'Saisissez les ingrédients un par un';

  @override
  String get scanAddToFind =>
      'Ajoutez des ingrédients pour trouver des recettes à préparer';

  @override
  String get scanRecentlyUsed => 'Utilisés récemment';

  @override
  String get scanUseAll => 'Tout utiliser';

  @override
  String get scanClearSelection => 'Effacer la sélection';

  @override
  String get scanNoSaved => 'Aucun ingrédient enregistré.';

  @override
  String get scanResultsTitleA => 'Les recettes que\n';

  @override
  String get scanResultsTitleB => 'vous pouvez cuisiner';

  @override
  String scanFoundRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nous avons trouvé $count recettes pour vous',
      one: 'Nous avons trouvé 1 recette pour vous',
    );
    return '$_temp0';
  }

  @override
  String get scanYourIngredients => 'Vos ingrédients';

  @override
  String scanFoundItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nous avons trouvé $count produits dans votre cuisine',
      one: 'Nous avons trouvé 1 produit dans votre cuisine',
    );
    return '$_temp0';
  }

  @override
  String get scanViewRecipe => 'Voir la recette';

  @override
  String get importRecipePreview => 'Aperçu de la recette';

  @override
  String get importLinkUnavailable =>
      'Ce lien de recette n\'est pas disponible.';

  @override
  String get importInvalidLink =>
      'Veuillez entrer un lien de recette valide (ex. : https://exemple.com/recette)';

  @override
  String get importAlreadyExists =>
      'Cette recette existe déjà dans votre collection';

  @override
  String get importExtractFailed =>
      'Nous n\'avons pas pu extraire cette recette de ce lien. La page ne contenait pas suffisamment d\'informations sur la recette.';

  @override
  String get importSuccess => 'Recette importée avec succès !';

  @override
  String get importManualSoon =>
      'Saisie manuelle de recette bientôt disponible';

  @override
  String get importRecipeLink => 'Lien de la recette';

  @override
  String get importPasteHint => 'Collez un lien de recette…';

  @override
  String get importImporting => 'Importation';

  @override
  String get importSearchWeb => 'Rechercher sur le web';

  @override
  String get importTrending => 'Tendances';

  @override
  String get importRecent => 'Imports récents';

  @override
  String get importNoRecent => 'Aucun import récent.';

  @override
  String get recipeEdit => 'Modifier la recette';

  @override
  String get importRecommended => 'Recommandé';

  @override
  String get importSuggestions => 'Suggestions';

  @override
  String get importSearchRecipesHint => 'Rechercher des recettes…';

  @override
  String get importSearchResults => 'Résultats';

  @override
  String get commonClear => 'Effacer';

  @override
  String get importViewThisRecipe => 'Voir cette recette';

  @override
  String get importToCooked => 'Importer dans Cooked';

  @override
  String get filterHighProtein => 'Riche en protéines';

  @override
  String get filterUnder30Min => 'Moins de 30 min';

  @override
  String get filterBreakfast => 'Petit-déjeuner';

  @override
  String get filterLunch => 'Déjeuner';

  @override
  String get filterDinner => 'Dîner';

  @override
  String get filterLowCalorie => 'Peu calorique';

  @override
  String get filterOnePot => 'Tout-en-un';

  @override
  String get filterBudgetFriendly => 'Petit budget';

  @override
  String get filterVegetarian => 'Végétarien';

  @override
  String get filterVegan => 'Végan';

  @override
  String get filterNoCook => 'Sans cuisson';

  @override
  String get filterDesserts => 'Desserts';

  @override
  String get filterSnacks => 'En-cas';

  @override
  String get filterSmoothies => 'Smoothies';

  @override
  String get filterSalads => 'Salades';

  @override
  String get filterSoups => 'Soupes';

  @override
  String get filterPasta => 'Pâtes';

  @override
  String get filterBowls => 'Bowls';

  @override
  String get filterSandwichesWraps => 'Sandwichs et wraps';

  @override
  String get filterChicken => 'Poulet';

  @override
  String get filterBeef => 'Bœuf';

  @override
  String get filterSeafood => 'Fruits de mer';

  @override
  String exploreNoFilterMatch(String filter) {
    return 'Aucune recette « $filter » pour l\'instant.';
  }

  @override
  String get exploreForYou => 'Pour vous';

  @override
  String get explorePopularCategories => 'Catégories populaires';

  @override
  String get exploreCategory => 'Catégorie';

  @override
  String get exploreCuisines => 'Cuisines';

  @override
  String get explorePopularNow => 'Populaires en ce moment';

  @override
  String get cookbookSelectRecipes => 'Choisir des recettes';

  @override
  String get cookbookNameHint => 'Nom du livre';

  @override
  String get cookbookAddRecipesLower => 'Ajouter des recettes';

  @override
  String get cookbookSelectForThis => 'Choisissez les recettes de ce livre';

  @override
  String get cookbookSelectedRecipes => 'Recettes sélectionnées';

  @override
  String get cookbookUpdated => 'Livre mis à jour !';

  @override
  String get cookbookCreated => 'Livre créé !';

  @override
  String cookbookSaveFailed(String name, String error) {
    return 'Impossible d\'enregistrer « $name » : $error';
  }

  @override
  String cookbookNoMatch(String query) {
    return 'Aucune recette pour « $query »';
  }

  @override
  String get cookbookExploreRecipes => 'Explorer les recettes';

  @override
  String get payActivated => 'Premium activé ! Bienvenue au Chef Club.';

  @override
  String get paySpecialComeback => 'Offre spéciale de retour';

  @override
  String get payUnlockPremium => 'Débloquer Premium';

  @override
  String get payUnlockToKeep =>
      'Débloquez Cooked pour continuer\nà créer des recettes.';

  @override
  String get paySpecialOffer => 'Offre spéciale';

  @override
  String get paySpecialOfferDesc =>
      'Débloquez toutes les fonctionnalités avec cette remise limitée.';

  @override
  String get payUnlimitedAccess => 'Accès illimité';

  @override
  String get payUnlimitedAccessDesc =>
      'Scannez votre frigo et importez des recettes sans limite.';

  @override
  String get payExclusiveRecipes => 'Recettes exclusives';

  @override
  String get payExclusiveRecipesDesc =>
      'Accédez aux recettes premium et aux livres thématiques.';

  @override
  String get payImmediateAccess => 'Accès immédiat';

  @override
  String get payImmediateAccessDesc =>
      'Scannez vos ingrédients et importez des recettes depuis n\'importe quel lien.';

  @override
  String get payExclusiveContent => 'Contenu exclusif';

  @override
  String get payExclusiveContentDesc =>
      'Accédez aux recettes générées premium et aux livres thématiques.';

  @override
  String get payMasterChef => 'Statut Master Chef';

  @override
  String get payMasterChefDesc =>
      'Profitez d\'une expérience sans publicité avec un traitement IA prioritaire.';

  @override
  String get payPercentOff => '-33 %';

  @override
  String get payBestValue => 'MEILLEURE OFFRE';

  @override
  String get payImmediatePremium => 'Accès Premium immédiat';

  @override
  String get paySubscribeNow => 'S\'abonner';

  @override
  String pricePerMonthLong(String price) {
    return '$price / mois';
  }

  @override
  String pricePerYearLong(String price) {
    return '$price / an';
  }

  @override
  String payDaysFree(String days) {
    return '$days jours offerts';
  }

  @override
  String get payNoPaymentToday => 'aucun paiement aujourd\'hui';

  @override
  String pricePerYearSentence(String price) {
    return '$price par an';
  }

  @override
  String get priceBilledYearly => 'facturé annuellement';

  @override
  String pricePerMonthSentence(String price) {
    return '$price par mois';
  }

  @override
  String get priceBilledMonthlyLower => 'facturé mensuellement';

  @override
  String get paySubscriptionsUnavailable =>
      'Les abonnements sont indisponibles pour le moment. Réessayez plus tard.';

  @override
  String payPurchaseFailed(String error) {
    return 'Échec de l\'achat : $error';
  }

  @override
  String payRestoreFailed(String error) {
    return 'Erreur de restauration : $error';
  }

  @override
  String get tutImportTarget =>
      'Importez des recettes depuis TikTok,\nInstagram ou n\'importe quel lien';

  @override
  String get tutScanTarget => 'Scannez et obtenez des recettes instantanément';

  @override
  String get tutCookbooksTarget => 'Enregistrez et organisez vos recettes ici.';

  @override
  String get tutScanBestTitle => 'Pour un scan réussi';

  @override
  String get tutScanSteady => 'Tenez votre téléphone stable';

  @override
  String get tutScanLighting => 'Utilisez un bon éclairage';

  @override
  String get tutScanVisible =>
      'Assurez-vous que tous les ingrédients sont visibles';

  @override
  String get commonNext => 'Suivant';

  @override
  String get tutScanFindTitle => 'Nous trouvons vos ingrédients instantanément';

  @override
  String get tutScanSnap => 'Prenez vos ingrédients en photo';

  @override
  String get tutScanDetect => 'Nous détectons instantanément ce qu\'il y a';

  @override
  String get tutScanEdit => 'Corrigez ce qui ne va pas';

  @override
  String get tutScanReadyTitle => 'Prêt à scanner';

  @override
  String get tutScanFridge =>
      'Scannez votre frigo, vos placards ou vos ingrédients';

  @override
  String get tutScanAngles =>
      'Essayez différents angles pour de meilleurs résultats';

  @override
  String get tutScanMoreVisible =>
      'Plus c\'est visible, meilleures sont vos recettes';

  @override
  String get tutScanNow => 'Scanner maintenant';

  @override
  String get tutImportTitle => 'Importez des recettes de partout';

  @override
  String get tutImportPaste =>
      'Collez un lien TikTok, Instagram ou de n\'importe quel site';

  @override
  String get tutImportShare =>
      'Ou partagez directement depuis vos réseaux pour importer instantanément';

  @override
  String get tutImportTurn =>
      'Nous en faisons automatiquement une recette complète';

  @override
  String get tutImportSave => 'Enregistrez-la dans votre livre';

  @override
  String get commonShare => 'Partager';

  @override
  String get tutCookbookTitle1 => 'Vos recettes bien rangées';

  @override
  String get tutCookbookItem1 => 'Parcourez toutes les recettes de ce livre';

  @override
  String get tutCookbookItem2 => 'Naviguez rapidement par catégorie';

  @override
  String get tutCookbookItem3 => 'Accédez à vos favoris en un geste';

  @override
  String get tutCookbookTitle2 => 'Contrôle total';

  @override
  String get tutCookbookItem4 => 'Modifiez votre livre à tout moment';

  @override
  String get tutCookbookItem5 => 'Ajoutez des recettes avec le bouton +';

  @override
  String get tutCookbookItem6 => 'Touchez une recette pour voir les détails';

  @override
  String get tutExploreNow => 'Explorer';

  @override
  String get tutIngredientsDetected => 'Ingrédients détectés';

  @override
  String get commonEdit => 'Modifier';

  @override
  String cookbookAddedTo(String name) {
    return 'Ajoutée à $name';
  }

  @override
  String get cookbookAddedGeneric => 'Ajoutée au livre';

  @override
  String get avatarChooseLibrary => 'Choisir dans la galerie';

  @override
  String get avatarTakePhoto => 'Prendre une photo';

  @override
  String get avatarDeleting => 'Suppression de la photo…';

  @override
  String get avatarDeleted => 'Photo de profil supprimée';

  @override
  String get avatarUpdating => 'Mise à jour de la photo…';

  @override
  String get avatarUpdated => 'Photo de profil mise à jour !';

  @override
  String get clipRecipeDetected => 'Recette détectée';

  @override
  String get clipLinkFound => 'Lien trouvé dans le presse-papiers';

  @override
  String get clipPaste => 'Coller';

  @override
  String get fallbackTitle => 'Recette introuvable';

  @override
  String get fallbackHeadline => 'Impossible d’importer cette recette.';

  @override
  String get fallbackMessage =>
      'Ce lien ne contenait pas assez d’informations pour que Cooked importe la recette correctement.';

  @override
  String get fallbackFailedUrl => 'Lien en échec';

  @override
  String get fallbackTryOther => 'Essayer un autre lien';

  @override
  String get fallbackTryOtherDesc => 'Coller un lien de recette différent';

  @override
  String get fallbackManual => 'Ajouter la recette manuellement';

  @override
  String get fallbackManualDesc =>
      'Saisissez vous-même les ingrédients et les étapes';

  @override
  String get groceryAlreadyTitle => 'Déjà dans votre liste de courses';

  @override
  String groceryAlreadyMessage(String name) {
    return '« $name » est déjà dans votre liste. L\'ajouter à nouveau ? ';
  }

  @override
  String get groceryQuantitiesDoubled =>
      'Les quantités de ces ingrédients seront doublées.';

  @override
  String get groceryAddAgain => 'Ajouter à nouveau';

  @override
  String get groceryAddToList => 'Ajouter à la liste de courses';

  @override
  String get grocerySelectIngredients => 'Choisir les ingrédients';

  @override
  String get grocerySaveLocation => 'Où enregistrer';

  @override
  String groceryDate(String date) {
    return 'Date : $date';
  }

  @override
  String get groceryGeneralList => 'Liste générale';

  @override
  String get grocerySpecificDate => 'Date précise';

  @override
  String get groceryAddSelected => 'Ajouter les ingrédients sélectionnés';

  @override
  String get commonSaving => 'Enregistrement';

  @override
  String get recipeSavedInCookbook => 'Enregistrée dans votre livre';

  @override
  String headerGreeting(String name) {
    return 'Bonjour $name';
  }

  @override
  String get importGettingReady => 'Préparation pour Cooked';

  @override
  String get scanGeneratingRecipes => 'Génération des recettes…';

  @override
  String get scanAnalyzingRecipe => 'Analyse de la recette…';

  @override
  String get importStageReceiving => 'Réception du lien…';

  @override
  String get importStageFinding => 'Recherche de la recette…';

  @override
  String get importStagePulling => 'Récupération des ingrédients et étapes…';

  @override
  String get importStageReady => 'Recette prête';

  @override
  String get errRegistration =>
      'L\'inscription a échoué. Vérifiez vos informations.';

  @override
  String get authAccountExistsLoggedIn =>
      'Ce compte existe déjà. Vous avez été connecté avec succès.';

  @override
  String get errInvalidCredentials => 'Identifiants invalides';

  @override
  String get errInvalidCredentialsRetry =>
      'Identifiants invalides, veuillez réessayer';

  @override
  String get errCodeExpired =>
      'Code de vérification invalide ou expiré, veuillez réessayer';

  @override
  String get errResendCode =>
      'Impossible de renvoyer le code. Veuillez réessayer.';

  @override
  String get errResetStart =>
      'Impossible de lancer la réinitialisation du mot de passe.';

  @override
  String get errResetCodeExpired =>
      'Code de réinitialisation invalide ou expiré, veuillez réessayer';

  @override
  String get errResetPassword =>
      'Impossible de réinitialiser le mot de passe. Veuillez réessayer.';

  @override
  String get errDeleteAccount => 'Impossible de supprimer le compte.';

  @override
  String get errUnexpected => 'Une erreur inattendue s\'est produite.';

  @override
  String errAi(String msg) {
    return '🤖 Erreur IA : $msg';
  }

  @override
  String errServer(String msg) {
    return '⚙️ Erreur serveur : $msg';
  }

  @override
  String errInput(String msg) {
    return '📝 Erreur de saisie : $msg';
  }

  @override
  String errAuth(String msg) {
    return '🔒 Erreur d\'authentification : $msg';
  }

  @override
  String get errPremiumRequired =>
      'Accès Premium requis. Vérifiez votre abonnement.';

  @override
  String get errNotFound => 'L\'élément demandé est introuvable.';

  @override
  String get errSessionExpired =>
      'Session expirée ou invalide. Veuillez vous reconnecter.';

  @override
  String get errNoInternet =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get errAccountExists =>
      'Ce compte existe déjà. Veuillez vous connecter.';

  @override
  String get errItemExists => 'Cet élément existe déjà.';

  @override
  String get errInvalidCode =>
      'Code de vérification invalide. Veuillez réessayer.';

  @override
  String get errAccountNotFound =>
      'Compte introuvable. Veuillez vous inscrire.';

  @override
  String get errServersBusy =>
      'Nos serveurs sont très sollicités. Réessayez dans un instant.';

  @override
  String get errExtractFailed =>
      'Impossible d\'extraire la recette de ce lien. Vérifiez l\'URL ou essayez-en un autre.';

  @override
  String get errSiteBlocking =>
      'Le site bloque l\'accès. Essayez une autre source.';

  @override
  String get errGeneric =>
      'Une erreur s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get notifChannelShopping => 'Rappels de courses';

  @override
  String get notifChannelShoppingDesc => 'Rappels pour faire les courses';

  @override
  String get notifGroceryTitle => 'Courses';

  @override
  String get notifGroceryBody => 'N\'oubliez pas de faire vos courses !';

  @override
  String get notifChannelPushDesc => 'Notifications de l\'équipe Cooked';

  @override
  String get errPurchaseNotActive => 'Achat effectué mais abonnement inactif';

  @override
  String get errPurchase => 'Une erreur est survenue lors de l\'achat';

  @override
  String get errIngredientDetection =>
      'La détection des ingrédients a échoué. Veuillez réessayer.';

  @override
  String get errScan => 'Le scan a échoué. Veuillez réessayer.';

  @override
  String get errValidation => 'La validation a échoué. Veuillez réessayer.';

  @override
  String get errGeneration => 'La génération a échoué. Veuillez réessayer.';

  @override
  String get errGenerateRecipes =>
      'Impossible de générer des recettes. Veuillez réessayer.';

  @override
  String savingsCopyName(String name) {
    return '(Copie) $name';
  }

  @override
  String get errImport => 'L\'import a échoué';

  @override
  String get errWebSearch => 'La recherche web a échoué';

  @override
  String get errPayment => 'Le paiement a échoué';

  @override
  String get errVerification => 'La vérification a échoué';

  @override
  String get errLoadProfile => 'Impossible de charger le profil.';

  @override
  String get errUpdateProfile => 'Impossible de mettre à jour le profil.';

  @override
  String get errSavePreferences => 'Impossible d\'enregistrer vos préférences.';

  @override
  String get errChangePassword => 'Impossible de changer le mot de passe.';

  @override
  String get errNotifSettings =>
      'Impossible de mettre à jour les notifications.';

  @override
  String get errUploadPhoto => 'Impossible d\'envoyer la photo de profil.';

  @override
  String get termsIntro =>
      'Avant de continuer avec la connexion sociale, veuillez lire et accepter nos conditions pour protéger vos données.';

  @override
  String get termsAgreeA => 'J\'ai lu et j\'accepte les ';

  @override
  String get termsAnd => ' et la ';

  @override
  String get termsConfirm => 'Confirmer et continuer';

  @override
  String get fallbackExtractTitle =>
      'Aucune recette n’a pu être extraite de ce lien.';

  @override
  String get fallbackExtractHint => 'Vérifiez l’URL ou essayez-en une autre.';

  @override
  String get fallbackLinkCopied => 'Lien copié';

  @override
  String get fallbackCopyLink => 'Copier le lien';

  @override
  String get splashTagline => 'Le dîner commence avec ce que vous avez déjà.';
}
