#!/usr/bin/env bash
# upload_to_drive.sh
# Uploads cv.pdf to Google Drive using rclone.
#
# CI mode (GDRIVE_ACCESS_TOKEN is set):
#   Configures rclone via environment variables using the short-lived access
#   token provided by Workload Identity Federation. No config file is written.
#   Requires: GDRIVE_ACCESS_TOKEN, GOOGLE_DRIVE_FOLDER_ID
#
# Local mode (GDRIVE_ACCESS_TOKEN is not set):
#   Uses an existing rclone remote named 'gdrive' configured via 'rclone config'.
#   Requires: GOOGLE_DRIVE_FOLDER_ID (or ROOT_FOLDER_ID set in rclone config)

set -euo pipefail

PDF="cv.pdf"

if [[ ! -f "${PDF}" ]]; then
    echo "Error: ${PDF} not found. Run build_pdf.sh first." >&2
    exit 1
fi

if [[ -n "${GDRIVE_ACCESS_TOKEN:-}" ]]; then
    # ── CI mode ────────────────────────────────────────────────────────────────
    echo "CI mode: configuring rclone via environment variables..."

    if [[ -z "${GOOGLE_DRIVE_FOLDER_ID:-}" ]]; then
        echo "Error: GOOGLE_DRIVE_FOLDER_ID must be set in CI mode." >&2
        exit 1
    fi

    # Build a minimal token JSON that rclone accepts.
    # The expiry is set far in the future; the token itself is short-lived and
    # will be rejected by Google if expired — rclone will surface that error.
    TOKEN_JSON="{\"access_token\":\"${GDRIVE_ACCESS_TOKEN}\",\"token_type\":\"Bearer\",\"expiry\":\"2099-01-01T00:00:00Z\"}"

    export RCLONE_CONFIG_GDRIVE_TYPE="drive"
    # export RCLONE_CONFIG_GDRIVE_SCOPE="drive.file"
    # export RCLONE_CONFIG_GDRIVE_TOKEN="${TOKEN_JSON}"
    # export RCLONE_CONFIG_GDRIVE_ROOT_FOLDER_ID="${GOOGLE_DRIVE_FOLDER_ID}"

    echo "Uploading ${PDF} to Google Drive folder ${GOOGLE_DRIVE_FOLDER_ID}..."
    rclone copy "${PDF}" gdrive: --no-update-modtime --drive-scope "drive.file" --drive-token "${TOKEN_JSON}" --drive-root-folder-id "${GOOGLE_DRIVE_FOLDER_ID}"
else
    # ── Local mode ─────────────────────────────────────────────────────────────
    echo "Local mode: using existing 'gdrive' rclone remote..."

    if ! rclone listremotes | grep -q "^gdrive:"; then
        echo "Error: no rclone remote named 'gdrive' found." >&2
        echo "Run 'rclone config' to create one, or see setup_gcp.sh for instructions." >&2
        exit 1
    fi

    echo "Uploading ${PDF} to gdrive:..."
    rclone copyTo "${PDF}" gdrive: --no-update-modtime
fi

echo "Upload complete."
