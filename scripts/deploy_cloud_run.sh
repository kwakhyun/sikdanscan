#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-${1:-}}"
REGION="${REGION:-asia-northeast3}"
SERVICE="${SERVICE:-sikdanscan-api}"
REPOSITORY="${REPOSITORY:-sikdanscan}"
TAG="${TAG:-$(git rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${SERVICE}:${TAG}"

OPENAI_SECRET="${OPENAI_SECRET:-sikdanscan-openai-api-key}"
FOOD_API_SECRET="${FOOD_API_SECRET:-sikdanscan-food-api-key}"
PROXY_TOKEN_SECRET="${PROXY_TOKEN_SECRET:-sikdanscan-proxy-client-token}"
AUTH_TOKEN_SECRET_NAME="${AUTH_TOKEN_SECRET_NAME:-sikdanscan-auth-token-secret}"
ENABLE_LOCAL_DEMO_AUTH="${ENABLE_LOCAL_DEMO_AUTH:-false}"
PROXY_RATE_LIMIT_PER_MINUTE="${PROXY_RATE_LIMIT_PER_MINUTE:-60}"
SERVICE_ACCOUNT_NAME="${SERVICE_ACCOUNT_NAME:-sikdanscan-api-runner}"
RUN_SERVICE_ACCOUNT="${RUN_SERVICE_ACCOUNT:-}"

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Usage: PROJECT_ID=<gcp-project-id> $0" >&2
  echo "   or: $0 <gcp-project-id>" >&2
  exit 64
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud CLI is required." >&2
  exit 69
fi

gcloud config set project "${PROJECT_ID}" >/dev/null

if [[ -z "${RUN_SERVICE_ACCOUNT}" ]]; then
  RUN_SERVICE_ACCOUNT="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
fi

gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  iam.googleapis.com \
  --project "${PROJECT_ID}"

if [[ "${RUN_SERVICE_ACCOUNT}" == "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" ]]; then
  if ! gcloud iam service-accounts describe "${RUN_SERVICE_ACCOUNT}" \
    --project "${PROJECT_ID}" >/dev/null 2>&1; then
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
      --display-name="SikdanScan Cloud Run API" \
      --project "${PROJECT_ID}"
  fi
fi

if ! gcloud artifacts repositories describe "${REPOSITORY}" \
  --location "${REGION}" \
  --project "${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud artifacts repositories create "${REPOSITORY}" \
    --repository-format=docker \
    --location "${REGION}" \
    --description="SikdanScan container images" \
    --project "${PROJECT_ID}"
fi

SECRET_NAMES=("${OPENAI_SECRET}" "${FOOD_API_SECRET}" "${PROXY_TOKEN_SECRET}")
if [[ "${ENABLE_LOCAL_DEMO_AUTH}" == "true" ]]; then
  SECRET_NAMES+=("${AUTH_TOKEN_SECRET_NAME}")
fi

for secret in "${SECRET_NAMES[@]}"; do
  gcloud secrets describe "${secret}" --project "${PROJECT_ID}" >/dev/null
  gcloud secrets add-iam-policy-binding "${secret}" \
    --member "serviceAccount:${RUN_SERVICE_ACCOUNT}" \
    --role "roles/secretmanager.secretAccessor" \
    --project "${PROJECT_ID}" \
    --quiet >/dev/null
done

gcloud builds submit . \
  --tag "${IMAGE}" \
  --project "${PROJECT_ID}"

RUN_ENV_VARS="OPENAI_MODEL=gpt-5.4-mini,PROXY_RATE_LIMIT_PER_MINUTE=${PROXY_RATE_LIMIT_PER_MINUTE},DATABASE_PATH=/tmp/sikdanscan_proxy_ephemeral_db.json"
RUN_SECRETS="OPENAI_API_KEY=${OPENAI_SECRET}:latest,FOOD_API_KEY=${FOOD_API_SECRET}:latest,PROXY_CLIENT_TOKEN=${PROXY_TOKEN_SECRET}:latest"
if [[ "${ENABLE_LOCAL_DEMO_AUTH}" == "true" ]]; then
  RUN_SECRETS="${RUN_SECRETS},AUTH_TOKEN_SECRET=${AUTH_TOKEN_SECRET_NAME}:latest"
fi

gcloud run deploy "${SERVICE}" \
  --image "${IMAGE}" \
  --region "${REGION}" \
  --platform managed \
  --allow-unauthenticated \
  --service-account "${RUN_SERVICE_ACCOUNT}" \
  --port 8080 \
  --cpu 1 \
  --memory 512Mi \
  --concurrency 20 \
  --timeout 60 \
  --min-instances 0 \
  --max-instances 3 \
  --set-env-vars "${RUN_ENV_VARS}" \
  --set-secrets "${RUN_SECRETS}" \
  --project "${PROJECT_ID}"

SERVICE_URL="$(gcloud run services describe "${SERVICE}" \
  --region "${REGION}" \
  --project "${PROJECT_ID}" \
  --format='value(status.url)')"

echo "Cloud Run service deployed: ${SERVICE_URL}"
echo "Configure Flutter with: --dart-define=SIKDANSCAN_PROXY_BASE_URL=${SERVICE_URL}"
