# 식단스캔 API Proxy

Flutter 앱에 OpenAI/Data.go.kr 키를 포함하지 않기 위한 경량 Dart 프록시입니다.

## 구조

```text
server/
├── bin/sikdanscan_proxy.dart      # 실행 엔트리포인트
└── lib/src/
    ├── proxy_handlers.dart     # 라우팅, 인증, 에러 매핑
    ├── upstream_client.dart    # OpenAI/Data.go.kr upstream 호출
    ├── food_parsers.dart       # 외부 응답 정규화
    ├── client_auth.dart        # Bearer 토큰 검증
    ├── cors.dart               # Origin 제한
    └── rate_limiter.dart       # IP 기반 minute bucket rate limit
```

## 실행

```bash
cp .env.proxy.example .env.proxy
# .env.proxy 파일에 OPENAI_API_KEY / FOOD_API_KEY 입력
dart run server/bin/sikdanscan_proxy.dart
```

`server/bin/sikdanscan_proxy.dart`는 로컬 실행 시 `.env.proxy`를 우선 읽고, 없으면 `.env`를 fallback으로 읽습니다. `Platform.environment`에 이미 설정된 값은 파일 값으로 덮어쓰지 않습니다.

Flutter 앱의 `.env`에는 공개 주소만 설정합니다.

```bash
SIKDANSCAN_PROXY_BASE_URL=http://localhost:8080
SIKDANSCAN_PROXY_CLIENT_TOKEN=replace_with_non_secret_client_token
```

로컬 주소는 실행 대상에 따라 달라집니다.

| 실행 대상 | `SIKDANSCAN_PROXY_BASE_URL` |
| --- | --- |
| iOS Simulator / macOS / web | `http://localhost:8080` |
| Android Emulator | `http://10.0.2.2:8080` |
| 실기기 | `http://<개발 머신 LAN IP>:8080` 또는 배포된 HTTPS URL |

## Endpoints

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/health` | 헬스체크 |
| `POST` | `/v1/chat` | AI 코치 응답 생성 |
| `GET` | `/v1/foods/public?query=...` | 식약처 식품영양정보 검색 |
| `POST` | `/v1/foods/analyze` | OpenAI 기반 음식 텍스트 영양 분석 |
| `POST` | `/v1/foods/recognize` | 음식 사진 기반 AI 비전 영양 분석 |

## 운영 메모

- `OPENAI_API_KEY`, `FOOD_API_KEY`는 서버 환경변수 또는 로컬 `.env.proxy`에만 보관합니다.
- `OPENAI_MODEL` 기본값은 `gpt-5.4-mini`이며, 필요하면 서버 환경변수 또는 `.env.proxy`에서 오버라이드할 수 있습니다.
- `PROXY_CLIENT_TOKEN`을 설정하면 `/health`를 제외한 모든 API 엔드포인트가 `Authorization: Bearer <token>`을 요구합니다.
- 모바일 앱에 들어가는 토큰은 역공학될 수 있으므로 운영 환경에서는 사용자 인증, App Check/DeviceCheck, WAF 정책과 함께 사용하세요.
- `PROXY_RATE_LIMIT_PER_MINUTE` 기본값은 `60`입니다. `0` 이하로 설정하면 rate limit을 끕니다.
- 이미지 인식 요청은 base64 JSON payload를 받으며, 프록시에서 6MB 요청 본문과 4MB 이미지 바이너리 제한을 적용합니다.
- 브라우저 웹 빌드를 함께 제공한다면 `ALLOWED_ORIGINS`에 허용 origin을 쉼표로 지정하세요.
- 실서비스에서는 observability, secret manager, 배포 플랫폼의 WAF/rate limit을 추가하세요.

## 검증

```bash
flutter test test/server
dart analyze
```

`test/server`는 인증, CORS, 본문 크기 제한, JSON 오류, rate limit, 이미지 payload 검증, public parser, AI parser를 단위/통합 레벨에서 검증합니다.
