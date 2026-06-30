# 식단스캔 Supabase Setup

Supabase는 사용자 인증, Postgres, Storage를 담당하는 선택형 원격 인프라입니다. `.env`에 Supabase 값이 없으면 앱은 기존 Hive 로컬 저장과 Dart proxy 방식으로 계속 동작합니다.

## 무료 플랜 기준 적용 순서

1. Supabase에서 무료 프로젝트를 생성합니다.
2. Project URL과 publishable key를 확인합니다. Secret/service role key는 모바일 앱에 넣지 않습니다.
3. SQL Editor 또는 Supabase CLI로 `migrations/` 파일을 순서대로 적용합니다.
   - `20260701000000_initial_sikdanscan_schema.sql`
   - `20260701001000_grant_authenticated_data_api_access.sql`
   - 이미 초기 스키마를 적용했다면 두 번째 grant migration만 추가로 실행하면 됩니다.
4. Flutter 앱 `.env`에 공개 설정만 추가합니다.

```bash
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_PUBLISHABLE_KEY=your_supabase_publishable_key
```

5. 앱을 재실행하면 `SupabaseBootstrap`이 설정된 경우에만 SDK를 초기화합니다.
6. 프로필 탭의 계정 동기화 카드에서 회원가입 또는 로그인을 진행하고, 필요하면 수동 동기화를 실행합니다.

## 소셜 로그인 설정

앱은 Supabase OAuth 리다이렉트 방식으로 Google, Kakao, Apple 로그인을 시작합니다. Supabase Dashboard에서 다음 값을 맞춰야 합니다.

1. Authentication > URL Configuration > Redirect URLs에 `sikdanscan://auth/callback`을 추가합니다.
2. Authentication > Providers에서 Google, Kakao, Apple을 각각 활성화합니다.
3. 각 provider 콘솔의 callback/redirect URL에는 Supabase가 제공하는 `https://<project-ref>.supabase.co/auth/v1/callback` 값을 등록합니다.
4. Apple 로그인을 운영 배포에 사용할 경우 Apple Developer에서 Services ID 또는 App ID 설정과 Sign in with Apple capability를 함께 확인합니다.

Jurnee는 앱이 provider 토큰을 받아 자체 Node 서버 `/auth/social`에 전달하고 서버가 자체 JWT를 발급하는 구조입니다. 식단스캔은 Supabase Auth가 provider 검증과 세션 발급을 담당하므로 secret key와 provider client secret은 Supabase Dashboard에만 보관합니다.

## 생성 리소스

- `profiles`: 사용자 프로필과 목표 설정
- `meal_records`: 사용자별 식단 기록
- `food_recognition_results`: AI 음식 인식 원본 결과
- `meal-images` storage bucket: 음식 사진 private bucket
- `avatars` storage bucket: 프로필 이미지 private bucket

## 보안 정책

- 모든 앱 데이터 테이블은 Row Level Security를 활성화합니다.
- `auth.uid()`가 소유한 row만 select/insert/update/delete 할 수 있습니다.
- Storage object는 `<user_id>/<file>` 경로만 접근 가능합니다.
- OpenAI/Data.go.kr secret은 계속 Dart proxy 또는 Edge Function 환경변수에만 보관합니다.

## 운영 메모

- 무료 플랜 범위에서는 초기 검증과 소규모 베타 운영에 적합합니다.
- 트래픽, Storage, Edge Functions 사용량이 무료 한도를 넘으면 과금 또는 업그레이드가 필요할 수 있습니다.
- AI 분석 endpoint는 현재 Dart proxy에 유지되어 있습니다. Supabase Edge Functions로 옮길 경우에도 OpenAI key는 function secret으로만 설정해야 합니다.
