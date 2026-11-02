#!/usr/bin/env bash
set -euo pipefail

set_failure_reason() {
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    printf 'failure-reason=%s\n' "$1" >> "$GITHUB_OUTPUT"
  fi
}

case "${RUNNER_OS}/${RUNNER_ARCH}" in
  Linux/X64)   platform="Linux_x86_64" ;;
  Linux/ARM64) platform="Linux_arm64" ;;
  macOS/X64)   platform="Darwin_x86_64" ;;
  macOS/ARM64) platform="Darwin_arm64" ;;
  *) echo "Unsupported runner: ${RUNNER_OS}/${RUNNER_ARCH}" >&2; set_failure_reason unsupported-runner; exit 1 ;;
esac

version="${YAMLFMT_VERSION#v}"
version_tag="v${version}"
archive="yamlfmt_${version}_${platform}.tar.gz"
release_url="https://github.com/google/yamlfmt/releases/download/${version_tag}"
install_dir="${RUNNER_TEMP}/yamlfmt-${version}"
mkdir -p "$install_dir"
curl --fail --silent --show-error --location "${release_url}/${archive}" -o "${install_dir}/${archive}"
for file in checksums.txt checksums.txt.pem checksums.txt.sig; do
  curl --fail --silent --show-error --location "${release_url}/${file}" -o "${install_dir}/${file}"
done
cosign verify-blob "${install_dir}/checksums.txt" \
  --certificate "${install_dir}/checksums.txt.pem" \
  --signature "${install_dir}/checksums.txt.sig" \
  --certificate-identity "https://github.com/google/yamlfmt/.github/workflows/release.yaml@refs/tags/${version_tag}" \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com'

checksum_line="$(awk -v asset="$archive" '$2 == asset { print $0 }' "${install_dir}/checksums.txt")"
if [[ -z "$checksum_line" ]]; then
  echo "No checksum found for ${archive}." >&2
  set_failure_reason checksum-missing
  exit 1
fi
if ! (cd "$install_dir" && printf '%s\n' "$checksum_line" | shasum --algorithm 256 --check --status); then
  echo "Checksum mismatch for ${archive}." >&2
  set_failure_reason checksum-mismatch
  exit 1
fi
tar -xzf "${install_dir}/${archive}" -C "$install_dir" yamlfmt
chmod +x "${install_dir}/yamlfmt"

paths=()
while IFS= read -r path || [[ -n "$path" ]]; do
  path="${path#"${path%%[![:space:]]*}"}"
  path="${path%"${path##*[![:space:]]}"}"
  [[ -z "$path" ]] && continue
  case "$path" in
    *'*'*|*'?'*|*'['*|*'{'*) paths+=("$path") ;;
    *)
      if [[ ! -e "$path" ]]; then
        echo "Path does not exist: ${path}" >&2
        set_failure_reason path-not-found
        exit 1
      fi
      paths+=("$path")
      ;;
  esac
done <<< "$INPUT_PATHS"

if [[ ${#paths[@]} -eq 0 ]]; then
  echo "No file paths or patterns were provided." >&2
  set_failure_reason no-paths
  exit 1
fi

yamlfmt_args=(-lint)
if [[ -n "$INPUT_CONFIG_FILE" ]]; then yamlfmt_args+=(-conf "$INPUT_CONFIG_FILE"); fi
if [[ "$INPUT_DSTAR" == "true" ]]; then yamlfmt_args+=(-dstar); fi
yamlfmt_args+=(-debug paths)
set +e
yamlfmt_output="$("${install_dir}/yamlfmt" "${yamlfmt_args[@]}" "${paths[@]}" 2>&1)"
yamlfmt_status=$?
set -e

# yamlfmt has no machine-readable match count. This check relies on debug text
# from the pinned version; CI covers both map and slice empty-list forms.
if grep -Eq 'paths to format: (map)?\[\]$' <<< "$yamlfmt_output"; then
  echo "No YAML files matched the supplied paths." >&2
  set_failure_reason no-matches
  exit 1
fi

# Retain the full output above for checks, but omit verbose debug lines in logs.
grep -v '^\[DEBUG\]' <<< "$yamlfmt_output" || true
if [[ "$yamlfmt_status" -ne 0 ]]; then set_failure_reason formatting-failed; fi
exit "$yamlfmt_status"
