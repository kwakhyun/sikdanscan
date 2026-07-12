// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SikdanScan - AI Meal Coach';

  @override
  String get brandName => 'SikdanScan';

  @override
  String get navDaily => 'Daily';

  @override
  String get navReport => 'Report';

  @override
  String get navAiCoach => 'AI Coach';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonOnline => 'Online';

  @override
  String get commonLoading => 'Loading';

  @override
  String get commonAnalyzing => 'Analyzing';

  @override
  String get authCloudNotConfiguredTitle => 'Cloud sync is not configured';

  @override
  String get authCloudNotConfiguredSubtitle =>
      'Set Supabase URL and publishable key to enable account sync.';

  @override
  String get authCloudSignedOutTitle => 'Sync data with an account';

  @override
  String get authCloudSignedOutSubtitle =>
      'Back up your profile and meal records to Supabase and restore them on another device.';

  @override
  String get authCloudSignedInTitle => 'Cloud sync enabled';

  @override
  String get authCloudSignedInSubtitle => 'You are signed in with an account.';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authSignInOrSignUp => 'Sign in / Sign up';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSyncNow => 'Sync now';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get authSheetSubtitle =>
      'After signing in, SikdanScan syncs this device\'s profile and meal records with Supabase.';

  @override
  String get authDisplayName => 'Name';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authSubmitSignIn => 'Sign in';

  @override
  String get authSubmitSignUp => 'Create and sync';

  @override
  String get authInvalidInput =>
      'Enter a valid email and a password with at least 8 characters.';

  @override
  String get authSignInDone => 'Signed in.';

  @override
  String get authSignUpDone =>
      'Account created. Check your email if confirmation is required.';

  @override
  String get authSignOutDone => 'Signed out.';

  @override
  String get authSyncDone => 'Sync completed.';

  @override
  String get authFailed => 'An account operation failed.';

  @override
  String get authSocialDivider => 'or';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithKakao => 'Continue with Kakao';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authOAuthStarted =>
      'Complete sign-in in the browser, then return to the app.';

  @override
  String get authOAuthDone => 'Signed in with social account.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsEditProfile => 'Edit profile';

  @override
  String get settingsGoal => 'Goal settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsApiStatus => 'API status';

  @override
  String get settingsExportData => 'Export data';

  @override
  String get settingsAppInfo => 'App info';

  @override
  String get settingsResetData => 'Reset data';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the app display language';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChanged => 'Language setting changed';

  @override
  String get exportSubject => 'SikdanScan data export';

  @override
  String get exportText => 'Your SikdanScan app data is attached.';

  @override
  String get exportFailed => 'Data export failed';

  @override
  String get appInfoDescription =>
      'AI-powered meal analysis and goal-based strategy coaching\n\nRecord meals with photos and design your next meal around\ngoals like skin health, weight management, and digestion.';

  @override
  String get apiChecking => 'Checking proxy status.';

  @override
  String get apiCheckFailed => 'An error occurred while checking proxy status.';

  @override
  String get apiRefresh => 'Refresh';

  @override
  String get apiOk => 'OK';

  @override
  String get apiConnected => 'Connected';

  @override
  String get apiProxyRequired => 'Proxy required';

  @override
  String get apiCheckingShort => 'Checking';

  @override
  String get apiNotConfigured => 'Not set';

  @override
  String get apiOffline => 'Offline';

  @override
  String get apiBuiltInDb => 'Built-in DB (80+ foods)';

  @override
  String get apiProxy => 'SikdanScan API proxy';

  @override
  String get apiPublicFoodDb => 'Public food nutrition DB';

  @override
  String get apiOpenAi => 'OpenAI GPT analysis';

  @override
  String get apiBarcode => 'Barcode search (Open Food Facts)';

  @override
  String get apiSecurityNote =>
      'Keep only the proxy URL and optional client token in the app .env. Store external API keys on the server.';

  @override
  String get resetTitle => 'Reset data';

  @override
  String get resetMessage =>
      'All data will be deleted.\nThis action cannot be undone.\n\nDo you want to reset?';

  @override
  String get resetAction => 'Reset';

  @override
  String get resetDone => 'Data has been reset';

  @override
  String get profileFallbackNeedsSetup => 'Needs setup';

  @override
  String get profileBodyNotConfigured => 'Not configured yet';

  @override
  String get profileEditTooltip => 'Edit profile';

  @override
  String get profileCurrentWeight => 'Current weight';

  @override
  String get profileInitialInputBasis => 'Based on signup input';

  @override
  String get profileDailyGoal => 'Daily goal';

  @override
  String get profileWellnessGoal => 'Goal';

  @override
  String get profileCalorieBasisTitle => 'Daily calorie goal basis';

  @override
  String get profileCalorieBasisCustom => 'This goal was adjusted manually';

  @override
  String get profileCalorieBasisAuto =>
      'This goal was calculated during signup';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditSubtitle => 'These details personalize your analysis';

  @override
  String get profilePhotoAdd => 'Add profile photo';

  @override
  String get profilePhotoChange => 'Change profile photo';

  @override
  String get profilePhotoGallery => 'Choose from library';

  @override
  String get profilePhotoCamera => 'Take a photo';

  @override
  String get profilePhotoDelete => 'Remove photo';

  @override
  String get profileName => 'Name';

  @override
  String get profileAge => 'Age';

  @override
  String get profileHeight => 'Height';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileMale => 'Male';

  @override
  String get profileFemale => 'Female';

  @override
  String get profileSave => 'Save';

  @override
  String get profileValidationError => 'Please enter all fields correctly';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get dashboardCapture => 'Capture';

  @override
  String get dashboardCaptureNow => 'Take photo';

  @override
  String get dashboardCaptureNowSubtitle =>
      'Take a meal photo and analyze it instantly';

  @override
  String get dashboardPickPhoto => 'Choose photo';

  @override
  String get dashboardPickPhotoSubtitle =>
      'Analyze a meal photo from your library';

  @override
  String get dashboardProxyRequired =>
      'Food recognition is available after connecting the SikdanScan API proxy';

  @override
  String get dashboardNoFoodFound =>
      'No food was found in the photo. Try again or search manually.';

  @override
  String get dashboardRecognitionError =>
      'An error occurred during photo recognition';

  @override
  String get dashboardCameraFallback =>
      'Camera is unavailable. Please choose a photo from your library.';

  @override
  String get dashboardPhotoPermissionError =>
      'Could not load the photo. Check camera/photo permissions.';

  @override
  String get dashboardAddedEstimated =>
      'Estimated results were added to today\'s log';

  @override
  String get dashboardAddedAnalyzed =>
      'Analysis results were added to today\'s log';

  @override
  String get addMealTitle => 'Add meal';

  @override
  String get addMealSearchError => 'An error occurred while searching';

  @override
  String get addMealRecognitionAdded =>
      'Recognition results were added to the selection. Review before saving.';

  @override
  String get addMealRecognitionTitle => 'Auto-recognize from photo';

  @override
  String get addMealRecognitionSubtitle =>
      'Take a food photo and estimate nutrition into the selected list';

  @override
  String get addMealAnalyzingPhoto => 'Analyzing photo';

  @override
  String get addMealRecognitionResult => 'Photo recognition result';

  @override
  String get addMealSearchHint =>
      'Search food (e.g. kimchi stew, acai bowl, salmon poke)';

  @override
  String get addMealSelectedFoods => 'Selected foods';

  @override
  String get addMealRetry => 'Retry';

  @override
  String get addMealNoSearchResults => 'No search results';

  @override
  String get addMealSourceBuiltInDb => 'Built-in database';

  @override
  String get addMealSourcePublicFoodDb => 'Public food nutrition DB';

  @override
  String get addMealPublicData => 'Public data';

  @override
  String get dailyOverviewTitle => 'Today\'s intake';

  @override
  String get dailyNutrition => 'Nutrition';

  @override
  String get dailyCarbs => 'Carbs';

  @override
  String get dailyProtein => 'Protein';

  @override
  String get dailyFat => 'Fat';

  @override
  String get dailyRecords => 'Today\'s records';

  @override
  String get dailyNoRecords => 'No food has been recorded yet';

  @override
  String get strategyEmptyTitle => 'Scan your first meal to start a strategy';

  @override
  String get strategyEmptyPrimary =>
      'Goal-based coaching is generated after you capture a meal photo.';

  @override
  String get reportTitle => 'Intake report';

  @override
  String get reportDay => 'Daily';

  @override
  String get reportWeek => 'Weekly';

  @override
  String get reportMonth => 'Monthly';

  @override
  String get reportDailySubtitle => 'One-day intake status';

  @override
  String get reportWeeklySubtitle => '7-day intake trend';

  @override
  String get chatTitle => 'SikdanScan AI Coach';

  @override
  String get chatTyping => 'Writing a response...';

  @override
  String get chatClearTitle => 'Clear chat';

  @override
  String get chatClearMessage =>
      'All chat messages will be deleted.\nAre you sure?';

  @override
  String get chatClearAction => 'Clear';

  @override
  String get chatInputHint => 'Ask anything...';

  @override
  String get chatWelcome =>
      'Hi, I\'m the SikdanScan AI Coach.\n\nWhat would you like to know about today\'s meals or your goal strategy?';

  @override
  String get chatTemporaryError =>
      'Sorry, a temporary error occurred.\nPlease ask again and I\'ll help you.';

  @override
  String get suggestionCalories => 'Analyze today\'s calories';

  @override
  String get suggestionExercise => 'Recommend exercise';

  @override
  String get suggestionWater => 'Hydration tips';

  @override
  String get suggestionWeight => 'Analyze weight trend';

  @override
  String get suggestionSnack => 'Healthy snack ideas';

  @override
  String get onboardingStartTitle => 'Start SikdanScan';

  @override
  String get onboardingStartSubtitle =>
      'Record meals with photos and adjust your next meal around goals like skin, weight, and digestion.';

  @override
  String get onboardingQuickStart => 'Quick signup and start';

  @override
  String get onboardingGoalTitle => 'What do you want to improve?';

  @override
  String get onboardingGoalSubtitle =>
      'SikdanScan changes today\'s analysis and next-meal strategy based on your selected goal.';

  @override
  String get onboardingMetricsTitle => 'Let\'s build your baseline';

  @override
  String get onboardingMetricsSubtitle =>
      'Your weight and activity level are used for calorie, hydration, and protein strategy calculations.';

  @override
  String get onboardingReviewTitle => 'Start with this baseline';

  @override
  String get onboardingReviewSubtitle =>
      'You can update it anytime from Profile later.';

  @override
  String get onboardingStartFlow => 'Start personalized flow';

  @override
  String get onboardingBenefitQuickTitle => 'Quick signup in 30 seconds';

  @override
  String get onboardingBenefitQuickDescription =>
      'Start right away with only your name and baseline details.';

  @override
  String get onboardingBenefitCalorieTitle => 'Automatic calorie baseline';

  @override
  String get onboardingBenefitCalorieDescription =>
      'Calculated from current weight, height, age, and activity level.';

  @override
  String get onboardingBenefitCoachTitle => 'Goal-based AI coaching';

  @override
  String get onboardingBenefitCoachDescription =>
      'Meal strategies adapt to the improvement direction you choose.';

  @override
  String get onboardingNickname => 'Nickname';

  @override
  String get onboardingNicknameHint => 'e.g. Jihyun';

  @override
  String get onboardingActivityTitle => 'Usual activity level';

  @override
  String get onboardingTargetCalories => 'Daily calorie goal';

  @override
  String get onboardingNeedsCalculation => 'Needs calculation';

  @override
  String get onboardingCheckInputs => 'Check your inputs.';

  @override
  String get onboardingWaterBasis => 'Hydration baseline';

  @override
  String get onboardingWaterBasisDescription =>
      'Current weight × 30 ml, rounded to the nearest 100 ml.';

  @override
  String get onboardingReviewInfo =>
      'SikdanScan calories are not fixed sample values. They are calculated from your body metrics and goal.';

  @override
  String get onboardingValidationAge => 'Enter age between 10 and 100.';

  @override
  String get onboardingValidationHeight =>
      'Enter height between 100 and 230 cm.';

  @override
  String get onboardingValidationWeight =>
      'Enter current weight between 30 and 250 kg.';

  @override
  String get onboardingSaveFailed =>
      'Failed to save profile. Please try again.';

  @override
  String get defaultUserName => 'SikdanScan user';

  @override
  String get goalSettingsTitle => 'Goal settings';

  @override
  String get goalSettingsSubtitle => 'Set your personal health goal';

  @override
  String get goalTargetWeight => 'Target weight';

  @override
  String get goalCalorieTarget => 'Daily calorie goal';

  @override
  String get goalWaterTarget => 'Hydration goal';

  @override
  String get goalStepTarget => 'Step goal';

  @override
  String get goalStepSuffix => 'steps';

  @override
  String get goalSettingsDone => 'Save goal settings';

  @override
  String get goalActivityTitle => 'Activity level';

  @override
  String get goalRecommendation => 'Recommended';

  @override
  String get goalApply => 'Apply';

  @override
  String get goalDirectionTitle => 'Improvement goal';

  @override
  String get goalTargetDate => 'Target date';

  @override
  String get goalSelectDate => 'Select a date';

  @override
  String get goalUpdated => 'Goal updated';

  @override
  String get goalBalancedDescription =>
      'Maintain balanced meals and steady logging';

  @override
  String get goalWeightLossDescription =>
      'Reduce calorie surplus and improve satiety';

  @override
  String get goalSkinHealthDescription =>
      'Lower sugar/fat imbalance and add recovery nutrients';

  @override
  String get goalDigestionDescription =>
      'Support digestion with fiber and hydration';

  @override
  String get goalEnergyDescription =>
      'Stabilize meals and glucose swings for steadier energy';

  @override
  String get goalMuscleDescription =>
      'Optimize protein intake for your weight and activity';

  @override
  String get goalGlucoseDescription => 'Manage carb ratio and meal order';

  @override
  String get activityLightDescription =>
      'Mostly seated days with light walking';

  @override
  String get activityModerateDescription =>
      'Exercise 2-4 times weekly or moderate daily movement';

  @override
  String get activityActiveDescription =>
      'Exercise 5+ times weekly or high daily activity';

  @override
  String get goalBalanced => 'Balanced care';

  @override
  String get goalWeightLoss => 'Weight loss';

  @override
  String get goalSkinHealth => 'Skin health';

  @override
  String get goalDigestion => 'Digestion';

  @override
  String get goalEnergy => 'Energy';

  @override
  String get goalMuscle => 'Protein boost';

  @override
  String get goalGlucose => 'Glucose stability';

  @override
  String get activityLight => 'Light activity';

  @override
  String get activityModerate => 'Moderate activity';

  @override
  String get activityActive => 'Active';

  @override
  String addMealRecognizedCount(int count) {
    return 'Recognized $count food item(s) and added them to your selection';
  }

  @override
  String get addMealAiHint =>
      'Foods not in the DB get AI-estimated nutrition automatically';

  @override
  String get addMealAiAnalyzing => 'AI is analyzing nutrition info...';

  @override
  String get addMealSourceAiResults => 'AI nutrition analysis';

  @override
  String get addMealAiTag => 'AI analysis';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get mealDetailTitle => 'Record details';

  @override
  String get mealDetailMealType => 'Meal type';

  @override
  String get mealDetailPortion => 'Adjust portion';

  @override
  String get mealDetailPortionHint =>
      'Recalculates calories and macros to match what you actually ate';

  @override
  String get mealDetailDeleteTitle => 'Delete record';

  @override
  String get mealDetailDeleteMessage =>
      'Delete this meal record? This cannot be undone.';

  @override
  String get mealDetailDeleted => 'Record deleted';

  @override
  String get mealDetailUpdated => 'Record updated';

  @override
  String get commonError => 'Something went wrong. Please try again';

  @override
  String get reportMealTypeTitle => 'Meal type breakdown';

  @override
  String reportMealTypeRecords(int count) {
    return '$count records';
  }

  @override
  String get dailyStatusNone => 'Not logged';

  @override
  String get dailyStatusRoom => 'Under goal';

  @override
  String get dailyStatusOnTrack => 'On track';

  @override
  String get dailyStatusCaution => 'Caution';

  @override
  String get dailyStatusOver => 'Over';

  @override
  String get bmiUnknown => 'Unknown';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

  @override
  String get bmiSeverelyObese => 'Severely obese';

  @override
  String profileBasisRecommended(int kcal) {
    return 'Goal $kcal kcal';
  }

  @override
  String profileBasisCurrent(int kcal) {
    return 'Current $kcal kcal';
  }

  @override
  String profileBasisWater(int ml) {
    return 'Water $ml ml';
  }

  @override
  String get calorieBasisNoAdjustment => 'no goal adjustment';

  @override
  String calorieBasisAdjustment(String amount) {
    return '$amount kcal goal adjustment';
  }

  @override
  String get startupErrorTitle => 'Unable to start the app';

  @override
  String get proxyStatusNotConfigured => 'The proxy URL is not configured.';

  @override
  String get proxyStatusConnected => 'The proxy responded normally.';

  @override
  String get proxyStatusUnexpectedResponse =>
      'The proxy returned an unexpected response.';

  @override
  String get proxyStatusInvalidToken => 'Check the proxy auth token.';

  @override
  String get proxyStatusHealthMissing =>
      'The proxy health check endpoint was not found.';

  @override
  String get proxyStatusServerError =>
      'The proxy server is not responding normally.';

  @override
  String get proxyStatusUnreachable => 'Cannot reach the proxy.';
}
