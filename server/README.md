# 식단스캔 API Proxy

Flutter 앱에 OpenAI/Data.go.kr 키를 포함하지 않기 위한 Dart 백엔드 프록시입니다. 운영에서는 AI/API gateway, readiness/metrics, 구조화 로그를 담당하고 사용자 영구 데이터는 Supabase Auth/Postgres/Storage를 기준으로 저장합니다.

파일 기반 인증/식단 저장소는 로컬 fallback/데모 용도로만 유지합니다. Cloud Run 운영 배포에서는 `ENABLE_LOCAL_DEMO_AUTH=true`를 명시하지 않는 한 `/v1/auth/*`, `/v1/me/*`용 `AUTH_TOKEN_SECRET`을 주입하지 않습니다.

## 구조

```text
server/
├── bin/sikdanscan_proxy.dart      # 실행 엔트리포인트
└── lib/src/
    ├── proxy_handlers.dart     # 라우팅, 인증, 에러 매핑, request logging
    ├── proxy_config.dart       # 환경변수 기반 서버 구성
    ├── auth_service.dart       # PBKDF2 password hash + HMAC access token
    ├── server_database.dart    # 파일 기반 사용자/식단 JSON 저장소
    ├── observability.dart      # request id, structured log, metrics
    ├── upstream_client.dart    # OpenAI/Data.go.kr upstream 호출
    ├── food_parsers.dart       # 외부 응답 정규화
    ├── client_auth.dart        # 프록시 Bearer 토큰 검증
    ├── cors.dart               # Origin 제한
    └── rate_limiter.dart       # IP 기반 minute bucket rate limit
```

## 실행

```bash
cp .env.proxy.example .env.proxy
# .env.proxy 파일에 OPENAI_API_KEY / FOOD_API_KEY / AUTH_TOKEN_SECRET 입력
dart run server/bin/sikdanscan_proxy.dart
```

`server/bin/sikdanscan_proxy.dart`는 로컬 실행 시 `.env.proxy`를 우선 읽고, 없으면 `.env`를 fallback으로 읽습니다. `Platform.environment`에 이미 설정된 값은 파일 값으로 덮어쓰지 않습니다.

Flutter 앱의 `.env`에는 공개 주소만 설정합니다.

```bash
SIKDANSCAN_PROXY_BASE_URL=http://localhost:8080
SIKDANSCAN_PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token
```

서버 `.env.proxy`의 운영 필수/권장 값입니다.

```bash
OPENAI_API_KEY=your_openai_api_key_here
FOOD_API_KEY=your_data_go_kr_api_key_here
PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token
AUTH_TOKEN_SECRET=replace_with_at_least_32_random_bytes
AUTH_TOKEN_TTL_MINUTES=43200
DATABASE_PATH=.sikdanscan_proxy_db.json
PROXY_RATE_LIMIT_PER_MINUTE=60
```

로컬 주소는 실행 대상에 따라 달라집니다.

| 실행 대상 | `SIKDANSCAN_PROXY_BASE_URL` |
| --- | --- |
| iOS Simulator / macOS / web | `http://localhost:8080` |
| Android Emulator | `http://10.0.2.2:8080` |
| 실기기 개발 | `http://<개발 머신 LAN IP>:8080` |
| 운영 빌드 | `https://<배포된 프록시 도메인>` |

## Cloud Run 배포

Cloud Run에서는 이 서버를 AI/API gateway로 운영합니다. 사용자 프로필, 식단, 사진의 영구 데이터는 Supabase를 기준으로 두고, Cloud Run 컨테이너의 파일 시스템은 임시 저장소로만 사용합니다. 데모용 파일 DB 인증 API는 기본 배포에서 비활성화됩니다.

### 1. Secret Manager 값 생성/갱신

