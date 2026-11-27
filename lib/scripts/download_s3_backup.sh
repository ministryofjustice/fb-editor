#!/usr/bin/env bash
#
# Download an S3 object (via a Kubernetes pod) to your local machine.
#
# Usage:
#   ./lib/scripts/download_s3_backup.sh [-n NAMESPACE] [-p POD] [-k KEY] [-o OUTPUT] [-d] [-b]
#   -n NAMESPACE  namespace       (default: formbuilder-saas-test)
#   -p POD        pod name        (default: first pod matching POD_PREFIX)
#   -k KEY        S3 object key   (default: metadata-backups/metadata-backup-xyz.zip)
#.  -b BUCKET     S3 bucket       (default: cloud-platform-XYZ)
#   -o OUTPUT     local filename  (default: basename of the key)
#   -c            run Export::S3::Form::MetadataBackup first (creates a new backup)
#   -d            delete the object from S3 after a successful download
#
# Commands
#   Create backup:
#     ./lib/scripts/download_s3_backup.sh -n <NAMESPACE> -p fb-editor-workers-test-ccf76cd4f-vm467 -b <BUCKET_NAME> -c
#   Delete backup:
#     ./lib/scripts/download_s3_backup.sh -n <NAMESPACE> -p fb-editor-workers-test-ccf76cd4f-vm467 -b <BUCKET_NAME> -k metadata-backups/metadata-backup-20261127T120251Z.zip -d
#   Download backup:
#     ./lib/scripts/download_s3_backup.sh -n <NAMESPACE> -p fb-editor-workers-test-ccf76cd4f-vm467 -b <BUCKET_NAME> -k metadata-backups/metadata-backup-20261127T114311Z.zip -o metadata-backup-20261127T114311Z.zip
set -euo pipefail

# ---- config ----------------------------------------------------------------
NAMESPACE=""
POD_PREFIX="fb-editor-workers-test"
REGION="eu-west-2"
BUCKET=""
KEY="metadata-backups/metadata-backup-xyz.zip"
OUTPUT=""
POD=""
RUN_BACKUP=false
DELETE=false
APP_DIR="/app"
# -----------------------------------------------------------------------------

while getopts "n:k:b:o:p:cd" opt; do
  case "$opt" in
    n) NAMESPACE="$OPTARG" ;;
    k) KEY="$OPTARG" ;;
    b) BUCKET="$OPTARG" ;;
    o) OUTPUT="$OPTARG" ;;
    p) POD="$OPTARG" ;;
    c) RUN_BACKUP=true ;;
    d) DELETE=true ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
  esac
done

OUTPUT="${OUTPUT:-$(basename "$KEY")}"
REMOTE_FILE="/tmp/$(basename "$KEY")"

# Find a pod if one wasn't given
if [[ -z "$POD" ]]; then
  POD=$(kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name" \
        | grep "^${POD_PREFIX}" | head -n1 || true)
  [[ -n "$POD" ]] || { echo "No pod found matching '${POD_PREFIX}' in ${NAMESPACE}" >&2; exit 1; }
fi
echo "Using NAMESPACE: $NAMESPACE"
echo "Using POD: $POD"
echo "Using REGION: $REGION"
echo "Using BUCKET: $BUCKET"

rails_runner() {
  kubectl exec -n "$NAMESPACE" "$POD" -- \
    env AWS_REGION="$REGION" BUCKET="$BUCKET" KEY="$KEY" REMOTE_FILE="$REMOTE_FILE" \
    bash -c "cd ${APP_DIR} && bundle exec rails runner '$1'"
}

# 1. (optional) create a fresh backup
if $RUN_BACKUP; then
  echo "Creating new metadata backup..."
  rails_runner 'Export::S3::Form::MetadataBackup.call(bucket: ENV["BUCKET"])'
  echo "Backup created."
  exit 0
fi

# 2. (optional) delete from S3
if $DELETE; then
  echo
  echo "About to permanently delete: s3://${BUCKET}/${KEY}"
  read -r -p "Are you sure? Type 'yes' to confirm: " CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo "Delete cancelled. Local copy kept at: ${OUTPUT}"
    exit 0
  fi
  echo "Deleting s3://${BUCKET}/${KEY} ..."
  rails_runner '
    Aws::S3::Client.new(region: ENV["AWS_REGION"]).delete_object(bucket: ENV["BUCKET"], key: ENV["KEY"])
    puts "Deleted"
  '
  echo "Deleted s3://${BUCKET}/${KEY}"
  exit 0
fi

# 3. download from S3 to the pod's /tmp
echo "Downloading s3://${BUCKET}/${KEY} to pod:${REMOTE_FILE} ..."
rails_runner '
  s3 = Aws::S3::Client.new(region: ENV["AWS_REGION"])
  File.open(ENV["REMOTE_FILE"], "wb") do |f|
    s3.get_object(bucket: ENV["BUCKET"], key: ENV["KEY"]) { |chunk, _| f.write(chunk) }
  end
  puts "Saved #{File.size(ENV["REMOTE_FILE"])} bytes"
'

# 4. copy from the pod to the local machine
echo "Copying to local: ${OUTPUT}"
kubectl cp "${NAMESPACE}/${POD}:${REMOTE_FILE}" "$OUTPUT"

# 5. clean up the temp file in the pod
kubectl exec -n "$NAMESPACE" "$POD" -- rm -f "$REMOTE_FILE"

echo "Done: $(ls -lh "$OUTPUT" | awk '{print $5, $9}')"
