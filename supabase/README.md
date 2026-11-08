# 식단스캔 Supabase Setup

Supabase는 사용자 인증, Postgres, Storage를 담당하는 선택형 원격 인프라입니다. `.env`에 Supabase 값이 없으면 앱은 기존 Hive 로컬 저장과 Dart proxy 방식으로 계속 동작합니다.

## 무료 플랜 기준 적용 순서

1. Supabase에서 무료 프로젝트를 생성합니다.
2. Project URL과 publishable key를 확인합니다. Secret/service role key는 모바일 앱에 넣지 않습니다.
3. SQL Editor 또는 Supabase CLI로 `migrations/` 파일을 순서대로 적용합니다.
   - `20260701000000_initial_sikdanscan_schema.sql`
   - `20260701001000_grant_authenticated_data_api_access.sql`
   - `20261107000000_meal_portion_and_account_deletion.sql`
   - 이미 앞의 migration을 적용했다면 남은 파일만 순서대로 추가 실행하면 됩니다.
   - 세 번째 migration은 앱이 동기화하는 `meal_records.portion`, `meal_records.image_storage_path` 컬럼, 수정 시각 기준 최신 기록 유지 트리거(`meal_records_keep_newer`), 앱 내 계정 삭제용 `delete_my_account()` RPC를 추가합니다. **적용하지 않으면 식단 동기화 upsert가 실패**하므로 앱 업데이트 전에 적용하세요.
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

## 동기화 동작

- 저장·수정·삭제는 기기에 먼저 반영되고, 서버 작업은 기기의 재시도 큐를 거쳐 백그라운드에서 한 번에 하나씩 전송됩니다. 실패한 작업은 큐에 남아 앱 복귀·수동 동기화·재로그인·다음 변경 시 다시 전송됩니다.
- 로그인 시 기기 기록과 계정 기록을 record id 기준으로 병합합니다. 같은 기록은 `updated_at`(기록을 수정한 시각)이 더 최근인 쪽을 유지하고, 기기에만 있는 기록은 업로드합니다. 서버 트리거도 더 오래된 수정 시각의 update는 건너뛰므로, 늦게 도착한 오래된 변경이 다른 기기의 최신 변경을 덮어쓰지 않습니다.
- 기기의 데이터가 **다른 계정**의 것이면(로그아웃 후 다른 계정으로 로그인) 업로드하지 않고, 기기 기록을 새 계정의 기록으로 교체합니다. 게스트로 쓰던 기록은 처음 로그인한 계정으로 옮겨집니다.
- 계정 기록은 페이지 단위로 모두 가져옵니다(Data API 기본 응답 상한 1000행).
- 사진은 `meal-images/<user_id>/<record_id>.<ext>`로 업로드되고(한 사진에서 저장한 여러 음식은 같은 파일을 공유), 다른 기기에서는 signed URL로 표시됩니다. 파일 형식은 파일 내용으로 판별합니다.
- 앱 내 `계정 삭제`는 Storage API로 사용자 폴더의 사진을 지운 뒤 `delete_my_account()`로 auth 사용자를 삭제합니다. 테이블 row는 `on delete cascade`로 함께 삭제됩니다.

## 보안 정책

- 모든 앱 데이터 테이블은 Row Level Security를 활성화합니다.
- `auth.uid()`가 소유한 row만 select/insert/update/delete 할 수 있습니다.
- Storage object는 `<user_id>/<file>` 경로만 접근 가능합니다.
- OpenAI/Data.go.kr secret은 계속 Dart proxy 또는 Edge Function 환경변수에만 보관합니다.

## 운영 메모

- 무료 플랜 범위에서는 초기 검증과 소규모 베타 운영에 적합합니다.
- 트래픽, Storage, Edge Functions 사용량이 무료 한도를 넘으면 과금 또는 업그레이드가 필요할 수 있습니다.
- AI 분석 endpoint는 현재 Dart proxy에 유지되어 있습니다. Supabase Edge Functions로 옮길 경우에도 OpenAI key는 function secret으로만 설정해야 합니다.