```bash
export PROJECT_ID=your-gcp-project-id
export OPENAI_API_KEY=your_openai_api_key
export FOOD_API_KEY=your_data_go_kr_api_key
export PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token
# 선택: 로컬/데모 auth API를 Cloud Run에서도 켤 때만 설정
# export AUTH_TOKEN_SECRET=$(openssl rand -base64 48)

scripts/create_cloud_run_secrets.sh
```

기본 secret 이름은 다음과 같습니다. 이름을 바꾸고 싶으면 같은 이름의 환경변수를 오버라이드하세요.

| Env override | Default Secret Manager name |
| --- | --- |
| `OPENAI_SECRET` | `sikdanscan-openai-api-key` |
| `FOOD_API_SECRET` | `sikdanscan-food-api-key` |
| `PROXY_TOKEN_SECRET` | `sikdanscan-proxy-client-token` |
| `AUTH_TOKEN_SECRET_NAME` | `sikdanscan-auth-token-secret` — `AUTH_TOKEN_SECRET`을 제공한 경우에만 생성 |

### 2. 컨테이너 빌드 및 Cloud Run 배포

```bash
export PROJECT_ID=your-gcp-project-id
export REGION=asia-northeast3
export SERVICE=sikdanscan-api
# 선택: 데모용 /v1/auth/*, /v1/me/* 파일 DB API를 켤 때만 true
# export ENABLE_LOCAL_DEMO_AUTH=true

scripts/deploy_cloud_run.sh
```

배포 스크립트는 다음 작업을 수행합니다.

- Cloud Run, Cloud Build, Artifact Registry, Secret Manager API 활성화
- Artifact Registry Docker repository 생성
- 루트 `Dockerfile` 기반 container image 빌드
- Cloud Run 서비스 배포
- `OPENAI_API_KEY`, `FOOD_API_KEY`, `PROXY_CLIENT_TOKEN`을 Secret Manager에서 주입
- `ENABLE_LOCAL_DEMO_AUTH=true`인 경우에만 `AUTH_TOKEN_SECRET`을 추가 주입
- Cloud Run 실행 서비스 계정에 `roles/secretmanager.secretAccessor` 권한 부여

기본 Cloud Run 운영 설정입니다. `RUN_SERVICE_ACCOUNT`를 지정하지 않으면 `sikdanscan-api-runner` 전용 서비스 계정을 생성해 사용합니다.

| 항목 | 값 |
| --- | --- |
| Region | `asia-northeast3` |
| min instances | `0` |
| max instances | `3` |
| memory | `512Mi` |
| cpu | `1` |
| concurrency | `20` |
| timeout | `60s` |
| `DATABASE_PATH` | `/tmp/sikdanscan_proxy_ephemeral_db.json` — 운영 영구 저장소로 사용하지 않음 |

### 3. 앱 운영 빌드에 API 주소 주입

Cloud Run 배포가 끝나면 출력된 service URL을 Flutter 앱에 주입합니다.

```bash
flutter build ipa \
  --dart-define=SIKDANSCAN_PROXY_BASE_URL=https://<cloud-run-service-url> \
  --dart-define=SIKDANSCAN_PROXY_CLIENT_TOKEN=$PROXY_CLIENT_TOKEN

flutter build appbundle \
  --dart-define=SIKDANSCAN_PROXY_BASE_URL=https://<cloud-run-service-url> \
  --dart-define=SIKDANSCAN_PROXY_CLIENT_TOKEN=$PROXY_CLIENT_TOKEN
```

Cloud Run 기본 URL을 그대로 써도 되지만, 운영 출시 전에는 `api.<domain>` 같은 custom domain을 연결하는 것을 권장합니다.

