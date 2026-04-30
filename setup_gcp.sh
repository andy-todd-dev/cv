#!/usr/bin/env bash
# setup_gcp.sh
# One-time setup script to configure GCP Workload Identity Federation for
# GitHub Actions and set the required GitHub Actions secrets.
#
# Prerequisites:
#   - gcloud CLI authenticated: gcloud auth login
#   - gh CLI authenticated:     gh auth login
#   - Sufficient IAM permissions on the GCP project

set -euo pipefail

GITHUB_REPO="andy-todd-dev/cv"
WIF_POOL_ID="github-actions"
WIF_PROVIDER_ID="github"
SERVICE_ACCOUNT_NAME="cv-uploader"

# ── Prompt for project ID ──────────────────────────────────────────────────────
read -rp "Enter your GCP project ID: " PROJECT_ID

echo ""
echo "Using project: ${PROJECT_ID}"
echo ""

# ── Derive project number ──────────────────────────────────────────────────────
echo "Fetching project number..."
PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
echo "Project number: ${PROJECT_NUMBER}"
echo ""

SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
WIF_POOL_RESOURCE="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_ID}"
WIF_PROVIDER_RESOURCE="${WIF_POOL_RESOURCE}/providers/${WIF_PROVIDER_ID}"

# ── Enable required APIs ───────────────────────────────────────────────────────
echo "Enabling required APIs..."
gcloud services enable \
    drive.googleapis.com \
    iam.googleapis.com \
    iamcredentials.googleapis.com \
    --project="${PROJECT_ID}"
echo "APIs enabled."
echo ""

# ── Create Workload Identity Pool ─────────────────────────────────────────────
echo "Creating Workload Identity Pool '${WIF_POOL_ID}'..."
if gcloud iam workload-identity-pools describe "${WIF_POOL_ID}" \
    --location="global" \
    --project="${PROJECT_ID}" \
    --format="value(name)" &>/dev/null; then
    echo "Pool already exists, skipping."
else
    gcloud iam workload-identity-pools create "${WIF_POOL_ID}" \
        --location="global" \
        --display-name="GitHub Actions" \
        --project="${PROJECT_ID}"
    echo "Pool created."
fi
echo ""

# ── Create OIDC Provider ───────────────────────────────────────────────────────
echo "Creating OIDC provider '${WIF_PROVIDER_ID}'..."
if gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER_ID}" \
    --workload-identity-pool="${WIF_POOL_ID}" \
    --location="global" \
    --project="${PROJECT_ID}" \
    --format="value(name)" &>/dev/null; then
    echo "Provider already exists, skipping."
else
    gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER_ID}" \
        --workload-identity-pool="${WIF_POOL_ID}" \
        --location="global" \
        --issuer-uri="https://token.actions.githubusercontent.com" \
        --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
        --attribute-condition="assertion.repository=='${GITHUB_REPO}'" \
        --project="${PROJECT_ID}"
    echo "Provider created."
fi
echo ""

# ── Create Service Account ─────────────────────────────────────────────────────
echo "Creating service account '${SERVICE_ACCOUNT_EMAIL}'..."
if gcloud iam service-accounts describe "${SERVICE_ACCOUNT_EMAIL}" \
    --project="${PROJECT_ID}" \
    --format="value(email)" &>/dev/null; then
    echo "Service account already exists, skipping."
else
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
        --display-name="CV Drive Uploader" \
        --project="${PROJECT_ID}"
    echo "Service account created."
fi
echo ""

# ── Bind Workload Identity User role ──────────────────────────────────────────
echo "Binding workloadIdentityUser role to service account..."
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${WIF_POOL_RESOURCE}/attribute.repository/${GITHUB_REPO}" \
    --project="${PROJECT_ID}"
echo "Binding applied."
echo ""

# ── Google Drive folder setup (manual step) ───────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MANUAL STEP REQUIRED — Google Drive folder sharing"
echo ""
echo "This step cannot be automated. Please do the following:"
echo ""
echo "  1. Go to Google Drive: https://drive.google.com"
echo "  2. Create a new folder (e.g. 'CV') or choose an existing one."
echo "  3. Right-click the folder → Share → Add the following email as Editor:"
echo ""
echo "       ${SERVICE_ACCOUNT_EMAIL}"
echo ""
echo "  4. Copy the folder ID from the URL:"
echo "       https://drive.google.com/drive/folders/<FOLDER_ID>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -rp "Paste the Google Drive folder ID: " DRIVE_FOLDER_ID
echo ""

# ── Set GitHub Actions secrets ─────────────────────────────────────────────────
echo "Setting GitHub Actions secrets on '${GITHUB_REPO}'..."

gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER \
    --repo="${GITHUB_REPO}" \
    --body="${WIF_PROVIDER_RESOURCE}"

gh secret set GCP_SERVICE_ACCOUNT \
    --repo="${GITHUB_REPO}" \
    --body="${SERVICE_ACCOUNT_EMAIL}"

gh secret set GOOGLE_DRIVE_FOLDER_ID \
    --repo="${GITHUB_REPO}" \
    --body="${DRIVE_FOLDER_ID}"

echo "Secrets set:"
echo "  GCP_WORKLOAD_IDENTITY_PROVIDER = ${WIF_PROVIDER_RESOURCE}"
echo "  GCP_SERVICE_ACCOUNT            = ${SERVICE_ACCOUNT_EMAIL}"
echo "  GOOGLE_DRIVE_FOLDER_ID         = ${DRIVE_FOLDER_ID}"
echo ""

# ── Local rclone configuration ────────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OPTIONAL — Configure rclone locally for upload_to_drive.sh in local mode"
echo ""
echo "  Run: rclone config"
echo "  Then follow the prompts to create a remote named 'gdrive':"
echo "    - Type:         drive"
echo "    - Scope:        drive.file"
echo "    - Root folder:  ${DRIVE_FOLDER_ID}"
echo "    - Authenticate interactively when prompted (opens browser)"
echo ""
echo "  Once configured, export this variable in your shell profile:"
echo "    export GOOGLE_DRIVE_FOLDER_ID=${DRIVE_FOLDER_ID}"
echo ""
echo "  Then run upload_to_drive.sh directly without any extra setup."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Setup complete."
