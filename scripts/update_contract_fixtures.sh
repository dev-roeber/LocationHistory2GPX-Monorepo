#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRODUCER_ROOT="${1:-"${REPO_ROOT}/../LocationHistory2GPX"}"
FIXTURE_DIR="${REPO_ROOT}/Fixtures/contract"
DEMO_RESOURCE_DIR="${REPO_ROOT}/Sources/LocationHistoryConsumerDemoSupport/Resources"

if [[ ! -d "${PRODUCER_ROOT}" ]]; then
  echo "Producer repo not found: ${PRODUCER_ROOT}" >&2
  exit 1
fi

required=(
  "app_export.schema.json"
  "testdata/golden/app_export_contract_gate.json"
  "testdata/golden/app_export_sample_small.json"
  "testdata/golden/app_export_sample_medium.json"
  "testdata/golden/app_export_sample_placeholder_many_days.json"
  "testdata/golden/app_export_sample_placeholder_mixed.json"
  "testdata/golden/app_export_sample_placeholder_nulls.json"
  "testdata/golden/app_export_sample_placeholder_stats_activities_only.json"
  "testdata/golden/app_export_sample_placeholder_stats_periods_only.json"
)

for path in "${required[@]}"; do
  if [[ ! -f "${PRODUCER_ROOT}/${path}" ]]; then
    echo "Missing required producer artifact: ${PRODUCER_ROOT}/${path}" >&2
    exit 1
  fi
done

mkdir -p "${FIXTURE_DIR}"

cp "${PRODUCER_ROOT}/app_export.schema.json" "${FIXTURE_DIR}/app_export.schema.json"

for path in "${required[@]:1}"; do
  base="$(basename "${path}")"
  cp "${PRODUCER_ROOT}/${path}" "${FIXTURE_DIR}/golden_${base}"
done

if [[ -d "${DEMO_RESOURCE_DIR}" ]]; then
  cp "${FIXTURE_DIR}/golden_app_export_sample_small.json" "${DEMO_RESOURCE_DIR}/golden_app_export_sample_small.json"
fi

producer_commit="$(git -C "${PRODUCER_ROOT}" rev-parse --short=7 HEAD)"

python3 - <<'PY' "${FIXTURE_DIR}/CONTRACT_SOURCE.json" "${producer_commit}"
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
producer_commit = sys.argv[2]

manifest = json.loads(manifest_path.read_text())
manifest["producer_commit"] = producer_commit
manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
PY

echo "Updated producer-derived contract artifacts from ${PRODUCER_ROOT} at ${producer_commit}"
