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
  String get settingsLanguage => 'Language';

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
  String get exportSubject => 'SikdanScan data export';

  @override
  String get exportText => 'Your SikdanScan app data is attached.';

  @override
  String get exportFailed => 'Data export failed';

  @override
  String get appInfoDescription =>
      'AI-powered meal analysis and goal-based strategy coaching\n\nRecord meals with photos and design your next meal around\ngoals like skin health, weight management, and digestion.';

  @override
  String get apiRefresh => 'Refresh';

  @override
  String get apiOk => 'OK';

  @override
  String get apiProxy => 'SikdanScan API proxy';

  @override
  String get apiPublicFoodDb => 'Public food nutrition DB';

  @override
  String get apiOpenAi => 'OpenAI GPT analysis';

  @override
  String get resetTitle => 'Reset data';

  @override
  String get resetMessage =>
      'This deletes the profile, meal, weight and water logs, and AI coach conversation on this device. If you are signed in you will be signed out; data backed up to your account stays there.\n\nReset anyway?';

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
  String get addMealTitle => 'Add meal';

  @override
  String get addMealSearchError => 'An error occurred while searching';

  @override
  String get addMealSearchHint =>
      'Search food (e.g. kimchi stew, acai bowl, salmon poke)';

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
  String get strategyEmptyTitle =>
      'Scan or log your first meal to start a strategy';

  @override
  String get strategyEmptyPrimary =>
      'Capture a meal photo or search a food to generate goal-based coaching.';

  @override
  String get reportTitle => 'Intake report';

  @override
  String get reportDay => 'Daily';

  @override
  String get reportWeek => 'Weekly';

  @override
  String get reportMonth => 'Monthly';

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
  String get onboardingBenefitQuickTitle => 'Start in 30 seconds';

  @override
  String get onboardingBenefitQuickDescription =>
      'Enter your goal and basics, then start logging right away.';

  @override
  String get onboardingBenefitCalorieTitle => 'Automatic calorie baseline';

  @override
  String get onboardingBenefitCalorieDescription =>
      'Calculated from current weight, height, age, and activity level.';

  @override
  String get onboardingBenefitCoachTitle => 'Goal strategy and AI coaching';

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
  String get mealDetailMealType => 'Meal type';

  @override
  String get mealDetailPortion => 'Adjust portion';

  @override
  String get mealDetailPortionHint =>
      'Recalculates calories and nutrients from the original single portion';

  @override
  String get mealDetailDeleteTitle => 'Delete record';

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

  @override
  String strategyMetaLabel(int count) {
    return 'Goal strategy · $count logs reflected';
  }

  @override
  String strategyEmptySummary(String goal) {
    return 'We will summarize today’s strengths and gaps for your $goal goal.';
  }

  @override
  String get strategyTipPhotoAngle =>
      'Take the photo from above with food clearly visible';

  @override
  String get strategyTipReviewBeforeSave =>
      'Review food names and portions before saving';

  @override
  String get strategyWeightLossOverTitle => 'Keep the rest of today lighter';

  @override
  String get strategyWeightLossOnTrackTitle =>
      'Your weight-loss pace is on track';

  @override
  String get strategyWeightLossOverSummary =>
      'You are above today’s calorie target. Make the next meal protein and vegetables first.';

  @override
  String get strategyWeightLossOnTrackSummary =>
      'Intake is within your target. Filling protein now lowers late-night cravings.';

  @override
  String get strategyWeightLossAddProtein =>
      'Add chicken breast, eggs, or tofu to your next meal.';

  @override
  String get strategyWeightLossVeggiesFirst =>
      'Add vegetables and water before adding more carbs.';

  @override
  String get strategyActionSkipFriedSauce =>
      'Skip fried food and heavy sauces next meal';

  @override
  String get strategyActionLightProteinMeal =>
      'Keep remaining meals to a ~400 kcal protein plate';

  @override
  String get strategyActionWalkAppetite =>
      'Walk 10 minutes after eating to steady glucose and appetite';

  @override
  String get strategySkinFixTitle => 'Your skin goal needs a correction';

  @override
  String get strategySkinGoodTitle => 'Skin-friendly balance is on track';

  @override
  String get strategySkinHighCarbSummary =>
      'Carbs are high today. Choose a next meal that reduces glucose spikes.';

  @override
  String get strategySkinBalancedSummary =>
      'Today’s intake is not skewed. Add antioxidant-rich foods if you can.';

  @override
  String get strategySkinPrimary =>
      'Prioritize fish, tofu, or eggs with leafy greens next.';

  @override
  String get strategyActionNoCreamy =>
      'Skip oily dishes and cream sauces for the rest of today';

  @override
  String get strategyActionNoSugarDrinks =>
      'Choose water or unsweetened tea instead of dessert drinks';

  @override
  String get strategyActionVitaminC =>
      'Add a small portion of vitamin C-rich fruit';

  @override
  String get strategyDigestionHeavyTitle => 'Ease the load on digestion';

  @override
  String get strategyDigestionGoodTitle => 'Keep your gut-health routine going';

  @override
  String get strategyDigestionHeavySummary =>
      'A high fat share can cause bloating. Keep the next meal light.';

  @override
  String get strategyDigestionGoodSummary =>
      'A good moment to add water and fiber today.';

  @override
  String get strategyDigestionPrimary =>
      'Fill half the next plate with vegetables and drink 500ml of water around it.';

  @override
  String get strategyActionSolidsOverBroth => 'Favor solids over broth';

  @override
  String get strategyActionFermented =>
      'Add yogurt, kimchi, or seasoned greens';

  @override
  String get strategyActionSkipFattyMeat =>
      'Skip fried food and fatty meat next meal';

  @override
  String get strategyEnergyCarbTitle => 'Smooth out afternoon energy dips';

  @override
  String get strategyEnergyGoodTitle => 'A good balance for steady energy';

  @override
  String get strategyEnergyLowSummary =>
      'Intake is low, which can lower focus later today.';

  @override
  String get strategyEnergyGoodSummary =>
      'Balanced meals reduce fatigue and snack cravings.';

  @override
  String get strategyEnergyAddProtein => 'Add a protein snack, eggs, or tofu.';

  @override
  String get strategyEnergyPairCarbs =>
      'Pair carbs with protein at the next meal.';

  @override
  String get strategyActionWaterOverSweet =>
      'Choose water or black coffee over sweet drinks';

  @override
  String get strategyActionSmartSnack => 'Snack on a few nuts or Greek yogurt';

  @override
  String get strategyActionStretch =>
      'Stretch 5 minutes after eating to beat drowsiness';

  @override
  String get strategyMuscleLowTitle => 'Protein needs attention';

  @override
  String get strategyMuscleCloseTitle =>
      'You are getting close to your protein goal';

  @override
  String strategyMuscleSummary(String protein, String goal) {
    return 'Protein today is ${protein}g. Your goal is ${goal}g.';
  }

  @override
  String strategyMuscleAddProtein(String gap) {
    return 'Aim to add ${gap}g of protein at the next meal.';
  }

  @override
  String get strategyMuscleRecovery =>
      'After exercise, add water and a small amount of carbs.';

  @override
  String get strategyActionLeanProtein =>
      'Choose chicken breast, fish, tofu, or Greek yogurt';

  @override
  String get strategyActionPreWorkoutSnack =>
      'Intake is low — add a snack around workouts';

  @override
  String get strategyActionSpreadProtein =>
      'Spread protein across meals instead of all at once';

  @override
  String get strategyGlucoseCarbTitle => 'Slow down the carbs';

  @override
  String get strategyGlucoseGoodTitle => 'Glucose-friendly balance';

  @override
  String get strategyGlucoseCarbSummary =>
      'Carb share is high. Meal order and extra protein matter at the next meal.';

  @override
  String get strategyGlucoseGoodSummary =>
      'Your current ratio helps avoid sharp spikes.';

  @override
  String get strategyGlucosePrimary =>
      'Eat vegetables, then protein, then carbs at the next meal.';

  @override
  String get strategyActionAddProteinSide =>
      'Avoid rice or noodles alone — add a protein side';

  @override
  String get strategyActionWalk10 => 'Walk 10 minutes after eating';

  @override
  String get strategyActionNoDessert => 'Skip sweet drinks and dessert today';

  @override
  String get strategyBalancedGoodTitle => 'A well-balanced day';

  @override
  String get strategyBalancedFixTitle => 'Rebalance the macros that are off';

  @override
  String get strategyBalancedGoodSummary => 'Calories and macros are steady.';

  @override
  String get strategyBalancedFixSummary =>
      'Filling the missing macro at the next meal will balance the day.';

  @override
  String get strategyBalancedPrimary =>
      'Build the next plate with protein, vegetables, and carbs together.';

  @override
  String get strategyActionLogWater => 'Log your water too';

  @override
  String get strategyActionReviewRecords => 'Review today’s records once';

  @override
  String get strategyFactorCalories => 'Calorie range';

  @override
  String get strategyFactorProtein => 'Protein';

  @override
  String get strategyFactorFat => 'Fat share';

  @override
  String get strategyFactorCarbs => 'Carb share';

  @override
  String get strategyFactorBalance => 'Macro balance';

  @override
  String get strategyFactorVolume => 'Meal volume';

  @override
  String get strategyFactorConsistency => 'Consistent logging';

  @override
  String get strategyDetailTitle => 'Today’s goal strategy';

  @override
  String get strategyRuleBasedNote =>
      'Calculated by comparing today’s logged calories and macro ratios with your goal. This is not medical advice.';

  @override
  String get strategyScoreTitle => 'How the score works';

  @override
  String strategyScoreSemantics(int score) {
    return 'Goal score $score out of 100';
  }

  @override
  String get strategyNextMeal => 'Next meal';

  @override
  String get strategyTips => 'Tips';

  @override
  String get strategyAskCoach => 'Ask the AI coach';

  @override
  String get strategyAskCoachPrompt =>
      'Based on today’s log, what should I eat next?';

  @override
  String get strategyOpenDetail => 'View strategy details';

  @override
  String get commonClose => 'Close';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonUndo => 'Undo';

  @override
  String commonItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String macroShort(String carbs, String protein, String fat) {
    return 'C ${carbs}g · P ${protein}g · F ${fat}g';
  }

  @override
  String get entrySheetTitle => 'Log a meal';

  @override
  String entrySheetTitleForDate(String date) {
    return 'Add to $date';
  }

  @override
  String get entryCamera => 'Take a photo';

  @override
  String get entryCameraSubtitle =>
      'AI estimates the food and nutrition; you review before saving';

  @override
  String get entryGallery => 'Choose from album';

  @override
  String get entryGallerySubtitle => 'Use a meal photo you already took';

  @override
  String get entrySearch => 'Search or enter manually';

  @override
  String get entrySearchSubtitle =>
      'Find a food by name or type the nutrition yourself · works offline';

  @override
  String get entryPhotoUnavailable =>
      'Photo recognition needs the AI server connection';

  @override
  String get dashboardLogMeal => 'Log meal';

  @override
  String get reviewTitle => 'Review meal';

  @override
  String get reviewAnalyzingTitle => 'Analyzing photo';

  @override
  String get reviewFailedTitle => 'Couldn’t recognize the food';

  @override
  String get reviewAnalyzingMessage => 'Estimating foods and nutrition';

  @override
  String get reviewAnalyzingHint =>
      'This usually takes 5–15 seconds. You can switch to manual entry instead.';

  @override
  String get reviewSwitchToManual => 'Enter manually instead';

  @override
  String get reviewCancelAnalysis => 'Cancel analysis';

  @override
  String get reviewRetry => 'Analyze again';

  @override
  String get reviewSearchAdd => 'Add from search';

  @override
  String get reviewAddManual => 'Add manually';

  @override
  String get reviewNeedsReview =>
      'These are AI estimates. Check food names and portions before saving.';

  @override
  String get reviewLowConfidence => 'Check this';

  @override
  String reviewConfidence(int percent) {
    return 'AI confidence $percent%';
  }

  @override
  String get reviewFoodsSection => 'Foods';

  @override
  String get reviewNoDrafts => 'No foods yet. Add one manually or search.';

  @override
  String get reviewNameHint => 'Food name';

  @override
  String get reviewCarbsLabel => 'Carbs (g)';

  @override
  String get reviewProteinLabel => 'Protein (g)';

  @override
  String get reviewFatLabel => 'Fat (g)';

  @override
  String get reviewPortion => 'Portion';

  @override
  String reviewPortionTotal(String kcal) {
    return 'Saved as $kcal kcal';
  }

  @override
  String get reviewDateTime => 'Date & time';

  @override
  String reviewDateSemantics(String date) {
    return 'Log date $date';
  }

  @override
  String reviewSave(int count, String kcal) {
    return 'Save $count · $kcal kcal';
  }

  @override
  String reviewSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Logged $count foods',
      one: 'Logged 1 food',
    );
    return '$_temp0';
  }

  @override
  String get reviewLeaveTitle => 'Discard this entry?';

  @override
  String get reviewLeaveMessage =>
      'The analysis and anything you entered won’t be saved.';

  @override
  String get reviewLeaveConfirm => 'Discard';

  @override
  String get reviewLeaveStay => 'Keep editing';

  @override
  String get reviewRemoveItem => 'Remove item';

  @override
  String get reviewSelectItem => 'Include in save';

  @override
  String get reviewPhotoSemantics => 'Captured meal photo';

  @override
  String get addMealManualEntry => 'Enter manually';

  @override
  String get addMealOfflineHint =>
      'Without the AI server you can use the built-in food list or enter food manually';

  @override
  String addMealSelectedSummary(int count, String kcal) {
    return '$count selected · $kcal kcal';
  }

  @override
  String addMealRemoveTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String addMealAddTooltip(String name) {
    return 'Add $name';
  }

  @override
  String get addMealRecentTitle => 'Recently logged';

  @override
  String get addMealSuggestedTitle => 'Suggested foods';

  @override
  String get mealDetailAiRecognized => 'AI recognized';

  @override
  String mealDetailServing(String serving) {
    return 'Serving $serving';
  }

  @override
  String get mealDetailLogAgain => 'Log again';

  @override
  String get mealDetailLoggedAgain => 'Logged again for now';

  @override
  String dailyKcalLeft(String goal, String amount) {
    return 'Goal $goal kcal · $amount kcal left';
  }

  @override
  String dailyKcalOver(String goal, String amount) {
    return 'Goal $goal kcal · $amount kcal over';
  }

  @override
  String dailyIntakeSemantics(String kcal, String remaining, String status) {
    return '$kcal kilocalories eaten today. $remaining. Status: $status';
  }

  @override
  String dailyMacroSemantics(String label, String grams, int percent) {
    return '$label $grams grams, $percent percent of calories';
  }

  @override
  String get dailyLogFirstMeal => 'Log your first meal';

  @override
  String get waterTitle => 'Water';

  @override
  String waterSemantics(String amount, String goal) {
    return 'Water $amount ml of $goal ml';
  }

  @override
  String waterSemanticsNoGoal(String amount) {
    return 'Water $amount ml';
  }

  @override
  String get waterAddGlass => 'Add a glass (250 ml)';

  @override
  String get waterRemoveGlass => 'Remove a glass';

  @override
  String get reportPrevious => 'Previous period';

  @override
  String get reportNext => 'Next period';

  @override
  String get reportToday => 'Today';

  @override
  String get reportSummaryTitle => 'Summary';

  @override
  String reportLoggedDays(int recorded, int total) {
    return '$recorded/$total days logged';
  }

  @override
  String reportGoalOver(String goal, String amount) {
    return 'Goal $goal kcal · $amount kcal over';
  }

  @override
  String reportGoalLeft(String goal, String amount) {
    return 'Goal $goal kcal · $amount kcal left';
  }

  @override
  String reportGoalElapsedNote(int days) {
    return 'The goal counts the $days days so far';
  }

  @override
  String get reportDailyAverage => 'Avg per logged day';

  @override
  String get reportMealTypeDayTitle => 'By meal';

  @override
  String get reportDailyTrend => 'Daily trend';

  @override
  String reportGoalLine(String goal) {
    return 'Goal $goal';
  }

  @override
  String get reportTapDayHint => 'Tap a bar to open that day';

  @override
  String reportBarSemantics(String date, String kcal) {
    return '$date, $kcal';
  }

  @override
  String get reportNoRecordsToShow => 'No records to display';

  @override
  String get reportRecordedFoods => 'Recorded foods';

  @override
  String get reportNoRecordsForPeriod => 'No records in this period';

  @override
  String get reportAddForDay => 'Add a meal for this day';

  @override
  String get reportShowLess => 'Show less';

  @override
  String reportShowAll(int count) {
    return 'Show all ($count)';
  }

  @override
  String get chatRetry => 'Try again';

  @override
  String get chatOfflineAnswer => 'Offline answer';

  @override
  String get chatCopied => 'Copied';

  @override
  String get chatStatusOnline => 'AI connected';

  @override
  String get chatStatusOffline => 'Offline mode';

  @override
  String get chatOfflineBanner =>
      'Not connected to the AI server, so answers are general tips. Personalized coaching works once connected.';

  @override
  String get chatSend => 'Send';

  @override
  String get unitYears => 'y';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get themeSubtitle => 'Choose how the app looks';

  @override
  String get themeSystem => 'Match system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsAiStatus => 'AI features';

  @override
  String get aiStatusAvailable => 'Available';

  @override
  String get aiStatusUnavailable => 'Not connected';

  @override
  String get aiStatusChecking => 'Checking';

  @override
  String get aiStatusAvailableBody =>
      'Photo recognition, AI nutrition analysis and the AI coach are available.';

  @override
  String get aiStatusUnavailableBody =>
      'The AI server is not reachable right now. Built-in food search, manual entry and reports still work.';

  @override
  String get aiStatusDeveloperDetails => 'Developer details (debug build)';

  @override
  String get authDeleteAccount => 'Delete account';

  @override
  String get authDeleteAccountTitle => 'Delete your account?';

  @override
  String get authDeleteAccountMessage =>
      'Your account and the profile, meal logs and photos stored in the cloud will be permanently deleted, and this device will be reset. This cannot be undone.';

  @override
  String get authDeleteAccountConfirm => 'Delete permanently';

  @override
  String get authDeleteAccountDone => 'Your account was deleted';

  @override
  String get authDeleteAccountFailed =>
      'Could not delete the account. Check your connection and try again.';

  @override
  String get profileLatestLogBasis => 'Latest log';

  @override
  String get weightTitle => 'Weight log';

  @override
  String get weightLog => 'Log';

  @override
  String get weightLogTitle => 'Log today’s weight';

  @override
  String weightDeltaFromStart(String delta) {
    return '$delta kg since start';
  }

  @override
  String get weightNoRecords =>
      'No weight logs yet. Log at the same time of day to see your trend.';

  @override
  String weightLastLogged(String date) {
    return 'Last logged $date';
  }

  @override
  String weightTrendSemantics(int count) {
    return 'Weight trend of the last $count logs';
  }

  @override
  String get weightHistoryTitle => 'Weight history';

  @override
  String get weightLogged => 'Weight logged';

  @override
  String get weightDeleted => 'Weight log deleted';

  @override
  String weightRecalculateSuggestion(String kcal) {
    return 'Your recommended calories changed to $kcal kcal';
  }

  @override
  String get weightRecalculateApply => 'Update goal';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingDecreaseCalories => 'Lower calorie goal by 50 kcal';

  @override
  String get onboardingIncreaseCalories => 'Raise calorie goal by 50 kcal';

  @override
  String onboardingResetRecommended(String kcal) {
    return 'Reset to recommended $kcal kcal';
  }

  @override
  String onboardingTargetWeightDescription(String date) {
    return 'Starts at about 5% below your current weight, targeted for $date. You can adjust it.';
  }

  @override
  String get onboardingDecreaseTarget => 'Lower target by 0.5 kg';

  @override
  String get onboardingIncreaseTarget => 'Raise target by 0.5 kg';
}
