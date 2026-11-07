import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 - AI 식단 코치'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔'**
  String get brandName;

  /// No description provided for @navDaily.
  ///
  /// In ko, this message translates to:
  /// **'데일리'**
  String get navDaily;

  /// No description provided for @navReport.
  ///
  /// In ko, this message translates to:
  /// **'리포트'**
  String get navReport;

  /// No description provided for @navAiCoach.
  ///
  /// In ko, this message translates to:
  /// **'AI 코치'**
  String get navAiCoach;

  /// No description provided for @navProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get navProfile;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @commonNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In ko, this message translates to:
  /// **'뒤로가기'**
  String get commonBack;

  /// No description provided for @commonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// No description provided for @authCloudNotConfiguredTitle.
  ///
  /// In ko, this message translates to:
  /// **'클라우드 동기화 미설정'**
  String get authCloudNotConfiguredTitle;

  /// No description provided for @authCloudNotConfiguredSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'Supabase URL과 publishable key를 설정하면 계정 동기화를 사용할 수 있습니다.'**
  String get authCloudNotConfiguredSubtitle;

  /// No description provided for @authCloudSignedOutTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정으로 데이터 동기화'**
  String get authCloudSignedOutTitle;

  /// No description provided for @authCloudSignedOutSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필과 식단 기록을 Supabase에 백업하고 기기 변경 시 복원합니다.'**
  String get authCloudSignedOutSubtitle;

  /// No description provided for @authCloudSignedInTitle.
  ///
  /// In ko, this message translates to:
  /// **'클라우드 동기화 활성화'**
  String get authCloudSignedInTitle;

  /// No description provided for @authCloudSignedInSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'계정으로 로그인되어 있습니다.'**
  String get authCloudSignedInSubtitle;

  /// No description provided for @authSignIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get authSignUp;

  /// No description provided for @authSignInOrSignUp.
  ///
  /// In ko, this message translates to:
  /// **'로그인 / 가입'**
  String get authSignInOrSignUp;

  /// No description provided for @authSignOut.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get authSignOut;

  /// No description provided for @authSyncNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 동기화'**
  String get authSyncNow;

  /// No description provided for @authSignInTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정 로그인'**
  String get authSignInTitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정 만들기'**
  String get authSignUpTitle;

  /// No description provided for @authSheetSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인하면 현재 기기의 프로필과 식단 기록을 Supabase와 동기화합니다.'**
  String get authSheetSubtitle;

  /// No description provided for @authDisplayName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get authDisplayName;

  /// No description provided for @authEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get authPassword;

  /// No description provided for @authSubmitSignIn.
  ///
  /// In ko, this message translates to:
  /// **'로그인하기'**
  String get authSubmitSignIn;

  /// No description provided for @authSubmitSignUp.
  ///
  /// In ko, this message translates to:
  /// **'가입하고 동기화'**
  String get authSubmitSignUp;

  /// No description provided for @authInvalidInput.
  ///
  /// In ko, this message translates to:
  /// **'이메일과 8자 이상 비밀번호를 입력해주세요.'**
  String get authInvalidInput;

  /// No description provided for @authSignInDone.
  ///
  /// In ko, this message translates to:
  /// **'로그인되었습니다.'**
  String get authSignInDone;

  /// No description provided for @authSignUpDone.
  ///
  /// In ko, this message translates to:
  /// **'가입되었습니다. 이메일 인증이 필요한 경우 메일함을 확인해주세요.'**
  String get authSignUpDone;

  /// No description provided for @authSignOutDone.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃되었습니다.'**
  String get authSignOutDone;

  /// No description provided for @authSyncDone.
  ///
  /// In ko, this message translates to:
  /// **'동기화가 완료되었습니다.'**
  String get authSyncDone;

  /// No description provided for @authFailed.
  ///
  /// In ko, this message translates to:
  /// **'계정 처리 중 오류가 발생했습니다.'**
  String get authFailed;

  /// No description provided for @authSocialDivider.
  ///
  /// In ko, this message translates to:
  /// **'또는'**
  String get authSocialDivider;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithKakao.
  ///
  /// In ko, this message translates to:
  /// **'카카오로 계속하기'**
  String get authContinueWithKakao;

  /// No description provided for @authContinueWithApple.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 계속하기'**
  String get authContinueWithApple;

  /// No description provided for @authOAuthStarted.
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 로그인을 완료한 뒤 앱으로 돌아와주세요.'**
  String get authOAuthStarted;

  /// No description provided for @authOAuthDone.
  ///
  /// In ko, this message translates to:
  /// **'소셜 로그인되었습니다.'**
  String get authOAuthDone;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsEditProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 편집'**
  String get settingsEditProfile;

  /// No description provided for @settingsGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표 설정'**
  String get settingsGoal;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguage;

  /// No description provided for @settingsExportData.
  ///
  /// In ko, this message translates to:
  /// **'데이터 내보내기'**
  String get settingsExportData;

  /// No description provided for @settingsAppInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsAppInfo;

  /// No description provided for @settingsResetData.
  ///
  /// In ko, this message translates to:
  /// **'데이터 초기화'**
  String get settingsResetData;

  /// No description provided for @languageTitle.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 표시 언어를 선택하세요'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 언어'**
  String get languageSystem;

  /// No description provided for @languageKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @exportSubject.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 데이터 내보내기'**
  String get exportSubject;

  /// No description provided for @exportText.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 앱 데이터가 첨부되었습니다.'**
  String get exportText;

  /// No description provided for @exportFailed.
  ///
  /// In ko, this message translates to:
  /// **'데이터 내보내기 실패'**
  String get exportFailed;

  /// No description provided for @appInfoDescription.
  ///
  /// In ko, this message translates to:
  /// **'AI 기반 식단 분석과 목표별 전략 코칭\n\n사진으로 식단을 기록하고 피부·감량·장 건강 등\n원하는 개선 방향에 맞춰 다음 식사를 설계하세요.'**
  String get appInfoDescription;

  /// No description provided for @apiRefresh.
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get apiRefresh;

  /// No description provided for @apiOk.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get apiOk;

  /// No description provided for @apiProxy.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 API 프록시'**
  String get apiProxy;

  /// No description provided for @apiPublicFoodDb.
  ///
  /// In ko, this message translates to:
  /// **'식약처 식품영양정보'**
  String get apiPublicFoodDb;

  /// No description provided for @apiOpenAi.
  ///
  /// In ko, this message translates to:
  /// **'OpenAI GPT 분석'**
  String get apiOpenAi;

  /// No description provided for @resetTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터 초기화'**
  String get resetTitle;

  /// No description provided for @resetMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 기기의 프로필, 식단·체중·수분 기록, AI 코치 대화가 모두 삭제됩니다. 로그인 중이라면 로그아웃되며, 클라우드에 백업된 데이터는 계정에 그대로 남습니다.\n\n정말 초기화하시겠습니까?'**
  String get resetMessage;

  /// No description provided for @resetAction.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get resetAction;

  /// No description provided for @resetDone.
  ///
  /// In ko, this message translates to:
  /// **'데이터가 초기화되었습니다'**
  String get resetDone;

  /// No description provided for @profileFallbackNeedsSetup.
  ///
  /// In ko, this message translates to:
  /// **'설정 필요'**
  String get profileFallbackNeedsSetup;

  /// No description provided for @profileBodyNotConfigured.
  ///
  /// In ko, this message translates to:
  /// **'맞춤 설정 전'**
  String get profileBodyNotConfigured;

  /// No description provided for @profileEditTooltip.
  ///
  /// In ko, this message translates to:
  /// **'내 정보 수정'**
  String get profileEditTooltip;

  /// No description provided for @profileCurrentWeight.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중'**
  String get profileCurrentWeight;

  /// No description provided for @profileInitialInputBasis.
  ///
  /// In ko, this message translates to:
  /// **'가입 시 입력 기준'**
  String get profileInitialInputBasis;

  /// No description provided for @profileDailyGoal.
  ///
  /// In ko, this message translates to:
  /// **'일일 목표'**
  String get profileDailyGoal;

  /// No description provided for @profileWellnessGoal.
  ///
  /// In ko, this message translates to:
  /// **'개선 목표'**
  String get profileWellnessGoal;

  /// No description provided for @profileCalorieBasisTitle.
  ///
  /// In ko, this message translates to:
  /// **'일일 목표 칼로리 기준'**
  String get profileCalorieBasisTitle;

  /// No description provided for @profileCalorieBasisCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접 조정된 목표입니다'**
  String get profileCalorieBasisCustom;

  /// No description provided for @profileCalorieBasisAuto.
  ///
  /// In ko, this message translates to:
  /// **'가입 시 자동 계산된 목표입니다'**
  String get profileCalorieBasisAuto;

  /// No description provided for @profileEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 정보 수정'**
  String get profileEditTitle;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'맞춤 분석에 쓰이는 기본 정보입니다'**
  String get profileEditSubtitle;

  /// No description provided for @profilePhotoAdd.
  ///
  /// In ko, this message translates to:
  /// **'프로필 사진 추가'**
  String get profilePhotoAdd;

  /// No description provided for @profilePhotoChange.
  ///
  /// In ko, this message translates to:
  /// **'프로필 사진 변경'**
  String get profilePhotoChange;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In ko, this message translates to:
  /// **'앨범에서 선택'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In ko, this message translates to:
  /// **'카메라로 촬영'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoDelete.
  ///
  /// In ko, this message translates to:
  /// **'사진 삭제'**
  String get profilePhotoDelete;

  /// No description provided for @profileName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get profileName;

  /// No description provided for @profileAge.
  ///
  /// In ko, this message translates to:
  /// **'나이'**
  String get profileAge;

  /// No description provided for @profileHeight.
  ///
  /// In ko, this message translates to:
  /// **'키'**
  String get profileHeight;

  /// No description provided for @profileGender.
  ///
  /// In ko, this message translates to:
  /// **'성별'**
  String get profileGender;

  /// No description provided for @profileMale.
  ///
  /// In ko, this message translates to:
  /// **'남성'**
  String get profileMale;

  /// No description provided for @profileFemale.
  ///
  /// In ko, this message translates to:
  /// **'여성'**
  String get profileFemale;

  /// No description provided for @profileSave.
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get profileSave;

  /// No description provided for @profileValidationError.
  ///
  /// In ko, this message translates to:
  /// **'모든 항목을 올바르게 입력해주세요'**
  String get profileValidationError;

  /// No description provided for @profileUpdated.
  ///
  /// In ko, this message translates to:
  /// **'프로필이 업데이트되었습니다'**
  String get profileUpdated;

  /// No description provided for @dashboardProxyRequired.
  ///
  /// In ko, this message translates to:
  /// **'사진 인식은 식단스캔 API 프록시 연결 후 사용할 수 있습니다'**
  String get dashboardProxyRequired;

  /// No description provided for @dashboardNoFoodFound.
  ///
  /// In ko, this message translates to:
  /// **'사진에서 음식을 찾을 수 없습니다. 다시 촬영하거나 직접 검색해 주세요'**
  String get dashboardNoFoodFound;

  /// No description provided for @dashboardRecognitionError.
  ///
  /// In ko, this message translates to:
  /// **'사진 인식 중 오류가 발생했습니다'**
  String get dashboardRecognitionError;

  /// No description provided for @dashboardCameraFallback.
  ///
  /// In ko, this message translates to:
  /// **'카메라를 사용할 수 없어 앨범에서 사진을 선택해주세요'**
  String get dashboardCameraFallback;

  /// No description provided for @dashboardPhotoPermissionError.
  ///
  /// In ko, this message translates to:
  /// **'사진을 불러올 수 없습니다. 카메라/사진 권한을 확인해주세요'**
  String get dashboardPhotoPermissionError;

  /// No description provided for @addMealTitle.
  ///
  /// In ko, this message translates to:
  /// **'식단 추가'**
  String get addMealTitle;

  /// No description provided for @addMealSearchError.
  ///
  /// In ko, this message translates to:
  /// **'검색 중 오류가 발생했습니다'**
  String get addMealSearchError;

  /// No description provided for @addMealSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'음식을 검색하세요 (예: 김치찌개, 아사이볼, 연어 포케)'**
  String get addMealSearchHint;

  /// No description provided for @addMealRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get addMealRetry;

  /// No description provided for @addMealNoSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다'**
  String get addMealNoSearchResults;

  /// No description provided for @addMealSourceBuiltInDb.
  ///
  /// In ko, this message translates to:
  /// **'내장 데이터베이스'**
  String get addMealSourceBuiltInDb;

  /// No description provided for @addMealSourcePublicFoodDb.
  ///
  /// In ko, this message translates to:
  /// **'식약처 식품영양정보'**
  String get addMealSourcePublicFoodDb;

  /// No description provided for @addMealPublicData.
  ///
  /// In ko, this message translates to:
  /// **'공공데이터'**
  String get addMealPublicData;

  /// No description provided for @dailyOverviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘 섭취 현황'**
  String get dailyOverviewTitle;

  /// No description provided for @dailyNutrition.
  ///
  /// In ko, this message translates to:
  /// **'영양소'**
  String get dailyNutrition;

  /// No description provided for @dailyCarbs.
  ///
  /// In ko, this message translates to:
  /// **'탄수'**
  String get dailyCarbs;

  /// No description provided for @dailyProtein.
  ///
  /// In ko, this message translates to:
  /// **'단백질'**
  String get dailyProtein;

  /// No description provided for @dailyFat.
  ///
  /// In ko, this message translates to:
  /// **'지방'**
  String get dailyFat;

  /// No description provided for @dailyRecords.
  ///
  /// In ko, this message translates to:
  /// **'오늘 기록'**
  String get dailyRecords;

  /// No description provided for @dailyNoRecords.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록된 음식이 없습니다'**
  String get dailyNoRecords;

  /// No description provided for @strategyEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'첫 식사를 기록해 전략을 시작하세요'**
  String get strategyEmptyTitle;

  /// No description provided for @strategyEmptyPrimary.
  ///
  /// In ko, this message translates to:
  /// **'음식 사진을 찍거나 검색해 기록하면 목표별 코칭이 생성됩니다.'**
  String get strategyEmptyPrimary;

  /// No description provided for @reportTitle.
  ///
  /// In ko, this message translates to:
  /// **'섭취 리포트'**
  String get reportTitle;

  /// No description provided for @reportDay.
  ///
  /// In ko, this message translates to:
  /// **'일일'**
  String get reportDay;

  /// No description provided for @reportWeek.
  ///
  /// In ko, this message translates to:
  /// **'주간'**
  String get reportWeek;

  /// No description provided for @reportMonth.
  ///
  /// In ko, this message translates to:
  /// **'월간'**
  String get reportMonth;

  /// No description provided for @chatTitle.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 AI 코치'**
  String get chatTitle;

  /// No description provided for @chatTyping.
  ///
  /// In ko, this message translates to:
  /// **'답변 작성 중...'**
  String get chatTyping;

  /// No description provided for @chatClearTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 초기화'**
  String get chatClearTitle;

  /// No description provided for @chatClearMessage.
  ///
  /// In ko, this message translates to:
  /// **'모든 대화 내용이 삭제됩니다.\n정말 초기화하시겠습니까?'**
  String get chatClearMessage;

  /// No description provided for @chatClearAction.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get chatClearAction;

  /// No description provided for @chatInputHint.
  ///
  /// In ko, this message translates to:
  /// **'무엇이든 물어보세요...'**
  String get chatInputHint;

  /// No description provided for @chatWelcome.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요. 저는 식단스캔 AI 코치입니다.\n\n오늘 식단이나 목표별 개선 전략에 대해 궁금한 점이 있으신가요?'**
  String get chatWelcome;

  /// No description provided for @chatTemporaryError.
  ///
  /// In ko, this message translates to:
  /// **'죄송해요, 일시적인 오류가 발생했어요.\n다시 질문해주시면 답변드릴게요!'**
  String get chatTemporaryError;

  /// No description provided for @suggestionCalories.
  ///
  /// In ko, this message translates to:
  /// **'오늘 칼로리 분석'**
  String get suggestionCalories;

  /// No description provided for @suggestionExercise.
  ///
  /// In ko, this message translates to:
  /// **'운동 추천해줘'**
  String get suggestionExercise;

  /// No description provided for @suggestionWater.
  ///
  /// In ko, this message translates to:
  /// **'수분 섭취 팁'**
  String get suggestionWater;

  /// No description provided for @suggestionWeight.
  ///
  /// In ko, this message translates to:
  /// **'체중 변화 분석'**
  String get suggestionWeight;

  /// No description provided for @suggestionSnack.
  ///
  /// In ko, this message translates to:
  /// **'건강한 간식 추천'**
  String get suggestionSnack;

  /// No description provided for @onboardingStartTitle.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 시작하기'**
  String get onboardingStartTitle;

  /// No description provided for @onboardingStartSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'사진으로 식단을 기록하고, 피부·감량·장 건강 같은 목표에 맞춰 다음 식사를 바로 조정합니다.'**
  String get onboardingStartSubtitle;

  /// No description provided for @onboardingQuickStart.
  ///
  /// In ko, this message translates to:
  /// **'간편 가입하고 시작'**
  String get onboardingQuickStart;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In ko, this message translates to:
  /// **'어떤 변화를 원하시나요?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔은 선택한 목표를 기준으로 오늘의 식단과 다음 끼니 전략을 다르게 제안합니다.'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingMetricsTitle.
  ///
  /// In ko, this message translates to:
  /// **'맞춤 기준을 만들게요'**
  String get onboardingMetricsTitle;

  /// No description provided for @onboardingMetricsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중과 활동량은 목표 칼로리, 수분 기준, 단백질 전략 계산에 사용됩니다.'**
  String get onboardingMetricsSubtitle;

  /// No description provided for @onboardingReviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'이 기준으로 시작합니다'**
  String get onboardingReviewTitle;

  /// No description provided for @onboardingReviewSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'나중에 프로필에서 언제든 다시 조정할 수 있습니다.'**
  String get onboardingReviewSubtitle;

  /// No description provided for @onboardingStartFlow.
  ///
  /// In ko, this message translates to:
  /// **'맞춤 플로우 시작'**
  String get onboardingStartFlow;

  /// No description provided for @onboardingBenefitQuickTitle.
  ///
  /// In ko, this message translates to:
  /// **'30초 만에 시작'**
  String get onboardingBenefitQuickTitle;

  /// No description provided for @onboardingBenefitQuickDescription.
  ///
  /// In ko, this message translates to:
  /// **'목표와 기본 정보만 입력하면 바로 기록을 시작합니다.'**
  String get onboardingBenefitQuickDescription;

  /// No description provided for @onboardingBenefitCalorieTitle.
  ///
  /// In ko, this message translates to:
  /// **'일일 칼로리 자동 산정'**
  String get onboardingBenefitCalorieTitle;

  /// No description provided for @onboardingBenefitCalorieDescription.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중, 키, 나이, 활동량으로 기준을 계산합니다.'**
  String get onboardingBenefitCalorieDescription;

  /// No description provided for @onboardingBenefitCoachTitle.
  ///
  /// In ko, this message translates to:
  /// **'목표별 전략 · AI 코칭'**
  String get onboardingBenefitCoachTitle;

  /// No description provided for @onboardingBenefitCoachDescription.
  ///
  /// In ko, this message translates to:
  /// **'사용자가 원하는 개선 방향에 맞춰 식단 전략을 제공합니다.'**
  String get onboardingBenefitCoachDescription;

  /// No description provided for @onboardingNickname.
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get onboardingNickname;

  /// No description provided for @onboardingNicknameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 지현'**
  String get onboardingNicknameHint;

  /// No description provided for @onboardingActivityTitle.
  ///
  /// In ko, this message translates to:
  /// **'평소 활동량'**
  String get onboardingActivityTitle;

  /// No description provided for @onboardingTargetCalories.
  ///
  /// In ko, this message translates to:
  /// **'일일 목표 칼로리'**
  String get onboardingTargetCalories;

  /// No description provided for @onboardingNeedsCalculation.
  ///
  /// In ko, this message translates to:
  /// **'계산 필요'**
  String get onboardingNeedsCalculation;

  /// No description provided for @onboardingCheckInputs.
  ///
  /// In ko, this message translates to:
  /// **'입력값을 확인해주세요.'**
  String get onboardingCheckInputs;

  /// No description provided for @onboardingWaterBasis.
  ///
  /// In ko, this message translates to:
  /// **'수분 기준'**
  String get onboardingWaterBasis;

  /// No description provided for @onboardingWaterBasisDescription.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중 × 30ml를 100ml 단위로 반올림합니다.'**
  String get onboardingWaterBasisDescription;

  /// No description provided for @onboardingReviewInfo.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔의 칼로리는 고정 더미 값이 아니라 입력한 신체 정보와 목표에 따라 자동 계산됩니다.'**
  String get onboardingReviewInfo;

  /// No description provided for @onboardingValidationAge.
  ///
  /// In ko, this message translates to:
  /// **'나이를 10~100 사이로 입력해주세요.'**
  String get onboardingValidationAge;

  /// No description provided for @onboardingValidationHeight.
  ///
  /// In ko, this message translates to:
  /// **'키를 100~230cm 사이로 입력해주세요.'**
  String get onboardingValidationHeight;

  /// No description provided for @onboardingValidationWeight.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중을 30~250kg 사이로 입력해주세요.'**
  String get onboardingValidationWeight;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'프로필 저장에 실패했습니다. 다시 시도해주세요.'**
  String get onboardingSaveFailed;

  /// No description provided for @defaultUserName.
  ///
  /// In ko, this message translates to:
  /// **'식단스캔 사용자'**
  String get defaultUserName;

  /// No description provided for @goalSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'목표 설정'**
  String get goalSettingsTitle;

  /// No description provided for @goalSettingsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'나만의 건강 목표를 세워보세요'**
  String get goalSettingsSubtitle;

  /// No description provided for @goalTargetWeight.
  ///
  /// In ko, this message translates to:
  /// **'목표 체중'**
  String get goalTargetWeight;

  /// No description provided for @goalCalorieTarget.
  ///
  /// In ko, this message translates to:
  /// **'일일 칼로리 목표'**
  String get goalCalorieTarget;

  /// No description provided for @goalWaterTarget.
  ///
  /// In ko, this message translates to:
  /// **'수분 목표'**
  String get goalWaterTarget;

  /// No description provided for @goalSettingsDone.
  ///
  /// In ko, this message translates to:
  /// **'목표 설정 완료'**
  String get goalSettingsDone;

  /// No description provided for @goalActivityTitle.
  ///
  /// In ko, this message translates to:
  /// **'활동량'**
  String get goalActivityTitle;

  /// No description provided for @goalRecommendation.
  ///
  /// In ko, this message translates to:
  /// **'추천'**
  String get goalRecommendation;

  /// No description provided for @goalApply.
  ///
  /// In ko, this message translates to:
  /// **'적용'**
  String get goalApply;

  /// No description provided for @goalDirectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'개선 방향'**
  String get goalDirectionTitle;

  /// No description provided for @goalTargetDate.
  ///
  /// In ko, this message translates to:
  /// **'목표 날짜'**
  String get goalTargetDate;

  /// No description provided for @goalSelectDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜를 선택하세요'**
  String get goalSelectDate;

  /// No description provided for @goalUpdated.
  ///
  /// In ko, this message translates to:
  /// **'목표가 업데이트되었습니다'**
  String get goalUpdated;

  /// No description provided for @goalBalancedDescription.
  ///
  /// In ko, this message translates to:
  /// **'식단 균형과 꾸준한 기록을 유지'**
  String get goalBalancedDescription;

  /// No description provided for @goalWeightLossDescription.
  ///
  /// In ko, this message translates to:
  /// **'칼로리 과잉을 줄이고 포만감을 높이는 전략'**
  String get goalWeightLossDescription;

  /// No description provided for @goalSkinHealthDescription.
  ///
  /// In ko, this message translates to:
  /// **'당류·지방 편중을 낮추고 회복 영양소 보강'**
  String get goalSkinHealthDescription;

  /// No description provided for @goalDigestionDescription.
  ///
  /// In ko, this message translates to:
  /// **'식이섬유와 수분 중심의 소화 컨디션 관리'**
  String get goalDigestionDescription;

  /// No description provided for @goalEnergyDescription.
  ///
  /// In ko, this message translates to:
  /// **'끼니 균형과 혈당 변동을 줄이는 에너지 관리'**
  String get goalEnergyDescription;

  /// No description provided for @goalMuscleDescription.
  ///
  /// In ko, this message translates to:
  /// **'체중과 활동량에 맞춘 단백질 섭취 최적화'**
  String get goalMuscleDescription;

  /// No description provided for @goalGlucoseDescription.
  ///
  /// In ko, this message translates to:
  /// **'탄수화물 비중과 식사 순서를 관리'**
  String get goalGlucoseDescription;

  /// No description provided for @activityLightDescription.
  ///
  /// In ko, this message translates to:
  /// **'대부분 앉아서 생활하거나 가벼운 걷기 위주'**
  String get activityLightDescription;

  /// No description provided for @activityModerateDescription.
  ///
  /// In ko, this message translates to:
  /// **'주 2~4회 운동 또는 하루 이동량이 있는 편'**
  String get activityModerateDescription;

  /// No description provided for @activityActiveDescription.
  ///
  /// In ko, this message translates to:
  /// **'주 5회 이상 운동하거나 활동량이 많은 편'**
  String get activityActiveDescription;

  /// No description provided for @goalBalanced.
  ///
  /// In ko, this message translates to:
  /// **'균형 관리'**
  String get goalBalanced;

  /// No description provided for @goalWeightLoss.
  ///
  /// In ko, this message translates to:
  /// **'체중 감량'**
  String get goalWeightLoss;

  /// No description provided for @goalSkinHealth.
  ///
  /// In ko, this message translates to:
  /// **'피부 개선'**
  String get goalSkinHealth;

  /// No description provided for @goalDigestion.
  ///
  /// In ko, this message translates to:
  /// **'장 건강'**
  String get goalDigestion;

  /// No description provided for @goalEnergy.
  ///
  /// In ko, this message translates to:
  /// **'컨디션 개선'**
  String get goalEnergy;

  /// No description provided for @goalMuscle.
  ///
  /// In ko, this message translates to:
  /// **'단백질 보강'**
  String get goalMuscle;

  /// No description provided for @goalGlucose.
  ///
  /// In ko, this message translates to:
  /// **'혈당 안정'**
  String get goalGlucose;

  /// No description provided for @activityLight.
  ///
  /// In ko, this message translates to:
  /// **'가벼운 활동'**
  String get activityLight;

  /// No description provided for @activityModerate.
  ///
  /// In ko, this message translates to:
  /// **'보통 활동'**
  String get activityModerate;

  /// No description provided for @activityActive.
  ///
  /// In ko, this message translates to:
  /// **'활동적'**
  String get activityActive;

  /// No description provided for @addMealAiHint.
  ///
  /// In ko, this message translates to:
  /// **'DB에 없는 음식은 AI가 자동으로 영양 정보를 분석합니다'**
  String get addMealAiHint;

  /// No description provided for @addMealAiAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'AI가 영양 정보를 분석하고 있어요...'**
  String get addMealAiAnalyzing;

  /// No description provided for @addMealSourceAiResults.
  ///
  /// In ko, this message translates to:
  /// **'AI 영양 분석 결과'**
  String get addMealSourceAiResults;

  /// No description provided for @addMealAiTag.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석'**
  String get addMealAiTag;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In ko, this message translates to:
  /// **'아침'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In ko, this message translates to:
  /// **'점심'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In ko, this message translates to:
  /// **'저녁'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In ko, this message translates to:
  /// **'간식'**
  String get mealTypeSnack;

  /// No description provided for @mealDetailMealType.
  ///
  /// In ko, this message translates to:
  /// **'식사 유형'**
  String get mealDetailMealType;

  /// No description provided for @mealDetailPortion.
  ///
  /// In ko, this message translates to:
  /// **'분량 조절'**
  String get mealDetailPortion;

  /// No description provided for @mealDetailPortionHint.
  ///
  /// In ko, this message translates to:
  /// **'처음 저장한 1인분을 기준으로 칼로리와 영양소를 다시 계산합니다'**
  String get mealDetailPortionHint;

  /// No description provided for @mealDetailDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록 삭제'**
  String get mealDetailDeleteTitle;

  /// No description provided for @mealDetailDeleted.
  ///
  /// In ko, this message translates to:
  /// **'기록을 삭제했습니다'**
  String get mealDetailDeleted;

  /// No description provided for @mealDetailUpdated.
  ///
  /// In ko, this message translates to:
  /// **'기록을 수정했습니다'**
  String get mealDetailUpdated;

  /// No description provided for @commonError.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다. 다시 시도해주세요'**
  String get commonError;

  /// No description provided for @reportMealTypeTitle.
  ///
  /// In ko, this message translates to:
  /// **'식사 유형별 비중'**
  String get reportMealTypeTitle;

  /// No description provided for @reportMealTypeRecords.
  ///
  /// In ko, this message translates to:
  /// **'{count}건'**
  String reportMealTypeRecords(int count);

  /// No description provided for @dailyStatusNone.
  ///
  /// In ko, this message translates to:
  /// **'기록 전'**
  String get dailyStatusNone;

  /// No description provided for @dailyStatusRoom.
  ///
  /// In ko, this message translates to:
  /// **'여유'**
  String get dailyStatusRoom;

  /// No description provided for @dailyStatusOnTrack.
  ///
  /// In ko, this message translates to:
  /// **'적정'**
  String get dailyStatusOnTrack;

  /// No description provided for @dailyStatusCaution.
  ///
  /// In ko, this message translates to:
  /// **'주의'**
  String get dailyStatusCaution;

  /// No description provided for @dailyStatusOver.
  ///
  /// In ko, this message translates to:
  /// **'초과'**
  String get dailyStatusOver;

  /// No description provided for @bmiUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없음'**
  String get bmiUnknown;

  /// No description provided for @bmiUnderweight.
  ///
  /// In ko, this message translates to:
  /// **'저체중'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In ko, this message translates to:
  /// **'정상'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In ko, this message translates to:
  /// **'과체중'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In ko, this message translates to:
  /// **'비만'**
  String get bmiObese;

  /// No description provided for @bmiSeverelyObese.
  ///
  /// In ko, this message translates to:
  /// **'고도비만'**
  String get bmiSeverelyObese;

  /// No description provided for @profileBasisRecommended.
  ///
  /// In ko, this message translates to:
  /// **'권장 {kcal} kcal'**
  String profileBasisRecommended(int kcal);

  /// No description provided for @profileBasisCurrent.
  ///
  /// In ko, this message translates to:
  /// **'현재 {kcal} kcal'**
  String profileBasisCurrent(int kcal);

  /// No description provided for @profileBasisWater.
  ///
  /// In ko, this message translates to:
  /// **'수분 {ml} ml'**
  String profileBasisWater(int ml);

  /// No description provided for @calorieBasisNoAdjustment.
  ///
  /// In ko, this message translates to:
  /// **'목표 보정 없음'**
  String get calorieBasisNoAdjustment;

  /// No description provided for @calorieBasisAdjustment.
  ///
  /// In ko, this message translates to:
  /// **'{amount} kcal 목표 보정'**
  String calorieBasisAdjustment(String amount);

  /// No description provided for @startupErrorTitle.
  ///
  /// In ko, this message translates to:
  /// **'앱을 시작할 수 없습니다'**
  String get startupErrorTitle;

  /// No description provided for @proxyStatusNotConfigured.
  ///
  /// In ko, this message translates to:
  /// **'프록시 URL이 설정되지 않았습니다.'**
  String get proxyStatusNotConfigured;

  /// No description provided for @proxyStatusConnected.
  ///
  /// In ko, this message translates to:
  /// **'프록시가 정상 응답했습니다.'**
  String get proxyStatusConnected;

  /// No description provided for @proxyStatusUnexpectedResponse.
  ///
  /// In ko, this message translates to:
  /// **'프록시가 예상과 다른 응답을 반환했습니다.'**
  String get proxyStatusUnexpectedResponse;

  /// No description provided for @proxyStatusInvalidToken.
  ///
  /// In ko, this message translates to:
  /// **'프록시 인증 토큰을 확인해주세요.'**
  String get proxyStatusInvalidToken;

  /// No description provided for @proxyStatusHealthMissing.
  ///
  /// In ko, this message translates to:
  /// **'프록시 헬스체크 엔드포인트를 찾을 수 없습니다.'**
  String get proxyStatusHealthMissing;

  /// No description provided for @proxyStatusServerError.
  ///
  /// In ko, this message translates to:
  /// **'프록시 서버가 정상 응답하지 않습니다.'**
  String get proxyStatusServerError;

  /// No description provided for @proxyStatusUnreachable.
  ///
  /// In ko, this message translates to:
  /// **'프록시에 연결할 수 없습니다.'**
  String get proxyStatusUnreachable;

  /// No description provided for @strategyMetaLabel.
  ///
  /// In ko, this message translates to:
  /// **'목표 전략 · 기록 {count}개 반영'**
  String strategyMetaLabel(int count);

  /// No description provided for @strategyEmptySummary.
  ///
  /// In ko, this message translates to:
  /// **'{goal} 목표에 맞춰 오늘 식단의 강점과 보완점을 정리해 드려요.'**
  String strategyEmptySummary(String goal);

  /// No description provided for @strategyTipPhotoAngle.
  ///
  /// In ko, this message translates to:
  /// **'음식이 잘 보이도록 위에서 촬영'**
  String get strategyTipPhotoAngle;

  /// No description provided for @strategyTipReviewBeforeSave.
  ///
  /// In ko, this message translates to:
  /// **'저장 전 음식명과 양 확인'**
  String get strategyTipReviewBeforeSave;

  /// No description provided for @strategyWeightLossOverTitle.
  ///
  /// In ko, this message translates to:
  /// **'남은 식사는 가볍게 보정하세요'**
  String get strategyWeightLossOverTitle;

  /// No description provided for @strategyWeightLossOnTrackTitle.
  ///
  /// In ko, this message translates to:
  /// **'감량 흐름은 유지 중입니다'**
  String get strategyWeightLossOnTrackTitle;

  /// No description provided for @strategyWeightLossOverSummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘 목표 칼로리를 넘겼습니다. 다음 식사는 포만감 높은 단백질과 채소 중심이 좋습니다.'**
  String get strategyWeightLossOverSummary;

  /// No description provided for @strategyWeightLossOnTrackSummary.
  ///
  /// In ko, this message translates to:
  /// **'현재 섭취량은 목표 범위 안입니다. 단백질을 채우면 야식 가능성을 줄일 수 있습니다.'**
  String get strategyWeightLossOnTrackSummary;

  /// No description provided for @strategyWeightLossAddProtein.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사에 닭가슴살, 달걀, 두부 중 하나를 추가하세요.'**
  String get strategyWeightLossAddProtein;

  /// No description provided for @strategyWeightLossVeggiesFirst.
  ///
  /// In ko, this message translates to:
  /// **'탄수화물 추가보다 채소와 수분을 먼저 보강하세요.'**
  String get strategyWeightLossVeggiesFirst;

  /// No description provided for @strategyActionSkipFriedSauce.
  ///
  /// In ko, this message translates to:
  /// **'튀김·소스류는 다음 식사에서 제외'**
  String get strategyActionSkipFriedSauce;

  /// No description provided for @strategyActionLightProteinMeal.
  ///
  /// In ko, this message translates to:
  /// **'남은 식사는 400kcal 안쪽의 단백질 식사로 조정'**
  String get strategyActionLightProteinMeal;

  /// No description provided for @strategyActionWalkAppetite.
  ///
  /// In ko, this message translates to:
  /// **'식사 후 10분 걷기로 혈당과 식욕 변동 완화'**
  String get strategyActionWalkAppetite;

  /// No description provided for @strategySkinFixTitle.
  ///
  /// In ko, this message translates to:
  /// **'피부 목표 기준 보정이 필요합니다'**
  String get strategySkinFixTitle;

  /// No description provided for @strategySkinGoodTitle.
  ///
  /// In ko, this message translates to:
  /// **'피부 친화적인 흐름입니다'**
  String get strategySkinGoodTitle;

  /// No description provided for @strategySkinHighCarbSummary.
  ///
  /// In ko, this message translates to:
  /// **'탄수화물 비중이 높아 다음 식사는 혈당 변동을 줄이는 조합이 좋습니다.'**
  String get strategySkinHighCarbSummary;

  /// No description provided for @strategySkinBalancedSummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘 식단은 한쪽으로 치우치지 않았습니다. 항산화 식품을 더하면 좋습니다.'**
  String get strategySkinBalancedSummary;

  /// No description provided for @strategySkinPrimary.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사는 생선·두부·달걀 + 녹황색 채소 조합을 우선하세요.'**
  String get strategySkinPrimary;

  /// No description provided for @strategyActionNoCreamy.
  ///
  /// In ko, this message translates to:
  /// **'기름진 메뉴와 크림 소스는 오늘 추가하지 않기'**
  String get strategyActionNoCreamy;

  /// No description provided for @strategyActionNoSugarDrinks.
  ///
  /// In ko, this message translates to:
  /// **'디저트·당 음료 대신 물 또는 무가당 차 선택'**
  String get strategyActionNoSugarDrinks;

  /// No description provided for @strategyActionVitaminC.
  ///
  /// In ko, this message translates to:
  /// **'비타민 C가 있는 과일은 한 번에 소량만 추가'**
  String get strategyActionVitaminC;

  /// No description provided for @strategyDigestionHeavyTitle.
  ///
  /// In ko, this message translates to:
  /// **'소화 부담을 낮춰야 합니다'**
  String get strategyDigestionHeavyTitle;

  /// No description provided for @strategyDigestionGoodTitle.
  ///
  /// In ko, this message translates to:
  /// **'장 건강 루틴을 이어가세요'**
  String get strategyDigestionGoodTitle;

  /// No description provided for @strategyDigestionHeavySummary.
  ///
  /// In ko, this message translates to:
  /// **'지방 비중이 높으면 더부룩함이 생길 수 있습니다. 다음 식사는 담백하게 보정하세요.'**
  String get strategyDigestionHeavySummary;

  /// No description provided for @strategyDigestionGoodSummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘은 수분과 식이섬유를 더하기 좋은 상태입니다.'**
  String get strategyDigestionGoodSummary;

  /// No description provided for @strategyDigestionPrimary.
  ///
  /// In ko, this message translates to:
  /// **'채소 반 접시와 물 500ml를 다음 식사 전후로 나눠 보강하세요.'**
  String get strategyDigestionPrimary;

  /// No description provided for @strategyActionSolidsOverBroth.
  ///
  /// In ko, this message translates to:
  /// **'국물보다 건더기 중심으로 선택'**
  String get strategyActionSolidsOverBroth;

  /// No description provided for @strategyActionFermented.
  ///
  /// In ko, this message translates to:
  /// **'요거트, 김치, 나물류 중 하나 추가'**
  String get strategyActionFermented;

  /// No description provided for @strategyActionSkipFattyMeat.
  ///
  /// In ko, this message translates to:
  /// **'튀김·기름진 고기는 다음 식사에서 제외'**
  String get strategyActionSkipFattyMeat;

  /// No description provided for @strategyEnergyCarbTitle.
  ///
  /// In ko, this message translates to:
  /// **'오후 에너지 변동을 줄이세요'**
  String get strategyEnergyCarbTitle;

  /// No description provided for @strategyEnergyGoodTitle.
  ///
  /// In ko, this message translates to:
  /// **'컨디션 유지에 좋은 균형입니다'**
  String get strategyEnergyGoodTitle;

  /// No description provided for @strategyEnergyLowSummary.
  ///
  /// In ko, this message translates to:
  /// **'섭취량이 낮아 오후 집중력 저하가 올 수 있습니다.'**
  String get strategyEnergyLowSummary;

  /// No description provided for @strategyEnergyGoodSummary.
  ///
  /// In ko, this message translates to:
  /// **'끼니 균형을 유지하면 피로감과 간식 욕구를 줄일 수 있습니다.'**
  String get strategyEnergyGoodSummary;

  /// No description provided for @strategyEnergyAddProtein.
  ///
  /// In ko, this message translates to:
  /// **'단백질 간식 또는 달걀/두부를 추가하세요.'**
  String get strategyEnergyAddProtein;

  /// No description provided for @strategyEnergyPairCarbs.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사는 탄수화물 단독보다 단백질과 함께 구성하세요.'**
  String get strategyEnergyPairCarbs;

  /// No description provided for @strategyActionWaterOverSweet.
  ///
  /// In ko, this message translates to:
  /// **'단 음료 대신 물 또는 아메리카노 선택'**
  String get strategyActionWaterOverSweet;

  /// No description provided for @strategyActionSmartSnack.
  ///
  /// In ko, this message translates to:
  /// **'간식은 견과류 소량이나 그릭요거트로 선택'**
  String get strategyActionSmartSnack;

  /// No description provided for @strategyActionStretch.
  ///
  /// In ko, this message translates to:
  /// **'식후 5분 스트레칭으로 졸림 완화'**
  String get strategyActionStretch;

  /// No description provided for @strategyMuscleLowTitle.
  ///
  /// In ko, this message translates to:
  /// **'단백질 보강이 우선입니다'**
  String get strategyMuscleLowTitle;

  /// No description provided for @strategyMuscleCloseTitle.
  ///
  /// In ko, this message translates to:
  /// **'단백질 목표에 가까워지고 있습니다'**
  String get strategyMuscleCloseTitle;

  /// No description provided for @strategyMuscleSummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘 단백질은 {protein}g, 목표는 {goal}g입니다.'**
  String strategyMuscleSummary(String protein, String goal);

  /// No description provided for @strategyMuscleAddProtein.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사에 단백질 {gap}g 보강을 목표로 하세요.'**
  String strategyMuscleAddProtein(String gap);

  /// No description provided for @strategyMuscleRecovery.
  ///
  /// In ko, this message translates to:
  /// **'운동 후에는 수분과 탄수화물을 소량 함께 보강하세요.'**
  String get strategyMuscleRecovery;

  /// No description provided for @strategyActionLeanProtein.
  ///
  /// In ko, this message translates to:
  /// **'닭가슴살·생선·두부·그릭요거트 중 하나 선택'**
  String get strategyActionLeanProtein;

  /// No description provided for @strategyActionPreWorkoutSnack.
  ///
  /// In ko, this message translates to:
  /// **'섭취량이 낮으니 운동 전후 간식을 추가'**
  String get strategyActionPreWorkoutSnack;

  /// No description provided for @strategyActionSpreadProtein.
  ///
  /// In ko, this message translates to:
  /// **'단백질은 한 끼에 몰지 말고 나눠 섭취'**
  String get strategyActionSpreadProtein;

  /// No description provided for @strategyGlucoseCarbTitle.
  ///
  /// In ko, this message translates to:
  /// **'탄수화물 속도 조절이 필요합니다'**
  String get strategyGlucoseCarbTitle;

  /// No description provided for @strategyGlucoseGoodTitle.
  ///
  /// In ko, this message translates to:
  /// **'혈당 안정 흐름입니다'**
  String get strategyGlucoseGoodTitle;

  /// No description provided for @strategyGlucoseCarbSummary.
  ///
  /// In ko, this message translates to:
  /// **'탄수화물 비중이 높습니다. 다음 식사는 식사 순서와 단백질 보강이 중요합니다.'**
  String get strategyGlucoseCarbSummary;

  /// No description provided for @strategyGlucoseGoodSummary.
  ///
  /// In ko, this message translates to:
  /// **'현재 비율은 급격한 변동을 줄이기 좋은 편입니다.'**
  String get strategyGlucoseGoodSummary;

  /// No description provided for @strategyGlucosePrimary.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사는 채소 → 단백질 → 탄수화물 순서로 드세요.'**
  String get strategyGlucosePrimary;

  /// No description provided for @strategyActionAddProteinSide.
  ///
  /// In ko, this message translates to:
  /// **'밥/면 단독 식사는 피하고 단백질 반찬 추가'**
  String get strategyActionAddProteinSide;

  /// No description provided for @strategyActionWalk10.
  ///
  /// In ko, this message translates to:
  /// **'식후 10분 걷기'**
  String get strategyActionWalk10;

  /// No description provided for @strategyActionNoDessert.
  ///
  /// In ko, this message translates to:
  /// **'단 음료와 디저트는 오늘 추가하지 않기'**
  String get strategyActionNoDessert;

  /// No description provided for @strategyBalancedGoodTitle.
  ///
  /// In ko, this message translates to:
  /// **'균형이 좋은 하루입니다'**
  String get strategyBalancedGoodTitle;

  /// No description provided for @strategyBalancedFixTitle.
  ///
  /// In ko, this message translates to:
  /// **'한쪽으로 치우친 영양소를 보정하세요'**
  String get strategyBalancedFixTitle;

  /// No description provided for @strategyBalancedGoodSummary.
  ///
  /// In ko, this message translates to:
  /// **'현재 칼로리와 탄단지 흐름이 안정적입니다.'**
  String get strategyBalancedGoodSummary;

  /// No description provided for @strategyBalancedFixSummary.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사에서 부족한 축을 보강하면 하루 균형이 좋아집니다.'**
  String get strategyBalancedFixSummary;

  /// No description provided for @strategyBalancedPrimary.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사는 단백질, 채소, 탄수화물을 한 접시에 함께 구성하세요.'**
  String get strategyBalancedPrimary;

  /// No description provided for @strategyActionLogWater.
  ///
  /// In ko, this message translates to:
  /// **'물 섭취도 함께 기록'**
  String get strategyActionLogWater;

  /// No description provided for @strategyActionReviewRecords.
  ///
  /// In ko, this message translates to:
  /// **'오늘 기록을 한 번 확인'**
  String get strategyActionReviewRecords;

  /// No description provided for @strategyFactorCalories.
  ///
  /// In ko, this message translates to:
  /// **'칼로리 범위'**
  String get strategyFactorCalories;

  /// No description provided for @strategyFactorProtein.
  ///
  /// In ko, this message translates to:
  /// **'단백질 충족'**
  String get strategyFactorProtein;

  /// No description provided for @strategyFactorFat.
  ///
  /// In ko, this message translates to:
  /// **'지방 비중'**
  String get strategyFactorFat;

  /// No description provided for @strategyFactorCarbs.
  ///
  /// In ko, this message translates to:
  /// **'탄수화물 비중'**
  String get strategyFactorCarbs;

  /// No description provided for @strategyFactorBalance.
  ///
  /// In ko, this message translates to:
  /// **'탄단지 균형'**
  String get strategyFactorBalance;

  /// No description provided for @strategyFactorVolume.
  ///
  /// In ko, this message translates to:
  /// **'식사량'**
  String get strategyFactorVolume;

  /// No description provided for @strategyFactorConsistency.
  ///
  /// In ko, this message translates to:
  /// **'기록 유지'**
  String get strategyFactorConsistency;

  /// No description provided for @strategyDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 목표 전략'**
  String get strategyDetailTitle;

  /// No description provided for @strategyRuleBasedNote.
  ///
  /// In ko, this message translates to:
  /// **'오늘 기록한 칼로리와 탄단지 비율을 목표 기준과 비교해 계산한 결과입니다. 의학적 진단이 아닙니다.'**
  String get strategyRuleBasedNote;

  /// No description provided for @strategyScoreTitle.
  ///
  /// In ko, this message translates to:
  /// **'점수 기준'**
  String get strategyScoreTitle;

  /// No description provided for @strategyScoreSemantics.
  ///
  /// In ko, this message translates to:
  /// **'목표 점수 100점 만점에 {score}점'**
  String strategyScoreSemantics(int score);

  /// No description provided for @strategyNextMeal.
  ///
  /// In ko, this message translates to:
  /// **'다음 식사 제안'**
  String get strategyNextMeal;

  /// No description provided for @strategyTips.
  ///
  /// In ko, this message translates to:
  /// **'실천 팁'**
  String get strategyTips;

  /// No description provided for @strategyAskCoach.
  ///
  /// In ko, this message translates to:
  /// **'AI 코치에게 물어보기'**
  String get strategyAskCoach;

  /// No description provided for @strategyAskCoachPrompt.
  ///
  /// In ko, this message translates to:
  /// **'오늘 기록을 보고 다음 식사로 무엇을 먹으면 좋을지 알려줘'**
  String get strategyAskCoachPrompt;

  /// No description provided for @strategyOpenDetail.
  ///
  /// In ko, this message translates to:
  /// **'전략 자세히 보기'**
  String get strategyOpenDetail;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @commonClear.
  ///
  /// In ko, this message translates to:
  /// **'지우기'**
  String get commonClear;

  /// No description provided for @commonUndo.
  ///
  /// In ko, this message translates to:
  /// **'되돌리기'**
  String get commonUndo;

  /// No description provided for @commonItemCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String commonItemCount(int count);

  /// No description provided for @macroShort.
  ///
  /// In ko, this message translates to:
  /// **'탄 {carbs}g · 단 {protein}g · 지 {fat}g'**
  String macroShort(String carbs, String protein, String fat);

  /// No description provided for @entrySheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'식사 기록하기'**
  String get entrySheetTitle;

  /// No description provided for @entrySheetTitleForDate.
  ///
  /// In ko, this message translates to:
  /// **'{date} 기록 추가'**
  String entrySheetTitleForDate(String date);

  /// No description provided for @entryCamera.
  ///
  /// In ko, this message translates to:
  /// **'사진 찍어 기록'**
  String get entryCamera;

  /// No description provided for @entryCameraSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'AI가 음식과 영양 정보를 추정하고, 저장 전에 확인할 수 있어요'**
  String get entryCameraSubtitle;

  /// No description provided for @entryGallery.
  ///
  /// In ko, this message translates to:
  /// **'앨범에서 선택'**
  String get entryGallery;

  /// No description provided for @entryGallerySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'찍어둔 음식 사진으로 기록해요'**
  String get entryGallerySubtitle;

  /// No description provided for @entrySearch.
  ///
  /// In ko, this message translates to:
  /// **'검색 · 직접 입력'**
  String get entrySearch;

  /// No description provided for @entrySearchSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'음식 이름으로 찾거나 영양 정보를 직접 입력해요 · 오프라인에서도 가능'**
  String get entrySearchSubtitle;

  /// No description provided for @entryPhotoUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'사진 인식은 AI 서버 연결 후 사용할 수 있어요'**
  String get entryPhotoUnavailable;

  /// No description provided for @dashboardLogMeal.
  ///
  /// In ko, this message translates to:
  /// **'식사 기록'**
  String get dashboardLogMeal;

  /// No description provided for @reviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록 확인'**
  String get reviewTitle;

  /// No description provided for @reviewAnalyzingTitle.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 중'**
  String get reviewAnalyzingTitle;

  /// No description provided for @reviewFailedTitle.
  ///
  /// In ko, this message translates to:
  /// **'음식을 인식하지 못했어요'**
  String get reviewFailedTitle;

  /// No description provided for @reviewAnalyzingMessage.
  ///
  /// In ko, this message translates to:
  /// **'음식과 영양 정보를 추정하고 있어요'**
  String get reviewAnalyzingMessage;

  /// No description provided for @reviewAnalyzingHint.
  ///
  /// In ko, this message translates to:
  /// **'보통 5~15초 걸려요. 기다리기 어렵다면 직접 입력으로 전환할 수 있어요.'**
  String get reviewAnalyzingHint;

  /// No description provided for @reviewSwitchToManual.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력으로 전환'**
  String get reviewSwitchToManual;

  /// No description provided for @reviewCancelAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'분석 취소'**
  String get reviewCancelAnalysis;

  /// No description provided for @reviewRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 분석'**
  String get reviewRetry;

  /// No description provided for @reviewSearchAdd.
  ///
  /// In ko, this message translates to:
  /// **'검색해서 추가'**
  String get reviewSearchAdd;

  /// No description provided for @reviewAddManual.
  ///
  /// In ko, this message translates to:
  /// **'직접 추가'**
  String get reviewAddManual;

  /// No description provided for @reviewNeedsReview.
  ///
  /// In ko, this message translates to:
  /// **'AI 추정치예요. 음식 이름과 양이 맞는지 확인한 뒤 저장해 주세요.'**
  String get reviewNeedsReview;

  /// No description provided for @reviewLowConfidence.
  ///
  /// In ko, this message translates to:
  /// **'확인 필요'**
  String get reviewLowConfidence;

  /// No description provided for @reviewConfidence.
  ///
  /// In ko, this message translates to:
  /// **'AI 신뢰도 {percent}%'**
  String reviewConfidence(int percent);

  /// No description provided for @reviewFoodsSection.
  ///
  /// In ko, this message translates to:
  /// **'음식'**
  String get reviewFoodsSection;

  /// No description provided for @reviewNoDrafts.
  ///
  /// In ko, this message translates to:
  /// **'추가된 음식이 없어요. 직접 추가하거나 검색해 보세요.'**
  String get reviewNoDrafts;

  /// No description provided for @reviewNameHint.
  ///
  /// In ko, this message translates to:
  /// **'음식 이름'**
  String get reviewNameHint;

  /// No description provided for @reviewCarbsLabel.
  ///
  /// In ko, this message translates to:
  /// **'탄수(g)'**
  String get reviewCarbsLabel;

  /// No description provided for @reviewProteinLabel.
  ///
  /// In ko, this message translates to:
  /// **'단백질(g)'**
  String get reviewProteinLabel;

  /// No description provided for @reviewFatLabel.
  ///
  /// In ko, this message translates to:
  /// **'지방(g)'**
  String get reviewFatLabel;

  /// No description provided for @reviewPortion.
  ///
  /// In ko, this message translates to:
  /// **'양'**
  String get reviewPortion;

  /// No description provided for @reviewPortionTotal.
  ///
  /// In ko, this message translates to:
  /// **'{kcal} kcal로 저장돼요'**
  String reviewPortionTotal(String kcal);

  /// No description provided for @reviewDateTime.
  ///
  /// In ko, this message translates to:
  /// **'날짜 · 시간'**
  String get reviewDateTime;

  /// No description provided for @reviewDateSemantics.
  ///
  /// In ko, this message translates to:
  /// **'기록 날짜 {date}'**
  String reviewDateSemantics(String date);

  /// No description provided for @reviewSave.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 저장 · {kcal} kcal'**
  String reviewSave(int count, String kcal);

  /// No description provided for @reviewSaved.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 음식을 기록했어요'**
  String reviewSaved(int count);

  /// No description provided for @reviewLeaveTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록을 취소할까요?'**
  String get reviewLeaveTitle;

  /// No description provided for @reviewLeaveMessage.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과와 입력한 내용은 저장되지 않아요.'**
  String get reviewLeaveMessage;

  /// No description provided for @reviewLeaveConfirm.
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get reviewLeaveConfirm;

  /// No description provided for @reviewLeaveStay.
  ///
  /// In ko, this message translates to:
  /// **'계속 작성'**
  String get reviewLeaveStay;

  /// No description provided for @reviewRemoveItem.
  ///
  /// In ko, this message translates to:
  /// **'항목 삭제'**
  String get reviewRemoveItem;

  /// No description provided for @reviewSelectItem.
  ///
  /// In ko, this message translates to:
  /// **'저장할 항목 선택'**
  String get reviewSelectItem;

  /// No description provided for @reviewPhotoSemantics.
  ///
  /// In ko, this message translates to:
  /// **'촬영한 음식 사진'**
  String get reviewPhotoSemantics;

  /// No description provided for @addMealManualEntry.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력'**
  String get addMealManualEntry;

  /// No description provided for @addMealOfflineHint.
  ///
  /// In ko, this message translates to:
  /// **'AI 서버 미연결 상태에서는 내장 음식 DB와 직접 입력을 사용할 수 있어요'**
  String get addMealOfflineHint;

  /// No description provided for @addMealSelectedSummary.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택 · {kcal} kcal'**
  String addMealSelectedSummary(int count, String kcal);

  /// No description provided for @addMealRemoveTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{name} 빼기'**
  String addMealRemoveTooltip(String name);

  /// No description provided for @addMealAddTooltip.
  ///
  /// In ko, this message translates to:
  /// **'{name} 추가'**
  String addMealAddTooltip(String name);

  /// No description provided for @addMealRecentTitle.
  ///
  /// In ko, this message translates to:
  /// **'최근 기록한 음식'**
  String get addMealRecentTitle;

  /// No description provided for @addMealSuggestedTitle.
  ///
  /// In ko, this message translates to:
  /// **'추천 음식'**
  String get addMealSuggestedTitle;

  /// No description provided for @mealDetailAiRecognized.
  ///
  /// In ko, this message translates to:
  /// **'AI 인식'**
  String get mealDetailAiRecognized;

  /// No description provided for @mealDetailServing.
  ///
  /// In ko, this message translates to:
  /// **'기준량 {serving}'**
  String mealDetailServing(String serving);

  /// No description provided for @mealDetailLogAgain.
  ///
  /// In ko, this message translates to:
  /// **'다시 기록'**
  String get mealDetailLogAgain;

  /// No description provided for @mealDetailLoggedAgain.
  ///
  /// In ko, this message translates to:
  /// **'지금 시간으로 다시 기록했어요'**
  String get mealDetailLoggedAgain;

  /// No description provided for @dailyKcalLeft.
  ///
  /// In ko, this message translates to:
  /// **'목표 {goal} kcal · {amount} kcal 남음'**
  String dailyKcalLeft(String goal, String amount);

  /// No description provided for @dailyKcalOver.
  ///
  /// In ko, this message translates to:
  /// **'목표 {goal} kcal · {amount} kcal 초과'**
  String dailyKcalOver(String goal, String amount);

  /// No description provided for @dailyIntakeSemantics.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {kcal} 킬로칼로리 섭취. {remaining}. 상태 {status}'**
  String dailyIntakeSemantics(String kcal, String remaining, String status);

  /// No description provided for @dailyMacroSemantics.
  ///
  /// In ko, this message translates to:
  /// **'{label} {grams}그램, 칼로리 비중 {percent}퍼센트'**
  String dailyMacroSemantics(String label, String grams, int percent);

  /// No description provided for @dailyLogFirstMeal.
  ///
  /// In ko, this message translates to:
  /// **'첫 식사 기록하기'**
  String get dailyLogFirstMeal;

  /// No description provided for @waterTitle.
  ///
  /// In ko, this message translates to:
  /// **'수분'**
  String get waterTitle;

  /// No description provided for @waterSemantics.
  ///
  /// In ko, this message translates to:
  /// **'수분 {amount}밀리리터, 목표 {goal}밀리리터'**
  String waterSemantics(String amount, String goal);

  /// No description provided for @waterSemanticsNoGoal.
  ///
  /// In ko, this message translates to:
  /// **'수분 {amount}밀리리터'**
  String waterSemanticsNoGoal(String amount);

  /// No description provided for @waterAddGlass.
  ///
  /// In ko, this message translates to:
  /// **'물 한 잔(250ml) 추가'**
  String get waterAddGlass;

  /// No description provided for @waterRemoveGlass.
  ///
  /// In ko, this message translates to:
  /// **'물 한 잔 빼기'**
  String get waterRemoveGlass;

  /// No description provided for @reportPrevious.
  ///
  /// In ko, this message translates to:
  /// **'이전 기간'**
  String get reportPrevious;

  /// No description provided for @reportNext.
  ///
  /// In ko, this message translates to:
  /// **'다음 기간'**
  String get reportNext;

  /// No description provided for @reportToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get reportToday;

  /// No description provided for @reportSummaryTitle.
  ///
  /// In ko, this message translates to:
  /// **'기간 요약'**
  String get reportSummaryTitle;

  /// No description provided for @reportLoggedDays.
  ///
  /// In ko, this message translates to:
  /// **'{recorded}/{total}일 기록'**
  String reportLoggedDays(int recorded, int total);

  /// No description provided for @reportGoalOver.
  ///
  /// In ko, this message translates to:
  /// **'목표 {goal} kcal · {amount} kcal 초과'**
  String reportGoalOver(String goal, String amount);

  /// No description provided for @reportGoalLeft.
  ///
  /// In ko, this message translates to:
  /// **'목표 {goal} kcal · {amount} kcal 남음'**
  String reportGoalLeft(String goal, String amount);

  /// No description provided for @reportGoalElapsedNote.
  ///
  /// In ko, this message translates to:
  /// **'목표는 지금까지 지난 {days}일 기준이에요'**
  String reportGoalElapsedNote(int days);

  /// No description provided for @reportDailyAverage.
  ///
  /// In ko, this message translates to:
  /// **'기록일 평균'**
  String get reportDailyAverage;

  /// No description provided for @reportMealTypeDayTitle.
  ///
  /// In ko, this message translates to:
  /// **'끼니별 섭취'**
  String get reportMealTypeDayTitle;

  /// No description provided for @reportDailyTrend.
  ///
  /// In ko, this message translates to:
  /// **'일별 추이'**
  String get reportDailyTrend;

  /// No description provided for @reportGoalLine.
  ///
  /// In ko, this message translates to:
  /// **'목표 {goal}'**
  String reportGoalLine(String goal);

  /// No description provided for @reportTapDayHint.
  ///
  /// In ko, this message translates to:
  /// **'막대를 누르면 그날 기록을 볼 수 있어요'**
  String get reportTapDayHint;

  /// No description provided for @reportBarSemantics.
  ///
  /// In ko, this message translates to:
  /// **'{date} {kcal}'**
  String reportBarSemantics(String date, String kcal);

  /// No description provided for @reportNoRecordsToShow.
  ///
  /// In ko, this message translates to:
  /// **'표시할 기록이 없습니다'**
  String get reportNoRecordsToShow;

  /// No description provided for @reportRecordedFoods.
  ///
  /// In ko, this message translates to:
  /// **'기록된 음식'**
  String get reportRecordedFoods;

  /// No description provided for @reportNoRecordsForPeriod.
  ///
  /// In ko, this message translates to:
  /// **'이 기간에 기록이 없어요'**
  String get reportNoRecordsForPeriod;

  /// No description provided for @reportAddForDay.
  ///
  /// In ko, this message translates to:
  /// **'이 날짜에 기록 추가'**
  String get reportAddForDay;

  /// No description provided for @reportShowLess.
  ///
  /// In ko, this message translates to:
  /// **'접기'**
  String get reportShowLess;

  /// No description provided for @reportShowAll.
  ///
  /// In ko, this message translates to:
  /// **'모두 보기 ({count})'**
  String reportShowAll(int count);

  /// No description provided for @chatRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get chatRetry;

  /// No description provided for @chatOfflineAnswer.
  ///
  /// In ko, this message translates to:
  /// **'오프라인 기본 답변'**
  String get chatOfflineAnswer;

  /// No description provided for @chatCopied.
  ///
  /// In ko, this message translates to:
  /// **'답변을 복사했어요'**
  String get chatCopied;

  /// No description provided for @chatStatusOnline.
  ///
  /// In ko, this message translates to:
  /// **'AI 연결됨'**
  String get chatStatusOnline;

  /// No description provided for @chatStatusOffline.
  ///
  /// In ko, this message translates to:
  /// **'오프라인 모드'**
  String get chatStatusOffline;

  /// No description provided for @chatOfflineBanner.
  ///
  /// In ko, this message translates to:
  /// **'AI 서버에 연결되지 않아 기본 팁으로 답변해요. 맞춤 코칭은 연결 후 이용할 수 있어요.'**
  String get chatOfflineBanner;

  /// No description provided for @chatSend.
  ///
  /// In ko, this message translates to:
  /// **'보내기'**
  String get chatSend;

  /// No description provided for @unitYears.
  ///
  /// In ko, this message translates to:
  /// **'세'**
  String get unitYears;

  /// No description provided for @settingsTheme.
  ///
  /// In ko, this message translates to:
  /// **'화면 테마'**
  String get settingsTheme;

  /// No description provided for @themeSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 화면 밝기를 선택하세요'**
  String get themeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @settingsAiStatus.
  ///
  /// In ko, this message translates to:
  /// **'AI 기능 상태'**
  String get settingsAiStatus;

  /// No description provided for @aiStatusAvailable.
  ///
  /// In ko, this message translates to:
  /// **'사용 가능'**
  String get aiStatusAvailable;

  /// No description provided for @aiStatusUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'연결 안 됨'**
  String get aiStatusUnavailable;

  /// No description provided for @aiStatusChecking.
  ///
  /// In ko, this message translates to:
  /// **'확인 중'**
  String get aiStatusChecking;

  /// No description provided for @aiStatusAvailableBody.
  ///
  /// In ko, this message translates to:
  /// **'사진 인식, AI 영양 분석, AI 코치를 사용할 수 있어요.'**
  String get aiStatusAvailableBody;

  /// No description provided for @aiStatusUnavailableBody.
  ///
  /// In ko, this message translates to:
  /// **'지금은 AI 서버에 연결되지 않아요. 내장 음식 DB 검색, 직접 입력, 리포트는 그대로 사용할 수 있어요.'**
  String get aiStatusUnavailableBody;

  /// No description provided for @aiStatusDeveloperDetails.
  ///
  /// In ko, this message translates to:
  /// **'개발자 정보 (디버그 빌드)'**
  String get aiStatusDeveloperDetails;

  /// No description provided for @authDeleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제'**
  String get authDeleteAccount;

  /// No description provided for @authDeleteAccountTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정을 삭제할까요?'**
  String get authDeleteAccountTitle;

  /// No description provided for @authDeleteAccountMessage.
  ///
  /// In ko, this message translates to:
  /// **'계정과 클라우드에 저장된 프로필, 식단 기록, 사진이 영구 삭제되고 이 기기의 데이터도 초기화됩니다. 되돌릴 수 없습니다.'**
  String get authDeleteAccountMessage;

  /// No description provided for @authDeleteAccountConfirm.
  ///
  /// In ko, this message translates to:
  /// **'영구 삭제'**
  String get authDeleteAccountConfirm;

  /// No description provided for @authDeleteAccountDone.
  ///
  /// In ko, this message translates to:
  /// **'계정이 삭제되었습니다'**
  String get authDeleteAccountDone;

  /// No description provided for @authDeleteAccountFailed.
  ///
  /// In ko, this message translates to:
  /// **'계정을 삭제하지 못했습니다. 네트워크 연결을 확인한 뒤 다시 시도해주세요.'**
  String get authDeleteAccountFailed;

  /// No description provided for @profileLatestLogBasis.
  ///
  /// In ko, this message translates to:
  /// **'최근 기록 기준'**
  String get profileLatestLogBasis;

  /// No description provided for @weightTitle.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록'**
  String get weightTitle;

  /// No description provided for @weightLog.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get weightLog;

  /// No description provided for @weightLogTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘 체중 기록'**
  String get weightLogTitle;

  /// No description provided for @weightDeltaFromStart.
  ///
  /// In ko, this message translates to:
  /// **'시작 대비 {delta} kg'**
  String weightDeltaFromStart(String delta);

  /// No description provided for @weightNoRecords.
  ///
  /// In ko, this message translates to:
  /// **'아직 체중 기록이 없어요. 같은 시간대에 꾸준히 기록하면 추이를 볼 수 있어요.'**
  String get weightNoRecords;

  /// No description provided for @weightLastLogged.
  ///
  /// In ko, this message translates to:
  /// **'마지막 기록 {date}'**
  String weightLastLogged(String date);

  /// No description provided for @weightTrendSemantics.
  ///
  /// In ko, this message translates to:
  /// **'최근 {count}회 체중 추이 그래프'**
  String weightTrendSemantics(int count);

  /// No description provided for @weightHistoryTitle.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록 내역'**
  String get weightHistoryTitle;

  /// No description provided for @weightLogged.
  ///
  /// In ko, this message translates to:
  /// **'체중을 기록했어요'**
  String get weightLogged;

  /// No description provided for @weightDeleted.
  ///
  /// In ko, this message translates to:
  /// **'체중 기록을 삭제했어요'**
  String get weightDeleted;

  /// No description provided for @weightRecalculateSuggestion.
  ///
  /// In ko, this message translates to:
  /// **'체중 변화로 권장 칼로리가 {kcal} kcal로 바뀌었어요'**
  String weightRecalculateSuggestion(String kcal);

  /// No description provided for @weightRecalculateApply.
  ///
  /// In ko, this message translates to:
  /// **'목표 갱신'**
  String get weightRecalculateApply;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingDecreaseCalories.
  ///
  /// In ko, this message translates to:
  /// **'목표 칼로리 50 kcal 낮추기'**
  String get onboardingDecreaseCalories;

  /// No description provided for @onboardingIncreaseCalories.
  ///
  /// In ko, this message translates to:
  /// **'목표 칼로리 50 kcal 높이기'**
  String get onboardingIncreaseCalories;

  /// No description provided for @onboardingResetRecommended.
  ///
  /// In ko, this message translates to:
  /// **'권장값 {kcal} kcal로 되돌리기'**
  String onboardingResetRecommended(String kcal);

  /// No description provided for @onboardingTargetWeightDescription.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중의 약 5% 감량을 기본으로 {date}까지 목표로 잡았어요. 조정할 수 있어요.'**
  String onboardingTargetWeightDescription(String date);

  /// No description provided for @onboardingDecreaseTarget.
  ///
  /// In ko, this message translates to:
  /// **'목표 체중 0.5kg 낮추기'**
  String get onboardingDecreaseTarget;

  /// No description provided for @onboardingIncreaseTarget.
  ///
  /// In ko, this message translates to:
  /// **'목표 체중 0.5kg 높이기'**
  String get onboardingIncreaseTarget;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
