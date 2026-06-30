// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '식단스캔 - AI 식단 코치';

  @override
  String get brandName => '식단스캔';

  @override
  String get navDaily => '데일리';

  @override
  String get navReport => '리포트';

  @override
  String get navAiCoach => 'AI 코치';

  @override
  String get navProfile => '프로필';

  @override
  String get commonCancel => '취소';

  @override
  String get commonSave => '저장';

  @override
  String get commonNext => '다음';

  @override
  String get commonBack => '뒤로가기';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEdit => '수정';

  @override
  String get commonOnline => '온라인';

  @override
  String get commonLoading => '로딩 중';

  @override
  String get commonAnalyzing => '분석 중';

  @override
  String get authCloudNotConfiguredTitle => '클라우드 동기화 미설정';

  @override
  String get authCloudNotConfiguredSubtitle =>
      'Supabase URL과 publishable key를 설정하면 계정 동기화를 사용할 수 있습니다.';

  @override
  String get authCloudSignedOutTitle => '계정으로 데이터 동기화';

  @override
  String get authCloudSignedOutSubtitle =>
      '프로필과 식단 기록을 Supabase에 백업하고 기기 변경 시 복원합니다.';

  @override
  String get authCloudSignedInTitle => '클라우드 동기화 활성화';

  @override
  String get authCloudSignedInSubtitle => '계정으로 로그인되어 있습니다.';

  @override
  String get authSignIn => '로그인';

  @override
  String get authSignUp => '회원가입';

  @override
  String get authSignInOrSignUp => '로그인 / 가입';

  @override
  String get authSignOut => '로그아웃';

  @override
  String get authSyncNow => '지금 동기화';

  @override
  String get authSignInTitle => '계정 로그인';

  @override
  String get authSignUpTitle => '계정 만들기';

  @override
  String get authSheetSubtitle => '로그인하면 현재 기기의 프로필과 식단 기록을 Supabase와 동기화합니다.';

  @override
  String get authDisplayName => '이름';

  @override
  String get authEmail => '이메일';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authSubmitSignIn => '로그인하기';

  @override
  String get authSubmitSignUp => '가입하고 동기화';

  @override
  String get authInvalidInput => '이메일과 8자 이상 비밀번호를 입력해주세요.';

  @override
  String get authSignInDone => '로그인되었습니다.';

  @override
  String get authSignUpDone => '가입되었습니다. 이메일 인증이 필요한 경우 메일함을 확인해주세요.';

  @override
  String get authSignOutDone => '로그아웃되었습니다.';

  @override
  String get authSyncDone => '동기화가 완료되었습니다.';

  @override
  String get authFailed => '계정 처리 중 오류가 발생했습니다.';

  @override
  String get authSocialDivider => '또는';

  @override
  String get authContinueWithGoogle => 'Google로 계속하기';

  @override
  String get authContinueWithKakao => '카카오로 계속하기';

  @override
  String get authContinueWithApple => 'Apple로 계속하기';

  @override
  String get authOAuthStarted => '브라우저에서 로그인을 완료한 뒤 앱으로 돌아와주세요.';

  @override
  String get authOAuthDone => '소셜 로그인되었습니다.';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsEditProfile => '프로필 편집';

  @override
  String get settingsGoal => '목표 설정';

  @override
  String get settingsNotifications => '알림 설정';

  @override
  String get settingsDarkMode => '다크 모드';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsApiStatus => 'API 연결 상태';

  @override
  String get settingsExportData => '데이터 내보내기';

  @override
  String get settingsAppInfo => '앱 정보';

  @override
  String get settingsResetData => '데이터 초기화';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSubtitle => '앱 표시 언어를 선택하세요';

  @override
  String get languageSystem => '시스템 언어';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChanged => '언어 설정이 변경되었습니다';

  @override
  String get exportSubject => '식단스캔 데이터 내보내기';

  @override
  String get exportText => '식단스캔 앱 데이터가 첨부되었습니다.';

  @override
  String get exportFailed => '데이터 내보내기 실패';

  @override
  String get appInfoDescription =>
      'AI 기반 식단 분석과 목표별 전략 코칭\n\n사진으로 식단을 기록하고 피부·감량·장 건강 등\n원하는 개선 방향에 맞춰 다음 식사를 설계하세요.';

  @override
  String get apiChecking => '프록시 상태를 확인하고 있습니다.';

  @override
  String get apiCheckFailed => '프록시 상태 확인 중 오류가 발생했습니다.';

  @override
  String get apiRefresh => '새로고침';

  @override
  String get apiOk => '확인';

  @override
  String get apiConnected => '연결됨';

  @override
  String get apiProxyRequired => '프록시 필요';

  @override
  String get apiCheckingShort => '확인 중';

  @override
  String get apiNotConfigured => '미설정';

  @override
  String get apiOffline => '오프라인';

  @override
  String get apiBuiltInDb => '내장 DB (80+ 음식)';

  @override
  String get apiProxy => '식단스캔 API 프록시';

  @override
  String get apiPublicFoodDb => '식약처 식품영양정보';

  @override
  String get apiOpenAi => 'OpenAI GPT 분석';

  @override
  String get apiBarcode => '바코드 검색 (Open Food Facts)';

  @override
  String get apiSecurityNote =>
      '앱 .env에는 프록시 URL과 선택적 클라이언트 토큰만 두고, 외부 API 키는 서버에 보관하세요.';

  @override
  String get resetTitle => '데이터 초기화';

  @override
  String get resetMessage =>
      '모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.\n\n정말 초기화하시겠습니까?';

  @override
  String get resetAction => '초기화';

  @override
  String get resetDone => '데이터가 초기화되었습니다';

  @override
  String get profileFallbackNeedsSetup => '설정 필요';

  @override
  String get profileBodyNotConfigured => '맞춤 설정 전';

  @override
  String get profileEditTooltip => '내 정보 수정';

  @override
  String get profileCurrentWeight => '현재 체중';

  @override
  String get profileInitialInputBasis => '가입 시 입력 기준';

  @override
  String get profileDailyGoal => '일일 목표';

  @override
  String get profileWellnessGoal => '개선 목표';

  @override
  String get profileCalorieBasisTitle => '일일 목표 칼로리 기준';

  @override
  String get profileCalorieBasisCustom => '직접 조정된 목표입니다';

  @override
  String get profileCalorieBasisAuto => '가입 시 자동 계산된 목표입니다';

  @override
  String get profileEditTitle => '내 정보 수정';

  @override
  String get profileEditSubtitle => '맞춤 분석에 쓰이는 기본 정보입니다';

  @override
  String get profilePhotoAdd => '프로필 사진 추가';

  @override
  String get profilePhotoChange => '프로필 사진 변경';

  @override
  String get profilePhotoGallery => '앨범에서 선택';

  @override
  String get profilePhotoCamera => '카메라로 촬영';

  @override
  String get profilePhotoDelete => '사진 삭제';

  @override
  String get profileName => '이름';

  @override
  String get profileAge => '나이';

  @override
  String get profileHeight => '키';

  @override
  String get profileGender => '성별';

  @override
  String get profileMale => '남성';

  @override
  String get profileFemale => '여성';

  @override
  String get profileSave => '저장하기';

  @override
  String get profileValidationError => '모든 항목을 올바르게 입력해주세요';

  @override
  String get profileUpdated => '프로필이 업데이트되었습니다';

  @override
  String get dashboardCapture => '촬영';

  @override
  String get dashboardCaptureNow => '바로 촬영';

  @override
  String get dashboardCaptureNowSubtitle => '카메라로 음식 사진을 찍고 즉시 분석합니다';

  @override
  String get dashboardPickPhoto => '사진 선택';

  @override
  String get dashboardPickPhotoSubtitle => '앨범의 음식 사진을 선택해 분석합니다';

  @override
  String get dashboardProxyRequired => '사진 인식은 식단스캔 API 프록시 연결 후 사용할 수 있습니다';

  @override
  String get dashboardNoFoodFound => '사진에서 음식을 찾을 수 없습니다. 다시 촬영하거나 직접 검색해 주세요';

  @override
  String get dashboardRecognitionError => '사진 인식 중 오류가 발생했습니다';

  @override
  String get dashboardCameraFallback => '카메라를 사용할 수 없어 앨범에서 사진을 선택해주세요';

  @override
  String get dashboardPhotoPermissionError =>
      '사진을 불러올 수 없습니다. 카메라/사진 권한을 확인해주세요';

  @override
  String get dashboardAddedEstimated => '추정 결과를 오늘 기록에 추가했습니다';

  @override
  String get dashboardAddedAnalyzed => '분석 결과를 오늘 기록에 추가했습니다';

  @override
  String get addMealTitle => '식단 추가';

  @override
  String get addMealSearchError => '검색 중 오류가 발생했습니다';

  @override
  String get addMealRecognitionAdded => '인식 결과를 선택 목록에 추가했습니다. 저장 전 확인해 주세요';

  @override
  String get addMealRecognitionTitle => '사진으로 자동 인식';

  @override
  String get addMealRecognitionSubtitle => '음식 사진을 찍으면 영양 정보를 추정해 선택 목록에 추가합니다';

  @override
  String get addMealAnalyzingPhoto => '사진을 분석하고 있습니다';

  @override
  String get addMealRecognitionResult => '사진 인식 결과';

  @override
  String get addMealSearchHint => '음식을 검색하세요 (예: 김치찌개, 아사이볼, 연어 포케)';

  @override
  String get addMealSelectedFoods => '선택된 음식';

  @override
  String get addMealRetry => '다시 시도';

  @override
  String get addMealNoSearchResults => '검색 결과가 없습니다';

  @override
  String get addMealSourceBuiltInDb => '내장 데이터베이스';

  @override
  String get addMealSourcePublicFoodDb => '식약처 식품영양정보';

  @override
  String get addMealPublicData => '공공데이터';

  @override
  String get dailyOverviewTitle => '오늘 섭취 현황';

  @override
  String get dailyNutrition => '영양소';

  @override
  String get dailyCarbs => '탄수';

  @override
  String get dailyProtein => '단백질';

  @override
  String get dailyFat => '지방';

  @override
  String get dailyRecords => '오늘 기록';

  @override
  String get dailyNoRecords => '아직 기록된 음식이 없습니다';

  @override
  String get strategyEmptyTitle => '첫 식사를 스캔해 전략을 시작하세요';

  @override
  String get strategyEmptyPrimary => '음식 사진을 촬영하면 목표별 코칭이 생성됩니다.';

  @override
  String get reportTitle => '섭취 리포트';

  @override
  String get reportDay => '일일';

  @override
  String get reportWeek => '주간';

  @override
  String get reportMonth => '월간';

  @override
  String get reportDailySubtitle => '하루 섭취 상태';

  @override
  String get reportWeeklySubtitle => '7일 섭취 흐름';

  @override
  String get chatTitle => '식단스캔 AI 코치';

  @override
  String get chatTyping => '답변 작성 중...';

  @override
  String get chatClearTitle => '대화 초기화';

  @override
  String get chatClearMessage => '모든 대화 내용이 삭제됩니다.\n정말 초기화하시겠습니까?';

  @override
  String get chatClearAction => '초기화';

  @override
  String get chatInputHint => '무엇이든 물어보세요...';

  @override
  String get chatWelcome =>
      '안녕하세요. 저는 식단스캔 AI 코치입니다.\n\n오늘 식단이나 목표별 개선 전략에 대해 궁금한 점이 있으신가요?';

  @override
  String get chatTemporaryError => '죄송해요, 일시적인 오류가 발생했어요.\n다시 질문해주시면 답변드릴게요!';

  @override
  String get suggestionCalories => '오늘 칼로리 분석';

  @override
  String get suggestionExercise => '운동 추천해줘';

  @override
  String get suggestionWater => '수분 섭취 팁';

  @override
  String get suggestionWeight => '체중 변화 분석';

  @override
  String get suggestionSnack => '건강한 간식 추천';

  @override
  String get onboardingStartTitle => '식단스캔 시작하기';

  @override
  String get onboardingStartSubtitle =>
      '사진으로 식단을 기록하고, 피부·감량·장 건강 같은 목표에 맞춰 다음 식사를 바로 조정합니다.';

  @override
  String get onboardingQuickStart => '간편 가입하고 시작';

  @override
  String get onboardingGoalTitle => '어떤 변화를 원하시나요?';

  @override
  String get onboardingGoalSubtitle =>
      '식단스캔은 선택한 목표를 기준으로 오늘의 식단과 다음 끼니 전략을 다르게 제안합니다.';

  @override
  String get onboardingMetricsTitle => '맞춤 기준을 만들게요';

  @override
  String get onboardingMetricsSubtitle =>
      '현재 체중과 활동량은 목표 칼로리, 수분 기준, 단백질 전략 계산에 사용됩니다.';

  @override
  String get onboardingReviewTitle => '이 기준으로 시작합니다';

  @override
  String get onboardingReviewSubtitle => '나중에 프로필에서 언제든 다시 조정할 수 있습니다.';

  @override
  String get onboardingStartFlow => '맞춤 플로우 시작';

  @override
  String get onboardingBenefitQuickTitle => '30초 안에 간편 가입';

  @override
  String get onboardingBenefitQuickDescription => '이름과 기준 정보만 입력하면 바로 시작합니다.';

  @override
  String get onboardingBenefitCalorieTitle => '일일 칼로리 자동 산정';

  @override
  String get onboardingBenefitCalorieDescription =>
      '현재 체중, 키, 나이, 활동량으로 기준을 계산합니다.';

  @override
  String get onboardingBenefitCoachTitle => '목표별 AI 코칭';

  @override
  String get onboardingBenefitCoachDescription =>
      '사용자가 원하는 개선 방향에 맞춰 식단 전략을 제공합니다.';

  @override
  String get onboardingNickname => '닉네임';

  @override
  String get onboardingNicknameHint => '예: 지현';

  @override
  String get onboardingActivityTitle => '평소 활동량';

  @override
  String get onboardingTargetCalories => '일일 목표 칼로리';

  @override
  String get onboardingNeedsCalculation => '계산 필요';

  @override
  String get onboardingCheckInputs => '입력값을 확인해주세요.';

  @override
  String get onboardingWaterBasis => '수분 기준';

  @override
  String get onboardingWaterBasisDescription =>
      '현재 체중 × 30ml를 100ml 단위로 반올림합니다.';

  @override
  String get onboardingReviewInfo =>
      '식단스캔의 칼로리는 고정 더미 값이 아니라 입력한 신체 정보와 목표에 따라 자동 계산됩니다.';

  @override
  String get onboardingValidationAge => '나이를 10~100 사이로 입력해주세요.';

  @override
  String get onboardingValidationHeight => '키를 100~230cm 사이로 입력해주세요.';

  @override
  String get onboardingValidationWeight => '현재 체중을 30~250kg 사이로 입력해주세요.';

  @override
  String get onboardingSaveFailed => '프로필 저장에 실패했습니다. 다시 시도해주세요.';

  @override
  String get defaultUserName => '식단스캔 사용자';

  @override
  String get goalSettingsTitle => '목표 설정';

  @override
  String get goalSettingsSubtitle => '나만의 건강 목표를 세워보세요';

  @override
  String get goalTargetWeight => '목표 체중';

  @override
  String get goalCalorieTarget => '일일 칼로리 목표';

  @override
  String get goalWaterTarget => '수분 목표';

  @override
  String get goalStepTarget => '걸음 목표';

  @override
  String get goalStepSuffix => '걸음';

  @override
  String get goalSettingsDone => '목표 설정 완료';

  @override
  String get goalActivityTitle => '활동량';

  @override
  String get goalRecommendation => '추천';

  @override
  String get goalApply => '적용';

  @override
  String get goalDirectionTitle => '개선 방향';

  @override
  String get goalTargetDate => '목표 날짜';

  @override
  String get goalSelectDate => '날짜를 선택하세요';

  @override
  String get goalUpdated => '목표가 업데이트되었습니다';

  @override
  String get goalBalancedDescription => '식단 균형과 꾸준한 기록을 유지';

  @override
  String get goalWeightLossDescription => '칼로리 과잉을 줄이고 포만감을 높이는 전략';

  @override
  String get goalSkinHealthDescription => '당류·지방 편중을 낮추고 회복 영양소 보강';

  @override
  String get goalDigestionDescription => '식이섬유와 수분 중심의 소화 컨디션 관리';

  @override
  String get goalEnergyDescription => '끼니 균형과 혈당 변동을 줄이는 에너지 관리';

  @override
  String get goalMuscleDescription => '체중과 활동량에 맞춘 단백질 섭취 최적화';

  @override
  String get goalGlucoseDescription => '탄수화물 비중과 식사 순서를 관리';

  @override
  String get activityLightDescription => '대부분 앉아서 생활하거나 가벼운 걷기 위주';

  @override
  String get activityModerateDescription => '주 2~4회 운동 또는 하루 이동량이 있는 편';

  @override
  String get activityActiveDescription => '주 5회 이상 운동하거나 활동량이 많은 편';

  @override
  String get goalBalanced => '균형 관리';

  @override
  String get goalWeightLoss => '체중 감량';

  @override
  String get goalSkinHealth => '피부 개선';

  @override
  String get goalDigestion => '장 건강';

  @override
  String get goalEnergy => '컨디션 개선';

  @override
  String get goalMuscle => '단백질 보강';

  @override
  String get goalGlucose => '혈당 안정';

  @override
  String get activityLight => '가벼운 활동';

  @override
  String get activityModerate => '보통 활동';

  @override
  String get activityActive => '활동적';
}
