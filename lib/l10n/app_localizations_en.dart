// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Cooked';

  @override
  String get groceryInlineAddHint => 'e.g. Garlic - 2, 2 Garlic, or Garlic 2';

  @override
  String get groceryAddIngredientPlaceholder => 'Add an ingredient...';

  @override
  String get groceryQuantityFormatError =>
      'Please add the quantity following the format, e.g: garlic - 2, 2 garlic, or garlic 2.';

  @override
  String get commonSave => 'Save';

  @override
  String get groceryAddItemOrRecipe => 'Please add an item or select a recipe';

  @override
  String get groceryIngredientHint => 'Cheese';

  @override
  String get commonIngredient => 'Ingredient';

  @override
  String get groceryChooseRecipe => 'Choose a recipe';

  @override
  String get commonNoRecipesFound => 'No recipes found';

  @override
  String get commonRecipe => 'Recipe';

  @override
  String get groceryAddSheetTitle => 'Add Grocery';

  @override
  String get groceryItemsSaved => 'Grocery items saved successfully';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonCancel => 'Cancel';

  @override
  String groceryDeleteItemMessage(String name) {
    return 'Are you sure you want to delete \"$name\" from your grocery list?';
  }

  @override
  String get groceryDeleteItemTitle => 'Delete Item';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get groceryAddIngredients => 'Add ingredients';

  @override
  String get groceryEmptySubtitle =>
      'Add ingredients from a recipe or import to get started.';

  @override
  String get groceryEmptyTitle => 'Your Grocery List Is Empty';

  @override
  String get commonAdd => 'Add';

  @override
  String get groceryListTitle => 'Grocery List';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonCheckConnection => 'Check your connection and try again.';

  @override
  String get groceryLoadErrorTitle => 'Couldn\'t load your Grocery List';

  @override
  String get authMissingIdentifier =>
      'Missing identifier context. Please try again.';

  @override
  String get authVerifying => 'Verifying';

  @override
  String get commonContinue => 'Continue';

  @override
  String get authResendCode => 'Resend Code';

  @override
  String get authResending => 'Resending';

  @override
  String get authDidntReceiveCode => 'If you didn’t receive a code? ';

  @override
  String authCodeSentTo(String target) {
    return 'Please enter the code we just sent to\n$target';
  }

  @override
  String get authForgotPasswordTitle => 'Forgot Password';

  @override
  String get authCodeResent => 'Verification code resent.';

  @override
  String get authEnterFullCode => 'Please enter the complete 6-digit code.';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonSending => 'Sending';

  @override
  String get commonSend => 'Send';

  @override
  String get commonPhoneNumber => 'Phone Number';

  @override
  String get authEnterPhoneForCode =>
      'Please enter the phone number, \nwe will send a verification code\n to your phone number';

  @override
  String get authEnterEmailForCode =>
      'Please enter the email, we will send a\nverification code to your email';

  @override
  String get authSendToPhone => 'Send to your phone';

  @override
  String get authSendToEmail => 'Send to your email';

  @override
  String get authSelectContactMethod =>
      'Select which contact details we should\nuse to reset your password';

  @override
  String get authCodeSent => 'Code sent!';

  @override
  String get commonFieldRequired => 'This field is required';

  @override
  String get commonGetStarted => 'Get Started';

  @override
  String get authPasswordChangedMessage =>
      'Password changed successfully, you can\nlogin again with a new password.';

  @override
  String get authPasswordChanged => 'Password Changed!';

  @override
  String get commonCongratulations => 'Congratulations!';

  @override
  String get commonTermsOfUse => 'Terms of Use';

  @override
  String get commonPrivacyPolicy => 'Privacy Policy';

  @override
  String get authSignInWithApple => 'Sign in with Apple';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get commonSignUp => 'Sign Up';

  @override
  String get authNoAccount => 'Don’t have an account? ';

  @override
  String get authLoggingIn => 'Logging in';

  @override
  String get authLogin => 'Login';

  @override
  String get authForgotPasswordLink => 'Forgot password?';

  @override
  String get commonPassword => 'Password';

  @override
  String get authSignInSubtitle => 'Sign in to your account';

  @override
  String get commonSignIn => 'Sign In';

  @override
  String get authSocialLoginSuccess => 'Social login successful!';

  @override
  String get authLoginSuccess => 'Login successful!';

  @override
  String get authVerificationCodeLabel => 'VERIFICATION CODE';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonUpdating => 'Updating';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authCreateNewPassword => 'Create New Password';

  @override
  String get authResetSuccess => 'Reset successful!';

  @override
  String get authPasswordsDontMatch => 'Passwords don\'t match';

  @override
  String get authPasswordMinLength => 'Minimum 6 characters';

  @override
  String get authAccountCreatedMessage =>
      'Your account is complete, please enjoy\nthe best menu from us.';

  @override
  String get authAccountCreated => 'Account Created!';

  @override
  String get welcomeHaveAccount => 'Already have an account? ';

  @override
  String get welcomeSubtitle =>
      'Scan ingredients. Save recipes.\nPlan effortlessly.';

  @override
  String get welcomeTitle => 'Welcome to Cooked';

  @override
  String get authEmailOrPhoneFallback => 'mail/phone number';

  @override
  String get authYourEmailFallback => 'your email';

  @override
  String get themeDarkOn => 'On';

  @override
  String get themeDarkOff => 'Off';

  @override
  String get themeSystemSettings => 'System Settings';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeMatchPhone => 'Match your phone\'s setting';

  @override
  String get themeAlwaysDark => 'Always use the dark theme';

  @override
  String get themeAlwaysLight => 'Always use the light theme';

  @override
  String get themeSystemHint =>
      'If System Settings is selected, the app\'s appearance will automatically switch to match your device\'s setting.';

  @override
  String get notifSecurityNote =>
      'Account and security alerts (like new sign-ins or payment issues) are always sent while push notifications are enabled.';

  @override
  String profileInviteMessage(String link) {
    return 'You should try Cooked. It turns what\'s in your fridge into recipes in seconds and saves you money on takeout. Click here to join! $link';
  }

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get langSuggestRow => 'Suggest a language…';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get langUpdateFailed => 'Failed to update language';

  @override
  String get langSuggestionFailed =>
      'Couldn\'t send your suggestion. Please try again.';

  @override
  String get langSuggestionThanks => 'Thanks! We got your suggestion.';

  @override
  String get langSendSuggestion => 'Send suggestion';

  @override
  String get langSuggestHint => 'e.g. Italian, Wolof, Portuguese…';

  @override
  String get langSuggestMessage =>
      'Which language would you like Cooked in? We\'ll use your suggestions to decide what comes next.';

  @override
  String get langSuggestTitle => 'Suggest a language';

  @override
  String get commonSaveChanges => 'Save Changes';

  @override
  String get commonName => 'Name';

  @override
  String get accountChangePicture => 'Change Picture';

  @override
  String get accountDefaultName => 'Chef';

  @override
  String get settingsMyAccount => 'My Account';

  @override
  String get accountProfileUpdated => 'Profile updated successfully!';

  @override
  String get notifNewsSubtitle => 'New features, recipes and special offers';

  @override
  String get notifNews => 'News, Tips & Offers';

  @override
  String get notifRemindersSubtitle =>
      'Trial ending and subscription reminders';

  @override
  String get notifReminders => 'Reminders';

  @override
  String get notifPushSubtitle => 'Receive notifications on this device';

  @override
  String get notifPush => 'Push Notifications';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDeletePermanently => 'Delete permanently';

  @override
  String get settingsDeleteAccountConfirm =>
      'Are you sure you want to permanently delete your account? This action cannot be undone and you will lose all your data (Cookbooks, grocery items, etc.).';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutConfirm =>
      'Are you sure you want to log out of your account? You will need to enter your credentials to log back in.';

  @override
  String get settingsContactSupport => 'Contact Support';

  @override
  String get settingsGiftCooked => 'Gift Cooked to a friend';

  @override
  String get settingsInviteFriends => 'Invite friends';

  @override
  String get settingsManageSubscription =>
      'Manage Subscription & Restore Purchases';

  @override
  String get settingsKitchenEquipment => 'Kitchen Equipment';

  @override
  String get settingsCuisineFlavor => 'Cuisine + Flavor DNA';

  @override
  String get settingsAllergies => 'Allergies';

  @override
  String get settingsDietaryPreferences => 'Dietary Preferences';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get pwdCurrentPassword => 'Current Password';

  @override
  String get pwdUpdated => 'Password updated successfully.';

  @override
  String get pwdNoMatch => 'New passwords do not match.';

  @override
  String get pwdFillAllFields => 'Please fill in all fields.';

  @override
  String get optTotalBeginner => 'Total Beginner';

  @override
  String get optICanBarelyBoilWater => 'I can barely boil water';

  @override
  String get optHomeCook => 'Home Cook';

  @override
  String get optIFollowRecipesStepByStep => 'I follow recipes step by step';

  @override
  String get optConfidentCook => 'Confident Cook';

  @override
  String get optIImproviseAndExperiment => 'I improvise and experiment';

  @override
  String get optAdvancedSemiPro => 'Advanced / Semi-Pro';

  @override
  String get optIWantChallengingRecipes => 'I want challenging recipes.';

  @override
  String get optUnder15Minutes => 'Under 15 minutes';

  @override
  String get optUltraFastMeals => 'Ultra-fast meals';

  @override
  String get optForWhenYouNeedFoodInstantly =>
      'For when you need food instantly.';

  @override
  String get opt_1530Minutes => '15–30 minutes';

  @override
  String get optQuickButNotRushed => 'Quick but not rushed';

  @override
  String get optPerfectForQuickWeekdayMeals =>
      'Perfect for quick weekday meals.';

  @override
  String get opt_3060Minutes => '30–60 minutes';

  @override
  String get optANormalCookingWindow => 'A normal cooking window';

  @override
  String get optGreatForRelaxedDinners => 'Great for relaxed dinners.';

  @override
  String get opt_12Hours => '1–2 hours';

  @override
  String get optIEnjoyTheCookingProcess => 'I enjoy the cooking process';

  @override
  String get optForWeekendCookingSessions => 'For weekend cooking sessions.';

  @override
  String get optAnyAmountOfTime => 'Any amount of time';

  @override
  String get optShowMeEverything => 'Show me everything';

  @override
  String get optAllRecipesAreOnTheTable => 'All recipes are on the table.';

  @override
  String get optWeeklyMealPlan => 'Weekly meal plan';

  @override
  String get optGetAFullPlanEveryWeek => 'Get a full plan every week';

  @override
  String get optDailySuggestions => 'Daily suggestions';

  @override
  String get optOneRecipeEachMorning => 'One recipe each morning';

  @override
  String get optILlPlanMyself => 'I\'ll plan myself';

  @override
  String get optJustShowMeRecipes => 'Just show me recipes';

  @override
  String get optPlanByIngredients => 'Plan by ingredients';

  @override
  String get optScanMyFridgeGiveMeA => 'Scan my fridge, give me a plan';

  @override
  String get optJustMe => 'Just me';

  @override
  String get opt_1Person => '1 person';

  @override
  String get optTwoPeople => 'Two people';

  @override
  String get optCoupleOrPair => 'Couple or pair';

  @override
  String get opt_34People => '3–4 people';

  @override
  String get optSmallFamily => 'Small family';

  @override
  String get opt_56People => '5–6 people';

  @override
  String get optLargerFamily => 'Larger family';

  @override
  String get opt_7PlusPeople => '7+ people';

  @override
  String get optLargeFamilyOrGroup => 'Large family or group';

  @override
  String get optItVaries => 'It varies';

  @override
  String get optILlAdjustPerRecipe => 'I\'ll adjust per recipe';

  @override
  String get optSaveMoney => 'Save money';

  @override
  String get optEatHealthier => 'Eat healthier';

  @override
  String get optGainMuscle => 'Gain muscle';

  @override
  String get optLoseWeight => 'Lose weight';

  @override
  String get optWasteLessFood => 'Waste less food';

  @override
  String get optLearnToCook => 'Learn to cook';

  @override
  String get optDiscoverRecipes => 'Discover recipes';

  @override
  String get optMealPrepEasier => 'Meal prep easier';

  @override
  String get optNoRestrictions => 'No Restrictions';

  @override
  String get optIEatEverything => 'I eat everything';

  @override
  String get optVegetarian => 'Vegetarian';

  @override
  String get optNoMeatOrFish => 'No meat or fish';

  @override
  String get optVegan => 'Vegan';

  @override
  String get optNoAnimalProducts => 'No animal products';

  @override
  String get optPescatarian => 'Pescatarian';

  @override
  String get optFishOkNoOtherMeat => 'Fish OK, no other meat';

  @override
  String get optGlutenFree => 'Gluten-Free';

  @override
  String get optNoWheatOrGluten => 'No wheat or gluten';

  @override
  String get optDairyFree => 'Dairy Free';

  @override
  String get optNoMilkOrDairy => 'No milk or dairy';

  @override
  String get optHalal => 'Halal';

  @override
  String get optIslamicDietaryLaws => 'Islamic dietary laws';

  @override
  String get optKosher => 'Kosher';

  @override
  String get optJewishDietaryLaws => 'Jewish Dietary Laws';

  @override
  String get optKetoLowCarb => 'Keto/Low-Carb';

  @override
  String get optHighFatLowCarb => 'High fat, low carb';

  @override
  String get optHighProtein => 'High Protein';

  @override
  String get optHighProteinFoods => 'High protein foods';

  @override
  String get optTreeNuts => 'Tree nuts';

  @override
  String get optPeanuts => 'Peanuts';

  @override
  String get optShellfish => 'Shellfish';

  @override
  String get optFish => 'Fish';

  @override
  String get optEggs => 'Eggs';

  @override
  String get optSoy => 'Soy';

  @override
  String get optDairyMilk => 'Dairy Milk';

  @override
  String get optWheatGluten => 'Wheat/Gluten';

  @override
  String get optSesame => 'Sesame';

  @override
  String get optNoAllergies => 'No Allergies';

  @override
  String get optItalian => 'Italian';

  @override
  String get optJapanese => 'Japanese';

  @override
  String get optMexican => 'Mexican';

  @override
  String get optChinese => 'Chinese';

  @override
  String get optThai => 'Thai';

  @override
  String get optMiddleEastern => 'Middle Eastern';

  @override
  String get optWestAfrican => 'West African';

  @override
  String get optEastAfrican => 'East African';

  @override
  String get optCaribbean => 'Caribbean';

  @override
  String get optIndian => 'Indian';

  @override
  String get optSpanish => 'Spanish';

  @override
  String get optGreek => 'Greek';

  @override
  String get optFrench => 'French';

  @override
  String get optKorean => 'Korean';

  @override
  String get optMediterranean => 'Mediterranean';

  @override
  String get optOthers => 'Others';

  @override
  String get optOven => 'Oven';

  @override
  String get optStovetopGasBurner => 'Stovetop / Gas burner';

  @override
  String get optMicrowave => 'Microwave';

  @override
  String get optAirFryer => 'Air fryer';

  @override
  String get optBlenderLiquidizer => 'Blender / Liquidizer';

  @override
  String get optFoodProcessor => 'Food processor';

  @override
  String get optInstantPotPressureCooker => 'Instant Pot / Pressure cooker';

  @override
  String get optGrillBbq => 'Grill / BBQ';

  @override
  String get optRiceCooker => 'Rice cooker';

  @override
  String get optStandMixerHandMixer => 'Stand mixer / Hand mixer';

  @override
  String get optSteamer => 'Steamer';

  @override
  String get optOther => 'Other';

  @override
  String get optScanIngredients => 'Scan Ingredients';

  @override
  String get optTakeAPhotoAndGetRecipes =>
      'Take a photo and get recipes from what you already have.';

  @override
  String get optMealPlanning => 'Meal Planning';

  @override
  String get optPlanYourMealsForTheWeek =>
      'Plan your meals for the week without starting from scratch.';

  @override
  String get optImportRecipes => 'Import Recipes';

  @override
  String get optSaveRecipesFromTiktokInstagramYoutube =>
      'Save recipes from TikTok, Instagram, YouTube, or websites.';

  @override
  String get optGroceryLists => 'Grocery Lists';

  @override
  String get optTurnRecipesIntoShoppingListsAutomatically =>
      'Turn recipes into shopping lists automatically.';

  @override
  String get optDailyRecipeInspiration => 'Daily recipe inspiration';

  @override
  String get optMorningSuggestion => 'Morning suggestion';

  @override
  String get optGroceryReminder => 'Grocery Reminder';

  @override
  String get optRememberWhatToBuyBeforeIngredients =>
      'Remember what to buy before ingredients run out.';

  @override
  String get optMild => 'Mild';

  @override
  String get optNoHeatAtAll => 'No heat at all';

  @override
  String get optMedium => 'Medium';

  @override
  String get optJustAHintOfSpice => 'Just a hint of spice';

  @override
  String get optSpicy => 'Spicy';

  @override
  String get optIEnjoySpice => 'I enjoy spice';

  @override
  String get optHot => 'Hot';

  @override
  String get optTheSpicierTheBetter => 'The spicier the better';

  @override
  String get optInferno => 'Inferno';

  @override
  String get optIPutHotSauce => 'I put hot sauce';

  @override
  String get optUnder18 => 'Under 18';

  @override
  String get optUnder50 => 'Under \$50';

  @override
  String get optIDonTKnowWhatTo => 'I don\'t know what to cook';

  @override
  String get optCookingTakesTooMuchTime => 'Cooking takes too much time';

  @override
  String get optISpendTooMuchOnTakeout => 'I spend too much on takeout';

  @override
  String get optHealthyEatingFeelsDifficult => 'Healthy eating feels difficult';

  @override
  String get optGroceryShoppingIsStressful => 'Grocery shopping is stressful';

  @override
  String get optAlmostNever => 'Almost never';

  @override
  String get optSometimes => 'Sometimes';

  @override
  String get optWeekly => 'Weekly';

  @override
  String get optConstantly => 'Constantly';

  @override
  String get optAnchovies => 'Anchovies';

  @override
  String get optBlackLicorice => 'Black licorice';

  @override
  String get optBrusselsSprouts => 'Brussels sprouts';

  @override
  String get optBlueCheese => 'Blue cheese';

  @override
  String get optOysters => 'Oysters';

  @override
  String get optSardines => 'Sardines';

  @override
  String get optOlives => 'Olives';

  @override
  String get optBeets => 'Beets';

  @override
  String get optCottageCheese => 'Cottage cheese';

  @override
  String get optOkra => 'Okra';

  @override
  String get optSpam => 'Spam';

  @override
  String get optTofu => 'Tofu';

  @override
  String get optTurnips => 'Turnips';

  @override
  String get optKimchi => 'Kimchi';

  @override
  String get optEggplant => 'Eggplant';

  @override
  String get optCauliflower => 'Cauliflower';

  @override
  String get optCilantro => 'Cilantro';

  @override
  String get optLimaBeans => 'Lima beans';

  @override
  String get optPickledHerring => 'Pickled herring';

  @override
  String get optSauerkraut => 'Sauerkraut';

  @override
  String get optGoatCheese => 'Goat cheese';

  @override
  String get optBitterMelon => 'Bitter melon';

  @override
  String get optMushrooms => 'Mushrooms';

  @override
  String get optGrapefruit => 'Grapefruit';

  @override
  String get opt_23TimesAWeek => '2–3 times a week';

  @override
  String get optMetric => 'Metric';

  @override
  String get optImperial => 'Imperial';

  @override
  String get optLiver => 'Liver';

  @override
  String get onbBestGuess => 'Take your best guess. We’ll do the math';

  @override
  String get onbEatingOutTitle =>
      'How much do you spend eating out every week?';

  @override
  String get onbThatCouldBeOver => 'That could be over';

  @override
  String get onbPotentialYearlySavings => 'Potential Yearly Savings';

  @override
  String get onbThanHome => 'Than cooking at home';

  @override
  String get onbNearlyB => ' more';

  @override
  String get onbNearlyA => 'That is nearly ';

  @override
  String get onbMadeAtHome => 'Made at home';

  @override
  String get onbHomeCooked => 'Home Cooked';

  @override
  String get onbThreeMealsWeek => '3 Meals / Week';

  @override
  String get onbTakeout => 'Takeout';

  @override
  String get onbCostingSubtitle => 'Small decisions become\nexpensive habits';

  @override
  String get onbCostingTitleD => 'time';

  @override
  String get onbCostingTitleC => 'more than ';

  @override
  String get onbCostingTitleB => 'costing\n';

  @override
  String get onbCostingTitleA => 'And it’s ';

  @override
  String get onbDinnerSubtitle => 'No stress. No guesswork';

  @override
  String get onbDinnerTitleB => 'figured out';

  @override
  String get onbDinnerTitleA => 'Imagine dinner\nalready ';

  @override
  String get onbViewOtherPlans => 'View other plans';

  @override
  String get onbTrialReminder =>
      'We\'ll send you a reminder before your trial ends.';

  @override
  String get onbTrialDay3 => 'Day 3';

  @override
  String get onbTrialDay2 => 'Day 2';

  @override
  String get onbTrialGuideToday =>
      'Unlock personalized recipes, meal suggestions, and ingredient scanning.';

  @override
  String get commonToday => 'Today';

  @override
  String get onbTrialGuideSubtitle => 'Get the most out of your Cooked trial.';

  @override
  String get onbTrialGuideTitle => 'Free trial guide';

  @override
  String get onbTryForZero => 'Start 3-Day Free Trial';

  @override
  String get onbKeepEverything =>
      'Create your account to keep your recipes, meal plans, grocery lists, and savings tracker.';

  @override
  String get onbTryFreeB => 'free';

  @override
  String get onbTryFreeA => 'We want you to try\nCooked for ';

  @override
  String get onbBenefitGrocery => 'Smart grocery lists that save you money';

  @override
  String get onbBenefitPlans => 'Personalized meal plans';

  @override
  String get onbBenefitRecipes => 'Full access to 10,000+ chef-curated recipes';

  @override
  String get onbGroceriesUnusedTitle => 'How often do groceries go unused?';

  @override
  String get onbOver => 'over ';

  @override
  String get onbHouseholdWastes => 'The average household wastes';

  @override
  String get onbHandlesSubtitle => 'We plan. You cook.';

  @override
  String get onbHandlesTitleB => 'meals';

  @override
  String get onbHandlesTitleA => 'Cooked handles\nall your ';

  @override
  String get onbHealthySubtitle =>
      'Recipes you’ll actually look forward\nto eating.';

  @override
  String get onbHealthyTitleD => 'second job';

  @override
  String get onbHealthyTitleC => ' a\n';

  @override
  String get onbHealthyTitleB => 'feel like';

  @override
  String get onbHealthyTitleA => 'Healthy eating\nshouldn’t ';

  @override
  String get onbMealsSubtitle =>
      'Dinner shouldn’t be the hardest\ndecision of your day';

  @override
  String get onbMealsTitleD => ' again';

  @override
  String get onbMealsTitleC => 'to cook';

  @override
  String get onbMealsTitleB => 'what\n';

  @override
  String get onbMealsTitleA => 'Never wonder ';

  @override
  String onbBuildingSystem(String dots) {
    return 'Building your\npersonalized cooking\nsystem$dots';
  }

  @override
  String get onbTaskPersonalizing => 'Personalizing recommendations';

  @override
  String get onbTaskFeed => 'Building your meal feed';

  @override
  String get onbTaskSavings => 'Calculating savings';

  @override
  String get onbTaskFindRecipes => 'Finding recipes you\'ll love';

  @override
  String get onbTaskTastes => 'Learning your tastes';

  @override
  String get onbRepetitionSubtitle => 'Built around your taste.';

  @override
  String get onbRepetitionTitle =>
      'Tired of eating the\nsame thing every\nweek?';

  @override
  String get onbOfYourLife => 'of your life\nevery year';

  @override
  String get onbDays => 'Days';

  @override
  String get onbSpentDeciding => 'Spent deciding\nwhat to eat';

  @override
  String get onbHours => 'Hours';

  @override
  String get onbNotAloneSubtitle =>
      'Most people spend over 200 hours\nevery year deciding what to eat';

  @override
  String get onbNotAloneB => 'not alone';

  @override
  String get onbNotAloneA => 'You’re ';

  @override
  String get onbSkillSubtitle => 'We\'ll match recipes to your experience.';

  @override
  String get onbSkillTitle => 'What\'s your cooking\nskill level?';

  @override
  String get onbAvoidB => ' recipes.';

  @override
  String get onbAvoidA => 'Great, we\'ll avoid ';

  @override
  String get onbAvoidComplex => 'complex';

  @override
  String get onbAvoidBasic => 'basic';

  @override
  String get onbAvoidBoring => 'boring';

  @override
  String get onbAvoidUntested => 'untested';

  @override
  String get onbAvoidOverlyComplex => 'overly complex';

  @override
  String get onbReview3 =>
      '\"Meal ideas feel personalized\ninstead of random.\"';

  @override
  String get onbReview2 => '\"I finally use the groceries I\nalready have.\"';

  @override
  String get onbReview1 =>
      '\"Cooked helped me stop\nordering dinner every night.\"';

  @override
  String get onbStarsFromThousands => 'Stars from thousands\nof food lovers';

  @override
  String get onbUnlock => 'Unlock';

  @override
  String get onbBadgeHealthier => 'Healthier meals,\nmade easy';

  @override
  String get onbBadgeRecipes => '1,847 recipes\nmatched';

  @override
  String get onbBadgeSaveHours => 'Save 180+ hours/\nyear';

  @override
  String get onbBadgeSaveMoney => 'Save \$2,496/\nyear';

  @override
  String get onbRecipesCurated => 'recipes curated for your taste';

  @override
  String get onbPlanReadySubtitle =>
      'Built around your goals, taste,\nschedule, and savings';

  @override
  String get onbPlanReady => 'Your personalized\nplan is ready.';

  @override
  String get onbStartArrow => 'Start →';

  @override
  String get onbBuildProfileSubtitle =>
      'The more we learn, the better your recommendations';

  @override
  String get onbBuildProfileB => 'profile';

  @override
  String get onbBuildProfileA => 'Let’s build your\ncooking ';

  @override
  String get onbTaskCuisines => 'Learning your cuisine preferences';

  @override
  String get onbTaskDietary => 'Understanding your dietary preferences';

  @override
  String get onbTaskPotentialSavings => 'Calculating your potential savings';

  @override
  String get onbTaskChallenges => 'Understanding your cooking challenges';

  @override
  String get onbCookingSmarter => 'Just by cooking smarter';

  @override
  String get onbEveryYear => 'Every Year';

  @override
  String get onbCouldSave => 'You could save\napproximately';

  @override
  String get optSweet => 'Sweet';

  @override
  String get optSavory => 'Savory';

  @override
  String get optCrunchyTextures => 'Crunchy textures';

  @override
  String get optSoftCreamy => 'Soft & creamy';

  @override
  String get flavorLeaningSweet => 'Sweet leaning';

  @override
  String get flavorLeaningSavory => 'Savory leaning';

  @override
  String get flavorLeaningBalanced => 'Balanced leaning';

  @override
  String get flavorTextureCrunchy => 'Crunchy texture';

  @override
  String get flavorTextureCreamy => 'Creamy texture';

  @override
  String get flavorTextureBalanced => 'Balanced texture';

  @override
  String get onbCreateAccount => 'Create Account';

  @override
  String get onbEmailHint => 'john@example.com';

  @override
  String get onbNameHint => 'John Doe';

  @override
  String get commonFullName => 'Full Name';

  @override
  String get onbCreateAccountSubtitle => 'Secure your recipes and preferences';

  @override
  String get onbCreateAccountTitle => 'Create your account';

  @override
  String get valPasswordMin => 'Password must be at least 6 characters';

  @override
  String get valEnterPassword => 'Please enter a password';

  @override
  String get valValidEmail => 'Please enter a valid email address';

  @override
  String get valEnterEmail => 'Please enter your email';

  @override
  String get valEnterName => 'Please enter your name';

  @override
  String get onbAgeSubtitle =>
      'We’ll use this to personalize your recommendations';

  @override
  String get onbAgeTitle => 'How old are you?';

  @override
  String get onbAllergiesSubtitle =>
      'We’ll automatically filter recipes for you';

  @override
  String get onbAllergiesTitle =>
      'Do you have any\ndietary restrictions or\nallergies?';

  @override
  String get onbMoreDietLater =>
      'Additional dietary preferences can be updated later in Settings.';

  @override
  String get onbCommonAllergies => 'Common allergies';

  @override
  String get onbTypeCuisine => 'Type a cuisine...';

  @override
  String get onbSpecifyCuisines => 'Specify other cuisines';

  @override
  String get onbCuisinesSubtitle =>
      'Pick your favorites. The more you choose, the\nbetter your recommendations';

  @override
  String get onbCuisinesTitle => 'What cuisines do\nyou love?';

  @override
  String get onbSelectOneCuisine => 'Please select at least one cuisine';

  @override
  String get commonSelectAllThatApply => 'Select all that apply.';

  @override
  String get onbDietTitle => 'What\'s your dietary profile?';

  @override
  String get onbMorePrefsLater =>
      'More preferences can be updated later in Settings.';

  @override
  String get onbDislikeHint => 'Type a food you dislike (e.g. Pork, Mayo)...';

  @override
  String get onbDislikesSubtitle =>
      'We’ll keep them out of your\nrecommendations';

  @override
  String get onbDislikesTitle => 'What foods don’t\nyou like?';

  @override
  String get onbFeaturesSubtitle => 'Pick the features you’ll use most';

  @override
  String get onbFeaturesTitle => 'What are you most\nexcited about?';

  @override
  String get onbProfilePreview => 'YOUR PROFILE PREVIEW';

  @override
  String get onbSpiceTolerance => 'Spice Tolerance';

  @override
  String get onbFlavorSubtitle => 'Move the sliders to match your taste';

  @override
  String get onbFlavorTitle => 'Your flavor DNA';

  @override
  String get onbFrustrationsSubtitle => 'Choose the ones that feel most true';

  @override
  String get onbFrustrationsTitle =>
      'What\'s holding you back from cooking more?';

  @override
  String get onbGoalsSubtitle => 'We’ll personalize everything around it';

  @override
  String get onbGoalsTitle => 'What’s your goal\nright now?';

  @override
  String get onbEquipmentHint => 'Enter equipment and press Enter';

  @override
  String get onbSpecifyEquipment => 'Specify other equipment';

  @override
  String get onbKitchenSubtitle => 'Select your equipment';

  @override
  String get onbKitchenTitle => 'What\'s in your kitchen?';

  @override
  String get onbPlanningSubtitle => 'We\'ll customize the experience for you';

  @override
  String get onbPlanningTitle => 'How do you like to plan meals?';

  @override
  String get onbNotifFooter => 'You can adjust these anytime in your settings';

  @override
  String get onbTurnOnAll => 'Turn on all';

  @override
  String get onbTurnOffAll => 'Turn off all';

  @override
  String get onbNotifSubtitle => 'Choose what you\'d like to hear about';

  @override
  String get onbNotifTitle => 'Stay inspired with new recipes';

  @override
  String get onbVerifyContinue => 'Verify & Continue';

  @override
  String get onbNoCode => 'Didn\'t receive a code?';

  @override
  String onbOtpSentTo(String email) {
    return 'Please enter the 6-digit code we sent to\n$email';
  }

  @override
  String get onbVerifyAccount => 'Verify your account';

  @override
  String get onbStartCooking => 'Start Cookin\'';

  @override
  String get onbUsesIngredients => 'Uses your ingredients';

  @override
  String get onbQuickDinner => 'Quick dinner';

  @override
  String get onbMatchesTaste => 'Matches your taste';

  @override
  String get onbWhyPicked => 'Why we picked this';

  @override
  String get onbPerfectMealSubtitle =>
      'Based on your goals, taste, and cooking';

  @override
  String get onbPerfectMeal => 'Perfect meal for you';

  @override
  String commonSoonSuffix(String label) {
    return '$label (Soon)';
  }

  @override
  String get authSignInWithEmail => 'Sign in with Email';

  @override
  String get onbSavePlan => 'Save your\npersonalized plan';

  @override
  String get onbTargetSubtitle => 'This helps us recommend the right portions';

  @override
  String get onbTargetTitle => 'Who are you usually\ncooking for?';

  @override
  String get onbCookingTime => 'Cooking time';

  @override
  String get onbTimeSubtitle =>
      'We’ll prioritize recipes that fit your schedule';

  @override
  String get onbTimeTitle => 'How much time do you\nusually have to cook?';

  @override
  String get priceBilledMonthly => 'Billed monthly';

  @override
  String priceBilledPerMonth(String price) {
    return 'Billed $price per month';
  }

  @override
  String get commonProcessing => 'Processing';

  @override
  String get commonContinuing => 'Continuing';

  @override
  String get onbStartTrial => 'Start My 3-Day Free Trial';

  @override
  String get onbSkipEatMost => 'Skip — I eat most things';

  @override
  String get commonConnecting => 'Connecting';

  @override
  String onbGoogleSignupTip(String error) {
    return '$error\n\nTip: If the problem persists with Google, try signing up via email.';
  }

  @override
  String get onbCompleteAccountInfo =>
      'Please complete account info to save your profile';

  @override
  String get payCouldNotStart => 'Could not initiate purchase';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get referralCodeHint => 'Referral Code';

  @override
  String get referralCanSkip => 'You can skip this step';

  @override
  String get referralEnterCode => 'Enter referral code (optional)';

  @override
  String giftUnlocked(String plan) {
    return '🎉 $plan of Cooked Premium unlocked!';
  }

  @override
  String priceTrialThenYearly(String price) {
    return '3 days free, then $price/year';
  }

  @override
  String get priceTrialThenBilledYearly => '3 days free, then billed yearly';

  @override
  String commonCancelAnytime(String text) {
    return '$text. Cancel anytime.';
  }

  @override
  String get trialHaveReferralCode => 'Do you have a referral code?';

  @override
  String get trialMonthlyNoTrialNoPrice =>
      'No free trial. Billed immediately. Cancel anytime.';

  @override
  String trialMonthlyNoTrial(String price) {
    return 'No free trial. Billed immediately at $price/month. Cancel anytime.';
  }

  @override
  String get commonProcessingDots => 'Processing...';

  @override
  String get trialTryFree => 'Start 3-Day Free Trial';

  @override
  String get trialSubscribeNow => 'Subscribe Now';

  @override
  String get trialNoPaymentToday => 'No payment due today';

  @override
  String get trialThreeDaysFree => '3 days free';

  @override
  String get planYearly => 'Yearly';

  @override
  String get planMonthly => 'Monthly';

  @override
  String get trialSubtitle => 'Built around your goals, schedule, and taste.';

  @override
  String get trialTitle => 'Unlock your full\npersonalized cooking system.';

  @override
  String pricePerYearShort(String price) {
    return '$price /year';
  }

  @override
  String pricePerMonthShort(String price) {
    return '$price /mo';
  }

  @override
  String get faqImportQ => 'How do I import a recipe?';

  @override
  String get faqImportA =>
      'Go to the Import tab, paste a link, or use the camera to scan a recipe.';

  @override
  String get faqShareQ => 'Can I share my recipes?';

  @override
  String get faqShareA =>
      'Yes! Open a recipe and tap the share button in the top right corner.';

  @override
  String get faqCookbookQ => 'How do I create a cookbook?';

  @override
  String get faqCookbookA =>
      'From the Home tab, tap the « + » button next to Your Cookbooks.';

  @override
  String get faqPasswordQ => 'How do I change my password?';

  @override
  String get faqPasswordA =>
      'Go to Settings → Change Password and enter your new password.';

  @override
  String get faqWebQ => 'Is there a web version?';

  @override
  String get faqWebA =>
      'No, Cooked is currently available as a mobile app only.';

  @override
  String get feedbackCatAccount => 'Account';

  @override
  String get feedbackCatPayment => 'Payment';

  @override
  String get feedbackCatScan => 'Scan';

  @override
  String get feedbackCatImport => 'Import';

  @override
  String get feedbackCatRecipe => 'Recipe';

  @override
  String get feedbackCatShopping => 'Shopping';

  @override
  String get feedbackCatOther => 'Other';

  @override
  String prefsFlavorSummary(String spice, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preferences',
      one: '1 preference',
    );
    return '$spice, $_temp0';
  }

  @override
  String savingsFromRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'From $count saved recipes',
      one: 'From 1 saved recipe',
    );
    return '$_temp0';
  }

  @override
  String get activityEmpty =>
      'You haven\'t imported or scanned any recipes yet.';

  @override
  String get activityRecentRecipes => 'Recent Recipes';

  @override
  String get prefsAllergiesUpdateFailed => 'Failed to update allergies';

  @override
  String get prefsFlavorSpice => 'Flavor & Spice';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get prefsFavoriteCuisines => 'Favorite Cuisines';

  @override
  String get prefsCuisineUpdateFailed =>
      'Failed to update cuisine & flavor preferences';

  @override
  String get feedbackHint => 'Describe your problem...';

  @override
  String get feedbackMessage => 'Message';

  @override
  String get feedbackCategory => 'Category';

  @override
  String get feedbackHeadline =>
      'We\'d love to hear from you 💬\nDescribe your problem and we\'ll help you as soon as possible.';

  @override
  String get feedbackFailed => 'Could not send feedback. Please try again.';

  @override
  String get feedbackSent => 'Thanks! Your feedback has been sent.';

  @override
  String get feedbackNoEmail => 'Could not find your account email.';

  @override
  String get feedbackWriteFirst => 'Please write a message first.';

  @override
  String get legalCookies => 'Cookie Policy';

  @override
  String get legalRefundCancellation => 'Refund & Cancellation';

  @override
  String get legalRefund => 'Refund Policy';

  @override
  String get legalTerms => 'Terms & Conditions';

  @override
  String get helpLegal => 'Legal & Policies';

  @override
  String get helpSendFeedbackSubtitle => 'Bugs, ideas, or anything else';

  @override
  String get helpSendFeedback => 'Send Feedback';

  @override
  String get helpHeadline =>
      'Tell us how we can help 👋\nOur team is standing by for service & support!';

  @override
  String get helpTitle => 'Help Center';

  @override
  String get prefsKitchenUpdateFailed => 'Failed to update kitchen equipment';

  @override
  String get giftRedeeming => 'Redeeming...';

  @override
  String get giftRedeem => 'Redeem';

  @override
  String get giftRedeemSubtitle =>
      'Enter your gift code to unlock Cooked Premium on this account.';

  @override
  String get giftRedeemHeadline => 'Someone gifted you Cooked?';

  @override
  String get giftRedeemTitle => 'Redeem a gift';

  @override
  String get savingsScannedAtHome => 'Scanned at home';

  @override
  String get savingsYourSaved => 'Your saved';

  @override
  String get savingsEmpty => 'No scan savings yet';

  @override
  String get savingsTitle => 'Your Savings';

  @override
  String get subAmount => 'Amount';

  @override
  String get commonNotAvailable => 'N/A';

  @override
  String get subFreeTrial => 'Free Trial';

  @override
  String get subPremiumPlan => 'Premium Plan';

  @override
  String get subNoPayments => 'No payment history found';

  @override
  String get subPaymentHistory => 'Payment History';

  @override
  String get subRestorePurchases => 'Restore Purchases';

  @override
  String get subActive => 'Active Subscription';

  @override
  String get subRenew => 'Renew or Upgrade';

  @override
  String get subAlreadyPremium => 'You are already a Premium member!';

  @override
  String get subStatus => 'Status';

  @override
  String get subEndDate => 'End Date';

  @override
  String get subStartDate => 'Start Date';

  @override
  String get subPlan => 'Plan';

  @override
  String get subDetails => 'Subscription Details';

  @override
  String get subTitle => 'Subscription';

  @override
  String get subNothingToRestore => 'No active subscriptions found to restore.';

  @override
  String get subRestored => 'Purchases restored!';

  @override
  String get subExpiringSoon => 'Expiring soon';

  @override
  String subHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours left',
      one: '1 hour left',
    );
    return '$_temp0';
  }

  @override
  String subDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get subExpired => 'Expired';

  @override
  String get subNoActive => 'No active subscription';

  @override
  String get subLoadFailed => 'Failed to load subscription status';

  @override
  String get prefsGoals => 'Onboarding Goals';

  @override
  String get prefsSectionOther => 'Other';

  @override
  String get prefsCookingTarget => 'Cooking Target';

  @override
  String get prefsPlanningStyle => 'Meal Planning Style';

  @override
  String get prefsSectionPlanning => 'Meal Planning & Habits';

  @override
  String get prefsTimePreference => 'Time Preference';

  @override
  String get prefsCookingSkill => 'Cooking Skill';

  @override
  String get prefsSectionCooking => 'Cooking & Skills';

  @override
  String get prefsFoodDislikes => 'Food Dislikes';

  @override
  String get prefsDietaryProfile => 'Dietary Profile';

  @override
  String get prefsSectionDiet => 'Diet';

  @override
  String get prefsUpdateFailed => 'Failed to update preferences';

  @override
  String get prefsUpdated => 'Preferences updated successfully!';

  @override
  String get prefsLoadFailed => 'Failed to load preferences';

  @override
  String get giftPlanOneYear => '1 Year';

  @override
  String get giftPlanThreeMonths => '3 Months';

  @override
  String get giftPlanOneYearDesc =>
      'Give the gift of a 1-year Premium subscription to Cooked. Purchase is not refundable.';

  @override
  String get giftPlanThreeMonthsDesc =>
      'Give the gift of a 3-month Premium subscription to Cooked. Purchase is not refundable.';

  @override
  String giftShareMessage(String plan, String url, String code) {
    return '🎁 I got you $plan of Cooked Premium! Redeem it here: $url\n\nOr open Cooked and enter this code: $code';
  }

  @override
  String get giftTapToCopy => 'Tap to copy';

  @override
  String get giftRefunded => 'Refunded';

  @override
  String get giftRedeemed => 'Redeemed';

  @override
  String get giftNotUsed => 'Not used yet';

  @override
  String get giftBuy => 'Buy gift';

  @override
  String get giftBestValue => 'Best value';

  @override
  String get giftYourGifts => 'Your gifts';

  @override
  String get giftSubtitle =>
      'Buy a gift code and send it to a friend. They redeem it in the app - no subscription needed on their side.';

  @override
  String get giftHeadline => 'Give the gift of Cooked';

  @override
  String get giftTitle => 'Gift Cooked';

  @override
  String get giftSendToFriend => 'Send to a friend';

  @override
  String giftSendThisCode(String plan) {
    return 'Send this $plan code to a friend. We also emailed it to you.';
  }

  @override
  String get giftReady => 'Your gift is ready!';

  @override
  String get giftCodeCopied => 'Gift code copied';

  @override
  String get giftPurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get giftPaymentReceived =>
      'Payment received! We\'ll email you the gift code in a moment.';

  @override
  String shareRecipe(String name, String link) {
    return 'Check out $name on Cooked 🙌\n$link';
  }

  @override
  String shareRecipeByCreator(String creator, String name, String link) {
    return 'Check out $creator\'s $name on Cooked 🙌\n$link';
  }

  @override
  String get savingsComparedTakeout => 'Comparing to ordered takeout.';

  @override
  String get savingsThisMonth => 'This month';

  @override
  String get recipeAlreadySaved =>
      'This recipe is already present in your recipes';

  @override
  String get homeSuggestedRecipes => 'Suggested Recipes';

  @override
  String get cookbookDeleteFailed => 'Failed to delete cookbook';

  @override
  String get cookbookDeleted => 'Cookbook deleted';

  @override
  String get cookbookDelete => 'Delete Cookbook';

  @override
  String get commonOperationFailed => 'Operation failed';

  @override
  String get cookbookUnpinned => 'Cookbook unpinned';

  @override
  String get cookbookPinned => 'Cookbook pinned';

  @override
  String get cookbookPin => 'Pin Cookbook';

  @override
  String get cookbookUnpin => 'Unpin Cookbook';

  @override
  String get cookbookEdit => 'Edit Cookbook';

  @override
  String get cookbookAddRecipes => 'Add Recipes';

  @override
  String get cookbookNew => 'New Cookbook';

  @override
  String get feedbackSubmit => 'Submit Feedback';

  @override
  String get feedbackThanks => 'Thank you for your feedback!';

  @override
  String get feedbackTypeHere => 'Type your feedback here...';

  @override
  String get feedbackCardSubtitle =>
      'Share your thoughts, ideas, or anything that could make your experience better.';

  @override
  String get feedbackCardTitle => 'Help us improve Cooked';

  @override
  String get feedbackCardButton => 'Send feedback';

  @override
  String get recipeDelete => 'Delete Recipe';

  @override
  String get recipeShare => 'Share Recipe';

  @override
  String get recipeAddToCookbook => 'Add to Cookbook';

  @override
  String get recipeRemoveFromCookbook => 'Remove from Cookbook';

  @override
  String get recipeUnpin => 'Unpin Recipe';

  @override
  String get recipePin => 'Pin Recipe';

  @override
  String get recipeRemovedToast => 'Recipe removed from saved';

  @override
  String get recipeSavedToast => 'Recipe saved to favorites!';

  @override
  String get navImport => 'Import';

  @override
  String get navScan => 'Scan';

  @override
  String get navExplore => 'Explore';

  @override
  String get commonTryDifferentSearch => 'Try a different search term.';

  @override
  String get homeBrowseRecipes => 'Browse Recipes';

  @override
  String get homeNoSavedSubtitle =>
      'Explore our recipes and save your favorites\nto build your personal collection.';

  @override
  String get homeNoSavedTitle => 'No saved recipes yet';

  @override
  String get homeAddCookbook => 'Add cookbook';

  @override
  String get homeCookbookEmptySubtitle =>
      'Save your favorite recipes and\nkeep them all in one place.';

  @override
  String get homeCookbookEmptyTitle => 'Start building your cookbook';

  @override
  String get commonViewAll => 'View All';

  @override
  String get homeSavedRecipes => 'Saved Recipes';

  @override
  String get homeSuggested => 'Suggested for you';

  @override
  String get homeRecentlyViewed => 'Recently Viewed';

  @override
  String get homeCookbooks => 'Cookbooks';

  @override
  String get homeYourCookbooks => 'Your Cookbooks';

  @override
  String get homeSearchHint => 'Search your recipes';

  @override
  String get homeHeadline => 'What would you like to cook today?';

  @override
  String get navGrocery => 'Grocery';

  @override
  String get navScanRecipe => 'Scan Recipe';

  @override
  String get navHome => 'Home';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0';
  }

  @override
  String recipeCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Recipes',
      one: '1 Recipe',
    );
    return '$_temp0';
  }

  @override
  String get cookbookDefaultName => 'Cookbook';

  @override
  String get recipePinned => 'Recipe pinned';

  @override
  String get recipeUnpinned => 'Recipe unpinned';

  @override
  String get recipePinFailed => 'Failed to pin recipe';

  @override
  String get recipeRemovedFromCookbook => 'Removed from Cookbook';

  @override
  String get recipeDeleted => 'Recipe deleted';

  @override
  String get cookbookEmptyTitle => 'No recipes yet';

  @override
  String get cookbookEmptySubtitle =>
      'Start adding recipes to this cookbook by scanning, importing or exploring.';

  @override
  String get recipeServings => 'Servings';

  @override
  String get recipeQuantitiesAdjust => 'Quantities adjust automatically';

  @override
  String get commonLoadingDots => 'Loading...';

  @override
  String get commonGoBack => 'Go Back';

  @override
  String recipeServingsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count People',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get recipeAddToGrocery => 'Add to Grocery';

  @override
  String get recipeSteps => 'Steps';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeAlsoRemoveSaved =>
      'Do you also want to remove this recipe from Saved Recipes?';

  @override
  String get commonNo => 'No';

  @override
  String get commonYes => 'Yes';

  @override
  String get recipeRemovedBoth => 'Removed from Cookbook and Saved Recipes';

  @override
  String get recipeNoIngredients => 'No ingredients listed';

  @override
  String get recipeNoIngredientsHint =>
      'Check the recipe description for details.';

  @override
  String get recipeNoEquipment => 'No specific equipment listed';

  @override
  String get recipeNoEquipmentHint =>
      'Standard kitchen tools should be enough.';

  @override
  String get recipeNoSteps => 'No steps listed';

  @override
  String get recipeNoStepsHint => 'Follow your intuition or check the source.';

  @override
  String get recipeRequiredEquipment => 'Required Equipment';

  @override
  String get recipeNotesTips => 'Notes / Tips';

  @override
  String get recipeTonightSaving => 'Tonight’s Saving';

  @override
  String get recipeOrderingNearby => 'Ordering nearby';

  @override
  String get recipeMakingAtHome => 'Making at home';

  @override
  String get recipeEstimatedSavings => 'Estimated savings';

  @override
  String get viewAllCuisine => 'Cuisine';

  @override
  String get viewAllSearchCuisine => 'Search cuisine ...';

  @override
  String get viewAllSearchCategory => 'Search category ...';

  @override
  String viewAllSearchCuisineRecipes(String cuisine) {
    return 'Search $cuisine recipes...';
  }

  @override
  String get viewAllSearchRecent => 'Search recently viewed recipes..';

  @override
  String get viewAllSearchAll => 'Search recipes, cookbooks....';

  @override
  String get viewAllNoCookbooks => 'No cookbooks found.';

  @override
  String get viewAllNoCookbooksMatch => 'No cookbooks match your search.';

  @override
  String get viewAllNoRecipesMatch => 'No recipes match your search.';

  @override
  String get viewAllNoRecipes => 'No recipes found.';

  @override
  String get commonRecipes => 'Recipes';

  @override
  String get recipeDeleteFailed =>
      'Couldn\'t delete this recipe. Please try again.';

  @override
  String get recipeAlreadyInYours => 'Already in your recipes';

  @override
  String get viewAllNoCreatorsMatch => 'No creators match your search.';

  @override
  String get viewAllNoItems => 'No items found.';

  @override
  String get viewAllNoItemsMatch => 'No items match your search.';

  @override
  String get cameraInitializing => 'Starting camera...';

  @override
  String get cameraOnHold => 'On hold';

  @override
  String get cameraOff => 'Camera off';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get cameraFinding => 'Finding cameras...';

  @override
  String get cameraNotFound => 'No camera found';

  @override
  String get cameraReady => 'Ready';

  @override
  String get cameraError => 'Camera unavailable';

  @override
  String get scanAddIngredientsFirst => 'Please add or select ingredients';

  @override
  String get scanTypeIngredient => 'Type Ingredient';

  @override
  String get scanSaved => 'Saved';

  @override
  String get scanGetRecipes => 'Get Recipes';

  @override
  String get scanTypeIngredients => 'Type Ingredients';

  @override
  String get scanEnterOneByOne => 'Enter ingredients one by one';

  @override
  String get scanAddToFind => 'Add ingredients to find recipes you can make';

  @override
  String get scanRecentlyUsed => 'Recently Used';

  @override
  String get scanUseAll => 'Use all';

  @override
  String get scanClearSelection => 'Clear selection';

  @override
  String get scanNoSaved => 'No saved ingredients yet.';

  @override
  String get scanResultsTitleA => 'Recipes You\n';

  @override
  String get scanResultsTitleB => 'Can Cook Now';

  @override
  String scanFoundRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'We found $count recipes for you',
      one: 'We found 1 recipe for you',
    );
    return '$_temp0';
  }

  @override
  String get scanYourIngredients => 'Your Ingredients';

  @override
  String scanFoundItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'We found $count items in your kitchen',
      one: 'We found 1 item in your kitchen',
    );
    return '$_temp0';
  }

  @override
  String get scanViewRecipe => 'View Recipe';

  @override
  String get importRecipePreview => 'Recipe Preview';

  @override
  String get importLinkUnavailable => 'This recipe link isn\'t available.';

  @override
  String get importInvalidLink =>
      'Please enter a valid recipe link (e.g. https://example.com/recipe)';

  @override
  String get importAlreadyExists => 'This recipe is already in your collection';

  @override
  String get importExtractFailed =>
      'We couldn\'t extract a recipe from this link. The page didn\'t contain enough recipe information.';

  @override
  String get importSuccess => 'Recipe imported successfully!';

  @override
  String get importManualSoon => 'Manual recipe entry coming soon';

  @override
  String get importRecipeLink => 'Recipe Link';

  @override
  String get importPasteHint => 'Paste a recipe link...';

  @override
  String get importImporting => 'Importing';

  @override
  String get importSearchWeb => 'Search web';

  @override
  String get importTrending => 'Trending';

  @override
  String get importRecent => 'Recent Imports';

  @override
  String get importNoRecent => 'No recent imports yet.';

  @override
  String get recipeEdit => 'Edit Recipe';

  @override
  String get importRecommended => 'Recommended';

  @override
  String get importSuggestions => 'Suggestions';

  @override
  String get importSearchRecipesHint => 'Search recipes...';

  @override
  String importNoWebResults(String query) {
    return 'No recipes found for “$query”';
  }

  @override
  String get importNoWebResultsHint =>
      'Try another dish name or a simpler search, like “pasta” or “chicken curry”.';

  @override
  String get importSearchResults => 'Search Results';

  @override
  String get commonClear => 'Clear';

  @override
  String get importViewThisRecipe => 'View this recipe';

  @override
  String get importToCooked => 'Import to Cooked';

  @override
  String get filterHighProtein => 'High Protein';

  @override
  String get filterUnder30Min => 'Under 30 Min';

  @override
  String get filterBreakfast => 'Breakfast';

  @override
  String get filterLunch => 'Lunch';

  @override
  String get filterDinner => 'Dinner';

  @override
  String get filterLowCalorie => 'Low Calorie';

  @override
  String get filterOnePot => 'One-Pot';

  @override
  String get filterBudgetFriendly => 'Budget Friendly';

  @override
  String get filterVegetarian => 'Vegetarian';

  @override
  String get filterVegan => 'Vegan';

  @override
  String get filterNoCook => 'No-Cook';

  @override
  String get filterDesserts => 'Desserts';

  @override
  String get filterSnacks => 'Snacks';

  @override
  String get filterSmoothies => 'Smoothies';

  @override
  String get filterSalads => 'Salads';

  @override
  String get filterSoups => 'Soups';

  @override
  String get filterPasta => 'Pasta';

  @override
  String get filterBowls => 'Bowls';

  @override
  String get filterSandwichesWraps => 'Sandwiches & Wraps';

  @override
  String get filterChicken => 'Chicken';

  @override
  String get filterBeef => 'Beef';

  @override
  String get filterSeafood => 'Seafood';

  @override
  String exploreNoFilterMatch(String filter) {
    return 'No recipes match \"$filter\" yet.';
  }

  @override
  String get exploreForYou => 'For You';

  @override
  String get explorePopularCategories => 'Popular Categories';

  @override
  String get exploreCategory => 'Category';

  @override
  String get exploreCuisines => 'Cuisines';

  @override
  String get explorePopularNow => 'Popular Now';

  @override
  String get cookbookSelectRecipes => 'Select Recipes';

  @override
  String get cookbookNameHint => 'Cookbook name';

  @override
  String get cookbookAddRecipesLower => 'Add recipes';

  @override
  String get cookbookSelectForThis => 'Select recipes for this cookbook';

  @override
  String get cookbookSelectedRecipes => 'Selected recipes';

  @override
  String get cookbookUpdated => 'Cookbook updated!';

  @override
  String get cookbookCreated => 'Cookbook created!';

  @override
  String cookbookSaveFailed(String name, String error) {
    return 'Couldn\'t save \"$name\": $error';
  }

  @override
  String cookbookNoMatch(String query) {
    return 'No recipes found matching \"$query\"';
  }

  @override
  String get cookbookExploreRecipes => 'Explore recipes';

  @override
  String get payActivated => 'Premium Activated! Welcome to the Chef Club.';

  @override
  String get paySpecialComeback => 'Special comeback offer';

  @override
  String get payUnlockPremium => 'Unlock Premium';

  @override
  String get payUnlockToKeep => 'Unlock Cooked to keep \ncreating recipes.';

  @override
  String get paySpecialOffer => 'Special Offer';

  @override
  String get paySpecialOfferDesc =>
      'Unlock all features forever with this limited discount.';

  @override
  String get payUnlimitedAccess => 'Unlimited Access';

  @override
  String get payUnlimitedAccessDesc =>
      'Scan your fridge and import recipes without any limits.';

  @override
  String get payExclusiveRecipes => 'Exclusive Recipes';

  @override
  String get payExclusiveRecipesDesc =>
      'Access premium recipes and themed cookbooks.';

  @override
  String get payImmediateAccess => 'Immediate Access';

  @override
  String get payImmediateAccessDesc =>
      'Scan your ingredients and import recipes from any link.';

  @override
  String get payExclusiveContent => 'Exclusive Content';

  @override
  String get payExclusiveContentDesc =>
      'Access premium generated recipes and themed cookbooks.';

  @override
  String get payMasterChef => 'Master Chef Status';

  @override
  String get payMasterChefDesc =>
      'Enjoy a complete ad-free experience with priority AI processing.';

  @override
  String get payPercentOff => '33% OFF';

  @override
  String get payBestValue => 'BEST VALUE';

  @override
  String get payImmediatePremium => 'Immediate Premium Access';

  @override
  String get paySubscribeNow => 'Subscribe now';

  @override
  String pricePerMonthLong(String price) {
    return '$price / month';
  }

  @override
  String pricePerYearLong(String price) {
    return '$price / year';
  }

  @override
  String payDaysFree(String days) {
    return '$days days free';
  }

  @override
  String get payNoPaymentToday => 'no payment due today';

  @override
  String pricePerYearSentence(String price) {
    return '$price per year';
  }

  @override
  String get priceBilledYearly => 'billed yearly';

  @override
  String pricePerMonthSentence(String price) {
    return '$price per month';
  }

  @override
  String get priceBilledMonthlyLower => 'billed monthly';

  @override
  String get paySubscriptionsUnavailable =>
      'Subscriptions are unavailable right now. Please try again later.';

  @override
  String payPurchaseFailed(String error) {
    return 'Purchase failed: $error';
  }

  @override
  String payRestoreFailed(String error) {
    return 'Restore error: $error';
  }

  @override
  String get tutImportTarget =>
      'Import recipes from TikTok,\nInstagram, or any Link';

  @override
  String get tutScanTarget => 'Scan and get instant recipes';

  @override
  String get tutCookbooksTarget => 'Save and organize your recipes here.';

  @override
  String get tutScanBestTitle => 'Get the best scan';

  @override
  String get tutScanSteady => 'Hold your phone steady';

  @override
  String get tutScanLighting => 'Use good lighting';

  @override
  String get tutScanVisible => 'Make sure all ingredients are visible';

  @override
  String get commonNext => 'Next';

  @override
  String get tutScanFindTitle => 'We instantly find your ingredients';

  @override
  String get tutScanSnap => 'Snap a photo of your ingredients';

  @override
  String get tutScanDetect => 'We detect what\'s inside instantly';

  @override
  String get tutScanEdit => 'Edit anything that looks off';

  @override
  String get tutScanReadyTitle => 'Ready to scan';

  @override
  String get tutScanFridge => 'Scan your fridge, pantry, or ingredients';

  @override
  String get tutScanAngles => 'Try different angles for better results';

  @override
  String get tutScanMoreVisible => 'The more visible, the better your recipes';

  @override
  String get tutScanNow => 'Scan Now';

  @override
  String get tutImportTitle => 'Import recipes from anywhere';

  @override
  String get tutImportPaste =>
      'Paste a link from TikTok, Instagram, or any site';

  @override
  String get tutImportShare =>
      'Or share directly from social apps to import instantly';

  @override
  String get tutImportTurn => 'We\'ll turn it into a full recipe automatically';

  @override
  String get tutImportSave => 'Save it to your cookbook';

  @override
  String get commonShare => 'Share';

  @override
  String get tutCookbookTitle1 => 'Your Organised Recipes';

  @override
  String get tutCookbookItem1 => 'Explore all recipes saved in this cookbook';

  @override
  String get tutCookbookItem2 => 'Quickly browse through categories';

  @override
  String get tutCookbookItem3 => 'Access your favorites in one tap';

  @override
  String get tutCookbookTitle2 => 'Complete Control';

  @override
  String get tutCookbookItem4 => 'Edit cookbook details anytime';

  @override
  String get tutCookbookItem5 => 'Add new recipes using the plus button';

  @override
  String get tutCookbookItem6 => 'Tap any recipe to see full details';

  @override
  String get tutExploreNow => 'Explore Now';

  @override
  String get tutIngredientsDetected => 'Ingredients detected';

  @override
  String get commonEdit => 'Edit';

  @override
  String cookbookAddedTo(String name) {
    return 'Added to $name';
  }

  @override
  String get cookbookAddedGeneric => 'Added to Cookbook';

  @override
  String get avatarChooseLibrary => 'Choose from library';

  @override
  String get avatarTakePhoto => 'Take photo';

  @override
  String get avatarDeleting => 'Deleting profile photo...';

  @override
  String get avatarDeleted => 'Profile photo deleted';

  @override
  String get avatarUpdating => 'Updating profile photo...';

  @override
  String get avatarUpdated => 'Profile photo updated!';

  @override
  String get clipRecipeDetected => 'Recipe detected';

  @override
  String get clipLinkFound => 'Link found in clipboard';

  @override
  String get clipPaste => 'Paste';

  @override
  String get fallbackTitle => 'Recipe not found';

  @override
  String get fallbackHeadline => 'We couldn’t import this recipe.';

  @override
  String get fallbackMessage =>
      'This link didn’t include enough recipe information for Cooked to import it correctly.';

  @override
  String get fallbackFailedUrl => 'Failed link';

  @override
  String get fallbackTryOther => 'Try another link';

  @override
  String get fallbackTryOtherDesc => 'Paste a different recipe link';

  @override
  String get fallbackManual => 'Add recipe manually';

  @override
  String get fallbackManualDesc => 'Enter the ingredients and steps yourself';

  @override
  String get groceryAlreadyTitle => 'Already in your Grocery List';

  @override
  String groceryAlreadyMessage(String name) {
    return '\"$name\" is already in your list. Add it again? ';
  }

  @override
  String get groceryQuantitiesDoubled =>
      'The quantities of these ingredients will be doubled.';

  @override
  String get groceryAddAgain => 'Add again';

  @override
  String get groceryAddToList => 'Add to Grocery List';

  @override
  String get grocerySelectIngredients => 'Select Ingredients';

  @override
  String get grocerySaveLocation => 'Save Location';

  @override
  String groceryDate(String date) {
    return 'Date: $date';
  }

  @override
  String get groceryGeneralList => 'General List';

  @override
  String get grocerySpecificDate => 'Specific Date';

  @override
  String get groceryAddSelected => 'Add selected ingredients';

  @override
  String get commonSaving => 'Saving';

  @override
  String get recipeSavedInCookbook => 'Saved in your cookbook';

  @override
  String headerGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get importGettingReady => 'Getting it ready for Cooked';

  @override
  String get scanGeneratingRecipes => 'Generating recipes...';

  @override
  String get scanAnalyzingRecipe => 'Analyzing recipe...';

  @override
  String get importStageReceiving => 'Receiving link…';

  @override
  String get importStageFinding => 'Finding the recipe…';

  @override
  String get importStagePulling => 'Pulling ingredients & steps…';

  @override
  String get importStageReady => 'Recipe ready';

  @override
  String get errRegistration =>
      'Registration failed. Please check your information.';

  @override
  String get authAccountExistsLoggedIn =>
      'This account already exists. You\'ve been signed in.';

  @override
  String get errInvalidCredentials => 'Invalid credentials';

  @override
  String get errInvalidCredentialsRetry =>
      'Invalid credentials, please try again';

  @override
  String get errCodeExpired =>
      'Invalid or expired verification code, please try again';

  @override
  String get errResendCode => 'Unable to resend the code. Please try again.';

  @override
  String get errResetStart => 'Unable to initiate password reset.';

  @override
  String get errResetCodeExpired =>
      'Invalid or expired reset code, please try again';

  @override
  String get errResetPassword => 'Unable to reset password. Please try again.';

  @override
  String get errDeleteAccount => 'Failed to delete account.';

  @override
  String get errUnexpected => 'An unexpected error occurred.';

  @override
  String errAi(String msg) {
    return '🤖 AI error: $msg';
  }

  @override
  String errServer(String msg) {
    return '⚙️ Server error: $msg';
  }

  @override
  String errInput(String msg) {
    return '📝 Input error: $msg';
  }

  @override
  String errAuth(String msg) {
    return '🔒 Authentication error: $msg';
  }

  @override
  String get errPremiumRequired =>
      'Premium access required. Please check your subscription.';

  @override
  String get errNotFound => 'The requested item was not found.';

  @override
  String get errSessionExpired =>
      'Session expired or invalid. Please log in again.';

  @override
  String get errNoInternet =>
      'No internet connection. Please check your network and try again.';

  @override
  String get errAccountExists => 'This account already exists. Please log in.';

  @override
  String get errItemExists => 'This item already exists.';

  @override
  String get errInvalidCode => 'Invalid verification code. Please try again.';

  @override
  String get errAccountNotFound =>
      'Account not found. Please sign up via onboarding.';

  @override
  String get errServersBusy =>
      'Our servers are currently busy. Please try again in a moment.';

  @override
  String get errExtractFailed =>
      'Failed to extract recipe from this link. Please check the URL or try another one.';

  @override
  String get errSiteBlocking =>
      'Website is blocking access. Please try another source.';

  @override
  String get errGeneric => 'Something went wrong. Please try again later.';

  @override
  String get notifChannelShopping => 'Shopping Reminders';

  @override
  String get notifChannelShoppingDesc => 'Reminders to go shopping';

  @override
  String get notifGroceryTitle => 'Grocery Shopping';

  @override
  String get notifGroceryBody => 'Don’t forget to do your shopping!';

  @override
  String get notifChannelPushDesc => 'Notifications from the Cooked team';

  @override
  String get errPurchaseNotActive =>
      'Purchase completed but subscription not active';

  @override
  String get errPurchase => 'Purchase error occurred';

  @override
  String get errIngredientDetection =>
      'Ingredient detection failed. Please try again.';

  @override
  String get errScan => 'Scan failed. Please try again.';

  @override
  String get errValidation => 'Validation failed. Please try again.';

  @override
  String get errGeneration => 'Generation failed. Please try again.';

  @override
  String get errGenerateRecipes =>
      'Failed to generate recipes. Please try again.';

  @override
  String savingsCopyName(String name) {
    return '(Copy) $name';
  }

  @override
  String get errImport => 'Import failed';

  @override
  String get errWebSearch => 'Web search failed';

  @override
  String get errPayment => 'Payment failed';

  @override
  String get errVerification => 'Verification failed';

  @override
  String get errLoadProfile => 'Unable to load profile.';

  @override
  String get errUpdateProfile => 'Unable to update profile.';

  @override
  String get errSavePreferences => 'Unable to save your preferences.';

  @override
  String get errChangePassword => 'Unable to change password.';

  @override
  String get errNotifSettings => 'Unable to update notification settings.';

  @override
  String get errUploadPhoto => 'Unable to upload profile picture.';

  @override
  String get termsIntro =>
      'Before continuing with social login, please review and accept our legal terms to protect your data.';

  @override
  String get termsAgreeA => 'I have read and agree to the ';

  @override
  String get termsAnd => ' and ';

  @override
  String get termsConfirm => 'Confirm and Continue';

  @override
  String get fallbackExtractTitle =>
      'We couldn’t extract a recipe from this link.';

  @override
  String get fallbackExtractHint => 'Please check the URL or try another one.';

  @override
  String get fallbackLinkCopied => 'Link copied';

  @override
  String get fallbackCopyLink => 'Copy link';

  @override
  String get splashTagline => 'Dinner starts with what you already have.';
}