## Endpoints

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/health` | 헬스체크 |
| `GET` | `/ready` | DB/auth/upstream 설정 준비 상태 |
| `GET` | `/metrics` | Prometheus 스타일 request/latency/error metrics |
| `POST` | `/v1/auth/register` | 로컬/데모 전용 이메일 가입 — `AUTH_TOKEN_SECRET` 설정 시 활성 |
| `POST` | `/v1/auth/login` | 로컬/데모 전용 로그인 — `AUTH_TOKEN_SECRET` 설정 시 활성 |
| `GET` | `/v1/me` | 로컬/데모 전용 현재 사용자 조회 |
| `GET` | `/v1/me/meals` | 로컬/데모 전용 식단 레코드 조회 |
| `POST` | `/v1/me/meals` | 로컬/데모 전용 식단 레코드 저장 |
| `POST` | `/v1/chat` | AI 코치 응답 생성 |
| `GET` | `/v1/foods/public?query=...` | 식약처 식품영양정보 검색 |
| `POST` | `/v1/foods/analyze` | OpenAI 기반 음식 텍스트 영양 분석 |
| `POST` | `/v1/foods/recognize` | 음식 사진 기반 AI 비전 영양 분석 |

인증 정책은 두 계층으로 분리됩니다.

- `PROXY_CLIENT_TOKEN`이 설정되면 `/health`, `/ready`를 제외한 프록시/AI 엔드포인트와 `/metrics`, `/v1/auth/*`가 `Authorization: Bearer <proxy token>`을 요구합니다.
- `/v1/me/*`는 로컬/데모 auth로 발급된 access token을 요구합니다. 프로덕션 앱의 사용자 인증과 영구 식단 데이터는 Supabase Auth/Postgres/RLS를 사용합니다.

## 운영 메모

- `OPENAI_API_KEY`, `FOOD_API_KEY`는 서버 환경변수 또는 로컬 `.env.proxy`에만 보관합니다.
- `OPENAI_MODEL` 기본값은 `gpt-5.4-mini`이며, 필요하면 서버 환경변수 또는 `.env.proxy`에서 오버라이드할 수 있습니다.
- `AUTH_TOKEN_SECRET`은 로컬/데모용 `/v1/auth/*`, `/v1/me/*`를 켤 때만 필요하며 32바이트 이상 난수 값을 권장합니다. 운영 기본값에서는 주입하지 않습니다.
- `DATABASE_PATH`는 임시 파일 DB 위치입니다. Cloud Run에서는 `/tmp` 아래 ephemeral 파일만 사용하고, 사용자 영구 데이터는 Supabase Postgres/RLS에 저장하세요.
- `PROXY_CLIENT_TOKEN`을 설정하면 공개 health/readiness를 제외한 프록시 보호 엔드포인트가 `Authorization: Bearer <token>`을 요구합니다.
- 모바일 앱에 들어가는 프록시 토큰은 역공학될 수 있으므로 운영 환경에서는 사용자 인증, App Check/DeviceCheck, WAF 정책과 함께 사용하세요.
- `PROXY_RATE_LIMIT_PER_MINUTE` 기본값은 `60`입니다. `0` 이하로 설정하면 rate limit을 끕니다.
- 이미지 인식 요청은 base64 JSON payload를 받으며, 프록시에서 6MB 요청 본문과 4MB 이미지 바이너리 제한을 적용합니다.
- 브라우저 웹 빌드를 함께 제공한다면 `ALLOWED_ORIGINS`에 허용 origin을 쉼표로 지정하세요.
- 운영 모니터링은 `/ready`, `/metrics`, JSON request log, OpenAI quota/rate-limit 알림을 기준으로 구성하세요.
- 파일 DB는 단일 인스턴스 로컬 데모에만 적합합니다. 실제 사용자 데이터 운영은 Supabase Postgres/RLS를 사용하고, 이 프록시는 AI/API gateway로 유지하세요.

## 검증

```bash
flutter test test/server
dart analyze
```

`test/server`는 인증, CORS, 본문 크기 제한, JSON 오류, rate limit, 이미지 payload 검증, public parser, AI parser를 단위/통합 레벨에서 검증합니다.
현재 서버 테스트는 31개이며, 전체 Flutter 테스트는 168개입니다.
