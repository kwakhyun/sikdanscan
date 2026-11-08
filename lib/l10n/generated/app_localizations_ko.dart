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
  String get settingsLanguage => '언어';

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
  String get exportSubject => '식단스캔 데이터 내보내기';

  @override
  String get exportText => '식단스캔 앱 데이터가 첨부되었습니다.';

  @override
  String get exportFailed => '데이터 내보내기 실패';

  @override
  String get appInfoDescription =>
      'AI 기반 식단 분석과 목표별 전략 코칭\n\n사진으로 식단을 기록하고 피부·감량·장 건강 등\n원하는 개선 방향에 맞춰 다음 식사를 설계하세요.';

  @override
  String get apiRefresh => '새로고침';

  @override
  String get apiOk => '확인';

  @override
  String get apiProxy => '식단스캔 API 프록시';

  @override
  String get apiPublicFoodDb => '식약처 식품영양정보';

  @override
  String get apiOpenAi => 'OpenAI GPT 분석';

  @override
  String get resetTitle => '데이터 초기화';

  @override
  String get resetMessage =>
      '이 기기의 프로필, 식단·체중·수분 기록, AI 코치 대화가 모두 삭제됩니다. 로그인 중이라면 로그아웃되며, 클라우드에 백업된 데이터는 계정에 그대로 남습니다.\n\n정말 초기화하시겠습니까?';

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
  String get dashboardProxyRequired =>
      '지금은 사진 분석을 사용할 수 없어요. 음식을 검색하거나 직접 입력해 주세요';

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
  String get addMealTitle => '식단 추가';

  @override
  String get addMealSearchError => '검색 중 오류가 발생했습니다';

  @override
  String get addMealSearchHint => '음식을 검색하세요 (예: 김치찌개, 아사이볼, 연어 포케)';

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
  String get strategyEmptyTitle => '첫 식사를 기록해 전략을 시작하세요';

  @override
  String get strategyEmptyPrimary => '음식 사진을 찍거나 검색해 기록하면 목표별 코칭이 생성됩니다.';

  @override
  String get reportTitle => '섭취 리포트';

  @override
  String get reportDay => '일일';

  @override
  String get reportWeek => '주간';

  @override
  String get reportMonth => '월간';

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
  String get onboardingBenefitQuickTitle => '30초 만에 시작';

  @override
  String get onboardingBenefitQuickDescription =>
      '목표와 기본 정보만 입력하면 바로 기록을 시작합니다.';

  @override
  String get onboardingBenefitCalorieTitle => '일일 칼로리 자동 산정';

  @override
  String get onboardingBenefitCalorieDescription =>
      '현재 체중, 키, 나이, 활동량으로 기준을 계산합니다.';

  @override
  String get onboardingBenefitCoachTitle => '목표별 전략 · AI 코칭';

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

  @override
  String get addMealAiHint => 'DB에 없는 음식은 AI가 자동으로 영양 정보를 분석합니다';

  @override
  String get addMealAiAnalyzing => 'AI가 영양 정보를 분석하고 있어요...';

  @override
  String get addMealSourceAiResults => 'AI 영양 분석 결과';

  @override
  String get addMealAiTag => 'AI 분석';

  @override
  String get mealTypeBreakfast => '아침';

  @override
  String get mealTypeLunch => '점심';

  @override
  String get mealTypeDinner => '저녁';

  @override
  String get mealTypeSnack => '간식';

  @override
  String get mealDetailMealType => '식사 유형';

  @override
  String get mealDetailPortion => '분량 조절';

  @override
  String get mealDetailPortionHint => '처음 저장한 1인분을 기준으로 칼로리와 영양소를 다시 계산합니다';

  @override
  String get mealDetailDeleteTitle => '기록 삭제';

  @override
  String get mealDetailDeleted => '기록을 삭제했습니다';

  @override
  String get mealDetailUpdated => '기록을 수정했습니다';

  @override
  String get commonError => '오류가 발생했습니다. 다시 시도해주세요';

  @override
  String get reportMealTypeTitle => '식사 유형별 비중';

  @override
  String reportMealTypeRecords(int count) {
    return '$count건';
  }

  @override
  String get dailyStatusNone => '기록 전';

  @override
  String get dailyStatusRoom => '여유';

  @override
  String get dailyStatusOnTrack => '적정';

  @override
  String get dailyStatusCaution => '주의';

  @override
  String get dailyStatusOver => '초과';

  @override
  String get bmiUnknown => '알 수 없음';

  @override
  String get bmiUnderweight => '저체중';

  @override
  String get bmiNormal => '정상';

  @override
  String get bmiOverweight => '과체중';

  @override
  String get bmiObese => '비만';

  @override
  String get bmiSeverelyObese => '고도비만';

  @override
  String profileBasisRecommended(int kcal) {
    return '권장 $kcal kcal';
  }

  @override
  String profileBasisCurrent(int kcal) {
    return '현재 $kcal kcal';
  }

  @override
  String profileBasisWater(int ml) {
    return '수분 $ml ml';
  }

  @override
  String get calorieBasisNoAdjustment => '목표 보정 없음';

  @override
  String calorieBasisAdjustment(String amount) {
    return '$amount kcal 목표 보정';
  }

  @override
  String get startupErrorTitle => '앱을 시작할 수 없습니다';

  @override
  String get proxyStatusNotConfigured => '프록시 URL이 설정되지 않았습니다.';

  @override
  String get proxyStatusConnected => '프록시가 정상 응답했습니다.';

  @override
  String get proxyStatusUnexpectedResponse => '프록시가 예상과 다른 응답을 반환했습니다.';

  @override
  String get proxyStatusInvalidToken => '프록시 인증 토큰을 확인해주세요.';

  @override
  String get proxyStatusHealthMissing => '프록시 헬스체크 엔드포인트를 찾을 수 없습니다.';

  @override
  String get proxyStatusServerError => '프록시 서버가 정상 응답하지 않습니다.';

  @override
  String get proxyStatusUnreachable => '프록시에 연결할 수 없습니다.';

  @override
  String strategyMetaLabel(int count) {
    return '목표 전략 · 기록 $count개 반영';
  }

  @override
  String strategyEmptySummary(String goal) {
    return '$goal 목표에 맞춰 오늘 식단의 강점과 보완점을 정리해 드려요.';
  }

  @override
  String get strategyTipPhotoAngle => '음식이 잘 보이도록 위에서 촬영';

  @override
  String get strategyTipReviewBeforeSave => '저장 전 음식명과 양 확인';

  @override
  String get strategyWeightLossOverTitle => '남은 식사는 가볍게 보정하세요';

  @override
  String get strategyWeightLossOnTrackTitle => '감량 흐름은 유지 중입니다';

  @override
  String get strategyWeightLossOverSummary =>
      '오늘 목표 칼로리를 넘겼습니다. 다음 식사는 포만감 높은 단백질과 채소 중심이 좋습니다.';

  @override
  String get strategyWeightLossOnTrackSummary =>
      '현재 섭취량은 목표 범위 안입니다. 단백질을 채우면 야식 가능성을 줄일 수 있습니다.';

  @override
  String get strategyWeightLossAddProtein => '다음 식사에 닭가슴살, 달걀, 두부 중 하나를 추가하세요.';

  @override
  String get strategyWeightLossVeggiesFirst => '탄수화물 추가보다 채소와 수분을 먼저 보강하세요.';

  @override
  String get strategyActionSkipFriedSauce => '튀김·소스류는 다음 식사에서 제외';

  @override
  String get strategyActionLightProteinMeal => '남은 식사는 400kcal 안쪽의 단백질 식사로 조정';

  @override
  String get strategyActionWalkAppetite => '식사 후 10분 걷기로 혈당과 식욕 변동 완화';

  @override
  String get strategySkinFixTitle => '피부 목표 기준 보정이 필요합니다';

  @override
  String get strategySkinGoodTitle => '피부 친화적인 흐름입니다';

  @override
  String get strategySkinHighCarbSummary =>
      '탄수화물 비중이 높아 다음 식사는 혈당 변동을 줄이는 조합이 좋습니다.';

  @override
  String get strategySkinBalancedSummary =>
      '오늘 식단은 한쪽으로 치우치지 않았습니다. 항산화 식품을 더하면 좋습니다.';

  @override
  String get strategySkinPrimary => '다음 식사는 생선·두부·달걀 + 녹황색 채소 조합을 우선하세요.';

  @override
  String get strategyActionNoCreamy => '기름진 메뉴와 크림 소스는 오늘 추가하지 않기';

  @override
  String get strategyActionNoSugarDrinks => '디저트·당 음료 대신 물 또는 무가당 차 선택';

  @override
  String get strategyActionVitaminC => '비타민 C가 있는 과일은 한 번에 소량만 추가';

  @override
  String get strategyDigestionHeavyTitle => '소화 부담을 낮춰야 합니다';

  @override
  String get strategyDigestionGoodTitle => '장 건강 루틴을 이어가세요';

  @override
  String get strategyDigestionHeavySummary =>
      '지방 비중이 높으면 더부룩함이 생길 수 있습니다. 다음 식사는 담백하게 보정하세요.';

  @override
  String get strategyDigestionGoodSummary => '오늘은 수분과 식이섬유를 더하기 좋은 상태입니다.';

  @override
  String get strategyDigestionPrimary =>
      '채소 반 접시와 물 500ml를 다음 식사 전후로 나눠 보강하세요.';

  @override
  String get strategyActionSolidsOverBroth => '국물보다 건더기 중심으로 선택';

  @override
  String get strategyActionFermented => '요거트, 김치, 나물류 중 하나 추가';

  @override
  String get strategyActionSkipFattyMeat => '튀김·기름진 고기는 다음 식사에서 제외';

  @override
  String get strategyEnergyCarbTitle => '오후 에너지 변동을 줄이세요';

  @override
  String get strategyEnergyGoodTitle => '컨디션 유지에 좋은 균형입니다';

  @override
  String get strategyEnergyLowSummary => '섭취량이 낮아 오후 집중력 저하가 올 수 있습니다.';

  @override
  String get strategyEnergyGoodSummary => '끼니 균형을 유지하면 피로감과 간식 욕구를 줄일 수 있습니다.';

  @override
  String get strategyEnergyAddProtein => '단백질 간식 또는 달걀/두부를 추가하세요.';

  @override
  String get strategyEnergyPairCarbs => '다음 식사는 탄수화물 단독보다 단백질과 함께 구성하세요.';

  @override
  String get strategyActionWaterOverSweet => '단 음료 대신 물 또는 아메리카노 선택';

  @override
  String get strategyActionSmartSnack => '간식은 견과류 소량이나 그릭요거트로 선택';

  @override
  String get strategyActionStretch => '식후 5분 스트레칭으로 졸림 완화';

  @override
  String get strategyMuscleLowTitle => '단백질 보강이 우선입니다';

  @override
  String get strategyMuscleCloseTitle => '단백질 목표에 가까워지고 있습니다';

  @override
  String strategyMuscleSummary(String protein, String goal) {
    return '오늘 단백질은 ${protein}g, 목표는 ${goal}g입니다.';
  }

  @override
  String strategyMuscleAddProtein(String gap) {
    return '다음 식사에 단백질 ${gap}g 보강을 목표로 하세요.';
  }

  @override
  String get strategyMuscleRecovery => '운동 후에는 수분과 탄수화물을 소량 함께 보강하세요.';

  @override
  String get strategyActionLeanProtein => '닭가슴살·생선·두부·그릭요거트 중 하나 선택';

  @override
  String get strategyActionPreWorkoutSnack => '섭취량이 낮으니 운동 전후 간식을 추가';

  @override
  String get strategyActionSpreadProtein => '단백질은 한 끼에 몰지 말고 나눠 섭취';

  @override
  String get strategyGlucoseCarbTitle => '탄수화물 속도 조절이 필요합니다';

  @override
  String get strategyGlucoseGoodTitle => '혈당 안정 흐름입니다';

  @override
  String get strategyGlucoseCarbSummary =>
      '탄수화물 비중이 높습니다. 다음 식사는 식사 순서와 단백질 보강이 중요합니다.';

  @override
  String get strategyGlucoseGoodSummary => '현재 비율은 급격한 변동을 줄이기 좋은 편입니다.';

  @override
  String get strategyGlucosePrimary => '다음 식사는 채소 → 단백질 → 탄수화물 순서로 드세요.';

  @override
  String get strategyActionAddProteinSide => '밥/면 단독 식사는 피하고 단백질 반찬 추가';

  @override
  String get strategyActionWalk10 => '식후 10분 걷기';

  @override
  String get strategyActionNoDessert => '단 음료와 디저트는 오늘 추가하지 않기';

  @override
  String get strategyBalancedGoodTitle => '균형이 좋은 하루입니다';

  @override
  String get strategyBalancedFixTitle => '한쪽으로 치우친 영양소를 보정하세요';

  @override
  String get strategyBalancedGoodSummary => '현재 칼로리와 탄단지 흐름이 안정적입니다.';

  @override
  String get strategyBalancedFixSummary => '다음 식사에서 부족한 축을 보강하면 하루 균형이 좋아집니다.';

  @override
  String get strategyBalancedPrimary => '다음 식사는 단백질, 채소, 탄수화물을 한 접시에 함께 구성하세요.';

  @override
  String get strategyActionLogWater => '물 섭취도 함께 기록';

  @override
  String get strategyActionReviewRecords => '오늘 기록을 한 번 확인';

  @override
  String get strategyFactorCalories => '칼로리 범위';

  @override
  String get strategyFactorProtein => '단백질 충족';

  @override
  String get strategyFactorFat => '지방 비중';

  @override
  String get strategyFactorCarbs => '탄수화물 비중';

  @override
  String get strategyFactorBalance => '탄단지 균형';

  @override
  String get strategyFactorVolume => '식사량';

  @override
  String get strategyFactorConsistency => '기록 유지';

  @override
  String get strategyDetailTitle => '오늘의 목표 전략';

  @override
  String get strategyRuleBasedNote =>
      '오늘 기록한 칼로리와 탄단지 비율을 목표 기준과 비교해 계산한 결과입니다. 의학적 진단이 아닙니다.';

  @override
  String get strategyScoreTitle => '점수 기준';

  @override
  String strategyScoreSemantics(int score) {
    return '목표 점수 100점 만점에 $score점';
  }

  @override
  String get strategyNextMeal => '다음 식사 제안';

  @override
  String get strategyTips => '실천 팁';

  @override
  String get strategyAskCoach => 'AI 코치에게 물어보기';

  @override
  String get strategyAskCoachPrompt => '오늘 기록을 보고 다음 식사로 무엇을 먹으면 좋을지 알려줘';

  @override
  String get strategyOpenDetail => '전략 자세히 보기';

  @override
  String get commonClose => '닫기';

  @override
  String get commonClear => '지우기';

  @override
  String get commonUndo => '되돌리기';

  @override
  String commonItemCount(int count) {
    return '$count개';
  }

  @override
  String macroShort(String carbs, String protein, String fat) {
    return '탄 ${carbs}g · 단 ${protein}g · 지 ${fat}g';
  }

  @override
  String get entrySheetTitle => '식사 기록하기';

  @override
  String entrySheetTitleForDate(String date) {
    return '$date 기록 추가';
  }

  @override
  String get entryCamera => '사진 찍어 기록';

  @override
  String get entryCameraSubtitle => 'AI가 음식과 영양 정보를 추정하고, 저장 전에 확인할 수 있어요';

  @override
  String get entryGallery => '앨범에서 선택';

  @override
  String get entryGallerySubtitle => '찍어둔 음식 사진으로 기록해요';

  @override
  String get entrySearch => '검색 · 직접 입력';

  @override
  String get entrySearchSubtitle => '음식 이름으로 찾거나 영양 정보를 직접 입력해요 · 오프라인에서도 가능';

  @override
  String get entryPhotoUnavailable => '사진 인식은 AI 서버 연결 후 사용할 수 있어요';

  @override
  String get dashboardLogMeal => '식사 기록';

  @override
  String get reviewTitle => '기록 확인';

  @override
  String get reviewAnalyzingTitle => '사진 분석 중';

  @override
  String get reviewFailedTitle => '음식을 인식하지 못했어요';

  @override
  String get reviewAnalyzingMessage => '음식과 영양 정보를 추정하고 있어요';

  @override
  String get reviewAnalyzingHint =>
      '보통 5~15초 걸려요. 기다리기 어렵다면 직접 입력으로 전환할 수 있어요.';

  @override
  String get reviewSwitchToManual => '직접 입력으로 전환';

  @override
  String get reviewCancelAnalysis => '분석 취소';

  @override
  String get reviewRetry => '다시 분석';

  @override
  String get reviewSearchAdd => '검색해서 추가';

  @override
  String get reviewAddManual => '직접 추가';

  @override
  String get reviewNeedsReview => 'AI 추정치예요. 음식 이름과 양이 맞는지 확인한 뒤 저장해 주세요.';

  @override
  String get reviewLowConfidence => '확인 필요';

  @override
  String reviewConfidence(int percent) {
    return 'AI 신뢰도 $percent%';
  }

  @override
  String get reviewFoodsSection => '음식';

  @override
  String get reviewNoDrafts => '추가된 음식이 없어요. 직접 추가하거나 검색해 보세요.';

  @override
  String get reviewNameHint => '음식 이름';

  @override
  String get reviewCarbsLabel => '탄수(g)';

  @override
  String get reviewProteinLabel => '단백질(g)';

  @override
  String get reviewFatLabel => '지방(g)';

  @override
  String get reviewPortion => '양';

  @override
  String reviewPortionTotal(String kcal) {
    return '$kcal kcal로 저장돼요';
  }

  @override
  String get reviewDateTime => '날짜 · 시간';

  @override
  String reviewDateSemantics(String date) {
    return '기록 날짜 $date';
  }

  @override
  String reviewSave(int count, String kcal) {
    return '$count개 저장 · $kcal kcal';
  }

  @override
  String reviewSaved(int count) {
    return '$count개 음식을 기록했어요';
  }

  @override
  String get reviewLeaveTitle => '기록을 취소할까요?';

  @override
  String get reviewLeaveMessage => '분석 결과와 입력한 내용은 저장되지 않아요.';

  @override
  String get reviewLeaveConfirm => '나가기';

  @override
  String get reviewLeaveStay => '계속 작성';

  @override
  String get reviewRemoveItem => '항목 삭제';

  @override
  String get reviewSelectItem => '저장할 항목 선택';

  @override
  String get reviewPhotoSemantics => '촬영한 음식 사진';

  @override
  String get addMealManualEntry => '직접 입력';

  @override
  String get addMealOfflineHint => 'AI 서버 미연결 상태에서는 내장 음식 DB와 직접 입력을 사용할 수 있어요';

  @override
  String addMealSelectedSummary(int count, String kcal) {
    return '$count개 선택 · $kcal kcal';
  }

  @override
  String addMealRemoveTooltip(String name) {
    return '$name 빼기';
  }

  @override
  String addMealAddTooltip(String name) {
    return '$name 추가';
  }

  @override
  String get addMealRecentTitle => '최근 기록한 음식';

  @override
  String get addMealSuggestedTitle => '추천 음식';

  @override
  String get mealDetailAiRecognized => 'AI 인식';

  @override
  String mealDetailServing(String serving) {
    return '기준량 $serving';
  }

  @override
  String get mealDetailLogAgain => '다시 기록';

  @override
  String get mealDetailLoggedAgain => '지금 시간으로 다시 기록했어요';

  @override
  String dailyKcalLeft(String goal, String amount) {
    return '목표 $goal kcal · $amount kcal 남음';
  }

  @override
  String dailyKcalOver(String goal, String amount) {
    return '목표 $goal kcal · $amount kcal 초과';
  }

  @override
  String dailyIntakeSemantics(String kcal, String remaining, String status) {
    return '오늘 $kcal 킬로칼로리 섭취. $remaining. 상태 $status';
  }

  @override
  String dailyMacroSemantics(String label, String grams, int percent) {
    return '$label $grams그램, 칼로리 비중 $percent퍼센트';
  }

  @override
  String get dailyLogFirstMeal => '첫 식사 기록하기';

  @override
  String get waterTitle => '수분';

  @override
  String waterSemantics(String amount, String goal) {
    return '수분 $amount밀리리터, 목표 $goal밀리리터';
  }

  @override
  String waterSemanticsNoGoal(String amount) {
    return '수분 $amount밀리리터';
  }

  @override
  String get waterAddGlass => '물 한 잔(250ml) 추가';

  @override
  String get waterRemoveGlass => '물 한 잔 빼기';

  @override
  String get reportPrevious => '이전 기간';

  @override
  String get reportNext => '다음 기간';

  @override
  String get reportToday => '오늘';

  @override
  String get reportSummaryTitle => '기간 요약';

  @override
  String reportLoggedDays(int recorded, int total) {
    return '$recorded/$total일 기록';
  }

  @override
  String reportGoalOver(String goal, String amount) {
    return '목표 $goal kcal · $amount kcal 초과';
  }

  @override
  String reportGoalLeft(String goal, String amount) {
    return '목표 $goal kcal · $amount kcal 남음';
  }

  @override
  String reportGoalElapsedNote(int days) {
    return '목표는 지금까지 지난 $days일 기준이에요';
  }

  @override
  String get reportDailyAverage => '기록일 평균';

  @override
  String get reportMealTypeDayTitle => '끼니별 섭취';

  @override
  String get reportDailyTrend => '일별 추이';

  @override
  String reportGoalLine(String goal) {
    return '목표 $goal';
  }

  @override
  String get reportTapDayHint => '막대를 누르면 그날 기록을 볼 수 있어요';

  @override
  String reportBarSemantics(String date, String kcal) {
    return '$date $kcal';
  }

  @override
  String get reportNoRecordsToShow => '표시할 기록이 없습니다';

  @override
  String get reportRecordedFoods => '기록된 음식';

  @override
  String get reportNoRecordsForPeriod => '이 기간에 기록이 없어요';

  @override
  String get reportAddForDay => '이 날짜에 기록 추가';

  @override
  String get reportShowLess => '접기';

  @override
  String reportShowAll(int count) {
    return '모두 보기 ($count)';
  }

  @override
  String get chatRetry => '다시 시도';

  @override
  String get chatOfflineAnswer => '오프라인 기본 답변';

  @override
  String get chatCopied => '답변을 복사했어요';

  @override
  String get chatStatusOnline => 'AI 연결됨';

  @override
  String get chatStatusOffline => '오프라인 모드';

  @override
  String get chatOfflineBanner =>
      'AI 서버에 연결되지 않아 기본 팁으로 답변해요. 맞춤 코칭은 연결 후 이용할 수 있어요.';

  @override
  String get chatStatusLimited => '요청 한도 도달';

  @override
  String get chatStatusError => '연결 불안정';

  @override
  String get chatLimitedBanner => '요청이 많아 잠시 기본 팁으로 답변해요. 잠시 후 다시 시도해 주세요.';

  @override
  String get goalDatePassed => '목표일이 지났어요 · 새 날짜를 선택해 주세요';

  @override
  String get aiConsentTitle => 'AI 기능 사용 동의';

  @override
  String get aiConsentIntro =>
      '사진 분석, AI 음식 검색, AI 코치를 사용하면 아래 정보가 식단스캔 서버를 거쳐 AI 제공업체(OpenAI)로 전송돼요. 답변을 만드는 데에만 사용돼요.';

  @override
  String get aiConsentItemPhoto => '분석을 요청한 음식 사진 (위치 정보는 지우고 보내요)';

  @override
  String get aiConsentItemMeals => '오늘의 식사 이름·시간·영양 정보와 목표, 체중';

  @override
  String get aiConsentItemChat => 'AI 코치에게 보낸 메시지와 최근 대화';

  @override
  String get aiConsentRevokeNote =>
      '설정 > AI 데이터 사용에서 언제든 철회할 수 있어요. 동의하지 않아도 직접 입력·내장 음식 DB·기본 팁은 사용할 수 있어요.';

  @override
  String get aiConsentAgree => '동의하고 계속';

  @override
  String get aiConsentDecline => '동의하지 않음';

  @override
  String get aiConsentRequired =>
      'AI 사진 분석은 데이터 사용에 동의한 뒤 사용할 수 있어요. 음식을 검색하거나 직접 입력해 주세요';

  @override
  String get aiConsentSearchHint => 'AI 음식 분석은 데이터 사용 동의 후 사용할 수 있어요';

  @override
  String get aiConsentSearchAction => '동의하기';

  @override
  String get settingsAiConsent => 'AI 데이터 사용';

  @override
  String get settingsAiConsentOn => '동의함';

  @override
  String get settingsAiConsentOff => '동의 안 함';

  @override
  String get aiConsentRevokeTitle => 'AI 데이터 사용 동의를 철회할까요?';

  @override
  String get aiConsentRevokeMessage =>
      '철회하면 사진 분석과 AI 음식 분석을 사용할 수 없고, AI 코치는 기본 팁으로 답변해요.';

  @override
  String get aiConsentRevokeAction => '철회';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get chatStatusNeedsConsent => '동의 필요';

  @override
  String get aiConsentChatBanner =>
      '데이터 사용에 동의하면 내 기록에 맞춘 AI 답변을 드려요. 지금은 기본 팁으로 답변해요.';

  @override
  String get chatSend => '보내기';

  @override
  String get unitYears => '세';

  @override
  String get settingsTheme => '화면 테마';

  @override
  String get themeSubtitle => '앱 화면 밝기를 선택하세요';

  @override
  String get themeSystem => '시스템 설정 따르기';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get settingsAiStatus => 'AI 기능 상태';

  @override
  String get aiStatusAvailable => '사용 가능';

  @override
  String get aiStatusUnavailable => '연결 안 됨';

  @override
  String get aiStatusChecking => '확인 중';

  @override
  String get aiStatusAvailableBody => '사진 인식, AI 영양 분석, AI 코치를 사용할 수 있어요.';

  @override
  String get aiStatusUnavailableBody =>
      '지금은 AI 서버에 연결되지 않아요. 내장 음식 DB 검색, 직접 입력, 리포트는 그대로 사용할 수 있어요.';

  @override
  String get aiStatusDeveloperDetails => '개발자 정보 (디버그 빌드)';

  @override
  String get authDeleteAccount => '계정 삭제';

  @override
  String get authDeleteAccountTitle => '계정을 삭제할까요?';

  @override
  String get authDeleteAccountMessage =>
      '계정과 클라우드에 저장된 프로필, 식단 기록, 사진이 영구 삭제되고 이 기기의 데이터도 초기화됩니다. 되돌릴 수 없습니다.';

  @override
  String get authDeleteAccountConfirm => '영구 삭제';

  @override
  String get authDeleteAccountDone => '계정이 삭제되었습니다';

  @override
  String get authDeleteAccountFailed =>
      '계정을 삭제하지 못했습니다. 네트워크 연결을 확인한 뒤 다시 시도해주세요.';

  @override
  String get profileLatestLogBasis => '최근 기록 기준';

  @override
  String get weightTitle => '체중 기록';

  @override
  String get weightLog => '기록';

  @override
  String get weightLogTitle => '오늘 체중 기록';

  @override
  String weightDeltaFromStart(String delta) {
    return '시작 대비 $delta kg';
  }

  @override
  String get weightNoRecords => '아직 체중 기록이 없어요. 같은 시간대에 꾸준히 기록하면 추이를 볼 수 있어요.';

  @override
  String weightLastLogged(String date) {
    return '마지막 기록 $date';
  }

  @override
  String weightTrendSemantics(int count) {
    return '최근 $count회 체중 추이 그래프';
  }

  @override
  String get weightHistoryTitle => '체중 기록 내역';

  @override
  String get weightLogged => '체중을 기록했어요';

  @override
  String get weightDeleted => '체중 기록을 삭제했어요';

  @override
  String weightRecalculateSuggestion(String kcal) {
    return '체중 변화로 권장 칼로리가 $kcal kcal로 바뀌었어요';
  }

  @override
  String get weightRecalculateApply => '목표 갱신';

  @override
  String get onboardingGetStarted => '시작하기';

  @override
  String get onboardingDecreaseCalories => '목표 칼로리 50 kcal 낮추기';

  @override
  String get onboardingIncreaseCalories => '목표 칼로리 50 kcal 높이기';

  @override
  String onboardingResetRecommended(String kcal) {
    return '권장값 $kcal kcal로 되돌리기';
  }

  @override
  String onboardingTargetWeightDescription(String date) {
    return '현재 체중의 약 5% 감량을 기본으로 $date까지 목표로 잡았어요. 조정할 수 있어요.';
  }

  @override
  String get onboardingDecreaseTarget => '목표 체중 0.5kg 낮추기';

  @override
  String get onboardingIncreaseTarget => '목표 체중 0.5kg 높이기';
}
