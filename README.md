# 식단스캔 — AI 기반 식단 분석 & 목표별 전략 코치

<p align="center">
  <img src="assets/icons/app_icon.png" alt="식단스캔 Logo" width="120" height="120" style="border-radius: 24px;" />
</p>

<p align="center">
  <strong>사진 한 장으로 식단을 읽고, 원하는 개선 목표에 맞춰 다음 식사를 설계합니다</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Riverpod-2.6-7C4DFF?style=for-the-badge" />
  <img src="https://img.shields.io/badge/OpenAI-GPT--5.4--mini-412991?style=for-the-badge&logo=openai&logoColor=white" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-2DD4A8?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tests-244%20passed-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Dart%20Files-115-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Dart%20Lines-31.9k-blue?style=for-the-badge" />
</p>

---

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [프로젝트 구조](#-프로젝트-구조)
- [로컬 실행](#-로컬-실행)
- [환경 변수 설정](#-환경-변수-설정)
- [아키텍처](#-아키텍처)
- [테스트 및 빌드](#-테스트-및-빌드)
- [운영 배포 체크리스트](#-운영-배포-체크리스트)

---

## 📖 프로젝트 소개

**식단스캔**은 카메라 기반 AI 음식 인식으로 평소 식단을 빠르게 기록하고, 사용자가 선택한 개선 목표에 맞춰 다음 끼니 전략을 제안하는 푸드 인사이트 앱입니다. 음식 사진 촬영, 영양소 자동 추정, 일일 섭취 대시보드, 피부·감량·장 건강·컨디션·혈당 안정 목표별 코칭까지 하나의 흐름으로 제공합니다.

> **핵심 가치**: 사용자가 매번 음식을 검색/입력하지 않아도 사진으로 식단 후보를 자동 생성하고, 단순 칼로리 기록을 넘어 피부 개선·체중 감량·장 건강·컨디션·혈당 안정 등 목표별 행동 전략으로 연결합니다.

---

## ✨ 주요 기능

### 📅 데일리

- `식사 기록` 버튼 하나로 **사진 촬영 / 앨범 / 검색·직접 입력** 중 선택 (AI 서버 없이도 검색·직접 입력으로 기록 가능)
- 항상 *오늘* 기준으로 표시하고 자정·앱 복귀 시 날짜를 자동 갱신 (리포트에서 고른 날짜와 분리)
- 선택한 개선 목표에 맞는 규칙 기반 **목표 전략 카드** — 탭하면 점수 기준, 실천 팁, AI 코치 질문 바로가기
- 오늘 섭취 kcal, 목표 대비 남은/초과 kcal, 탄수·단백질·지방 g·비중 표시
- 오늘 기록 전체 목록(사진 썸네일·AI 신뢰도 배지) — 탭하면 편집 시트
- 수분 카드: 한 잔(250ml) 단위 기록, 프로필의 수분 목표 대비 진행률

### 📊 리포트 — 섭취 대시보드

- 일일 / 주간 / 월간 단위 섭취량, 목표 달성률, 매크로 요약 제공
- 기간 목표는 **지난 날짜만** 반영하고, 평균은 **기록한 날 기준**으로 계산 (미래·미기록 일이 수치를 낮추지 않음)
- 일일은 끼니별 섭취 막대, 주간/월간은 목표선이 있는 일별 막대 그래프 — 막대를 누르면 해당 날짜로 이동
- 기간 내 기록 전체를 날짜별로 그룹화해 표시 (긴 목록은 `모두 보기`), 지난 날짜에도 기록 추가 가능

### 📸 음식 기록 — 카메라 우선 자동 기록

| 소스                  | 설명                                      |
| --------------------- | ----------------------------------------- |
| 📸 **사진 인식**      | 음식 사진 촬영/갤러리 선택 후 AI 비전 기반 식단 후보 자동 생성 |
| 📦 **내장 DB**        | 80개 이상의 한국 음식 데이터, 즉시 응답   |
| 🏛️ **공공데이터포털** | 식약처 식품영양성분DB정보 API 실시간 연동 |
| 🤖 **AI 분석**        | OpenAI GPT-5.4-mini 자연어 기반 영양 분석  |
| 🕘 **최근 음식**      | 최근 기록한 음식을 1인분 기준으로 바로 재기록 |
| ✍️ **직접 입력**      | 음식명·kcal·탄단지를 직접 입력 (오프라인 가능) |

- 사진 인식·검색 결과는 바로 저장하지 않고 **기록 확인 화면**에서 음식명·kcal·탄단지·양(0.5~2×)·끼니·날짜/시간을 수정한 뒤 저장
- 분석은 화면 밖 컨트롤러에서 진행되어 탭 이동으로 결과가 유실되지 않으며, 분석 중 취소/직접 입력 전환 가능 (이미지 인식 재시도는 최대 1회)
- confidence/needsReview 기반으로 확인이 필요한 항목을 강조
- 저장된 기록은 편집 시트에서 이름·영양소·양·끼니·시간 수정, `다시 기록`, 삭제 후 되돌리기 지원
- 양 조절은 저장 시점의 1인분 기준으로 재계산되어 반복 수정해도 누적되지 않음
- 분석 중이거나 확인 중이던 기록은 앱이 종료돼도 보관되어 데일리 화면에서 `이어서 확인` 가능 (Android 카메라 중 앱이 종료된 경우 사진도 복구)
- 촬영 이미지는 앱 문서 디렉터리에 **상대경로**로 보관 (iOS 컨테이너 경로 변경에도 유지), 저장 시 사진의 GPS 위치 정보를 제거하고 로그인 시 Supabase Storage에 업로드

### 🤖 AI 코치 (챗봇)

- OpenAI GPT 기반 **멀티턴** 코칭 — 최근 대화 10턴을 함께 전송, 서버에서 역할/길이 검증
- 오늘 기록한 식사 목록, 칼로리·탄단지, 단백질·수분 목표를 컨텍스트로 전달
- 대화 기록을 기기에 저장해 앱 재시작·언어 변경 후에도 유지
- AI 서버 미연결 시 `오프라인 모드` 표시와 `오프라인 기본 답변` 라벨로 로컬 팁 제공, 요청 한도·응답 지연·서버 오류는 상태 표시와 다시 시도 버튼으로 구분
- 처음 AI 기능(코치·사진 분석·AI 음식 분석)을 쓸 때 전송되는 데이터와 제공업체를 알리고 **동의**를 받으며, 동의 전에는 개인 데이터를 보내지 않음 (설정 > AI 데이터 사용에서 철회 가능)
- 답변 길게 눌러 복사, 첫 질문 전에만 추천 질문 칩 표시

### 👤 프로필 & 설정

- 체중 기록 — 최근 추이 그래프, 시작 대비 변화, 기록 내역/삭제(되돌리기), 체중 변화 시 권장 칼로리·수분 목표 갱신 제안
- BMI 자동 계산 및 분류 (저체중/정상/과체중/비만)
- 피부 개선, 체중 감량, 장 건강, 컨디션, 단백질 보강, 혈당 안정 등 개선 방향 설정
- AI 기능 상태 (사용자용 요약, 프록시 세부 정보는 디버그 빌드에서만), AI 데이터 사용 동의/철회, 개인정보 처리방침 링크(`SIKDANSCAN_PRIVACY_POLICY_URL` 설정 시)
- 화면 테마 — 시스템 설정 따르기 / 라이트 / 다크, 언어 — 시스템 언어 / 한국어 / English
- 계정 동기화: 저장은 기기에 먼저 반영하고 서버 전송은 백그라운드 큐로 처리, 로그인 시 기기 기록과 계정 기록을 id 기준 병합(다른 계정의 기기 데이터는 업로드하지 않고 교체), 다른 기기에서 삭제한 기록은 되살리지 않음(삭제 표시), 앱 시작·복귀 시 변경분만 자동으로 가져오기, 프로필은 더 최근 수정이 우선, 실패한 작업은 재시도 큐에 보관
- 앱 내 계정 삭제 (클라우드 데이터·사진 영구 삭제), 데이터 내보내기 (JSON), 기기 데이터 초기화

---

## 🛠 기술 스택

| 구분                 | 기술                                                      |
| -------------------- | --------------------------------------------------------- |
| **Framework**        | Flutter 3.41 / Dart 3.11                                  |
| **State Management** | Riverpod 2.6 (feature-scoped StateNotifier + 파생 프로바이더) |
| **Navigation**       | GoRouter (선언적 라우팅)                                  |
| **Networking**       | Dio (RetryInterceptor, 지수 백오프 자동 재시도)           |
| **Local Storage**    | Hive (NoSQL, 데이터 영속화)                               |
| **Remote Backend**   | Supabase Auth/Postgres/Storage — 선택형 원격 계정·식단 동기화 인프라 |
| **Backend Proxy**    | Dart HTTP server — AI/API key 격리, Cloud Run API gateway, `/ready`, `/metrics`, 구조화 로그 |
| **AI / ML**          | OpenAI GPT-5.4-mini (서버 프록시 경유 챗봇 + 음식 텍스트/이미지 영양 분석) |
| **외부 API**         | 식단스캔 API Proxy, 식약처 식품영양성분DB정보, Open Food Facts |
| **환경 설정**        | flutter_dotenv (.env 기반 프록시 URL 관리)                |
| **Charts**           | 커스텀 위젯/CustomPainter (목표선 막대, 체중 스파크라인)  |
| **UI**               | 시스템 폰트(SF/Apple SD Gothic Neo, Roboto/Noto Sans CJK), flutter_svg, Material 3 NavigationBar |
| **Icons**            | flutter_lucide                                            |
| **Localization**     | Flutter gen-l10n — 한국어/영어, 시스템 언어/수동 선택 지원 |
| **Code Generation**  | Freezed, json_serializable, build_runner                  |
| **Testing**          | flutter_test — 244개 단위·위젯·서버 테스트                 |
| **CI/CD**            | GitHub Actions — build_runner, format, analyze, test, Android release APK |
| **Architecture**     | Feature-first + Service Layer + Typed Model Layer         |

---

## 📁 프로젝트 구조

```
lib/                                    # 앱 소스 70개 Dart 파일
├── main.dart                           # 앱 진입점 (Hive/dotenv/splash 초기화)
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # API URL, 프롬프트, 설정값
│   ├── theme/
│   │   ├── app_colors.dart             # 디자인 시스템 컬러 (라이트/다크)
│   │   └── app_theme.dart              # Material3 테마 정의
│   ├── router/
│   │   └── app_router.dart             # GoRouter 라우팅 설정
│   └── utils/
│       └── formatters.dart             # intl 기반 숫자/날짜 포맷 (ko/en)
│
├── data/
│   ├── models/                         # Freezed 도메인 모델 (6개)
│   │   ├── user_profile.dart           # 사용자 프로필 (BMI/목표 계산)
│   │   ├── weight_record.dart          # 체중 기록
│   │   ├── meal_record.dart            # 식단 기록 (영양소 포함)
│   │   ├── daily_health.dart           # 일일 건강 데이터
│   │   ├── chat_message.dart           # 채팅 메시지
│   │   ├── food_recognition_result.dart # 사진 인식 결과/confidence 모델
│   │   ├── persisted_model_decoder.dart # 저장 데이터 안전 복원/마이그레이션 가드
│   │   └── *.freezed.dart / *.g.dart   # generated copyWith/equality/JSON
│   ├── services/                       # 서비스 계층 (10개)
│   │   ├── api_service.dart            # Dio HTTP 클라이언트 + RetryInterceptor
│   │   ├── ai_chat_service.dart        # OpenAI GPT 챗봇 서비스
│   │   ├── food_api_service.dart       # 다중 소스 음식 검색 서비스
│   │   ├── food_image_recognition_service.dart # 사진 기반 음식 인식 클라이언트
│   │   ├── local_storage_service.dart  # Hive 영속화 서비스
│   │   ├── proxy_client_config.dart    # 프록시 URL/토큰 환경 설정
│   │   ├── proxy_status_service.dart   # /health 기반 프록시 상태 확인
│   │   ├── supabase_config.dart        # Supabase 공개 설정 로더
│   │   ├── supabase_bootstrap.dart     # 설정된 경우에만 Supabase 초기화
│   │   └── supabase_backend_service.dart # Supabase Auth/Postgres/Storage 래퍼
│   └── repositories/
│       └── dummy_data.dart             # 로컬 음식 DB (80+)
│
├── providers/
│   ├── app_providers.dart              # 공개 provider barrel
│   ├── app_lifecycle_providers.dart    # 데이터 초기화/리셋
│   └── service_providers.dart          # API/프록시/스토리지 서비스 DI
│
├── features/
│   ├── auth/                           # Supabase 계정/동기화
│   │   ├── providers/
│   │   │   └── auth_providers.dart     # Supabase Auth session + local/remote sync
│   │   └── widgets/
│   │       ├── supabase_account_card.dart # 프로필 계정 동기화 카드
│   │       └── supabase_auth_sheet.dart # 로그인/회원가입 바텀시트
│   ├── dashboard/                      # 📅 데일리 홈
│   │   ├── providers/
│   │   │   ├── daily_health_providers.dart
│   │   │   └── meal_strategy_providers.dart # 목표별 식단 전략 생성
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── daily_intake_overview_card.dart # 일일 섭취 상태 카드
│   │       └── goal_strategy_card.dart # 개선 목표별 다음 식사 전략
│   ├── meal/                           # 📊 섭취 리포트 + 음식 기록
│   │   ├── providers/
│   │   │   └── meal_providers.dart
│   │   ├── meal_screen.dart            # 날짜별 섭취 리포트
│   │   ├── add_meal_screen.dart        # 카메라/검색 기반 음식 기록
│   │   └── widgets/
│   │       ├── meal_entry_sheet.dart  # 촬영/앨범/검색 기록 진입 시트
│   │       ├── meal_record_sheet.dart # 저장된 기록 편집 시트
│   │       └── photo_picker.dart      # 카메라/앨범 선택 + 권한 오류 처리
│   ├── onboarding/                     # 최초 실행 맞춤 플로우
│   │   └── onboarding_screen.dart
│   ├── chat/                           # 🤖 AI 챗봇
│   │   ├── providers/
│   │   │   └── chat_providers.dart
│   │   ├── chat_screen.dart
│   │   └── widgets/
│   │       ├── chat_bubble.dart        # 채팅 말풍선
│   │       ├── suggestion_chips.dart   # 추천 질문 칩
│   │       └── typing_indicator.dart   # 타이핑 인디케이터
│   └── profile/                        # 👤 프로필/설정
│       ├── providers/
│       │   └── profile_providers.dart
│       ├── profile_screen.dart
│       └── widgets/
│           ├── edit_profile_sheet.dart  # 프로필 편집 바텀시트
│           ├── goal_settings_sheet.dart # 목표 설정 바텀시트
│           ├── profile_stat_card.dart   # 프로필 통계 카드
│           └── settings_section.dart   # 설정 섹션
│
└── shared/
    └── widgets/
        ├── app_svg_icon.dart           # SVG 아이콘 래퍼
        └── main_scaffold.dart          # 하단 네비게이션 공통 레이아웃

lib/l10n/                               # Flutter gen-l10n 다국어 리소스
├── app_ko.arb                          # 한국어 UI 문자열
├── app_en.arb                          # 영어 UI 문자열
├── app_localizations_context.dart      # context.l10n / enum label helper
└── generated/                          # AppLocalizations generated files

test/                                   # 244개 테스트
├── models/                             # 모델 단위 테스트 (4개 파일, 27개 테스트)
├── services/                           # 서비스 단위 테스트 (5개 파일, 64개 테스트)
├── providers/                          # 프로바이더 테스트 (2개 파일, 39개 테스트)
├── server/                             # 프록시 서버 단위/통합 테스트 (2개 파일, 31개 테스트)
└── widget_test.dart                    # 위젯 통합 테스트 (7개 테스트)

server/
├── bin/
│   └── sikdanscan_proxy.dart              # 프록시 서버 엔트리포인트
└── lib/src/                            # 인증, DB, 관측, CORS, rate limit, upstream, parser, handler 모듈

supabase/
├── README.md                           # Supabase 무료 프로젝트 설정 가이드
└── migrations/
    ├── 20260701000000_initial_sikdanscan_schema.sql # RLS 기반 초기 운영 스키마
    ├── 20260701001000_grant_authenticated_data_api_access.sql # Data API authenticated grant
    └── 20261107000000_meal_portion_and_account_deletion.sql # 양/사진 경로 컬럼 + 계정 삭제 RPC

.github/workflows/
└── flutter-ci.yml                      # pub get, build_runner, format, analyze, test, Android release APK
```

---

## 🚀 로컬 실행

### 사전 요구사항

- Flutter SDK 3.41.1 이상 권장 (CI 검증 기준)
- Dart SDK 3.8 이상 (`pubspec.yaml` 기준, 현재 검증 환경 3.11)
- iOS: Xcode 16+ / Android: SDK 21+

### 실행 순서

```bash
# 1. 저장소 클론
git clone https://github.com/kwakhyun/fitmate.git sikdanscan
cd sikdanscan

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정 (선택사항 — 없어도 앱 동작)
cp .env.example .env
# 필요하면 .env 파일에 SIKDANSCAN_PROXY_BASE_URL 입력
# 프록시에 PROXY_CLIENT_TOKEN을 설정했다면 SIKDANSCAN_PROXY_CLIENT_TOKEN도 입력
# 실제 운영 도메인과 토큰 값은 공개 README에 기록하지 않습니다.
# release 빌드에서는 HTTPS 프록시 URL만 사용됩니다.

# 4. 로컬 프록시 실행 (선택사항)
cp .env.proxy.example .env.proxy
# .env.proxy 파일에 OPENAI_API_KEY / FOOD_API_KEY 입력
dart run server/bin/sikdanscan_proxy.dart

# 5. 앱 실행
flutter run

# 6. 테스트 실행
flutter test

# 7. 정적 분석
dart analyze

# 8. 생성 코드 갱신
dart run build_runner build
```

---

## 🔑 환경 변수 설정

> 공개 저장소에는 변수명과 예시 placeholder만 문서화합니다. 실제 `.env`, `.env.proxy`, Android signing key, Supabase service role key, OAuth provider secret, OpenAI/Data.go.kr API key, 운영 프록시 토큰은 커밋하지 않습니다. Supabase publishable key는 공개 클라이언트 키지만, 실제 보호 경계는 RLS policy와 서버 측 secret 분리입니다.

```bash
# Flutter 앱 .env 파일 예시 (개발용)
SIKDANSCAN_PROXY_BASE_URL=http://127.0.0.1:8080
SIKDANSCAN_PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token

# 서버 프록시 .env.proxy 파일 예시
OPENAI_API_KEY=your_openai_api_key_here
FOOD_API_KEY=your_data_go_kr_api_key_here
PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token
PORT=8080
OPENAI_MODEL=gpt-5.4-mini
# Optional local/demo-only /v1/auth/* and /v1/me/* endpoints.
# Cloud Run 배포에서는 ENABLE_LOCAL_DEMO_AUTH=true일 때만 AUTH_TOKEN_SECRET을 주입합니다.
# AUTH_TOKEN_SECRET=replace_with_at_least_32_random_bytes
# AUTH_TOKEN_TTL_MINUTES=43200
# DATABASE_PATH=.sikdanscan_proxy_db.json

# Supabase 앱 공개 설정 예시
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
```

| 실행 대상 | `SIKDANSCAN_PROXY_BASE_URL` |
| --------- | ------------------------ |
| iOS Simulator / macOS / web | `http://localhost:8080` |
| Android Emulator | `http://10.0.2.2:8080` |
| 실기기 개발 | `http://<개발 머신 LAN IP>:8080` |
| 운영 빌드 | `https://<배포된 프록시 도메인>` |

| API                    | 용도                     | 발급처                                                           |
| ---------------------- | ------------------------ | ---------------------------------------------------------------- |
| **OpenAI API**         | AI 챗봇 + 음식 텍스트/이미지 영양 분석 | [platform.openai.com](https://platform.openai.com)               |
| **식품영양성분DB API** | 공공 식품 DB 검색        | [data.go.kr](https://www.data.go.kr) — 식약처 식품영양성분DB정보 |

> 💡 **프록시 없이도 앱은 동작합니다.** 내장 DB(80+ 음식)와 로컬 폴백 응답이 제공되며, 프록시 연결 시 AI/공공데이터 검색이 활성화됩니다.

> 🔒 Flutter 앱 `.env`에는 프록시 URL과 선택적 클라이언트 토큰만 둡니다. OpenAI 및 공공 API 키는 로컬 `.env.proxy` 또는 배포 플랫폼의 Secret Manager에만 보관합니다. 운영 앱은 `--dart-define=SIKDANSCAN_PROXY_BASE_URL=https://...` 방식으로 주입하는 것을 권장합니다. `server/bin/sikdanscan_proxy.dart`는 로컬 실행 시 `.env.proxy`를 우선 읽고, 없으면 `.env`를 fallback으로 읽습니다. 실제 값이 들어간 `.env`/`.env.proxy`는 `.gitignore`로 제외됩니다.

> 🚫 Release 빌드는 `http://` 프록시 URL을 무시합니다. 운영 환경에서는 반드시 TLS가 적용된 HTTPS 프록시를 사용하세요.

> ⚠️ `SIKDANSCAN_PROXY_CLIENT_TOKEN`은 모바일 앱에 포함되므로 사용자 인증이 아닙니다. OpenAI/공공 API 프록시 보호용 최소 장치로만 사용하고, 사용자 계정/식단 영구 데이터는 Supabase Auth/Postgres/RLS로 분리합니다. 운영 환경에서는 App Check/DeviceCheck, WAF/rate limit, 토큰 로테이션을 함께 적용하세요.

> 🟢 Supabase는 `.env`에 `SUPABASE_URL`과 `SUPABASE_PUBLISHABLE_KEY`가 있을 때만 초기화됩니다. 무료 프로젝트를 사용해 Auth/Postgres/Storage를 붙일 수 있으며, secret/service role key는 모바일 앱에 넣지 않습니다.

---

## 🏗 아키텍처

### Feature-first + Service Layer + Typed Model Layer

```
┌─────────────────────────────────────────────────┐
│                    UI Layer                      │
│  features/ (Screen + Widgets)                    │
│  shared/widgets/ (공통 컴포넌트)                  │
├─────────────────────────────────────────────────┤
│               State Management                   │
│  feature/providers/ (StateNotifier + Derived)     │
│  providers/ (service DI + lifecycle barrel)        │
├─────────────────────────────────────────────────┤
│                Service Layer                     │
│  data/services/ (API, AI, Proxy Status, Storage) │
├─────────────────────────────────────────────────┤
│                 Data Layer                       │
│  data/models/ (Freezed immutable models + JSON)   │
│  data/repositories/ (로컬 DB)                    │
├─────────────────────────────────────────────────┤
│                  Core Layer                      │
│  core/ (Theme, Router, Constants, Utils)         │
└─────────────────────────────────────────────────┘
```

### 다중 소스 음식 검색 파이프라인

```
사용자 검색어
  │
  ├─ 1️⃣ 로컬 DB (80+ 음식, 즉시 응답)
  │
  ├─ 2️⃣ 식단스캔 API Proxy → 공공데이터포털 API (식약처 식품영양정보)
  │     └─ 캐시 확인 → 프록시 호출 → 정규화된 JSON 파싱 → 중복 제거
  │
  ├─ 3️⃣ 식단스캔 API Proxy → OpenAI GPT 분석 (결과 부족 시 자동 트리거)
  │     └─ 프록시 호출 → 정규화된 JSON 파싱 → 메모리 캐시
  │
  └─ 결과 병합 & 중복 제거 → UI 표시 (출처별 섹션 구분)
```

### 에러 처리 전략

| 전략                     | 설명                                                            |
| ------------------------ | --------------------------------------------------------------- |
| **RetryInterceptor**     | 429(Rate Limit), 5xx 에러 시 지수 백오프로 최대 3회 자동 재시도 |
| **Graceful Degradation** | AI 서비스 불가 시 로컬 폴백 응답 (앱이 항상 동작)               |
| **Resilient Parsing**    | 외부 API의 문자열 숫자, 단일 객체, Markdown JSON 응답 방어      |
| **Secret Isolation**     | 모바일 앱은 프록시 URL/클라이언트 토큰만 보관하고 외부 API 키는 서버 환경변수로 격리 |
| **Proxy Health Check**   | 설정 화면에서 `/health`를 호출해 실제 프록시 연결 상태 확인     |
| **Proxy Guardrails**     | Bearer 토큰, CORS Origin 제한, 요청 본문 크기 제한, IP 기반 rate limit |
| **Cloud Sync Auth**      | Supabase Auth 기반 이메일/소셜 로그인, RLS 사용자 데이터 분리 |
| **Readiness & Metrics**  | `/ready` DB/auth/upstream 준비 상태, `/metrics` Prometheus 스타일 카운터/latency |
| **Structured Logging**   | 요청별 `x-request-id`, method/path/status/duration JSON 로그 |
| **메모리 캐시**          | AI/공공 API 결과를 캐시하여 중복 API 호출 방지                  |
| **입력 디바운스**        | 검색 입력 300ms 디바운스로 불필요한 API 호출 최소화             |
| **검색 레이스 방지**     | 최신 검색 요청만 UI 상태를 갱신하여 빠른 입력에도 결과 일관성 유지 |

### 데이터 영속화

- Hive NoSQL 기반 — 모든 StateNotifier가 자동 저장/복원
- 앱 재시작 시 사용자 데이터 유지
- Supabase Auth/Postgres/Storage 기반 원격 인프라를 선택적으로 지원하며, RLS로 사용자별 프로필/식단/사진 접근을 제한
- 서버 프록시 파일 DB는 로컬 fallback/데모용으로만 유지하고, 실제 사용자 계정·장기 식단 데이터의 운영 기준은 Supabase Postgres/RLS
- 언어 설정은 `system` / `ko` / `en` 값을 Hive settings에 저장하고, `system` 모드에서는 기기 locale을 따름
- 데이터 내보내기(JSON) 및 전체 초기화 기능 제공

### Supabase 원격 인프라

- `supabase_flutter` 기반 공식 SDK 초기화 — `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`가 있을 때만 활성화
- `profiles`, `meal_records`, `food_recognition_results` 테이블과 `meal-images`, `avatars` private bucket migration 제공
- 모든 테이블과 Storage object는 `auth.uid()` 기반 RLS policy로 사용자별 접근 제한
- 프로필 화면에서 이메일 로그인/회원가입과 Google/Kakao/Apple 소셜 로그인, 로그아웃, 수동 동기화를 제공하고, 로그인 시 원격 데이터가 있으면 로컬 상태로 병합
- 프로필·식단 저장은 로컬 Hive를 우선 성공시킨 뒤 Supabase에 best-effort 동기화해 네트워크 장애 시에도 앱 기록 흐름을 유지
- Data API 자동 노출 설정을 끈 프로젝트에서도 동작하도록 `authenticated` role 명시 grant migration 제공
- OpenAI/Data.go.kr 호출은 기존 Dart proxy에 유지해 secret key가 앱에 포함되지 않도록 분리
- 소셜 로그인은 Supabase OAuth 리다이렉트 `sikdanscan://auth/callback`을 사용하며, provider secret은 Supabase Dashboard에만 저장

### 다국어 처리

- Flutter 공식 `gen-l10n` 기반 — `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`
- `MaterialApp.router`에서 `AppLocalizations` delegate와 `languageProvider`를 연결해 런타임 언어 전환 지원
- 프로필 > 설정 > 언어 바텀시트에서 시스템 언어, 한국어, English 선택 가능
- AI 코치, 음식 텍스트 분석, 사진 인식 프록시 요청에 `locale`을 포함해 응답 언어를 맞춤
- 사용자 입력값, 저장된 음식명, 과거 기록명은 자동 번역하지 않고 원문 유지

### 모델링 & 코드 생성

- Freezed 기반 불변 도메인 모델 — generated `copyWith`, equality, debug output 활용
- json_serializable 기반 타입 안전 JSON 직렬화 — Hive 저장/복원과 API 파싱 계약을 명시
- 저장 데이터 손상/스키마 변경 시 안전 decoder로 앱 시작 실패를 방지하고, 유효한 레코드만 복원
- GitHub Actions에서 `build_runner build`와 `git diff --exit-code`로 생성 코드 누락을 차단

---

## 🧪 테스트 및 빌드

```bash
flutter test        # 전체 244개 테스트 실행
dart analyze        # 앱 정적 분석 (0 issues)
dart analyze server # 서버 정적 분석 (0 issues)
dart run build_runner build
flutter build apk --release
flutter build appbundle --release
flutter build ios --release --no-codesign
```

| 영역           | 파일 수 | 테스트 수 | 커버리지                                      |
| -------------- | ------- | --------- | --------------------------------------------- |
| **모델**       | 4       | 28        | JSON 직렬화/역직렬화, 개선 목표, BMI, 날짜 계산 |
| **서비스**     | 6       | 74        | 음식 검색/캐시/프록시 파싱, 사진 인식 locale payload·사용자용 오류 문구, AI 멀티턴/폴백/오프라인·타임아웃 판정/재시도 횟수, 이미지 상대경로·레거시 경로 복구, Supabase row 매핑 |
| **프로바이더** | 4       | 88        | CRUD, 백그라운드 동기화 큐(업로드 중 삭제·수정, 사진 공유 업로드, 되돌리기), 계정 병합·다른 계정 데이터 보호, 오늘/리포트 날짜 분리, 리포트 계산, 양 재계산, 기록 확인 플로우, 대화 저장·재시도·늦은 응답 무시, AI 데이터 동의, 사진 GPS 제거, 테마/언어, 목표별 전략(ko/en) |
| **서버**       | 2       | 35        | 프록시 헬스체크, readiness, metrics, 인증, CORS, 본문 제한, rate limit, 이미지 payload 검증, 대화 기록 검증, 코치 프롬프트 |
| **위젯**       | 1       | 19        | 온보딩(소셜 로그인 노출, 인라인 검증, 감량 목표 입력 회귀), 데일리·기록 시트·수분, 기록 확인 저장, 기록 편집/되돌리기, 리포트, 설정·AI 데이터 동의/철회, AI 코치 오프라인 |
| **합계**       | **17**  | **244**   | **All passed ✅**                             |

## 🚢 운영 배포 체크리스트

- 프록시 서버를 HTTPS 도메인 뒤에 배포하고 `SIKDANSCAN_PROXY_BASE_URL`을 HTTPS로 주입
- Cloud Run 배포는 루트 `Dockerfile`과 `scripts/deploy_cloud_run.sh`를 사용하고, secret은 Secret Manager에서 주입
- OpenAI/Data.go.kr 키는 서버 Secret Manager에만 저장
- 로컬/데모용 `/v1/auth/*`, `/v1/me/*` API를 Cloud Run에서도 예외적으로 켤 때만 `AUTH_TOKEN_SECRET`을 32바이트 이상 난수로 설정하고 Secret Manager에서 로테이션. 기본 운영 배포에서는 주입하지 않음
- Cloud Run은 AI/API gateway로 운영하고, 사용자 영구 데이터는 Supabase Postgres/RLS를 기준으로 운영. 데모용 파일 DB auth는 `ENABLE_LOCAL_DEMO_AUTH=true`일 때만 활성화
- `/ready`를 배포 health check에 연결하고, `/metrics`를 Prometheus/Grafana 또는 호스팅 플랫폼 메트릭 수집기에 연결
- `PROXY_CLIENT_TOKEN`은 upstream 보호용 최소 장치로만 사용하고, 운영에는 App Check/DeviceCheck, WAF/rate limit 추가
- Android 배포 전 `android/key.properties.example`을 복사해 `android/key.properties`를 만들고 업로드 키스토어 설정
- iOS 배포 전 Apple Developer Team, bundle identifier, capability, privacy manifest/앱 개인정보 항목 확인
- 개인정보 처리방침을 HTTPS로 게시하고 `SIKDANSCAN_PRIVACY_POLICY_URL`로 주입 (설정 화면과 AI 데이터 사용 동의 화면에 링크 표시)
- Supabase migration `20261107000000_meal_portion_and_account_deletion.sql`을 앱 업데이트 전에 적용 (양/사진 경로 컬럼, 최신 수정 우선 트리거, 계정 삭제 RPC)
- 장애 대응을 위해 프록시 로그, latency, 4xx/5xx, OpenAI quota/rate-limit 모니터링 구성
- 사용자 프로필/식단의 앱 로컬 상태와 Supabase 원격 저장소 간 동기화 정책을 앱 로그인 플로우와 함께 확정
