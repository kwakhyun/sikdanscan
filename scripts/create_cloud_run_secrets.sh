#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-${1:-}}"
OPENAI_SECRET="${OPENAI_SECRET:-sikdanscan-openai-api-key}"
FOOD_API_SECRET="${FOOD_API_SECRET:-sikdanscan-food-api-key}"
PROXY_TOKEN_SECRET="${PROXY_TOKEN_SECRET:-sikdanscan-proxy-client-token}"
AUTH_TOKEN_SECRET_NAME="${AUTH_TOKEN_SECRET_NAME:-sikdanscan-auth-token-secret}"

if [[ -z "${PROJECT_ID}" ]]; then
  echo "Usage: PROJECT_ID=<gcp-project-id> OPENAI_API_KEY=... FOOD_API_KEY=... PROXY_CLIENT_TOKEN=... [AUTH_TOKEN_SECRET=...] $0" >&2
  exit 64
fi

: "${OPENAI_API_KEY:?OPENAI_API_KEY is required}"
: "${FOOD_API_KEY:?FOOD_API_KEY is required}"
: "${PROXY_CLIENT_TOKEN:?PROXY_CLIENT_TOKEN is required}"

if [[ -n "${AUTH_TOKEN_SECRET:-}" && "${#AUTH_TOKEN_SECRET}" -lt 32 ]]; then
  echo "AUTH_TOKEN_SECRET must be at least 32 characters when provided." >&2
  exit 65
fi

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud CLI is required." >&2
  exit 69
fi

gcloud config set project "${PROJECT_ID}" >/dev/null

gcloud services enable secretmanager.googleapis.com --project "${PROJECT_ID}"

upsert_secret() {
  local name="$1"
  local value="$2"

  if ! gcloud secrets describe "${name}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
    gcloud secrets create "${name}" \
      --replication-policy="automatic" \
      --project "${PROJECT_ID}" >/dev/null
  fi

  printf '%s' "${value}" | gcloud secrets versions add "${name}" \
    --data-file=- \
    --project "${PROJECT_ID}" >/dev/null

  echo "Updated Secret Manager secret: ${name}"
}

upsert_secret "${OPENAI_SECRET}" "${OPENAI_API_KEY}"
upsert_secret "${FOOD_API_SECRET}" "${FOOD_API_KEY}"
upsert_secret "${PROXY_TOKEN_SECRET}" "${PROXY_CLIENT_TOKEN}"

if [[ -n "${AUTH_TOKEN_SECRET:-}" ]]; then
  upsert_secret "${AUTH_TOKEN_SECRET_NAME}" "${AUTH_TOKEN_SECRET}"
else
  echo "Skipped ${AUTH_TOKEN_SECRET_NAME}; set AUTH_TOKEN_SECRET only for local demo auth endpoints."
fi
