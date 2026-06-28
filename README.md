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
  <img src="https://img.shields.io/badge/Tests-153%20passed-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Dart%20Files-68-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Dart%20Lines-17.9k-blue?style=for-the-badge" />
</p>

---

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [프로젝트 구조](#-프로젝트-구조)
- [시작하기](#-시작하기)
- [환경 설정](#-환경-설정)
- [아키텍처](#-아키텍처)
- [테스트](#-테스트)

---

## 📖 프로젝트 소개

**식단스캔**은 카메라 기반 AI 음식 인식으로 평소 식단을 빠르게 기록하고, 사용자가 선택한 개선 목표에 맞춰 다음 끼니 전략을 제안하는 푸드 인사이트 앱입니다. 음식 사진 촬영, 영양소 자동 추정, 일일 섭취 대시보드, 피부·감량·장 건강·컨디션·혈당 안정 목표별 코칭까지 하나의 흐름으로 제공합니다.

> **핵심 가치**: 사용자가 매번 음식을 검색/입력하지 않아도 사진으로 식단 후보를 자동 생성하고, 단순 칼로리 기록을 넘어 피부 개선·체중 감량·장 건강·컨디션·혈당 안정 등 목표별 행동 전략으로 연결합니다.

---

## ✨ 주요 기능

### 📅 데일리

- 첫 화면에서 바로 음식 촬영 가능
- 선택한 개선 목표에 맞는 오늘의 식사 전략 카드 제공
- 오늘 섭취 kcal, 목표 대비 남은/초과 kcal, 탄수·단백질·지방 요약 표시
- 촬영 이미지, AI 인식 음식명, 신뢰도, kcal, 탄수·단백질·지방을 한 화면에서 확인
- 상단 인사/장식 요소와 복잡한 그래프를 제거한 심플한 홈 화면

### 📊 리포트 — 섭취 대시보드

- 일일 / 주간 / 월간 단위 섭취량, 목표 달성률, 매크로 요약 제공
- 일일은 시간대별 기록, 주간/월간은 일별 추이를 막대 그래프로 시각화
- 선택 기간에 기록된 음식 목록 요약
- 촬영 액션은 데일리 화면에 집중하고, 리포트는 분석/회고 화면으로 단순화

### 📸 음식 기록 — 카메라 우선 자동 기록

| 소스                  | 설명                                      |
| --------------------- | ----------------------------------------- |
| 📸 **사진 인식**      | 음식 사진 촬영/갤러리 선택 후 AI 비전 기반 식단 후보 자동 생성 |
| 📦 **내장 DB**        | 80개 이상의 한국 음식 데이터, 즉시 응답   |
| 🏛️ **공공데이터포털** | 식약처 식품영양성분DB정보 API 실시간 연동 |
| 🤖 **AI 분석**        | OpenAI GPT-5.4-mini 자연어 기반 영양 분석  |
| 📷 **바코드 검색**    | Open Food Facts API 연동                  |

- 카메라 촬영 즉시 음식 후보를 인식하고 선택 목록에 자동 추가
- 촬영 이미지는 앱 문서 디렉터리에 보관하고, 저장된 식단 기록과 연결
- confidence/needsReview 기반으로 인식 결과 검토 필요 여부 표시
- 영양소 자동 계산 및 선택 목록 기반 저장

### 🤖 AI 코치 (챗봇)

- OpenAI GPT 기반 실시간 식단 전략 코칭
- 사용자 건강 데이터와 개선 목표 컨텍스트 자동 연동 (칼로리, 체중, 수분, 목표 방향 등)
- 429/5xx 에러 시 자동 재시도 (Exponential Backoff, 최대 3회)
- API 실패 시 로컬 폴백 응답 — 오프라인에서도 동작
- 추천 질문 Suggestion Chips

### 👤 프로필 & 설정

- BMI 자동 계산 및 분류 (저체중/정상/과체중/비만)
- 피부 개선, 체중 감량, 장 건강, 컨디션, 단백질 보강, 혈당 안정 등 개선 방향 설정
- API 연결 상태 확인 대시보드
- 언어 설정 — 시스템 언어 / 한국어 / English 지원
- 데이터 내보내기 (JSON) / 전체 초기화
- 다크 모드 / 알림 설정

---

## 🛠 기술 스택

| 구분                 | 기술                                                      |
| -------------------- | --------------------------------------------------------- |
| **Framework**        | Flutter 3.41 / Dart 3.11                                  |
| **State Management** | Riverpod 2.6 (feature-scoped StateNotifier + 파생 프로바이더) |
| **Navigation**       | GoRouter (선언적 라우팅)                                  |
| **Networking**       | Dio (RetryInterceptor, 지수 백오프 자동 재시도)           |
| **Local Storage**    | Hive (NoSQL, 데이터 영속화)                               |
| **AI / ML**          | OpenAI GPT-5.4-mini (서버 프록시 경유 챗봇 + 음식 텍스트/이미지 영양 분석) |
| **외부 API**         | 식단스캔 API Proxy, 식약처 식품영양성분DB정보, Open Food Facts |
| **환경 설정**        | flutter_dotenv (.env 기반 프록시 URL 관리)                |
| **Charts**           | fl_chart (라인/링 차트)                                   |
| **UI**               | percent_indicator, Google Fonts, shimmer, flutter_animate |
| **Icons**            | flutter_lucide                                            |
| **Localization**     | Flutter gen-l10n — 한국어/영어, 시스템 언어/수동 선택 지원 |
| **Code Generation**  | Freezed, json_serializable, build_runner                  |
| **Testing**          | flutter_test — 153개 단위·위젯·서버 테스트                 |
| **CI/CD**            | GitHub Actions — build_runner, format, analyze, test      |
| **Architecture**     | Feature-first + Service Layer + Typed Model Layer         |

---

## 📁 프로젝트 구조

```
lib/                                    # 68개 Dart 파일
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
│       ├── date_utils.dart             # 날짜 포맷 유틸리티
│       └── number_utils.dart           # 숫자 포맷 유틸리티
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
│   ├── services/                       # 서비스 계층 (7개)
│   │   ├── api_service.dart            # Dio HTTP 클라이언트 + RetryInterceptor
│   │   ├── ai_chat_service.dart        # OpenAI GPT 챗봇 서비스
│   │   ├── food_api_service.dart       # 다중 소스 음식 검색 서비스
│   │   ├── food_image_recognition_service.dart # 사진 기반 음식 인식 클라이언트
│   │   ├── local_storage_service.dart  # Hive 영속화 서비스
│   │   ├── proxy_client_config.dart    # 프록시 URL/토큰 환경 설정
│   │   └── proxy_status_service.dart   # /health 기반 프록시 상태 확인
│   └── repositories/
│       └── dummy_data.dart             # 로컬 음식 DB (80+)
│
├── providers/
│   ├── app_providers.dart              # 공개 provider barrel
│   ├── app_lifecycle_providers.dart    # 데이터 초기화/리셋
│   └── service_providers.dart          # API/프록시/스토리지 서비스 DI
│
├── features/
│   ├── dashboard/                      # 📅 데일리 홈
│   │   ├── providers/
│   │   │   ├── daily_health_providers.dart
│   │   │   └── meal_strategy_providers.dart # 목표별 식단 전략 생성
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── daily_intake_overview_card.dart # 일일 섭취 상태 카드
│   │       ├── goal_strategy_card.dart # 개선 목표별 다음 식사 전략
│   │       ├── calorie_ring_card.dart
│   │       ├── health_metrics_card.dart
│   │       ├── quick_actions_card.dart
│   │       └── weight_chart_card.dart
│   ├── meal/                           # 📊 섭취 리포트 + 음식 기록
│   │   ├── providers/
│   │   │   └── meal_providers.dart
│   │   ├── meal_screen.dart            # 날짜별 섭취 리포트
│   │   ├── add_meal_screen.dart        # 카메라/검색 기반 음식 기록
│   │   └── widgets/
│   │       └── nutrition_summary_bar.dart # 영양소 요약 바
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

test/                                   # 153개 테스트
├── models/                             # 모델 단위 테스트 (4개 파일, 27개 테스트)
├── services/                           # 서비스 단위 테스트 (4개 파일, 60개 테스트)
├── providers/                          # 프로바이더 테스트 (2개 파일, 34개 테스트)
├── server/                             # 프록시 서버 단위/통합 테스트 (2개 파일, 25개 테스트)
└── widget_test.dart                    # 위젯 통합 테스트 (7개 테스트)

server/
├── bin/
│   └── sikdanscan_proxy.dart              # 프록시 서버 엔트리포인트
└── lib/src/                            # 인증, CORS, rate limit, upstream, parser, handler 모듈

.github/workflows/
└── flutter-ci.yml                      # pub get, build_runner, format, analyze, test
```

---

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.41 이상
- Dart SDK 3.11 이상
- iOS: Xcode 16+ / Android: SDK 21+

### 설치 및 실행

```bash
# 1. 저장소 클론
git clone https://github.com/your-username/sikdanscan.git
cd sikdanscan

# 2. 의존성 설치
flutter pub get

# 3. 환경 변수 설정 (선택사항 — 없어도 앱 동작)
cp .env.example .env
# .env 파일에 SIKDANSCAN_PROXY_BASE_URL 입력
# 프록시에 PROXY_CLIENT_TOKEN을 설정했다면 SIKDANSCAN_PROXY_CLIENT_TOKEN도 입력

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

## 🔑 환경 설정

```bash
# Flutter 앱 .env 파일 예시
SIKDANSCAN_PROXY_BASE_URL=http://localhost:8080
SIKDANSCAN_PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token

# 서버 프록시 .env.proxy 파일 예시
OPENAI_API_KEY=your_openai_api_key_here
FOOD_API_KEY=your_data_go_kr_api_key_here
PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token
PORT=8080
OPENAI_MODEL=gpt-5.4-mini
```

| 실행 대상 | `SIKDANSCAN_PROXY_BASE_URL` |
| --------- | ------------------------ |
| iOS Simulator / macOS / web | `http://localhost:8080` |
| Android Emulator | `http://10.0.2.2:8080` |
| 실기기 | `http://<개발 머신 LAN IP>:8080` 또는 배포된 HTTPS URL |

| API                    | 용도                     | 발급처                                                           |
| ---------------------- | ------------------------ | ---------------------------------------------------------------- |
| **OpenAI API**         | AI 챗봇 + 음식 텍스트/이미지 영양 분석 | [platform.openai.com](https://platform.openai.com)               |
| **식품영양성분DB API** | 공공 식품 DB 검색        | [data.go.kr](https://www.data.go.kr) — 식약처 식품영양성분DB정보 |

> 💡 **프록시 없이도 앱은 동작합니다.** 내장 DB(80+ 음식)와 로컬 폴백 응답이 제공되며, 프록시 연결 시 AI/공공데이터 검색이 활성화됩니다.

> 🔒 Flutter 앱 `.env`에는 프록시 URL과 선택적 클라이언트 토큰만 둡니다. OpenAI 및 공공 API 키는 로컬 `.env.proxy` 또는 배포 플랫폼의 Secret Manager에만 보관합니다. `server/bin/sikdanscan_proxy.dart`는 로컬 실행 시 `.env.proxy`를 우선 읽고, 없으면 `.env`를 fallback으로 읽습니다.

> ⚠️ `SIKDANSCAN_PROXY_CLIENT_TOKEN`은 모바일 앱에 포함되므로 완전한 사용자 인증이 아닙니다. 포트폴리오/개발 환경의 최소 보호막으로 사용하고, 운영 환경에서는 사용자 인증, App Check/DeviceCheck, WAF/rate limit을 함께 적용하세요.

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
| **메모리 캐시**          | AI/공공 API 결과를 캐시하여 중복 API 호출 방지                  |
| **입력 디바운스**        | 검색 입력 300ms 디바운스로 불필요한 API 호출 최소화             |
| **검색 레이스 방지**     | 최신 검색 요청만 UI 상태를 갱신하여 빠른 입력에도 결과 일관성 유지 |

### 데이터 영속화

- Hive NoSQL 기반 — 모든 StateNotifier가 자동 저장/복원
- 앱 재시작 시 사용자 데이터 유지
- 언어 설정은 `system` / `ko` / `en` 값을 Hive settings에 저장하고, `system` 모드에서는 기기 locale을 따름
- 데이터 내보내기(JSON) 및 전체 초기화 기능 제공

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

## 🧪 테스트

```bash
flutter test        # 전체 153개 테스트 실행
dart analyze        # 정적 분석 (0 issues)
dart run build_runner build
```

| 영역           | 파일 수 | 테스트 수 | 커버리지                                      |
| -------------- | ------- | --------- | --------------------------------------------- |
| **모델**       | 4       | 27        | JSON 직렬화/역직렬화, 개선 목표, BMI, 날짜 계산 |
| **서비스**     | 4       | 60        | 음식 검색/캐시/프록시 파싱, 사진 인식 locale payload, AI 폴백, 프록시 상태 확인 |
| **프로바이더** | 2       | 34        | StateNotifier CRUD, 목표별 식단 전략, 언어 설정 저장 복원/rollback |
| **서버**       | 2       | 25        | 프록시 헬스체크, Bearer 인증, CORS, JSON 오류, 본문 제한, rate limit, 이미지 payload 검증, 텍스트/이미지 파서 |
| **위젯**       | 1       | 7         | 데일리 홈 로드, 한국어/영어 네비게이션, 촬영 CTA, Chips, 언어 설정 바텀시트 |
| **합계**       | **13**  | **153**   | **All passed ✅**                             |
