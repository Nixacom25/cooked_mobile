import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Cooked'**
  String get appName;

  /// No description provided for @groceryInlineAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Garlic - 2, 2 Garlic, or Garlic 2'**
  String get groceryInlineAddHint;

  /// No description provided for @groceryAddIngredientPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add an ingredient...'**
  String get groceryAddIngredientPlaceholder;

  /// No description provided for @groceryQuantityFormatError.
  ///
  /// In en, this message translates to:
  /// **'Please add the quantity following the format, e.g: garlic - 2, 2 garlic, or garlic 2.'**
  String get groceryQuantityFormatError;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @groceryAddItemOrRecipe.
  ///
  /// In en, this message translates to:
  /// **'Please add an item or select a recipe'**
  String get groceryAddItemOrRecipe;

  /// No description provided for @groceryIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get groceryIngredientHint;

  /// No description provided for @commonIngredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get commonIngredient;

  /// No description provided for @groceryChooseRecipe.
  ///
  /// In en, this message translates to:
  /// **'Choose a recipe'**
  String get groceryChooseRecipe;

  /// No description provided for @commonNoRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get commonNoRecipesFound;

  /// No description provided for @commonRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get commonRecipe;

  /// No description provided for @groceryAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Grocery'**
  String get groceryAddSheetTitle;

  /// No description provided for @groceryItemsSaved.
  ///
  /// In en, this message translates to:
  /// **'Grocery items saved successfully'**
  String get groceryItemsSaved;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @groceryDeleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\" from your grocery list?'**
  String groceryDeleteItemMessage(String name);

  /// No description provided for @groceryDeleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get groceryDeleteItemTitle;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @groceryAddIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients'**
  String get groceryAddIngredients;

  /// No description provided for @groceryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients from a recipe or import to get started.'**
  String get groceryEmptySubtitle;

  /// No description provided for @groceryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Grocery List Is Empty'**
  String get groceryEmptyTitle;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @groceryListTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery List'**
  String get groceryListTitle;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get commonCheckConnection;

  /// No description provided for @groceryLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your Grocery List'**
  String get groceryLoadErrorTitle;

  /// No description provided for @authMissingIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Missing identifier context. Please try again.'**
  String get authMissingIdentifier;

  /// No description provided for @authVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get authVerifying;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authResendCode;

  /// No description provided for @authResending.
  ///
  /// In en, this message translates to:
  /// **'Resending'**
  String get authResending;

  /// No description provided for @authDidntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'If you didn’t receive a code? '**
  String get authDidntReceiveCode;

  /// No description provided for @authCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code we just sent to\n{target}'**
  String authCodeSentTo(String target);

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authCodeResent.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent.'**
  String get authCodeResent;

  /// No description provided for @authEnterFullCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code.'**
  String get authEnterFullCode;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get commonSending;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get commonPhoneNumber;

  /// No description provided for @authEnterPhoneForCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the phone number, \nwe will send a verification code\n to your phone number'**
  String get authEnterPhoneForCode;

  /// No description provided for @authEnterEmailForCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the email, we will send a\nverification code to your email'**
  String get authEnterEmailForCode;

  /// No description provided for @authSendToPhone.
  ///
  /// In en, this message translates to:
  /// **'Send to your phone'**
  String get authSendToPhone;

  /// No description provided for @authSendToEmail.
  ///
  /// In en, this message translates to:
  /// **'Send to your email'**
  String get authSendToEmail;

  /// No description provided for @authSelectContactMethod.
  ///
  /// In en, this message translates to:
  /// **'Select which contact details we should\nuse to reset your password'**
  String get authSelectContactMethod;

  /// No description provided for @authCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent!'**
  String get authCodeSent;

  /// No description provided for @commonFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get commonFieldRequired;

  /// No description provided for @commonGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get commonGetStarted;

  /// No description provided for @authPasswordChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully, you can\nlogin again with a new password.'**
  String get authPasswordChangedMessage;

  /// No description provided for @authPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password Changed!'**
  String get authPasswordChanged;

  /// No description provided for @commonCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get commonCongratulations;

  /// No description provided for @commonTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get commonTermsOfUse;

  /// No description provided for @commonPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get commonPrivacyPolicy;

  /// No description provided for @authSignInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get authSignInWithApple;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInWithGoogle;

  /// No description provided for @commonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get commonSignUp;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? '**
  String get authNoAccount;

  /// No description provided for @authLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get authLoggingIn;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get authSignInSubtitle;

  /// No description provided for @commonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get commonSignIn;

  /// No description provided for @authSocialLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Social login successful!'**
  String get authSocialLoginSuccess;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get authLoginSuccess;

  /// No description provided for @authVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION CODE'**
  String get authVerificationCodeLabel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get commonUpdating;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authNewPassword;

  /// No description provided for @authCreateNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get authCreateNewPassword;

  /// No description provided for @authResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reset successful!'**
  String get authResetSuccess;

  /// No description provided for @authPasswordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get authPasswordsDontMatch;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authAccountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account is complete, please enjoy\nthe best menu from us.'**
  String get authAccountCreatedMessage;

  /// No description provided for @authAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get authAccountCreated;

  /// No description provided for @welcomeHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get welcomeHaveAccount;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan ingredients. Save recipes.\nPlan effortlessly.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Cooked'**
  String get welcomeTitle;

  /// No description provided for @authEmailOrPhoneFallback.
  ///
  /// In en, this message translates to:
  /// **'mail/phone number'**
  String get authEmailOrPhoneFallback;

  /// No description provided for @authYourEmailFallback.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get authYourEmailFallback;

  /// No description provided for @themeDarkOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get themeDarkOn;

  /// No description provided for @themeDarkOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get themeDarkOff;

  /// No description provided for @themeSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get themeSystemSettings;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeMatchPhone.
  ///
  /// In en, this message translates to:
  /// **'Match your phone\'s setting'**
  String get themeMatchPhone;

  /// No description provided for @themeAlwaysDark.
  ///
  /// In en, this message translates to:
  /// **'Always use the dark theme'**
  String get themeAlwaysDark;

  /// No description provided for @themeAlwaysLight.
  ///
  /// In en, this message translates to:
  /// **'Always use the light theme'**
  String get themeAlwaysLight;

  /// No description provided for @themeSystemHint.
  ///
  /// In en, this message translates to:
  /// **'If System Settings is selected, the app\'s appearance will automatically switch to match your device\'s setting.'**
  String get themeSystemHint;

  /// No description provided for @notifSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Account and security alerts (like new sign-ins or payment issues) are always sent while push notifications are enabled.'**
  String get notifSecurityNote;

  /// No description provided for @profileInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'You should try Cooked. It turns what\'s in your fridge into recipes in seconds and saves you money on takeout. Click here to join! {link}'**
  String profileInviteMessage(String link);

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @langSuggestRow.
  ///
  /// In en, this message translates to:
  /// **'Suggest a language…'**
  String get langSuggestRow;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @langUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update language'**
  String get langUpdateFailed;

  /// No description provided for @langSuggestionFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send your suggestion. Please try again.'**
  String get langSuggestionFailed;

  /// No description provided for @langSuggestionThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! We got your suggestion.'**
  String get langSuggestionThanks;

  /// No description provided for @langSendSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Send suggestion'**
  String get langSendSuggestion;

  /// No description provided for @langSuggestHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Italian, Wolof, Portuguese…'**
  String get langSuggestHint;

  /// No description provided for @langSuggestMessage.
  ///
  /// In en, this message translates to:
  /// **'Which language would you like Cooked in? We\'ll use your suggestions to decide what comes next.'**
  String get langSuggestMessage;

  /// No description provided for @langSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest a language'**
  String get langSuggestTitle;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get commonSaveChanges;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @accountChangePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Picture'**
  String get accountChangePicture;

  /// No description provided for @accountDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Chef'**
  String get accountDefaultName;

  /// No description provided for @settingsMyAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get settingsMyAccount;

  /// No description provided for @accountProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get accountProfileUpdated;

  /// No description provided for @notifNewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New features, recipes and special offers'**
  String get notifNewsSubtitle;

  /// No description provided for @notifNews.
  ///
  /// In en, this message translates to:
  /// **'News, Tips & Offers'**
  String get notifNews;

  /// No description provided for @notifRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trial ending and subscription reminders'**
  String get notifRemindersSubtitle;

  /// No description provided for @notifReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifReminders;

  /// No description provided for @notifPushSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications on this device'**
  String get notifPushSubtitle;

  /// No description provided for @notifPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notifPush;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get settingsDeletePermanently;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone and you will lose all your data (Cookbooks, grocery items, etc.).'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account? You will need to enter your credentials to log back in.'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsContactSupport;

  /// No description provided for @settingsGiftCooked.
  ///
  /// In en, this message translates to:
  /// **'Gift Cooked to a friend'**
  String get settingsGiftCooked;

  /// No description provided for @settingsInviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get settingsInviteFriends;

  /// No description provided for @settingsManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription & Restore Purchases'**
  String get settingsManageSubscription;

  /// No description provided for @settingsKitchenEquipment.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Equipment'**
  String get settingsKitchenEquipment;

  /// No description provided for @settingsCuisineFlavor.
  ///
  /// In en, this message translates to:
  /// **'Cuisine + Flavor DNA'**
  String get settingsCuisineFlavor;

  /// No description provided for @settingsAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get settingsAllergies;

  /// No description provided for @settingsDietaryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get settingsDietaryPreferences;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @pwdCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get pwdCurrentPassword;

  /// No description provided for @pwdUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get pwdUpdated;

  /// No description provided for @pwdNoMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get pwdNoMatch;

  /// No description provided for @pwdFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get pwdFillAllFields;

  /// No description provided for @optTotalBeginner.
  ///
  /// In en, this message translates to:
  /// **'Total Beginner'**
  String get optTotalBeginner;

  /// No description provided for @optICanBarelyBoilWater.
  ///
  /// In en, this message translates to:
  /// **'I can barely boil water'**
  String get optICanBarelyBoilWater;

  /// No description provided for @optHomeCook.
  ///
  /// In en, this message translates to:
  /// **'Home Cook'**
  String get optHomeCook;

  /// No description provided for @optIFollowRecipesStepByStep.
  ///
  /// In en, this message translates to:
  /// **'I follow recipes step by step'**
  String get optIFollowRecipesStepByStep;

  /// No description provided for @optConfidentCook.
  ///
  /// In en, this message translates to:
  /// **'Confident Cook'**
  String get optConfidentCook;

  /// No description provided for @optIImproviseAndExperiment.
  ///
  /// In en, this message translates to:
  /// **'I improvise and experiment'**
  String get optIImproviseAndExperiment;

  /// No description provided for @optAdvancedSemiPro.
  ///
  /// In en, this message translates to:
  /// **'Advanced / Semi-Pro'**
  String get optAdvancedSemiPro;

  /// No description provided for @optIWantChallengingRecipes.
  ///
  /// In en, this message translates to:
  /// **'I want challenging recipes.'**
  String get optIWantChallengingRecipes;

  /// No description provided for @optUnder15Minutes.
  ///
  /// In en, this message translates to:
  /// **'Under 15 minutes'**
  String get optUnder15Minutes;

  /// No description provided for @optUltraFastMeals.
  ///
  /// In en, this message translates to:
  /// **'Ultra-fast meals'**
  String get optUltraFastMeals;

  /// No description provided for @optForWhenYouNeedFoodInstantly.
  ///
  /// In en, this message translates to:
  /// **'For when you need food instantly.'**
  String get optForWhenYouNeedFoodInstantly;

  /// No description provided for @opt_1530Minutes.
  ///
  /// In en, this message translates to:
  /// **'15–30 minutes'**
  String get opt_1530Minutes;

  /// No description provided for @optQuickButNotRushed.
  ///
  /// In en, this message translates to:
  /// **'Quick but not rushed'**
  String get optQuickButNotRushed;

  /// No description provided for @optPerfectForQuickWeekdayMeals.
  ///
  /// In en, this message translates to:
  /// **'Perfect for quick weekday meals.'**
  String get optPerfectForQuickWeekdayMeals;

  /// No description provided for @opt_3060Minutes.
  ///
  /// In en, this message translates to:
  /// **'30–60 minutes'**
  String get opt_3060Minutes;

  /// No description provided for @optANormalCookingWindow.
  ///
  /// In en, this message translates to:
  /// **'A normal cooking window'**
  String get optANormalCookingWindow;

  /// No description provided for @optGreatForRelaxedDinners.
  ///
  /// In en, this message translates to:
  /// **'Great for relaxed dinners.'**
  String get optGreatForRelaxedDinners;

  /// No description provided for @opt_12Hours.
  ///
  /// In en, this message translates to:
  /// **'1–2 hours'**
  String get opt_12Hours;

  /// No description provided for @optIEnjoyTheCookingProcess.
  ///
  /// In en, this message translates to:
  /// **'I enjoy the cooking process'**
  String get optIEnjoyTheCookingProcess;

  /// No description provided for @optForWeekendCookingSessions.
  ///
  /// In en, this message translates to:
  /// **'For weekend cooking sessions.'**
  String get optForWeekendCookingSessions;

  /// No description provided for @optAnyAmountOfTime.
  ///
  /// In en, this message translates to:
  /// **'Any amount of time'**
  String get optAnyAmountOfTime;

  /// No description provided for @optShowMeEverything.
  ///
  /// In en, this message translates to:
  /// **'Show me everything'**
  String get optShowMeEverything;

  /// No description provided for @optAllRecipesAreOnTheTable.
  ///
  /// In en, this message translates to:
  /// **'All recipes are on the table.'**
  String get optAllRecipesAreOnTheTable;

  /// No description provided for @optWeeklyMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Weekly meal plan'**
  String get optWeeklyMealPlan;

  /// No description provided for @optGetAFullPlanEveryWeek.
  ///
  /// In en, this message translates to:
  /// **'Get a full plan every week'**
  String get optGetAFullPlanEveryWeek;

  /// No description provided for @optDailySuggestions.
  ///
  /// In en, this message translates to:
  /// **'Daily suggestions'**
  String get optDailySuggestions;

  /// No description provided for @optOneRecipeEachMorning.
  ///
  /// In en, this message translates to:
  /// **'One recipe each morning'**
  String get optOneRecipeEachMorning;

  /// No description provided for @optILlPlanMyself.
  ///
  /// In en, this message translates to:
  /// **'I\'ll plan myself'**
  String get optILlPlanMyself;

  /// No description provided for @optJustShowMeRecipes.
  ///
  /// In en, this message translates to:
  /// **'Just show me recipes'**
  String get optJustShowMeRecipes;

  /// No description provided for @optPlanByIngredients.
  ///
  /// In en, this message translates to:
  /// **'Plan by ingredients'**
  String get optPlanByIngredients;

  /// No description provided for @optScanMyFridgeGiveMeA.
  ///
  /// In en, this message translates to:
  /// **'Scan my fridge, give me a plan'**
  String get optScanMyFridgeGiveMeA;

  /// No description provided for @optJustMe.
  ///
  /// In en, this message translates to:
  /// **'Just me'**
  String get optJustMe;

  /// No description provided for @opt_1Person.
  ///
  /// In en, this message translates to:
  /// **'1 person'**
  String get opt_1Person;

  /// No description provided for @optTwoPeople.
  ///
  /// In en, this message translates to:
  /// **'Two people'**
  String get optTwoPeople;

  /// No description provided for @optCoupleOrPair.
  ///
  /// In en, this message translates to:
  /// **'Couple or pair'**
  String get optCoupleOrPair;

  /// No description provided for @opt_34People.
  ///
  /// In en, this message translates to:
  /// **'3–4 people'**
  String get opt_34People;

  /// No description provided for @optSmallFamily.
  ///
  /// In en, this message translates to:
  /// **'Small family'**
  String get optSmallFamily;

  /// No description provided for @opt_56People.
  ///
  /// In en, this message translates to:
  /// **'5–6 people'**
  String get opt_56People;

  /// No description provided for @optLargerFamily.
  ///
  /// In en, this message translates to:
  /// **'Larger family'**
  String get optLargerFamily;

  /// No description provided for @opt_7PlusPeople.
  ///
  /// In en, this message translates to:
  /// **'7+ people'**
  String get opt_7PlusPeople;

  /// No description provided for @optLargeFamilyOrGroup.
  ///
  /// In en, this message translates to:
  /// **'Large family or group'**
  String get optLargeFamilyOrGroup;

  /// No description provided for @optItVaries.
  ///
  /// In en, this message translates to:
  /// **'It varies'**
  String get optItVaries;

  /// No description provided for @optILlAdjustPerRecipe.
  ///
  /// In en, this message translates to:
  /// **'I\'ll adjust per recipe'**
  String get optILlAdjustPerRecipe;

  /// No description provided for @optSaveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save money'**
  String get optSaveMoney;

  /// No description provided for @optEatHealthier.
  ///
  /// In en, this message translates to:
  /// **'Eat healthier'**
  String get optEatHealthier;

  /// No description provided for @optGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain muscle'**
  String get optGainMuscle;

  /// No description provided for @optLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get optLoseWeight;

  /// No description provided for @optWasteLessFood.
  ///
  /// In en, this message translates to:
  /// **'Waste less food'**
  String get optWasteLessFood;

  /// No description provided for @optLearnToCook.
  ///
  /// In en, this message translates to:
  /// **'Learn to cook'**
  String get optLearnToCook;

  /// No description provided for @optDiscoverRecipes.
  ///
  /// In en, this message translates to:
  /// **'Discover recipes'**
  String get optDiscoverRecipes;

  /// No description provided for @optMealPrepEasier.
  ///
  /// In en, this message translates to:
  /// **'Meal prep easier'**
  String get optMealPrepEasier;

  /// No description provided for @optNoRestrictions.
  ///
  /// In en, this message translates to:
  /// **'No Restrictions'**
  String get optNoRestrictions;

  /// No description provided for @optIEatEverything.
  ///
  /// In en, this message translates to:
  /// **'I eat everything'**
  String get optIEatEverything;

  /// No description provided for @optVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get optVegetarian;

  /// No description provided for @optNoMeatOrFish.
  ///
  /// In en, this message translates to:
  /// **'No meat or fish'**
  String get optNoMeatOrFish;

  /// No description provided for @optVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get optVegan;

  /// No description provided for @optNoAnimalProducts.
  ///
  /// In en, this message translates to:
  /// **'No animal products'**
  String get optNoAnimalProducts;

  /// No description provided for @optPescatarian.
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get optPescatarian;

  /// No description provided for @optFishOkNoOtherMeat.
  ///
  /// In en, this message translates to:
  /// **'Fish OK, no other meat'**
  String get optFishOkNoOtherMeat;

  /// No description provided for @optGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-Free'**
  String get optGlutenFree;

  /// No description provided for @optNoWheatOrGluten.
  ///
  /// In en, this message translates to:
  /// **'No wheat or gluten'**
  String get optNoWheatOrGluten;

  /// No description provided for @optDairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy Free'**
  String get optDairyFree;

  /// No description provided for @optNoMilkOrDairy.
  ///
  /// In en, this message translates to:
  /// **'No milk or dairy'**
  String get optNoMilkOrDairy;

  /// No description provided for @optHalal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get optHalal;

  /// No description provided for @optIslamicDietaryLaws.
  ///
  /// In en, this message translates to:
  /// **'Islamic dietary laws'**
  String get optIslamicDietaryLaws;

  /// No description provided for @optKosher.
  ///
  /// In en, this message translates to:
  /// **'Kosher'**
  String get optKosher;

  /// No description provided for @optJewishDietaryLaws.
  ///
  /// In en, this message translates to:
  /// **'Jewish Dietary Laws'**
  String get optJewishDietaryLaws;

  /// No description provided for @optKetoLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Keto/Low-Carb'**
  String get optKetoLowCarb;

  /// No description provided for @optHighFatLowCarb.
  ///
  /// In en, this message translates to:
  /// **'High fat, low carb'**
  String get optHighFatLowCarb;

  /// No description provided for @optHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get optHighProtein;

  /// No description provided for @optHighProteinFoods.
  ///
  /// In en, this message translates to:
  /// **'High protein foods'**
  String get optHighProteinFoods;

  /// No description provided for @optTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree nuts'**
  String get optTreeNuts;

  /// No description provided for @optPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get optPeanuts;

  /// No description provided for @optShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get optShellfish;

  /// No description provided for @optFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get optFish;

  /// No description provided for @optEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get optEggs;

  /// No description provided for @optSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get optSoy;

  /// No description provided for @optDairyMilk.
  ///
  /// In en, this message translates to:
  /// **'Dairy Milk'**
  String get optDairyMilk;

  /// No description provided for @optWheatGluten.
  ///
  /// In en, this message translates to:
  /// **'Wheat/Gluten'**
  String get optWheatGluten;

  /// No description provided for @optSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get optSesame;

  /// No description provided for @optNoAllergies.
  ///
  /// In en, this message translates to:
  /// **'No Allergies'**
  String get optNoAllergies;

  /// No description provided for @optItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get optItalian;

  /// No description provided for @optJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get optJapanese;

  /// No description provided for @optMexican.
  ///
  /// In en, this message translates to:
  /// **'Mexican'**
  String get optMexican;

  /// No description provided for @optChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get optChinese;

  /// No description provided for @optThai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get optThai;

  /// No description provided for @optMiddleEastern.
  ///
  /// In en, this message translates to:
  /// **'Middle Eastern'**
  String get optMiddleEastern;

  /// No description provided for @optWestAfrican.
  ///
  /// In en, this message translates to:
  /// **'West African'**
  String get optWestAfrican;

  /// No description provided for @optEastAfrican.
  ///
  /// In en, this message translates to:
  /// **'East African'**
  String get optEastAfrican;

  /// No description provided for @optCaribbean.
  ///
  /// In en, this message translates to:
  /// **'Caribbean'**
  String get optCaribbean;

  /// No description provided for @optIndian.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get optIndian;

  /// No description provided for @optSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get optSpanish;

  /// No description provided for @optGreek.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get optGreek;

  /// No description provided for @optFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get optFrench;

  /// No description provided for @optKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get optKorean;

  /// No description provided for @optMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get optMediterranean;

  /// No description provided for @optOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get optOthers;

  /// No description provided for @optOven.
  ///
  /// In en, this message translates to:
  /// **'Oven'**
  String get optOven;

  /// No description provided for @optStovetopGasBurner.
  ///
  /// In en, this message translates to:
  /// **'Stovetop / Gas burner'**
  String get optStovetopGasBurner;

  /// No description provided for @optMicrowave.
  ///
  /// In en, this message translates to:
  /// **'Microwave'**
  String get optMicrowave;

  /// No description provided for @optAirFryer.
  ///
  /// In en, this message translates to:
  /// **'Air fryer'**
  String get optAirFryer;

  /// No description provided for @optBlenderLiquidizer.
  ///
  /// In en, this message translates to:
  /// **'Blender / Liquidizer'**
  String get optBlenderLiquidizer;

  /// No description provided for @optFoodProcessor.
  ///
  /// In en, this message translates to:
  /// **'Food processor'**
  String get optFoodProcessor;

  /// No description provided for @optInstantPotPressureCooker.
  ///
  /// In en, this message translates to:
  /// **'Instant Pot / Pressure cooker'**
  String get optInstantPotPressureCooker;

  /// No description provided for @optGrillBbq.
  ///
  /// In en, this message translates to:
  /// **'Grill / BBQ'**
  String get optGrillBbq;

  /// No description provided for @optRiceCooker.
  ///
  /// In en, this message translates to:
  /// **'Rice cooker'**
  String get optRiceCooker;

  /// No description provided for @optStandMixerHandMixer.
  ///
  /// In en, this message translates to:
  /// **'Stand mixer / Hand mixer'**
  String get optStandMixerHandMixer;

  /// No description provided for @optSteamer.
  ///
  /// In en, this message translates to:
  /// **'Steamer'**
  String get optSteamer;

  /// No description provided for @optOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get optOther;

  /// No description provided for @optScanIngredients.
  ///
  /// In en, this message translates to:
  /// **'Scan Ingredients'**
  String get optScanIngredients;

  /// No description provided for @optTakeAPhotoAndGetRecipes.
  ///
  /// In en, this message translates to:
  /// **'Take a photo and get recipes from what you already have.'**
  String get optTakeAPhotoAndGetRecipes;

  /// No description provided for @optMealPlanning.
  ///
  /// In en, this message translates to:
  /// **'Meal Planning'**
  String get optMealPlanning;

  /// No description provided for @optPlanYourMealsForTheWeek.
  ///
  /// In en, this message translates to:
  /// **'Plan your meals for the week without starting from scratch.'**
  String get optPlanYourMealsForTheWeek;

  /// No description provided for @optImportRecipes.
  ///
  /// In en, this message translates to:
  /// **'Import Recipes'**
  String get optImportRecipes;

  /// No description provided for @optSaveRecipesFromTiktokInstagramYoutube.
  ///
  /// In en, this message translates to:
  /// **'Save recipes from TikTok, Instagram, YouTube, or websites.'**
  String get optSaveRecipesFromTiktokInstagramYoutube;

  /// No description provided for @optGroceryLists.
  ///
  /// In en, this message translates to:
  /// **'Grocery Lists'**
  String get optGroceryLists;

  /// No description provided for @optTurnRecipesIntoShoppingListsAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Turn recipes into shopping lists automatically.'**
  String get optTurnRecipesIntoShoppingListsAutomatically;

  /// No description provided for @optDailyRecipeInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily recipe inspiration'**
  String get optDailyRecipeInspiration;

  /// No description provided for @optMorningSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Morning suggestion'**
  String get optMorningSuggestion;

  /// No description provided for @optGroceryReminder.
  ///
  /// In en, this message translates to:
  /// **'Grocery Reminder'**
  String get optGroceryReminder;

  /// No description provided for @optRememberWhatToBuyBeforeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Remember what to buy before ingredients run out.'**
  String get optRememberWhatToBuyBeforeIngredients;

  /// No description provided for @optMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get optMild;

  /// No description provided for @optNoHeatAtAll.
  ///
  /// In en, this message translates to:
  /// **'No heat at all'**
  String get optNoHeatAtAll;

  /// No description provided for @optMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get optMedium;

  /// No description provided for @optJustAHintOfSpice.
  ///
  /// In en, this message translates to:
  /// **'Just a hint of spice'**
  String get optJustAHintOfSpice;

  /// No description provided for @optSpicy.
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get optSpicy;

  /// No description provided for @optIEnjoySpice.
  ///
  /// In en, this message translates to:
  /// **'I enjoy spice'**
  String get optIEnjoySpice;

  /// No description provided for @optHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get optHot;

  /// No description provided for @optTheSpicierTheBetter.
  ///
  /// In en, this message translates to:
  /// **'The spicier the better'**
  String get optTheSpicierTheBetter;

  /// No description provided for @optInferno.
  ///
  /// In en, this message translates to:
  /// **'Inferno'**
  String get optInferno;

  /// No description provided for @optIPutHotSauce.
  ///
  /// In en, this message translates to:
  /// **'I put hot sauce'**
  String get optIPutHotSauce;

  /// No description provided for @optUnder18.
  ///
  /// In en, this message translates to:
  /// **'Under 18'**
  String get optUnder18;

  /// No description provided for @optUnder50.
  ///
  /// In en, this message translates to:
  /// **'Under \$50'**
  String get optUnder50;

  /// No description provided for @optIDonTKnowWhatTo.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know what to cook'**
  String get optIDonTKnowWhatTo;

  /// No description provided for @optCookingTakesTooMuchTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking takes too much time'**
  String get optCookingTakesTooMuchTime;

  /// No description provided for @optISpendTooMuchOnTakeout.
  ///
  /// In en, this message translates to:
  /// **'I spend too much on takeout'**
  String get optISpendTooMuchOnTakeout;

  /// No description provided for @optHealthyEatingFeelsDifficult.
  ///
  /// In en, this message translates to:
  /// **'Healthy eating feels difficult'**
  String get optHealthyEatingFeelsDifficult;

  /// No description provided for @optGroceryShoppingIsStressful.
  ///
  /// In en, this message translates to:
  /// **'Grocery shopping is stressful'**
  String get optGroceryShoppingIsStressful;

  /// No description provided for @optAlmostNever.
  ///
  /// In en, this message translates to:
  /// **'Almost never'**
  String get optAlmostNever;

  /// No description provided for @optSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get optSometimes;

  /// No description provided for @optWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get optWeekly;

  /// No description provided for @optConstantly.
  ///
  /// In en, this message translates to:
  /// **'Constantly'**
  String get optConstantly;

  /// No description provided for @optAnchovies.
  ///
  /// In en, this message translates to:
  /// **'Anchovies'**
  String get optAnchovies;

  /// No description provided for @optBlackLicorice.
  ///
  /// In en, this message translates to:
  /// **'Black licorice'**
  String get optBlackLicorice;

  /// No description provided for @optBrusselsSprouts.
  ///
  /// In en, this message translates to:
  /// **'Brussels sprouts'**
  String get optBrusselsSprouts;

  /// No description provided for @optBlueCheese.
  ///
  /// In en, this message translates to:
  /// **'Blue cheese'**
  String get optBlueCheese;

  /// No description provided for @optOysters.
  ///
  /// In en, this message translates to:
  /// **'Oysters'**
  String get optOysters;

  /// No description provided for @optSardines.
  ///
  /// In en, this message translates to:
  /// **'Sardines'**
  String get optSardines;

  /// No description provided for @optOlives.
  ///
  /// In en, this message translates to:
  /// **'Olives'**
  String get optOlives;

  /// No description provided for @optBeets.
  ///
  /// In en, this message translates to:
  /// **'Beets'**
  String get optBeets;

  /// No description provided for @optCottageCheese.
  ///
  /// In en, this message translates to:
  /// **'Cottage cheese'**
  String get optCottageCheese;

  /// No description provided for @optOkra.
  ///
  /// In en, this message translates to:
  /// **'Okra'**
  String get optOkra;

  /// No description provided for @optSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get optSpam;

  /// No description provided for @optTofu.
  ///
  /// In en, this message translates to:
  /// **'Tofu'**
  String get optTofu;

  /// No description provided for @optTurnips.
  ///
  /// In en, this message translates to:
  /// **'Turnips'**
  String get optTurnips;

  /// No description provided for @optKimchi.
  ///
  /// In en, this message translates to:
  /// **'Kimchi'**
  String get optKimchi;

  /// No description provided for @optEggplant.
  ///
  /// In en, this message translates to:
  /// **'Eggplant'**
  String get optEggplant;

  /// No description provided for @optCauliflower.
  ///
  /// In en, this message translates to:
  /// **'Cauliflower'**
  String get optCauliflower;

  /// No description provided for @optCilantro.
  ///
  /// In en, this message translates to:
  /// **'Cilantro'**
  String get optCilantro;

  /// No description provided for @optLimaBeans.
  ///
  /// In en, this message translates to:
  /// **'Lima beans'**
  String get optLimaBeans;

  /// No description provided for @optPickledHerring.
  ///
  /// In en, this message translates to:
  /// **'Pickled herring'**
  String get optPickledHerring;

  /// No description provided for @optSauerkraut.
  ///
  /// In en, this message translates to:
  /// **'Sauerkraut'**
  String get optSauerkraut;

  /// No description provided for @optGoatCheese.
  ///
  /// In en, this message translates to:
  /// **'Goat cheese'**
  String get optGoatCheese;

  /// No description provided for @optBitterMelon.
  ///
  /// In en, this message translates to:
  /// **'Bitter melon'**
  String get optBitterMelon;

  /// No description provided for @optMushrooms.
  ///
  /// In en, this message translates to:
  /// **'Mushrooms'**
  String get optMushrooms;

  /// No description provided for @optGrapefruit.
  ///
  /// In en, this message translates to:
  /// **'Grapefruit'**
  String get optGrapefruit;

  /// No description provided for @opt_23TimesAWeek.
  ///
  /// In en, this message translates to:
  /// **'2–3 times a week'**
  String get opt_23TimesAWeek;

  /// No description provided for @optMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get optMetric;

  /// No description provided for @optImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get optImperial;

  /// No description provided for @optLiver.
  ///
  /// In en, this message translates to:
  /// **'Liver'**
  String get optLiver;

  /// No description provided for @onbBestGuess.
  ///
  /// In en, this message translates to:
  /// **'Take your best guess. We’ll do the math'**
  String get onbBestGuess;

  /// No description provided for @onbEatingOutTitle.
  ///
  /// In en, this message translates to:
  /// **'How much do you spend eating out every week?'**
  String get onbEatingOutTitle;

  /// No description provided for @onbThatCouldBeOver.
  ///
  /// In en, this message translates to:
  /// **'That could be over'**
  String get onbThatCouldBeOver;

  /// No description provided for @onbPotentialYearlySavings.
  ///
  /// In en, this message translates to:
  /// **'Potential Yearly Savings'**
  String get onbPotentialYearlySavings;

  /// No description provided for @onbThanHome.
  ///
  /// In en, this message translates to:
  /// **'Than cooking at home'**
  String get onbThanHome;

  /// No description provided for @onbNearlyB.
  ///
  /// In en, this message translates to:
  /// **' more'**
  String get onbNearlyB;

  /// No description provided for @onbNearlyA.
  ///
  /// In en, this message translates to:
  /// **'That is nearly '**
  String get onbNearlyA;

  /// No description provided for @onbMadeAtHome.
  ///
  /// In en, this message translates to:
  /// **'Made at home'**
  String get onbMadeAtHome;

  /// No description provided for @onbHomeCooked.
  ///
  /// In en, this message translates to:
  /// **'Home Cooked'**
  String get onbHomeCooked;

  /// No description provided for @onbThreeMealsWeek.
  ///
  /// In en, this message translates to:
  /// **'3 Meals / Week'**
  String get onbThreeMealsWeek;

  /// No description provided for @onbTakeout.
  ///
  /// In en, this message translates to:
  /// **'Takeout'**
  String get onbTakeout;

  /// No description provided for @onbCostingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small decisions become\nexpensive habits'**
  String get onbCostingSubtitle;

  /// No description provided for @onbCostingTitleD.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get onbCostingTitleD;

  /// No description provided for @onbCostingTitleC.
  ///
  /// In en, this message translates to:
  /// **'more than '**
  String get onbCostingTitleC;

  /// No description provided for @onbCostingTitleB.
  ///
  /// In en, this message translates to:
  /// **'costing\n'**
  String get onbCostingTitleB;

  /// No description provided for @onbCostingTitleA.
  ///
  /// In en, this message translates to:
  /// **'And it’s '**
  String get onbCostingTitleA;

  /// No description provided for @onbDinnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No stress. No guesswork'**
  String get onbDinnerSubtitle;

  /// No description provided for @onbDinnerTitleB.
  ///
  /// In en, this message translates to:
  /// **'figured out'**
  String get onbDinnerTitleB;

  /// No description provided for @onbDinnerTitleA.
  ///
  /// In en, this message translates to:
  /// **'Imagine dinner\nalready '**
  String get onbDinnerTitleA;

  /// No description provided for @onbViewOtherPlans.
  ///
  /// In en, this message translates to:
  /// **'View other plans'**
  String get onbViewOtherPlans;

  /// No description provided for @onbTrialReminder.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a reminder before your trial ends.'**
  String get onbTrialReminder;

  /// No description provided for @onbTrialDay3.
  ///
  /// In en, this message translates to:
  /// **'Day 3'**
  String get onbTrialDay3;

  /// No description provided for @onbTrialDay2.
  ///
  /// In en, this message translates to:
  /// **'Day 2'**
  String get onbTrialDay2;

  /// No description provided for @onbTrialGuideToday.
  ///
  /// In en, this message translates to:
  /// **'Unlock personalized recipes, meal suggestions, and ingredient scanning.'**
  String get onbTrialGuideToday;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @onbTrialGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get the most out of your Cooked trial.'**
  String get onbTrialGuideSubtitle;

  /// No description provided for @onbTrialGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Free trial guide'**
  String get onbTrialGuideTitle;

  /// No description provided for @onbTryForZero.
  ///
  /// In en, this message translates to:
  /// **'Start 3-Day Free Trial'**
  String get onbTryForZero;

  /// No description provided for @onbKeepEverything.
  ///
  /// In en, this message translates to:
  /// **'Create your account to keep your recipes, meal plans, grocery lists, and savings tracker.'**
  String get onbKeepEverything;

  /// No description provided for @onbTryFreeB.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get onbTryFreeB;

  /// No description provided for @onbTryFreeA.
  ///
  /// In en, this message translates to:
  /// **'We want you to try\nCooked for '**
  String get onbTryFreeA;

  /// No description provided for @onbBenefitGrocery.
  ///
  /// In en, this message translates to:
  /// **'Smart grocery lists that save you money'**
  String get onbBenefitGrocery;

  /// No description provided for @onbBenefitPlans.
  ///
  /// In en, this message translates to:
  /// **'Personalized meal plans'**
  String get onbBenefitPlans;

  /// No description provided for @onbBenefitRecipes.
  ///
  /// In en, this message translates to:
  /// **'Full access to 10,000+ chef-curated recipes'**
  String get onbBenefitRecipes;

  /// No description provided for @onbGroceriesUnusedTitle.
  ///
  /// In en, this message translates to:
  /// **'How often do groceries go unused?'**
  String get onbGroceriesUnusedTitle;

  /// No description provided for @onbOver.
  ///
  /// In en, this message translates to:
  /// **'over '**
  String get onbOver;

  /// No description provided for @onbHouseholdWastes.
  ///
  /// In en, this message translates to:
  /// **'The average household wastes'**
  String get onbHouseholdWastes;

  /// No description provided for @onbHandlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We plan. You cook.'**
  String get onbHandlesSubtitle;

  /// No description provided for @onbHandlesTitleB.
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get onbHandlesTitleB;

  /// No description provided for @onbHandlesTitleA.
  ///
  /// In en, this message translates to:
  /// **'Cooked handles\nall your '**
  String get onbHandlesTitleA;

  /// No description provided for @onbHealthySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes you’ll actually look forward\nto eating.'**
  String get onbHealthySubtitle;

  /// No description provided for @onbHealthyTitleD.
  ///
  /// In en, this message translates to:
  /// **'second job'**
  String get onbHealthyTitleD;

  /// No description provided for @onbHealthyTitleC.
  ///
  /// In en, this message translates to:
  /// **' a\n'**
  String get onbHealthyTitleC;

  /// No description provided for @onbHealthyTitleB.
  ///
  /// In en, this message translates to:
  /// **'feel like'**
  String get onbHealthyTitleB;

  /// No description provided for @onbHealthyTitleA.
  ///
  /// In en, this message translates to:
  /// **'Healthy eating\nshouldn’t '**
  String get onbHealthyTitleA;

  /// No description provided for @onbMealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dinner shouldn’t be the hardest\ndecision of your day'**
  String get onbMealsSubtitle;

  /// No description provided for @onbMealsTitleD.
  ///
  /// In en, this message translates to:
  /// **' again'**
  String get onbMealsTitleD;

  /// No description provided for @onbMealsTitleC.
  ///
  /// In en, this message translates to:
  /// **'to cook'**
  String get onbMealsTitleC;

  /// No description provided for @onbMealsTitleB.
  ///
  /// In en, this message translates to:
  /// **'what\n'**
  String get onbMealsTitleB;

  /// No description provided for @onbMealsTitleA.
  ///
  /// In en, this message translates to:
  /// **'Never wonder '**
  String get onbMealsTitleA;

  /// No description provided for @onbBuildingSystem.
  ///
  /// In en, this message translates to:
  /// **'Building your\npersonalized cooking\nsystem{dots}'**
  String onbBuildingSystem(String dots);

  /// No description provided for @onbTaskPersonalizing.
  ///
  /// In en, this message translates to:
  /// **'Personalizing recommendations'**
  String get onbTaskPersonalizing;

  /// No description provided for @onbTaskFeed.
  ///
  /// In en, this message translates to:
  /// **'Building your meal feed'**
  String get onbTaskFeed;

  /// No description provided for @onbTaskSavings.
  ///
  /// In en, this message translates to:
  /// **'Calculating savings'**
  String get onbTaskSavings;

  /// No description provided for @onbTaskFindRecipes.
  ///
  /// In en, this message translates to:
  /// **'Finding recipes you\'ll love'**
  String get onbTaskFindRecipes;

  /// No description provided for @onbTaskTastes.
  ///
  /// In en, this message translates to:
  /// **'Learning your tastes'**
  String get onbTaskTastes;

  /// No description provided for @onbRepetitionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built around your taste.'**
  String get onbRepetitionSubtitle;

  /// No description provided for @onbRepetitionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tired of eating the\nsame thing every\nweek?'**
  String get onbRepetitionTitle;

  /// No description provided for @onbOfYourLife.
  ///
  /// In en, this message translates to:
  /// **'of your life\nevery year'**
  String get onbOfYourLife;

  /// No description provided for @onbDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get onbDays;

  /// No description provided for @onbSpentDeciding.
  ///
  /// In en, this message translates to:
  /// **'Spent deciding\nwhat to eat'**
  String get onbSpentDeciding;

  /// No description provided for @onbHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get onbHours;

  /// No description provided for @onbNotAloneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most people spend over 200 hours\nevery year deciding what to eat'**
  String get onbNotAloneSubtitle;

  /// No description provided for @onbNotAloneB.
  ///
  /// In en, this message translates to:
  /// **'not alone'**
  String get onbNotAloneB;

  /// No description provided for @onbNotAloneA.
  ///
  /// In en, this message translates to:
  /// **'You’re '**
  String get onbNotAloneA;

  /// No description provided for @onbSkillSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll match recipes to your experience.'**
  String get onbSkillSubtitle;

  /// No description provided for @onbSkillTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your cooking\nskill level?'**
  String get onbSkillTitle;

  /// No description provided for @onbAvoidB.
  ///
  /// In en, this message translates to:
  /// **' recipes.'**
  String get onbAvoidB;

  /// No description provided for @onbAvoidA.
  ///
  /// In en, this message translates to:
  /// **'Great, we\'ll avoid '**
  String get onbAvoidA;

  /// No description provided for @onbAvoidComplex.
  ///
  /// In en, this message translates to:
  /// **'complex'**
  String get onbAvoidComplex;

  /// No description provided for @onbAvoidBasic.
  ///
  /// In en, this message translates to:
  /// **'basic'**
  String get onbAvoidBasic;

  /// No description provided for @onbAvoidBoring.
  ///
  /// In en, this message translates to:
  /// **'boring'**
  String get onbAvoidBoring;

  /// No description provided for @onbAvoidUntested.
  ///
  /// In en, this message translates to:
  /// **'untested'**
  String get onbAvoidUntested;

  /// No description provided for @onbAvoidOverlyComplex.
  ///
  /// In en, this message translates to:
  /// **'overly complex'**
  String get onbAvoidOverlyComplex;

  /// No description provided for @onbReview3.
  ///
  /// In en, this message translates to:
  /// **'\"Meal ideas feel personalized\ninstead of random.\"'**
  String get onbReview3;

  /// No description provided for @onbReview2.
  ///
  /// In en, this message translates to:
  /// **'\"I finally use the groceries I\nalready have.\"'**
  String get onbReview2;

  /// No description provided for @onbReview1.
  ///
  /// In en, this message translates to:
  /// **'\"Cooked helped me stop\nordering dinner every night.\"'**
  String get onbReview1;

  /// No description provided for @onbStarsFromThousands.
  ///
  /// In en, this message translates to:
  /// **'Stars from thousands\nof food lovers'**
  String get onbStarsFromThousands;

  /// No description provided for @onbUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get onbUnlock;

  /// No description provided for @onbBadgeHealthier.
  ///
  /// In en, this message translates to:
  /// **'Healthier meals,\nmade easy'**
  String get onbBadgeHealthier;

  /// No description provided for @onbBadgeRecipes.
  ///
  /// In en, this message translates to:
  /// **'1,847 recipes\nmatched'**
  String get onbBadgeRecipes;

  /// No description provided for @onbBadgeSaveHours.
  ///
  /// In en, this message translates to:
  /// **'Save 180+ hours/\nyear'**
  String get onbBadgeSaveHours;

  /// No description provided for @onbBadgeSaveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save \$2,496/\nyear'**
  String get onbBadgeSaveMoney;

  /// No description provided for @onbRecipesCurated.
  ///
  /// In en, this message translates to:
  /// **'recipes curated for your taste'**
  String get onbRecipesCurated;

  /// No description provided for @onbPlanReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built around your goals, taste,\nschedule, and savings'**
  String get onbPlanReadySubtitle;

  /// No description provided for @onbPlanReady.
  ///
  /// In en, this message translates to:
  /// **'Your personalized\nplan is ready.'**
  String get onbPlanReady;

  /// No description provided for @onbStartArrow.
  ///
  /// In en, this message translates to:
  /// **'Start →'**
  String get onbStartArrow;

  /// No description provided for @onbBuildProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The more we learn, the better your recommendations'**
  String get onbBuildProfileSubtitle;

  /// No description provided for @onbBuildProfileB.
  ///
  /// In en, this message translates to:
  /// **'profile'**
  String get onbBuildProfileB;

  /// No description provided for @onbBuildProfileA.
  ///
  /// In en, this message translates to:
  /// **'Let’s build your\ncooking '**
  String get onbBuildProfileA;

  /// No description provided for @onbTaskCuisines.
  ///
  /// In en, this message translates to:
  /// **'Learning your cuisine preferences'**
  String get onbTaskCuisines;

  /// No description provided for @onbTaskDietary.
  ///
  /// In en, this message translates to:
  /// **'Understanding your dietary preferences'**
  String get onbTaskDietary;

  /// No description provided for @onbTaskPotentialSavings.
  ///
  /// In en, this message translates to:
  /// **'Calculating your potential savings'**
  String get onbTaskPotentialSavings;

  /// No description provided for @onbTaskChallenges.
  ///
  /// In en, this message translates to:
  /// **'Understanding your cooking challenges'**
  String get onbTaskChallenges;

  /// No description provided for @onbCookingSmarter.
  ///
  /// In en, this message translates to:
  /// **'Just by cooking smarter'**
  String get onbCookingSmarter;

  /// No description provided for @onbEveryYear.
  ///
  /// In en, this message translates to:
  /// **'Every Year'**
  String get onbEveryYear;

  /// No description provided for @onbCouldSave.
  ///
  /// In en, this message translates to:
  /// **'You could save\napproximately'**
  String get onbCouldSave;

  /// No description provided for @optSweet.
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get optSweet;

  /// No description provided for @optSavory.
  ///
  /// In en, this message translates to:
  /// **'Savory'**
  String get optSavory;

  /// No description provided for @optCrunchyTextures.
  ///
  /// In en, this message translates to:
  /// **'Crunchy textures'**
  String get optCrunchyTextures;

  /// No description provided for @optSoftCreamy.
  ///
  /// In en, this message translates to:
  /// **'Soft & creamy'**
  String get optSoftCreamy;

  /// No description provided for @flavorLeaningSweet.
  ///
  /// In en, this message translates to:
  /// **'Sweet leaning'**
  String get flavorLeaningSweet;

  /// No description provided for @flavorLeaningSavory.
  ///
  /// In en, this message translates to:
  /// **'Savory leaning'**
  String get flavorLeaningSavory;

  /// No description provided for @flavorLeaningBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced leaning'**
  String get flavorLeaningBalanced;

  /// No description provided for @flavorTextureCrunchy.
  ///
  /// In en, this message translates to:
  /// **'Crunchy texture'**
  String get flavorTextureCrunchy;

  /// No description provided for @flavorTextureCreamy.
  ///
  /// In en, this message translates to:
  /// **'Creamy texture'**
  String get flavorTextureCreamy;

  /// No description provided for @flavorTextureBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced texture'**
  String get flavorTextureBalanced;

  /// No description provided for @onbCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get onbCreateAccount;

  /// No description provided for @onbEmailHint.
  ///
  /// In en, this message translates to:
  /// **'john@example.com'**
  String get onbEmailHint;

  /// No description provided for @onbNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get onbNameHint;

  /// No description provided for @commonFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get commonFullName;

  /// No description provided for @onbCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure your recipes and preferences'**
  String get onbCreateAccountSubtitle;

  /// No description provided for @onbCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get onbCreateAccountTitle;

  /// No description provided for @valPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get valPasswordMin;

  /// No description provided for @valEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get valEnterPassword;

  /// No description provided for @valValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get valValidEmail;

  /// No description provided for @valEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get valEnterEmail;

  /// No description provided for @valEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get valEnterName;

  /// No description provided for @onbAgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll use this to personalize your recommendations'**
  String get onbAgeSubtitle;

  /// No description provided for @onbAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get onbAgeTitle;

  /// No description provided for @onbAllergiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll automatically filter recipes for you'**
  String get onbAllergiesSubtitle;

  /// No description provided for @onbAllergiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you have any\ndietary restrictions or\nallergies?'**
  String get onbAllergiesTitle;

  /// No description provided for @onbMoreDietLater.
  ///
  /// In en, this message translates to:
  /// **'Additional dietary preferences can be updated later in Settings.'**
  String get onbMoreDietLater;

  /// No description provided for @onbCommonAllergies.
  ///
  /// In en, this message translates to:
  /// **'Common allergies'**
  String get onbCommonAllergies;

  /// No description provided for @onbTypeCuisine.
  ///
  /// In en, this message translates to:
  /// **'Type a cuisine...'**
  String get onbTypeCuisine;

  /// No description provided for @onbSpecifyCuisines.
  ///
  /// In en, this message translates to:
  /// **'Specify other cuisines'**
  String get onbSpecifyCuisines;

  /// No description provided for @onbCuisinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your favorites. The more you choose, the\nbetter your recommendations'**
  String get onbCuisinesSubtitle;

  /// No description provided for @onbCuisinesTitle.
  ///
  /// In en, this message translates to:
  /// **'What cuisines do\nyou love?'**
  String get onbCuisinesTitle;

  /// No description provided for @onbSelectOneCuisine.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one cuisine'**
  String get onbSelectOneCuisine;

  /// No description provided for @commonSelectAllThatApply.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply.'**
  String get commonSelectAllThatApply;

  /// No description provided for @onbDietTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your dietary profile?'**
  String get onbDietTitle;

  /// No description provided for @onbMorePrefsLater.
  ///
  /// In en, this message translates to:
  /// **'More preferences can be updated later in Settings.'**
  String get onbMorePrefsLater;

  /// No description provided for @onbDislikeHint.
  ///
  /// In en, this message translates to:
  /// **'Type a food you dislike (e.g. Pork, Mayo)...'**
  String get onbDislikeHint;

  /// No description provided for @onbDislikesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll keep them out of your\nrecommendations'**
  String get onbDislikesSubtitle;

  /// No description provided for @onbDislikesTitle.
  ///
  /// In en, this message translates to:
  /// **'What foods don’t\nyou like?'**
  String get onbDislikesTitle;

  /// No description provided for @onbFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the features you’ll use most'**
  String get onbFeaturesSubtitle;

  /// No description provided for @onbFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you most\nexcited about?'**
  String get onbFeaturesTitle;

  /// No description provided for @onbProfilePreview.
  ///
  /// In en, this message translates to:
  /// **'YOUR PROFILE PREVIEW'**
  String get onbProfilePreview;

  /// No description provided for @onbSpiceTolerance.
  ///
  /// In en, this message translates to:
  /// **'Spice Tolerance'**
  String get onbSpiceTolerance;

  /// No description provided for @onbFlavorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move the sliders to match your taste'**
  String get onbFlavorSubtitle;

  /// No description provided for @onbFlavorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your flavor DNA'**
  String get onbFlavorTitle;

  /// No description provided for @onbFrustrationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the ones that feel most true'**
  String get onbFrustrationsSubtitle;

  /// No description provided for @onbFrustrationsTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s holding you back from cooking more?'**
  String get onbFrustrationsTitle;

  /// No description provided for @onbGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll personalize everything around it'**
  String get onbGoalsSubtitle;

  /// No description provided for @onbGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'What’s your goal\nright now?'**
  String get onbGoalsTitle;

  /// No description provided for @onbEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter equipment and press Enter'**
  String get onbEquipmentHint;

  /// No description provided for @onbSpecifyEquipment.
  ///
  /// In en, this message translates to:
  /// **'Specify other equipment'**
  String get onbSpecifyEquipment;

  /// No description provided for @onbKitchenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your equipment'**
  String get onbKitchenSubtitle;

  /// No description provided for @onbKitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s in your kitchen?'**
  String get onbKitchenTitle;

  /// No description provided for @onbPlanningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll customize the experience for you'**
  String get onbPlanningSubtitle;

  /// No description provided for @onbPlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you like to plan meals?'**
  String get onbPlanningTitle;

  /// No description provided for @onbNotifFooter.
  ///
  /// In en, this message translates to:
  /// **'You can adjust these anytime in your settings'**
  String get onbNotifFooter;

  /// No description provided for @onbTurnOnAll.
  ///
  /// In en, this message translates to:
  /// **'Turn on all'**
  String get onbTurnOnAll;

  /// No description provided for @onbTurnOffAll.
  ///
  /// In en, this message translates to:
  /// **'Turn off all'**
  String get onbTurnOffAll;

  /// No description provided for @onbNotifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you\'d like to hear about'**
  String get onbNotifSubtitle;

  /// No description provided for @onbNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay inspired with new recipes'**
  String get onbNotifTitle;

  /// No description provided for @onbVerifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get onbVerifyContinue;

  /// No description provided for @onbNoCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive a code?'**
  String get onbNoCode;

  /// No description provided for @onbOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code we sent to\n{email}'**
  String onbOtpSentTo(String email);

  /// No description provided for @onbVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get onbVerifyAccount;

  /// No description provided for @onbStartCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cookin\''**
  String get onbStartCooking;

  /// No description provided for @onbUsesIngredients.
  ///
  /// In en, this message translates to:
  /// **'Uses your ingredients'**
  String get onbUsesIngredients;

  /// No description provided for @onbQuickDinner.
  ///
  /// In en, this message translates to:
  /// **'Quick dinner'**
  String get onbQuickDinner;

  /// No description provided for @onbMatchesTaste.
  ///
  /// In en, this message translates to:
  /// **'Matches your taste'**
  String get onbMatchesTaste;

  /// No description provided for @onbWhyPicked.
  ///
  /// In en, this message translates to:
  /// **'Why we picked this'**
  String get onbWhyPicked;

  /// No description provided for @onbPerfectMealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your goals, taste, and cooking'**
  String get onbPerfectMealSubtitle;

  /// No description provided for @onbPerfectMeal.
  ///
  /// In en, this message translates to:
  /// **'Perfect meal for you'**
  String get onbPerfectMeal;

  /// No description provided for @commonSoonSuffix.
  ///
  /// In en, this message translates to:
  /// **'{label} (Soon)'**
  String commonSoonSuffix(String label);

  /// No description provided for @authSignInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get authSignInWithEmail;

  /// No description provided for @onbSavePlan.
  ///
  /// In en, this message translates to:
  /// **'Save your\npersonalized plan'**
  String get onbSavePlan;

  /// No description provided for @onbTargetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us recommend the right portions'**
  String get onbTargetSubtitle;

  /// No description provided for @onbTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you usually\ncooking for?'**
  String get onbTargetTitle;

  /// No description provided for @onbCookingTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking time'**
  String get onbCookingTime;

  /// No description provided for @onbTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll prioritize recipes that fit your schedule'**
  String get onbTimeSubtitle;

  /// No description provided for @onbTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'How much time do you\nusually have to cook?'**
  String get onbTimeTitle;

  /// No description provided for @priceBilledMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get priceBilledMonthly;

  /// No description provided for @priceBilledPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Billed {price} per month'**
  String priceBilledPerMonth(String price);

  /// No description provided for @commonProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get commonProcessing;

  /// No description provided for @commonContinuing.
  ///
  /// In en, this message translates to:
  /// **'Continuing'**
  String get commonContinuing;

  /// No description provided for @onbStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start My 3-Day Free Trial'**
  String get onbStartTrial;

  /// No description provided for @onbSkipEatMost.
  ///
  /// In en, this message translates to:
  /// **'Skip — I eat most things'**
  String get onbSkipEatMost;

  /// No description provided for @commonConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get commonConnecting;

  /// No description provided for @onbGoogleSignupTip.
  ///
  /// In en, this message translates to:
  /// **'{error}\n\nTip: If the problem persists with Google, try signing up via email.'**
  String onbGoogleSignupTip(String error);

  /// No description provided for @onbCompleteAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Please complete account info to save your profile'**
  String get onbCompleteAccountInfo;

  /// No description provided for @payCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Could not initiate purchase'**
  String get payCouldNotStart;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCodeHint;

  /// No description provided for @referralCanSkip.
  ///
  /// In en, this message translates to:
  /// **'You can skip this step'**
  String get referralCanSkip;

  /// No description provided for @referralEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code (optional)'**
  String get referralEnterCode;

  /// No description provided for @giftUnlocked.
  ///
  /// In en, this message translates to:
  /// **'🎉 {plan} of Cooked Premium unlocked!'**
  String giftUnlocked(String plan);

  /// No description provided for @priceTrialThenYearly.
  ///
  /// In en, this message translates to:
  /// **'3 days free, then {price}/year'**
  String priceTrialThenYearly(String price);

  /// No description provided for @priceTrialThenBilledYearly.
  ///
  /// In en, this message translates to:
  /// **'3 days free, then billed yearly'**
  String get priceTrialThenBilledYearly;

  /// No description provided for @commonCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'{text}. Cancel anytime.'**
  String commonCancelAnytime(String text);

  /// No description provided for @trialHaveReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Do you have a referral code?'**
  String get trialHaveReferralCode;

  /// No description provided for @trialMonthlyNoTrialNoPrice.
  ///
  /// In en, this message translates to:
  /// **'No free trial. Billed immediately. Cancel anytime.'**
  String get trialMonthlyNoTrialNoPrice;

  /// No description provided for @trialMonthlyNoTrial.
  ///
  /// In en, this message translates to:
  /// **'No free trial. Billed immediately at {price}/month. Cancel anytime.'**
  String trialMonthlyNoTrial(String price);

  /// No description provided for @commonProcessingDots.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get commonProcessingDots;

  /// No description provided for @trialTryFree.
  ///
  /// In en, this message translates to:
  /// **'Start 3-Day Free Trial'**
  String get trialTryFree;

  /// No description provided for @trialSubscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get trialSubscribeNow;

  /// No description provided for @trialNoPaymentToday.
  ///
  /// In en, this message translates to:
  /// **'No payment due today'**
  String get trialNoPaymentToday;

  /// No description provided for @trialThreeDaysFree.
  ///
  /// In en, this message translates to:
  /// **'3 days free'**
  String get trialThreeDaysFree;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @trialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built around your goals, schedule, and taste.'**
  String get trialSubtitle;

  /// No description provided for @trialTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock your full\npersonalized cooking system.'**
  String get trialTitle;

  /// No description provided for @pricePerYearShort.
  ///
  /// In en, this message translates to:
  /// **'{price} /year'**
  String pricePerYearShort(String price);

  /// No description provided for @pricePerMonthShort.
  ///
  /// In en, this message translates to:
  /// **'{price} /mo'**
  String pricePerMonthShort(String price);

  /// No description provided for @faqImportQ.
  ///
  /// In en, this message translates to:
  /// **'How do I import a recipe?'**
  String get faqImportQ;

  /// No description provided for @faqImportA.
  ///
  /// In en, this message translates to:
  /// **'Go to the Import tab, paste a link, or use the camera to scan a recipe.'**
  String get faqImportA;

  /// No description provided for @faqShareQ.
  ///
  /// In en, this message translates to:
  /// **'Can I share my recipes?'**
  String get faqShareQ;

  /// No description provided for @faqShareA.
  ///
  /// In en, this message translates to:
  /// **'Yes! Open a recipe and tap the share button in the top right corner.'**
  String get faqShareA;

  /// No description provided for @faqCookbookQ.
  ///
  /// In en, this message translates to:
  /// **'How do I create a cookbook?'**
  String get faqCookbookQ;

  /// No description provided for @faqCookbookA.
  ///
  /// In en, this message translates to:
  /// **'From the Home tab, tap the « + » button next to Your Cookbooks.'**
  String get faqCookbookA;

  /// No description provided for @faqPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'How do I change my password?'**
  String get faqPasswordQ;

  /// No description provided for @faqPasswordA.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings → Change Password and enter your new password.'**
  String get faqPasswordA;

  /// No description provided for @faqWebQ.
  ///
  /// In en, this message translates to:
  /// **'Is there a web version?'**
  String get faqWebQ;

  /// No description provided for @faqWebA.
  ///
  /// In en, this message translates to:
  /// **'No, Cooked is currently available as a mobile app only.'**
  String get faqWebA;

  /// No description provided for @feedbackCatAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get feedbackCatAccount;

  /// No description provided for @feedbackCatPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get feedbackCatPayment;

  /// No description provided for @feedbackCatScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get feedbackCatScan;

  /// No description provided for @feedbackCatImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get feedbackCatImport;

  /// No description provided for @feedbackCatRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get feedbackCatRecipe;

  /// No description provided for @feedbackCatShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get feedbackCatShopping;

  /// No description provided for @feedbackCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackCatOther;

  /// No description provided for @prefsFlavorSummary.
  ///
  /// In en, this message translates to:
  /// **'{spice}, {count, plural, =1{1 preference} other{{count} preferences}}'**
  String prefsFlavorSummary(String spice, int count);

  /// No description provided for @savingsFromRecipes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{From 1 saved recipe} other{From {count} saved recipes}}'**
  String savingsFromRecipes(int count);

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t imported or scanned any recipes yet.'**
  String get activityEmpty;

  /// No description provided for @activityRecentRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recent Recipes'**
  String get activityRecentRecipes;

  /// No description provided for @prefsAllergiesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update allergies'**
  String get prefsAllergiesUpdateFailed;

  /// No description provided for @prefsFlavorSpice.
  ///
  /// In en, this message translates to:
  /// **'Flavor & Spice'**
  String get prefsFlavorSpice;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @prefsFavoriteCuisines.
  ///
  /// In en, this message translates to:
  /// **'Favorite Cuisines'**
  String get prefsFavoriteCuisines;

  /// No description provided for @prefsCuisineUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update cuisine & flavor preferences'**
  String get prefsCuisineUpdateFailed;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem...'**
  String get feedbackHint;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get feedbackMessage;

  /// No description provided for @feedbackCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get feedbackCategory;

  /// No description provided for @feedbackHeadline.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you 💬\nDescribe your problem and we\'ll help you as soon as possible.'**
  String get feedbackHeadline;

  /// No description provided for @feedbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send feedback. Please try again.'**
  String get feedbackFailed;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your feedback has been sent.'**
  String get feedbackSent;

  /// No description provided for @feedbackNoEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not find your account email.'**
  String get feedbackNoEmail;

  /// No description provided for @feedbackWriteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please write a message first.'**
  String get feedbackWriteFirst;

  /// No description provided for @legalCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookie Policy'**
  String get legalCookies;

  /// No description provided for @legalRefundCancellation.
  ///
  /// In en, this message translates to:
  /// **'Refund & Cancellation'**
  String get legalRefundCancellation;

  /// No description provided for @legalRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund Policy'**
  String get legalRefund;

  /// No description provided for @legalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get legalTerms;

  /// No description provided for @helpLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal & Policies'**
  String get helpLegal;

  /// No description provided for @helpSendFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bugs, ideas, or anything else'**
  String get helpSendFeedbackSubtitle;

  /// No description provided for @helpSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get helpSendFeedback;

  /// No description provided for @helpHeadline.
  ///
  /// In en, this message translates to:
  /// **'Tell us how we can help 👋\nOur team is standing by for service & support!'**
  String get helpHeadline;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpTitle;

  /// No description provided for @prefsKitchenUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update kitchen equipment'**
  String get prefsKitchenUpdateFailed;

  /// No description provided for @giftRedeeming.
  ///
  /// In en, this message translates to:
  /// **'Redeeming...'**
  String get giftRedeeming;

  /// No description provided for @giftRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get giftRedeem;

  /// No description provided for @giftRedeemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your gift code to unlock Cooked Premium on this account.'**
  String get giftRedeemSubtitle;

  /// No description provided for @giftRedeemHeadline.
  ///
  /// In en, this message translates to:
  /// **'Someone gifted you Cooked?'**
  String get giftRedeemHeadline;

  /// No description provided for @giftRedeemTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem a gift'**
  String get giftRedeemTitle;

  /// No description provided for @savingsScannedAtHome.
  ///
  /// In en, this message translates to:
  /// **'Scanned at home'**
  String get savingsScannedAtHome;

  /// No description provided for @savingsYourSaved.
  ///
  /// In en, this message translates to:
  /// **'Your saved'**
  String get savingsYourSaved;

  /// No description provided for @savingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No scan savings yet'**
  String get savingsEmpty;

  /// No description provided for @savingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Savings'**
  String get savingsTitle;

  /// No description provided for @subAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get subAmount;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNotAvailable;

  /// No description provided for @subFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get subFreeTrial;

  /// No description provided for @subPremiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get subPremiumPlan;

  /// No description provided for @subNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payment history found'**
  String get subNoPayments;

  /// No description provided for @subPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get subPaymentHistory;

  /// No description provided for @subRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subRestorePurchases;

  /// No description provided for @subActive.
  ///
  /// In en, this message translates to:
  /// **'Active Subscription'**
  String get subActive;

  /// No description provided for @subRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew or Upgrade'**
  String get subRenew;

  /// No description provided for @subAlreadyPremium.
  ///
  /// In en, this message translates to:
  /// **'You are already a Premium member!'**
  String get subAlreadyPremium;

  /// No description provided for @subStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get subStatus;

  /// No description provided for @subEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get subEndDate;

  /// No description provided for @subStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get subStartDate;

  /// No description provided for @subPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get subPlan;

  /// No description provided for @subDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subDetails;

  /// No description provided for @subTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subTitle;

  /// No description provided for @subNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions found to restore.'**
  String get subNothingToRestore;

  /// No description provided for @subRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored!'**
  String get subRestored;

  /// No description provided for @subExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get subExpiringSoon;

  /// No description provided for @subHoursLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour left} other{{count} hours left}}'**
  String subHoursLeft(int count);

  /// No description provided for @subDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day left} other{{count} days left}}'**
  String subDaysLeft(int count);

  /// No description provided for @subExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get subExpired;

  /// No description provided for @subNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get subNoActive;

  /// No description provided for @subLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscription status'**
  String get subLoadFailed;

  /// No description provided for @prefsGoals.
  ///
  /// In en, this message translates to:
  /// **'Onboarding Goals'**
  String get prefsGoals;

  /// No description provided for @prefsSectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get prefsSectionOther;

  /// No description provided for @prefsCookingTarget.
  ///
  /// In en, this message translates to:
  /// **'Cooking Target'**
  String get prefsCookingTarget;

  /// No description provided for @prefsPlanningStyle.
  ///
  /// In en, this message translates to:
  /// **'Meal Planning Style'**
  String get prefsPlanningStyle;

  /// No description provided for @prefsSectionPlanning.
  ///
  /// In en, this message translates to:
  /// **'Meal Planning & Habits'**
  String get prefsSectionPlanning;

  /// No description provided for @prefsTimePreference.
  ///
  /// In en, this message translates to:
  /// **'Time Preference'**
  String get prefsTimePreference;

  /// No description provided for @prefsCookingSkill.
  ///
  /// In en, this message translates to:
  /// **'Cooking Skill'**
  String get prefsCookingSkill;

  /// No description provided for @prefsSectionCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking & Skills'**
  String get prefsSectionCooking;

  /// No description provided for @prefsFoodDislikes.
  ///
  /// In en, this message translates to:
  /// **'Food Dislikes'**
  String get prefsFoodDislikes;

  /// No description provided for @prefsDietaryProfile.
  ///
  /// In en, this message translates to:
  /// **'Dietary Profile'**
  String get prefsDietaryProfile;

  /// No description provided for @prefsSectionDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get prefsSectionDiet;

  /// No description provided for @prefsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update preferences'**
  String get prefsUpdateFailed;

  /// No description provided for @prefsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated successfully!'**
  String get prefsUpdated;

  /// No description provided for @prefsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load preferences'**
  String get prefsLoadFailed;

  /// No description provided for @giftPlanOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get giftPlanOneYear;

  /// No description provided for @giftPlanThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get giftPlanThreeMonths;

  /// No description provided for @giftPlanOneYearDesc.
  ///
  /// In en, this message translates to:
  /// **'Give the gift of a 1-year Premium subscription to Cooked. Purchase is not refundable.'**
  String get giftPlanOneYearDesc;

  /// No description provided for @giftPlanThreeMonthsDesc.
  ///
  /// In en, this message translates to:
  /// **'Give the gift of a 3-month Premium subscription to Cooked. Purchase is not refundable.'**
  String get giftPlanThreeMonthsDesc;

  /// No description provided for @giftShareMessage.
  ///
  /// In en, this message translates to:
  /// **'🎁 I got you {plan} of Cooked Premium! Redeem it here: {url}\n\nOr open Cooked and enter this code: {code}'**
  String giftShareMessage(String plan, String url, String code);

  /// No description provided for @giftTapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get giftTapToCopy;

  /// No description provided for @giftRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get giftRefunded;

  /// No description provided for @giftRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get giftRedeemed;

  /// No description provided for @giftNotUsed.
  ///
  /// In en, this message translates to:
  /// **'Not used yet'**
  String get giftNotUsed;

  /// No description provided for @giftBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy gift'**
  String get giftBuy;

  /// No description provided for @giftBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get giftBestValue;

  /// No description provided for @giftYourGifts.
  ///
  /// In en, this message translates to:
  /// **'Your gifts'**
  String get giftYourGifts;

  /// No description provided for @giftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy a gift code and send it to a friend. They redeem it in the app - no subscription needed on their side.'**
  String get giftSubtitle;

  /// No description provided for @giftHeadline.
  ///
  /// In en, this message translates to:
  /// **'Give the gift of Cooked'**
  String get giftHeadline;

  /// No description provided for @giftTitle.
  ///
  /// In en, this message translates to:
  /// **'Gift Cooked'**
  String get giftTitle;

  /// No description provided for @giftSendToFriend.
  ///
  /// In en, this message translates to:
  /// **'Send to a friend'**
  String get giftSendToFriend;

  /// No description provided for @giftSendThisCode.
  ///
  /// In en, this message translates to:
  /// **'Send this {plan} code to a friend. We also emailed it to you.'**
  String giftSendThisCode(String plan);

  /// No description provided for @giftReady.
  ///
  /// In en, this message translates to:
  /// **'Your gift is ready!'**
  String get giftReady;

  /// No description provided for @giftCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Gift code copied'**
  String get giftCodeCopied;

  /// No description provided for @giftPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get giftPurchaseFailed;

  /// No description provided for @giftPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received! We\'ll email you the gift code in a moment.'**
  String get giftPaymentReceived;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Check out {name} on Cooked 🙌\n{link}'**
  String shareRecipe(String name, String link);

  /// No description provided for @shareRecipeByCreator.
  ///
  /// In en, this message translates to:
  /// **'Check out {creator}\'s {name} on Cooked 🙌\n{link}'**
  String shareRecipeByCreator(String creator, String name, String link);

  /// No description provided for @savingsComparedTakeout.
  ///
  /// In en, this message translates to:
  /// **'Comparing to ordered takeout.'**
  String get savingsComparedTakeout;

  /// No description provided for @savingsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get savingsThisMonth;

  /// No description provided for @recipeAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'This recipe is already present in your recipes'**
  String get recipeAlreadySaved;

  /// No description provided for @homeSuggestedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Suggested Recipes'**
  String get homeSuggestedRecipes;

  /// No description provided for @cookbookDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete cookbook'**
  String get cookbookDeleteFailed;

  /// No description provided for @cookbookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cookbook deleted'**
  String get cookbookDeleted;

  /// No description provided for @cookbookDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Cookbook'**
  String get cookbookDelete;

  /// No description provided for @commonOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get commonOperationFailed;

  /// No description provided for @cookbookUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Cookbook unpinned'**
  String get cookbookUnpinned;

  /// No description provided for @cookbookPinned.
  ///
  /// In en, this message translates to:
  /// **'Cookbook pinned'**
  String get cookbookPinned;

  /// No description provided for @cookbookPin.
  ///
  /// In en, this message translates to:
  /// **'Pin Cookbook'**
  String get cookbookPin;

  /// No description provided for @cookbookUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin Cookbook'**
  String get cookbookUnpin;

  /// No description provided for @cookbookEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Cookbook'**
  String get cookbookEdit;

  /// No description provided for @cookbookAddRecipes.
  ///
  /// In en, this message translates to:
  /// **'Add Recipes'**
  String get cookbookAddRecipes;

  /// No description provided for @cookbookNew.
  ///
  /// In en, this message translates to:
  /// **'New Cookbook'**
  String get cookbookNew;

  /// No description provided for @feedbackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get feedbackSubmit;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThanks;

  /// No description provided for @feedbackTypeHere.
  ///
  /// In en, this message translates to:
  /// **'Type your feedback here...'**
  String get feedbackTypeHere;

  /// No description provided for @feedbackCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts, ideas, or anything that could make your experience better.'**
  String get feedbackCardSubtitle;

  /// No description provided for @feedbackCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve Cooked'**
  String get feedbackCardTitle;

  /// No description provided for @feedbackCardButton.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackCardButton;

  /// No description provided for @recipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get recipeDelete;

  /// No description provided for @recipeShare.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get recipeShare;

  /// No description provided for @recipeAddToCookbook.
  ///
  /// In en, this message translates to:
  /// **'Add to Cookbook'**
  String get recipeAddToCookbook;

  /// No description provided for @recipeRemoveFromCookbook.
  ///
  /// In en, this message translates to:
  /// **'Remove from Cookbook'**
  String get recipeRemoveFromCookbook;

  /// No description provided for @recipeUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin Recipe'**
  String get recipeUnpin;

  /// No description provided for @recipePin.
  ///
  /// In en, this message translates to:
  /// **'Pin Recipe'**
  String get recipePin;

  /// No description provided for @recipeRemovedToast.
  ///
  /// In en, this message translates to:
  /// **'Recipe removed from saved'**
  String get recipeRemovedToast;

  /// No description provided for @recipeSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved to favorites!'**
  String get recipeSavedToast;

  /// No description provided for @navImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get navImport;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @commonTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get commonTryDifferentSearch;

  /// No description provided for @homeBrowseRecipes.
  ///
  /// In en, this message translates to:
  /// **'Browse Recipes'**
  String get homeBrowseRecipes;

  /// No description provided for @homeNoSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore our recipes and save your favorites\nto build your personal collection.'**
  String get homeNoSavedSubtitle;

  /// No description provided for @homeNoSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved recipes yet'**
  String get homeNoSavedTitle;

  /// No description provided for @homeAddCookbook.
  ///
  /// In en, this message translates to:
  /// **'Add cookbook'**
  String get homeAddCookbook;

  /// No description provided for @homeCookbookEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite recipes and\nkeep them all in one place.'**
  String get homeCookbookEmptySubtitle;

  /// No description provided for @homeCookbookEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start building your cookbook'**
  String get homeCookbookEmptyTitle;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @homeSavedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Saved Recipes'**
  String get homeSavedRecipes;

  /// No description provided for @homeSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested for you'**
  String get homeSuggested;

  /// No description provided for @homeRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get homeRecentlyViewed;

  /// No description provided for @homeCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks'**
  String get homeCookbooks;

  /// No description provided for @homeYourCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Your Cookbooks'**
  String get homeYourCookbooks;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your recipes'**
  String get homeSearchHint;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'What would you like to cook today?'**
  String get homeHeadline;

  /// No description provided for @navGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get navGrocery;

  /// No description provided for @navScanRecipe.
  ///
  /// In en, this message translates to:
  /// **'Scan Recipe'**
  String get navScanRecipe;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe} other{{count} recipes}}'**
  String recipeCount(int count);

  /// No description provided for @recipeCountTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Recipe} other{{count} Recipes}}'**
  String recipeCountTitle(int count);

  /// No description provided for @cookbookDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get cookbookDefaultName;

  /// No description provided for @recipePinned.
  ///
  /// In en, this message translates to:
  /// **'Recipe pinned'**
  String get recipePinned;

  /// No description provided for @recipeUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Recipe unpinned'**
  String get recipeUnpinned;

  /// No description provided for @recipePinFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pin recipe'**
  String get recipePinFailed;

  /// No description provided for @recipeRemovedFromCookbook.
  ///
  /// In en, this message translates to:
  /// **'Removed from Cookbook'**
  String get recipeRemovedFromCookbook;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted'**
  String get recipeDeleted;

  /// No description provided for @cookbookEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get cookbookEmptyTitle;

  /// No description provided for @cookbookEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding recipes to this cookbook by scanning, importing or exploring.'**
  String get cookbookEmptySubtitle;

  /// No description provided for @recipeServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get recipeServings;

  /// No description provided for @recipeQuantitiesAdjust.
  ///
  /// In en, this message translates to:
  /// **'Quantities adjust automatically'**
  String get recipeQuantitiesAdjust;

  /// No description provided for @commonLoadingDots.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoadingDots;

  /// No description provided for @commonGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get commonGoBack;

  /// No description provided for @recipeServingsPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Person} other{{count} People}}'**
  String recipeServingsPeople(int count);

  /// No description provided for @recipeAddToGrocery.
  ///
  /// In en, this message translates to:
  /// **'Add to Grocery'**
  String get recipeAddToGrocery;

  /// No description provided for @recipeSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get recipeSteps;

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// No description provided for @recipeAlsoRemoveSaved.
  ///
  /// In en, this message translates to:
  /// **'Do you also want to remove this recipe from Saved Recipes?'**
  String get recipeAlsoRemoveSaved;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @recipeRemovedBoth.
  ///
  /// In en, this message translates to:
  /// **'Removed from Cookbook and Saved Recipes'**
  String get recipeRemovedBoth;

  /// No description provided for @recipeNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed'**
  String get recipeNoIngredients;

  /// No description provided for @recipeNoIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'Check the recipe description for details.'**
  String get recipeNoIngredientsHint;

  /// No description provided for @recipeNoEquipment.
  ///
  /// In en, this message translates to:
  /// **'No specific equipment listed'**
  String get recipeNoEquipment;

  /// No description provided for @recipeNoEquipmentHint.
  ///
  /// In en, this message translates to:
  /// **'Standard kitchen tools should be enough.'**
  String get recipeNoEquipmentHint;

  /// No description provided for @recipeNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No steps listed'**
  String get recipeNoSteps;

  /// No description provided for @recipeNoStepsHint.
  ///
  /// In en, this message translates to:
  /// **'Follow your intuition or check the source.'**
  String get recipeNoStepsHint;

  /// No description provided for @recipeRequiredEquipment.
  ///
  /// In en, this message translates to:
  /// **'Required Equipment'**
  String get recipeRequiredEquipment;

  /// No description provided for @recipeNotesTips.
  ///
  /// In en, this message translates to:
  /// **'Notes / Tips'**
  String get recipeNotesTips;

  /// No description provided for @recipeTonightSaving.
  ///
  /// In en, this message translates to:
  /// **'Tonight’s Saving'**
  String get recipeTonightSaving;

  /// No description provided for @recipeOrderingNearby.
  ///
  /// In en, this message translates to:
  /// **'Ordering nearby'**
  String get recipeOrderingNearby;

  /// No description provided for @recipeMakingAtHome.
  ///
  /// In en, this message translates to:
  /// **'Making at home'**
  String get recipeMakingAtHome;

  /// No description provided for @recipeEstimatedSavings.
  ///
  /// In en, this message translates to:
  /// **'Estimated savings'**
  String get recipeEstimatedSavings;

  /// No description provided for @viewAllCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get viewAllCuisine;

  /// No description provided for @viewAllSearchCuisine.
  ///
  /// In en, this message translates to:
  /// **'Search cuisine ...'**
  String get viewAllSearchCuisine;

  /// No description provided for @viewAllSearchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search category ...'**
  String get viewAllSearchCategory;

  /// No description provided for @viewAllSearchCuisineRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search {cuisine} recipes...'**
  String viewAllSearchCuisineRecipes(String cuisine);

  /// No description provided for @viewAllSearchRecent.
  ///
  /// In en, this message translates to:
  /// **'Search recently viewed recipes..'**
  String get viewAllSearchRecent;

  /// No description provided for @viewAllSearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search recipes, cookbooks....'**
  String get viewAllSearchAll;

  /// No description provided for @viewAllNoCookbooks.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks found.'**
  String get viewAllNoCookbooks;

  /// No description provided for @viewAllNoCookbooksMatch.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks match your search.'**
  String get viewAllNoCookbooksMatch;

  /// No description provided for @viewAllNoRecipesMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipes match your search.'**
  String get viewAllNoRecipesMatch;

  /// No description provided for @viewAllNoRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes found.'**
  String get viewAllNoRecipes;

  /// No description provided for @commonRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get commonRecipes;

  /// No description provided for @recipeDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete this recipe. Please try again.'**
  String get recipeDeleteFailed;

  /// No description provided for @recipeAlreadyInYours.
  ///
  /// In en, this message translates to:
  /// **'Already in your recipes'**
  String get recipeAlreadyInYours;

  /// No description provided for @viewAllNoCreatorsMatch.
  ///
  /// In en, this message translates to:
  /// **'No creators match your search.'**
  String get viewAllNoCreatorsMatch;

  /// No description provided for @viewAllNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items found.'**
  String get viewAllNoItems;

  /// No description provided for @viewAllNoItemsMatch.
  ///
  /// In en, this message translates to:
  /// **'No items match your search.'**
  String get viewAllNoItemsMatch;

  /// No description provided for @cameraInitializing.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get cameraInitializing;

  /// No description provided for @cameraOnHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get cameraOnHold;

  /// No description provided for @cameraOff.
  ///
  /// In en, this message translates to:
  /// **'Camera off'**
  String get cameraOff;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding cameras...'**
  String get cameraFinding;

  /// No description provided for @cameraNotFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found'**
  String get cameraNotFound;

  /// No description provided for @cameraReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get cameraReady;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraError;

  /// No description provided for @scanAddIngredientsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add or select ingredients'**
  String get scanAddIngredientsFirst;

  /// No description provided for @scanTypeIngredient.
  ///
  /// In en, this message translates to:
  /// **'Type Ingredient'**
  String get scanTypeIngredient;

  /// No description provided for @scanSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get scanSaved;

  /// No description provided for @scanGetRecipes.
  ///
  /// In en, this message translates to:
  /// **'Get Recipes'**
  String get scanGetRecipes;

  /// No description provided for @scanTypeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Type Ingredients'**
  String get scanTypeIngredients;

  /// No description provided for @scanEnterOneByOne.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredients one by one'**
  String get scanEnterOneByOne;

  /// No description provided for @scanAddToFind.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to find recipes you can make'**
  String get scanAddToFind;

  /// No description provided for @scanRecentlyUsed.
  ///
  /// In en, this message translates to:
  /// **'Recently Used'**
  String get scanRecentlyUsed;

  /// No description provided for @scanUseAll.
  ///
  /// In en, this message translates to:
  /// **'Use all'**
  String get scanUseAll;

  /// No description provided for @scanClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get scanClearSelection;

  /// No description provided for @scanNoSaved.
  ///
  /// In en, this message translates to:
  /// **'No saved ingredients yet.'**
  String get scanNoSaved;

  /// No description provided for @scanResultsTitleA.
  ///
  /// In en, this message translates to:
  /// **'Recipes You\n'**
  String get scanResultsTitleA;

  /// No description provided for @scanResultsTitleB.
  ///
  /// In en, this message translates to:
  /// **'Can Cook Now'**
  String get scanResultsTitleB;

  /// No description provided for @scanFoundRecipes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{We found 1 recipe for you} other{We found {count} recipes for you}}'**
  String scanFoundRecipes(int count);

  /// No description provided for @scanYourIngredients.
  ///
  /// In en, this message translates to:
  /// **'Your Ingredients'**
  String get scanYourIngredients;

  /// No description provided for @scanFoundItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{We found 1 item in your kitchen} other{We found {count} items in your kitchen}}'**
  String scanFoundItems(int count);

  /// No description provided for @scanViewRecipe.
  ///
  /// In en, this message translates to:
  /// **'View Recipe'**
  String get scanViewRecipe;

  /// No description provided for @importRecipePreview.
  ///
  /// In en, this message translates to:
  /// **'Recipe Preview'**
  String get importRecipePreview;

  /// No description provided for @importLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This recipe link isn\'t available.'**
  String get importLinkUnavailable;

  /// No description provided for @importInvalidLink.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid recipe link (e.g. https://example.com/recipe)'**
  String get importInvalidLink;

  /// No description provided for @importAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This recipe is already in your collection'**
  String get importAlreadyExists;

  /// No description provided for @importExtractFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t extract a recipe from this link. The page didn\'t contain enough recipe information.'**
  String get importExtractFailed;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe imported successfully!'**
  String get importSuccess;

  /// No description provided for @importManualSoon.
  ///
  /// In en, this message translates to:
  /// **'Manual recipe entry coming soon'**
  String get importManualSoon;

  /// No description provided for @importRecipeLink.
  ///
  /// In en, this message translates to:
  /// **'Recipe Link'**
  String get importRecipeLink;

  /// No description provided for @importPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe link...'**
  String get importPasteHint;

  /// No description provided for @importImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing'**
  String get importImporting;

  /// No description provided for @importSearchWeb.
  ///
  /// In en, this message translates to:
  /// **'Search web'**
  String get importSearchWeb;

  /// No description provided for @importTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get importTrending;

  /// No description provided for @importRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent Imports'**
  String get importRecent;

  /// No description provided for @importNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No recent imports yet.'**
  String get importNoRecent;

  /// No description provided for @recipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get recipeEdit;

  /// No description provided for @importRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get importRecommended;

  /// No description provided for @importSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get importSuggestions;

  /// No description provided for @importSearchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get importSearchRecipesHint;

  /// No description provided for @importSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get importSearchResults;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @importViewThisRecipe.
  ///
  /// In en, this message translates to:
  /// **'View this recipe'**
  String get importViewThisRecipe;

  /// No description provided for @importToCooked.
  ///
  /// In en, this message translates to:
  /// **'Import to Cooked'**
  String get importToCooked;

  /// No description provided for @filterHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get filterHighProtein;

  /// No description provided for @filterUnder30Min.
  ///
  /// In en, this message translates to:
  /// **'Under 30 Min'**
  String get filterUnder30Min;

  /// No description provided for @filterBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get filterBreakfast;

  /// No description provided for @filterLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get filterLunch;

  /// No description provided for @filterDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get filterDinner;

  /// No description provided for @filterLowCalorie.
  ///
  /// In en, this message translates to:
  /// **'Low Calorie'**
  String get filterLowCalorie;

  /// No description provided for @filterOnePot.
  ///
  /// In en, this message translates to:
  /// **'One-Pot'**
  String get filterOnePot;

  /// No description provided for @filterBudgetFriendly.
  ///
  /// In en, this message translates to:
  /// **'Budget Friendly'**
  String get filterBudgetFriendly;

  /// No description provided for @filterVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get filterVegetarian;

  /// No description provided for @filterVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get filterVegan;

  /// No description provided for @filterNoCook.
  ///
  /// In en, this message translates to:
  /// **'No-Cook'**
  String get filterNoCook;

  /// No description provided for @filterDesserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get filterDesserts;

  /// No description provided for @filterSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get filterSnacks;

  /// No description provided for @filterSmoothies.
  ///
  /// In en, this message translates to:
  /// **'Smoothies'**
  String get filterSmoothies;

  /// No description provided for @filterSalads.
  ///
  /// In en, this message translates to:
  /// **'Salads'**
  String get filterSalads;

  /// No description provided for @filterSoups.
  ///
  /// In en, this message translates to:
  /// **'Soups'**
  String get filterSoups;

  /// No description provided for @filterPasta.
  ///
  /// In en, this message translates to:
  /// **'Pasta'**
  String get filterPasta;

  /// No description provided for @filterBowls.
  ///
  /// In en, this message translates to:
  /// **'Bowls'**
  String get filterBowls;

  /// No description provided for @filterSandwichesWraps.
  ///
  /// In en, this message translates to:
  /// **'Sandwiches & Wraps'**
  String get filterSandwichesWraps;

  /// No description provided for @filterChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get filterChicken;

  /// No description provided for @filterBeef.
  ///
  /// In en, this message translates to:
  /// **'Beef'**
  String get filterBeef;

  /// No description provided for @filterSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get filterSeafood;

  /// No description provided for @exploreNoFilterMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipes match \"{filter}\" yet.'**
  String exploreNoFilterMatch(String filter);

  /// No description provided for @exploreForYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get exploreForYou;

  /// No description provided for @explorePopularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular Categories'**
  String get explorePopularCategories;

  /// No description provided for @exploreCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exploreCategory;

  /// No description provided for @exploreCuisines.
  ///
  /// In en, this message translates to:
  /// **'Cuisines'**
  String get exploreCuisines;

  /// No description provided for @explorePopularNow.
  ///
  /// In en, this message translates to:
  /// **'Popular Now'**
  String get explorePopularNow;

  /// No description provided for @cookbookSelectRecipes.
  ///
  /// In en, this message translates to:
  /// **'Select Recipes'**
  String get cookbookSelectRecipes;

  /// No description provided for @cookbookNameHint.
  ///
  /// In en, this message translates to:
  /// **'Cookbook name'**
  String get cookbookNameHint;

  /// No description provided for @cookbookAddRecipesLower.
  ///
  /// In en, this message translates to:
  /// **'Add recipes'**
  String get cookbookAddRecipesLower;

  /// No description provided for @cookbookSelectForThis.
  ///
  /// In en, this message translates to:
  /// **'Select recipes for this cookbook'**
  String get cookbookSelectForThis;

  /// No description provided for @cookbookSelectedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Selected recipes'**
  String get cookbookSelectedRecipes;

  /// No description provided for @cookbookUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cookbook updated!'**
  String get cookbookUpdated;

  /// No description provided for @cookbookCreated.
  ///
  /// In en, this message translates to:
  /// **'Cookbook created!'**
  String get cookbookCreated;

  /// No description provided for @cookbookSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save \"{name}\": {error}'**
  String cookbookSaveFailed(String name, String error);

  /// No description provided for @cookbookNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipes found matching \"{query}\"'**
  String cookbookNoMatch(String query);

  /// No description provided for @cookbookExploreRecipes.
  ///
  /// In en, this message translates to:
  /// **'Explore recipes'**
  String get cookbookExploreRecipes;

  /// No description provided for @payActivated.
  ///
  /// In en, this message translates to:
  /// **'Premium Activated! Welcome to the Chef Club.'**
  String get payActivated;

  /// No description provided for @paySpecialComeback.
  ///
  /// In en, this message translates to:
  /// **'Special comeback offer'**
  String get paySpecialComeback;

  /// No description provided for @payUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get payUnlockPremium;

  /// No description provided for @payUnlockToKeep.
  ///
  /// In en, this message translates to:
  /// **'Unlock Cooked to keep \ncreating recipes.'**
  String get payUnlockToKeep;

  /// No description provided for @paySpecialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get paySpecialOffer;

  /// No description provided for @paySpecialOfferDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features forever with this limited discount.'**
  String get paySpecialOfferDesc;

  /// No description provided for @payUnlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Access'**
  String get payUnlimitedAccess;

  /// No description provided for @payUnlimitedAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan your fridge and import recipes without any limits.'**
  String get payUnlimitedAccessDesc;

  /// No description provided for @payExclusiveRecipes.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Recipes'**
  String get payExclusiveRecipes;

  /// No description provided for @payExclusiveRecipesDesc.
  ///
  /// In en, this message translates to:
  /// **'Access premium recipes and themed cookbooks.'**
  String get payExclusiveRecipesDesc;

  /// No description provided for @payImmediateAccess.
  ///
  /// In en, this message translates to:
  /// **'Immediate Access'**
  String get payImmediateAccess;

  /// No description provided for @payImmediateAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan your ingredients and import recipes from any link.'**
  String get payImmediateAccessDesc;

  /// No description provided for @payExclusiveContent.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Content'**
  String get payExclusiveContent;

  /// No description provided for @payExclusiveContentDesc.
  ///
  /// In en, this message translates to:
  /// **'Access premium generated recipes and themed cookbooks.'**
  String get payExclusiveContentDesc;

  /// No description provided for @payMasterChef.
  ///
  /// In en, this message translates to:
  /// **'Master Chef Status'**
  String get payMasterChef;

  /// No description provided for @payMasterChefDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a complete ad-free experience with priority AI processing.'**
  String get payMasterChefDesc;

  /// No description provided for @payPercentOff.
  ///
  /// In en, this message translates to:
  /// **'33% OFF'**
  String get payPercentOff;

  /// No description provided for @payBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get payBestValue;

  /// No description provided for @payImmediatePremium.
  ///
  /// In en, this message translates to:
  /// **'Immediate Premium Access'**
  String get payImmediatePremium;

  /// No description provided for @paySubscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now'**
  String get paySubscribeNow;

  /// No description provided for @pricePerMonthLong.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String pricePerMonthLong(String price);

  /// No description provided for @pricePerYearLong.
  ///
  /// In en, this message translates to:
  /// **'{price} / year'**
  String pricePerYearLong(String price);

  /// No description provided for @payDaysFree.
  ///
  /// In en, this message translates to:
  /// **'{days} days free'**
  String payDaysFree(String days);

  /// No description provided for @payNoPaymentToday.
  ///
  /// In en, this message translates to:
  /// **'no payment due today'**
  String get payNoPaymentToday;

  /// No description provided for @pricePerYearSentence.
  ///
  /// In en, this message translates to:
  /// **'{price} per year'**
  String pricePerYearSentence(String price);

  /// No description provided for @priceBilledYearly.
  ///
  /// In en, this message translates to:
  /// **'billed yearly'**
  String get priceBilledYearly;

  /// No description provided for @pricePerMonthSentence.
  ///
  /// In en, this message translates to:
  /// **'{price} per month'**
  String pricePerMonthSentence(String price);

  /// No description provided for @priceBilledMonthlyLower.
  ///
  /// In en, this message translates to:
  /// **'billed monthly'**
  String get priceBilledMonthlyLower;

  /// No description provided for @paySubscriptionsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are unavailable right now. Please try again later.'**
  String get paySubscriptionsUnavailable;

  /// No description provided for @payPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String payPurchaseFailed(String error);

  /// No description provided for @payRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore error: {error}'**
  String payRestoreFailed(String error);

  /// No description provided for @tutImportTarget.
  ///
  /// In en, this message translates to:
  /// **'Import recipes from TikTok,\nInstagram, or any Link'**
  String get tutImportTarget;

  /// No description provided for @tutScanTarget.
  ///
  /// In en, this message translates to:
  /// **'Scan and get instant recipes'**
  String get tutScanTarget;

  /// No description provided for @tutCookbooksTarget.
  ///
  /// In en, this message translates to:
  /// **'Save and organize your recipes here.'**
  String get tutCookbooksTarget;

  /// No description provided for @tutScanBestTitle.
  ///
  /// In en, this message translates to:
  /// **'Get the best scan'**
  String get tutScanBestTitle;

  /// No description provided for @tutScanSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone steady'**
  String get tutScanSteady;

  /// No description provided for @tutScanLighting.
  ///
  /// In en, this message translates to:
  /// **'Use good lighting'**
  String get tutScanLighting;

  /// No description provided for @tutScanVisible.
  ///
  /// In en, this message translates to:
  /// **'Make sure all ingredients are visible'**
  String get tutScanVisible;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @tutScanFindTitle.
  ///
  /// In en, this message translates to:
  /// **'We instantly find your ingredients'**
  String get tutScanFindTitle;

  /// No description provided for @tutScanSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo of your ingredients'**
  String get tutScanSnap;

  /// No description provided for @tutScanDetect.
  ///
  /// In en, this message translates to:
  /// **'We detect what\'s inside instantly'**
  String get tutScanDetect;

  /// No description provided for @tutScanEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit anything that looks off'**
  String get tutScanEdit;

  /// No description provided for @tutScanReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan'**
  String get tutScanReadyTitle;

  /// No description provided for @tutScanFridge.
  ///
  /// In en, this message translates to:
  /// **'Scan your fridge, pantry, or ingredients'**
  String get tutScanFridge;

  /// No description provided for @tutScanAngles.
  ///
  /// In en, this message translates to:
  /// **'Try different angles for better results'**
  String get tutScanAngles;

  /// No description provided for @tutScanMoreVisible.
  ///
  /// In en, this message translates to:
  /// **'The more visible, the better your recipes'**
  String get tutScanMoreVisible;

  /// No description provided for @tutScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get tutScanNow;

  /// No description provided for @tutImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import recipes from anywhere'**
  String get tutImportTitle;

  /// No description provided for @tutImportPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste a link from TikTok, Instagram, or any site'**
  String get tutImportPaste;

  /// No description provided for @tutImportShare.
  ///
  /// In en, this message translates to:
  /// **'Or share directly from social apps to import instantly'**
  String get tutImportShare;

  /// No description provided for @tutImportTurn.
  ///
  /// In en, this message translates to:
  /// **'We\'ll turn it into a full recipe automatically'**
  String get tutImportTurn;

  /// No description provided for @tutImportSave.
  ///
  /// In en, this message translates to:
  /// **'Save it to your cookbook'**
  String get tutImportSave;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @tutCookbookTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Organised Recipes'**
  String get tutCookbookTitle1;

  /// No description provided for @tutCookbookItem1.
  ///
  /// In en, this message translates to:
  /// **'Explore all recipes saved in this cookbook'**
  String get tutCookbookItem1;

  /// No description provided for @tutCookbookItem2.
  ///
  /// In en, this message translates to:
  /// **'Quickly browse through categories'**
  String get tutCookbookItem2;

  /// No description provided for @tutCookbookItem3.
  ///
  /// In en, this message translates to:
  /// **'Access your favorites in one tap'**
  String get tutCookbookItem3;

  /// No description provided for @tutCookbookTitle2.
  ///
  /// In en, this message translates to:
  /// **'Complete Control'**
  String get tutCookbookTitle2;

  /// No description provided for @tutCookbookItem4.
  ///
  /// In en, this message translates to:
  /// **'Edit cookbook details anytime'**
  String get tutCookbookItem4;

  /// No description provided for @tutCookbookItem5.
  ///
  /// In en, this message translates to:
  /// **'Add new recipes using the plus button'**
  String get tutCookbookItem5;

  /// No description provided for @tutCookbookItem6.
  ///
  /// In en, this message translates to:
  /// **'Tap any recipe to see full details'**
  String get tutCookbookItem6;

  /// No description provided for @tutExploreNow.
  ///
  /// In en, this message translates to:
  /// **'Explore Now'**
  String get tutExploreNow;

  /// No description provided for @tutIngredientsDetected.
  ///
  /// In en, this message translates to:
  /// **'Ingredients detected'**
  String get tutIngredientsDetected;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @cookbookAddedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String cookbookAddedTo(String name);

  /// No description provided for @cookbookAddedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Added to Cookbook'**
  String get cookbookAddedGeneric;

  /// No description provided for @avatarChooseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get avatarChooseLibrary;

  /// No description provided for @avatarTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get avatarTakePhoto;

  /// No description provided for @avatarDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting profile photo...'**
  String get avatarDeleting;

  /// No description provided for @avatarDeleted.
  ///
  /// In en, this message translates to:
  /// **'Profile photo deleted'**
  String get avatarDeleted;

  /// No description provided for @avatarUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating profile photo...'**
  String get avatarUpdating;

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated!'**
  String get avatarUpdated;

  /// No description provided for @clipRecipeDetected.
  ///
  /// In en, this message translates to:
  /// **'Recipe detected'**
  String get clipRecipeDetected;

  /// No description provided for @clipLinkFound.
  ///
  /// In en, this message translates to:
  /// **'Link found in clipboard'**
  String get clipLinkFound;

  /// No description provided for @clipPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get clipPaste;

  /// No description provided for @fallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get fallbackTitle;

  /// No description provided for @fallbackHeadline.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t import this recipe.'**
  String get fallbackHeadline;

  /// No description provided for @fallbackMessage.
  ///
  /// In en, this message translates to:
  /// **'This link didn’t include enough recipe information for Cooked to import it correctly.'**
  String get fallbackMessage;

  /// No description provided for @fallbackFailedUrl.
  ///
  /// In en, this message translates to:
  /// **'Failed link'**
  String get fallbackFailedUrl;

  /// No description provided for @fallbackTryOther.
  ///
  /// In en, this message translates to:
  /// **'Try another link'**
  String get fallbackTryOther;

  /// No description provided for @fallbackTryOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Paste a different recipe link'**
  String get fallbackTryOtherDesc;

  /// No description provided for @fallbackManual.
  ///
  /// In en, this message translates to:
  /// **'Add recipe manually'**
  String get fallbackManual;

  /// No description provided for @fallbackManualDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the ingredients and steps yourself'**
  String get fallbackManualDesc;

  /// No description provided for @groceryAlreadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Already in your Grocery List'**
  String get groceryAlreadyTitle;

  /// No description provided for @groceryAlreadyMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is already in your list. Add it again? '**
  String groceryAlreadyMessage(String name);

  /// No description provided for @groceryQuantitiesDoubled.
  ///
  /// In en, this message translates to:
  /// **'The quantities of these ingredients will be doubled.'**
  String get groceryQuantitiesDoubled;

  /// No description provided for @groceryAddAgain.
  ///
  /// In en, this message translates to:
  /// **'Add again'**
  String get groceryAddAgain;

  /// No description provided for @groceryAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to Grocery List'**
  String get groceryAddToList;

  /// No description provided for @grocerySelectIngredients.
  ///
  /// In en, this message translates to:
  /// **'Select Ingredients'**
  String get grocerySelectIngredients;

  /// No description provided for @grocerySaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get grocerySaveLocation;

  /// No description provided for @groceryDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String groceryDate(String date);

  /// No description provided for @groceryGeneralList.
  ///
  /// In en, this message translates to:
  /// **'General List'**
  String get groceryGeneralList;

  /// No description provided for @grocerySpecificDate.
  ///
  /// In en, this message translates to:
  /// **'Specific Date'**
  String get grocerySpecificDate;

  /// No description provided for @groceryAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add selected ingredients'**
  String get groceryAddSelected;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get commonSaving;

  /// No description provided for @recipeSavedInCookbook.
  ///
  /// In en, this message translates to:
  /// **'Saved in your cookbook'**
  String get recipeSavedInCookbook;

  /// No description provided for @headerGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String headerGreeting(String name);

  /// No description provided for @importGettingReady.
  ///
  /// In en, this message translates to:
  /// **'Getting it ready for Cooked'**
  String get importGettingReady;

  /// No description provided for @scanGeneratingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Generating recipes...'**
  String get scanGeneratingRecipes;

  /// No description provided for @scanAnalyzingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Analyzing recipe...'**
  String get scanAnalyzingRecipe;

  /// No description provided for @importStageReceiving.
  ///
  /// In en, this message translates to:
  /// **'Receiving link…'**
  String get importStageReceiving;

  /// No description provided for @importStageFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding the recipe…'**
  String get importStageFinding;

  /// No description provided for @importStagePulling.
  ///
  /// In en, this message translates to:
  /// **'Pulling ingredients & steps…'**
  String get importStagePulling;

  /// No description provided for @importStageReady.
  ///
  /// In en, this message translates to:
  /// **'Recipe ready'**
  String get importStageReady;

  /// No description provided for @errRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please check your information.'**
  String get errRegistration;

  /// No description provided for @authAccountExistsLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'This account already exists. You\'ve been signed in.'**
  String get authAccountExistsLoggedIn;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get errInvalidCredentials;

  /// No description provided for @errInvalidCredentialsRetry.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials, please try again'**
  String get errInvalidCredentialsRetry;

  /// No description provided for @errCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code, please try again'**
  String get errCodeExpired;

  /// No description provided for @errResendCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend the code. Please try again.'**
  String get errResendCode;

  /// No description provided for @errResetStart.
  ///
  /// In en, this message translates to:
  /// **'Unable to initiate password reset.'**
  String get errResetStart;

  /// No description provided for @errResetCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset code, please try again'**
  String get errResetCodeExpired;

  /// No description provided for @errResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password. Please try again.'**
  String get errResetPassword;

  /// No description provided for @errDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account.'**
  String get errDeleteAccount;

  /// No description provided for @errUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errUnexpected;

  /// No description provided for @errAi.
  ///
  /// In en, this message translates to:
  /// **'🤖 AI error: {msg}'**
  String errAi(String msg);

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Server error: {msg}'**
  String errServer(String msg);

  /// No description provided for @errInput.
  ///
  /// In en, this message translates to:
  /// **'📝 Input error: {msg}'**
  String errInput(String msg);

  /// No description provided for @errAuth.
  ///
  /// In en, this message translates to:
  /// **'🔒 Authentication error: {msg}'**
  String errAuth(String msg);

  /// No description provided for @errPremiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium access required. Please check your subscription.'**
  String get errPremiumRequired;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get errNotFound;

  /// No description provided for @errSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired or invalid. Please log in again.'**
  String get errSessionExpired;

  /// No description provided for @errNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get errNoInternet;

  /// No description provided for @errAccountExists.
  ///
  /// In en, this message translates to:
  /// **'This account already exists. Please log in.'**
  String get errAccountExists;

  /// No description provided for @errItemExists.
  ///
  /// In en, this message translates to:
  /// **'This item already exists.'**
  String get errItemExists;

  /// No description provided for @errInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get errInvalidCode;

  /// No description provided for @errAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found. Please sign up via onboarding.'**
  String get errAccountNotFound;

  /// No description provided for @errServersBusy.
  ///
  /// In en, this message translates to:
  /// **'Our servers are currently busy. Please try again in a moment.'**
  String get errServersBusy;

  /// No description provided for @errExtractFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to extract recipe from this link. Please check the URL or try another one.'**
  String get errExtractFailed;

  /// No description provided for @errSiteBlocking.
  ///
  /// In en, this message translates to:
  /// **'Website is blocking access. Please try another source.'**
  String get errSiteBlocking;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errGeneric;

  /// No description provided for @notifChannelShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping Reminders'**
  String get notifChannelShopping;

  /// No description provided for @notifChannelShoppingDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders to go shopping'**
  String get notifChannelShoppingDesc;

  /// No description provided for @notifGroceryTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery Shopping'**
  String get notifGroceryTitle;

  /// No description provided for @notifGroceryBody.
  ///
  /// In en, this message translates to:
  /// **'Don’t forget to do your shopping!'**
  String get notifGroceryBody;

  /// No description provided for @notifChannelPushDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications from the Cooked team'**
  String get notifChannelPushDesc;

  /// No description provided for @errPurchaseNotActive.
  ///
  /// In en, this message translates to:
  /// **'Purchase completed but subscription not active'**
  String get errPurchaseNotActive;

  /// No description provided for @errPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase error occurred'**
  String get errPurchase;

  /// No description provided for @errIngredientDetection.
  ///
  /// In en, this message translates to:
  /// **'Ingredient detection failed. Please try again.'**
  String get errIngredientDetection;

  /// No description provided for @errScan.
  ///
  /// In en, this message translates to:
  /// **'Scan failed. Please try again.'**
  String get errScan;

  /// No description provided for @errValidation.
  ///
  /// In en, this message translates to:
  /// **'Validation failed. Please try again.'**
  String get errValidation;

  /// No description provided for @errGeneration.
  ///
  /// In en, this message translates to:
  /// **'Generation failed. Please try again.'**
  String get errGeneration;

  /// No description provided for @errGenerateRecipes.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate recipes. Please try again.'**
  String get errGenerateRecipes;

  /// No description provided for @savingsCopyName.
  ///
  /// In en, this message translates to:
  /// **'(Copy) {name}'**
  String savingsCopyName(String name);

  /// No description provided for @errImport.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get errImport;

  /// No description provided for @errWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Web search failed'**
  String get errWebSearch;

  /// No description provided for @errPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get errPayment;

  /// No description provided for @errVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get errVerification;

  /// No description provided for @errLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get errLoadProfile;

  /// No description provided for @errUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile.'**
  String get errUpdateProfile;

  /// No description provided for @errSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Unable to save your preferences.'**
  String get errSavePreferences;

  /// No description provided for @errChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Unable to change password.'**
  String get errChangePassword;

  /// No description provided for @errNotifSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to update notification settings.'**
  String get errNotifSettings;

  /// No description provided for @errUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Unable to upload profile picture.'**
  String get errUploadPhoto;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'Before continuing with social login, please review and accept our legal terms to protect your data.'**
  String get termsIntro;

  /// No description provided for @termsAgreeA.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get termsAgreeA;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsAnd;

  /// No description provided for @termsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Continue'**
  String get termsConfirm;

  /// No description provided for @fallbackExtractTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t extract a recipe from this link.'**
  String get fallbackExtractTitle;

  /// No description provided for @fallbackExtractHint.
  ///
  /// In en, this message translates to:
  /// **'Please check the URL or try another one.'**
  String get fallbackExtractHint;

  /// No description provided for @fallbackLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get fallbackLinkCopied;

  /// No description provided for @fallbackCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get fallbackCopyLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
