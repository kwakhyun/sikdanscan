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

  /// No description provided for @commonEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get commonEdit;

  /// No description provided for @commonOnline.
  ///
  /// In ko, this message translates to:
  /// **'온라인'**
  String get commonOnline;

  /// No description provided for @commonLoading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중'**
  String get commonLoading;

  /// No description provided for @commonAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'분석 중'**
  String get commonAnalyzing;

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

  /// No description provided for @settingsNotifications.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get settingsNotifications;

  /// No description provided for @settingsDarkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get settingsDarkMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguage;

  /// No description provided for @settingsApiStatus.
  ///
  /// In ko, this message translates to:
  /// **'API 연결 상태'**
  String get settingsApiStatus;

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

  /// No description provided for @languageChanged.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정이 변경되었습니다'**
  String get languageChanged;

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

  /// No description provided for @apiChecking.
  ///
  /// In ko, this message translates to:
  /// **'프록시 상태를 확인하고 있습니다.'**
  String get apiChecking;

  /// No description provided for @apiCheckFailed.
  ///
  /// In ko, this message translates to:
  /// **'프록시 상태 확인 중 오류가 발생했습니다.'**
  String get apiCheckFailed;

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

  /// No description provided for @apiConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결됨'**
  String get apiConnected;

  /// No description provided for @apiProxyRequired.
  ///
  /// In ko, this message translates to:
  /// **'프록시 필요'**
  String get apiProxyRequired;

  /// No description provided for @apiCheckingShort.
  ///
  /// In ko, this message translates to:
  /// **'확인 중'**
  String get apiCheckingShort;

  /// No description provided for @apiNotConfigured.
  ///
  /// In ko, this message translates to:
  /// **'미설정'**
  String get apiNotConfigured;

  /// No description provided for @apiOffline.
  ///
  /// In ko, this message translates to:
  /// **'오프라인'**
  String get apiOffline;

  /// No description provided for @apiBuiltInDb.
  ///
  /// In ko, this message translates to:
  /// **'내장 DB (80+ 음식)'**
  String get apiBuiltInDb;

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

  /// No description provided for @apiBarcode.
  ///
  /// In ko, this message translates to:
  /// **'바코드 검색 (Open Food Facts)'**
  String get apiBarcode;

  /// No description provided for @apiSecurityNote.
  ///
  /// In ko, this message translates to:
  /// **'앱 .env에는 프록시 URL과 선택적 클라이언트 토큰만 두고, 외부 API 키는 서버에 보관하세요.'**
  String get apiSecurityNote;

  /// No description provided for @resetTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터 초기화'**
  String get resetTitle;

  /// No description provided for @resetMessage.
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 초기화하시겠습니까?'**
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

  /// No description provided for @dashboardCapture.
  ///
  /// In ko, this message translates to:
  /// **'촬영'**
  String get dashboardCapture;

  /// No description provided for @dashboardCaptureNow.
  ///
  /// In ko, this message translates to:
  /// **'바로 촬영'**
  String get dashboardCaptureNow;

  /// No description provided for @dashboardCaptureNowSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'카메라로 음식 사진을 찍고 즉시 분석합니다'**
  String get dashboardCaptureNowSubtitle;

  /// No description provided for @dashboardPickPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 선택'**
  String get dashboardPickPhoto;

  /// No description provided for @dashboardPickPhotoSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'앨범의 음식 사진을 선택해 분석합니다'**
  String get dashboardPickPhotoSubtitle;

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

  /// No description provided for @dashboardAddedEstimated.
  ///
  /// In ko, this message translates to:
  /// **'추정 결과를 오늘 기록에 추가했습니다'**
  String get dashboardAddedEstimated;

  /// No description provided for @dashboardAddedAnalyzed.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과를 오늘 기록에 추가했습니다'**
  String get dashboardAddedAnalyzed;

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

  /// No description provided for @addMealRecognitionAdded.
  ///
  /// In ko, this message translates to:
  /// **'인식 결과를 선택 목록에 추가했습니다. 저장 전 확인해 주세요'**
  String get addMealRecognitionAdded;

  /// No description provided for @addMealRecognitionTitle.
  ///
  /// In ko, this message translates to:
  /// **'사진으로 자동 인식'**
  String get addMealRecognitionTitle;

  /// No description provided for @addMealRecognitionSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'음식 사진을 찍으면 영양 정보를 추정해 선택 목록에 추가합니다'**
  String get addMealRecognitionSubtitle;

  /// No description provided for @addMealAnalyzingPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진을 분석하고 있습니다'**
  String get addMealAnalyzingPhoto;

  /// No description provided for @addMealRecognitionResult.
  ///
  /// In ko, this message translates to:
  /// **'사진 인식 결과'**
  String get addMealRecognitionResult;

  /// No description provided for @addMealSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'음식을 검색하세요 (예: 김치찌개, 아사이볼, 연어 포케)'**
  String get addMealSearchHint;

  /// No description provided for @addMealSelectedFoods.
  ///
  /// In ko, this message translates to:
  /// **'선택된 음식'**
  String get addMealSelectedFoods;

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
  /// **'첫 식사를 스캔해 전략을 시작하세요'**
  String get strategyEmptyTitle;

  /// No description provided for @strategyEmptyPrimary.
  ///
  /// In ko, this message translates to:
  /// **'음식 사진을 촬영하면 목표별 코칭이 생성됩니다.'**
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

  /// No description provided for @reportDailySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'하루 섭취 상태'**
  String get reportDailySubtitle;

  /// No description provided for @reportWeeklySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'7일 섭취 흐름'**
  String get reportWeeklySubtitle;

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
  /// **'30초 안에 간편 가입'**
  String get onboardingBenefitQuickTitle;

  /// No description provided for @onboardingBenefitQuickDescription.
  ///
  /// In ko, this message translates to:
  /// **'이름과 기준 정보만 입력하면 바로 시작합니다.'**
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
  /// **'목표별 AI 코칭'**
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

  /// No description provided for @goalStepTarget.
  ///
  /// In ko, this message translates to:
  /// **'걸음 목표'**
  String get goalStepTarget;

  /// No description provided for @goalStepSuffix.
  ///
  /// In ko, this message translates to:
  /// **'걸음'**
  String get goalStepSuffix;

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
