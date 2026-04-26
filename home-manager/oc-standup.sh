#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: oc-standup [--dry-run] [--push] [--emit-raw DIR] [--no-llm]

Generate standup notes from recent shell, session, and git activity.

Options:
  --dry-run       Print computed window and planned actions only
  --push          Push the notes repo after a successful commit (private repos only)
  --emit-raw DIR  Write raw collector files into DIR for QA/debugging
  --no-llm        Skip the summarization call (reserved for QA)
  -h, --help      Show this help
EOF
}

DRY_RUN=0
DO_PUSH=0
NO_LLM=0
EMIT_RAW_DIR=

while [ "$#" -gt 0 ]; do
  case "$1" in
  --dry-run)
    DRY_RUN=1
    ;;
  --push)
    DO_PUSH=1
    ;;
  --no-llm)
    NO_LLM=1
    ;;
  --emit-raw)
    if [ "$#" -lt 2 ]; then
      echo "oc-standup: --emit-raw requires a directory argument" >&2
      exit 2
    fi
    EMIT_RAW_DIR="$2"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "oc-standup: unknown argument: $1" >&2
    usage >&2
    exit 2
    ;;
  esac
  shift
done

export TZ=America/Los_Angeles
export OC_STANDUP=1

NOTES_REPO="${HOME}/source/personal/notes"
SOURCE_ROOT="${HOME}/source"
STANDUP_DIR="${NOTES_REPO}/standup"
LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_FILE="${LOCK_DIR}/oc-standup.lock"
VISIBILITY_FILE="${HOME}/.config/sisyphus/notes-visibility"
MAX_ATUIN_ROWS=500
MAX_SESSION_COUNT=8
MAX_SESSION_BYTES=200000
MAX_SECTION_LINES=40
MAX_PRS=20
REDACT_CONFIG_PATH="${HOME}/.config/home-manager/oc-standup-redact.toml"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/oc-standup.XXXXXX")"
trap 'rm -rf -- "${TMP_DIR}"' EXIT INT TERM HUP

mkdir -p "${LOCK_DIR}"
exec 9>"${LOCK_FILE}"
if ! flock -n 9; then
  echo "another oc-standup is running" >&2
  exit 1
fi

if [ -n "${OC_STANDUP_FAKE_TODAY:-}" ]; then
  TODAY="${OC_STANDUP_FAKE_TODAY}"
else
  TODAY="$(date +%F)"
fi

DAY_OF_WEEK="$(date -d "${TODAY}" +%u)"
# Fri/Sat/Sun/Mon walk back to the most recent Thursday so a Monday (or
# weekend) standup covers Thu/Fri/Sat/Sun activity in one note.
case "${DAY_OF_WEEK}" in
5) START="$(date -d "${TODAY} -1 day" +%F)" ;;
6) START="$(date -d "${TODAY} -2 days" +%F)" ;;
7) START="$(date -d "${TODAY} -3 days" +%F)" ;;
1) START="$(date -d "${TODAY} -4 days" +%F)" ;;
*) START="$(date -d "${TODAY} -1 day" +%F)" ;;
esac
END="${TODAY}"
OUTPUT_PATH="${STANDUP_DIR}/${TODAY}.md"
WINDOW_AFTER="${START} 00:00"
WINDOW_BEFORE="${END} 00:00"
START_MS="$(($(date -d "${WINDOW_AFTER}" +%s) * 1000))"
END_MS="$(($(date -d "${WINDOW_BEFORE}" +%s) * 1000))"

if [ -n "${EMIT_RAW_DIR}" ]; then
  RAW_DIR="${EMIT_RAW_DIR}"
else
  RAW_DIR="${TMP_DIR}/raw"
fi

ATUIN_RAW="${RAW_DIR}/atuin.txt"
SESSIONS_RAW="${RAW_DIR}/sessions.txt"
GIT_RAW="${RAW_DIR}/git.txt"
PRS_RAW="${RAW_DIR}/prs.txt"

mkdir -p "${RAW_DIR}"
: >"${ATUIN_RAW}"
: >"${SESSIONS_RAW}"
: >"${GIT_RAW}"
: >"${PRS_RAW}"

VISIBILITY=
if [ -f "${VISIBILITY_FILE}" ]; then
  VISIBILITY="$(tr -d '[:space:]' <"${VISIBILITY_FILE}")"
fi

echo "start=${START}"
echo "end=${END}"
echo "notes_repo=${NOTES_REPO}"
echo "output_path=${OUTPUT_PATH}"
echo "dry_run=${DRY_RUN}"
echo "push=${DO_PUSH}"
echo "no_llm=${NO_LLM}"
echo "visibility=${VISIBILITY:-unknown}"

if [ "${DO_PUSH}" = "1" ] && [ "${VISIBILITY:-}" != "private" ]; then
  echo "oc-standup: refusing --push because notes repo visibility is not private" >&2
  exit 1
fi

collect_atuin() {
  atuin search \
    --after "${WINDOW_AFTER}" \
    --before "${WINDOW_BEFORE}" \
    --reverse \
    --limit "${MAX_ATUIN_ROWS}" \
    --format '{time}|{exit}|{directory}|{command}' >"${ATUIN_RAW}"
}

collect_sessions() {
  local session_list_json
  local session_id
  local session_title
  local session_directory
  local session_updated
  local session_export_path
  local session_bytes
  local total_bytes
  local count

  session_list_json="${TMP_DIR}/session-list.json"
  opencode session list -n 200 --format json >"${session_list_json}"

  total_bytes=0
  count=0
  while IFS=$'\t' read -r session_id session_updated session_directory session_title; do
    [ -n "${session_id}" ] || continue
    if [ "${count}" -ge "${MAX_SESSION_COUNT}" ]; then
      break
    fi

    session_export_path="${TMP_DIR}/${session_id}.json"
    opencode export "${session_id}" --sanitize >"${session_export_path}"
    session_bytes="$(wc -c <"${session_export_path}")"
    if [ $((total_bytes + session_bytes)) -gt "${MAX_SESSION_BYTES}" ]; then
      break
    fi

    {
      printf '=== SESSION %s ===\n' "${session_id}"
      printf 'updated_ms=%s\n' "${session_updated}"
      printf 'directory=%s\n' "${session_directory}"
      printf 'title=%s\n' "${session_title}"
      cat "${session_export_path}"
      printf '\n\n'
    } >>"${SESSIONS_RAW}"

    total_bytes=$((total_bytes + session_bytes))
    count=$((count + 1))
  done < <(
    jq -r \
      --arg notes_repo "${NOTES_REPO}" \
      --argjson start_ms "${START_MS}" \
      --argjson end_ms "${END_MS}" \
      '
        .[]
        | select(.directory != $notes_repo)
        | select((.title // "") | test("standup"; "i") | not)
        | select(((.updated // .created) >= $start_ms) and ((.updated // .created) < $end_ms))
        | [
            .id,
            (.updated // .created | tostring),
            (.directory // ""),
            (.title // "")
          ]
        | @tsv
      ' "${session_list_json}"
  )
}

collect_git() {
  local git_dir
  local repo_root
  local repo_email
  local fallback_email
  local common_dir
  local origin_url
  local seen_common_dirs
  local seen_origins

  fallback_email="$(git config --global --get user.email || true)"
  seen_common_dirs="${TMP_DIR}/git-common-dirs.txt"
  seen_origins="${TMP_DIR}/git-origins.txt"
  : >"${seen_common_dirs}"
  : >"${seen_origins}"

  while IFS= read -r git_dir; do
    repo_root="$(dirname "${git_dir}")"
    if [ "${repo_root}" = "${NOTES_REPO}" ]; then
      continue
    fi

    repo_email="$(git -C "${repo_root}" config --get user.email || true)"
    if [ -z "${repo_email}" ]; then
      repo_email="${fallback_email}"
    fi
    if [ -z "${repo_email}" ]; then
      continue
    fi

    if git -C "${repo_root}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      common_dir="$(git -C "${repo_root}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
      if [ -n "${common_dir}" ] && grep -Fxq "${common_dir}" "${seen_common_dirs}"; then
        continue
      fi
      # Sibling clones (e.g. parallel worktrees t1/t2/t3/t4 of the same upstream
      # repo) have distinct common-dirs but identical origin URLs — dedup by
      # origin to avoid multiplying commit counts in the digest.
      origin_url="$(git -C "${repo_root}" remote get-url origin 2>/dev/null || true)"
      if [ -n "${origin_url}" ] && grep -Fxq "${origin_url}" "${seen_origins}"; then
        continue
      fi
      if [ -n "${common_dir}" ]; then
        printf '%s\n' "${common_dir}" >>"${seen_common_dirs}"
      fi
      if [ -n "${origin_url}" ]; then
        printf '%s\n' "${origin_url}" >>"${seen_origins}"
      fi

      {
        printf '=== REPO %s ===\n' "${repo_root}"
        git -C "${repo_root}" log --remotes=origin \
          --since "${WINDOW_AFTER}" \
          --until "${WINDOW_BEFORE}" \
          --author "${repo_email}" \
          --no-merges \
          --pretty=format:'%h %aI %ae %s'
        printf '\n\n'
      } >>"${GIT_RAW}"
    fi
  done < <(
    find "${SOURCE_ROOT}" \
      \( -path '*/node_modules' -o -path '*/.direnv' -o -path '*/.terraform' -o -path '*/result' -o -path '*/result-*' \) -prune -o \
      -name .git -type d -print
  )
}

collect_prs() {
  local search_json
  local pr_count
  local pr_rows
  local pr_lines_dir

  search_json="${TMP_DIR}/prs-search.json"
  if ! gh search prs \
    --author=@me \
    --state=open \
    --draft=false \
    --updated=">=${START}" \
    --limit "${MAX_PRS}" \
    --json repository,number,title,url,updatedAt \
    >"${search_json}" 2>/dev/null; then
    return
  fi

  pr_count="$(jq 'length' "${search_json}")"
  if [ "${pr_count}" = "0" ]; then
    return
  fi

  pr_rows="${TMP_DIR}/prs-rows.tsv"
  pr_lines_dir="${TMP_DIR}/pr-lines"
  mkdir -p "${pr_lines_dir}"

  jq -r '
    .[]
    | [
        .repository.nameWithOwner,
        (.number | tostring),
        .title,
        .url,
        .updatedAt
      ]
    | @tsv
  ' "${search_json}" >"${pr_rows}"

  # Parallel `gh pr view` (xargs -P) with per-worker output files to
  # avoid stdout interleaving; `timeout` caps any hung gh call.
  local worker_script="${TMP_DIR}/pr-worker.sh"
  cat >"${worker_script}" <<'WORKER'
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t' read -r repo num title url updated outfile <<<"$1"
decision="$(timeout 15 gh pr view "$num" \
  --repo "$repo" \
  --json reviewDecision \
  --jq '.reviewDecision // "NONE"' 2>/dev/null || echo "UNKNOWN")"
printf '%s|%s#%s|%s|%s|%s\n' \
  "$updated" "$repo" "$num" "$decision" "$title" "$url" >"$outfile"
WORKER
  chmod +x "${worker_script}"

  awk -F'\t' -v dir="${pr_lines_dir}" '{
    printf "%s\t%s\t%s\t%s\t%s\t%s/%04d.line\n", $1, $2, $3, $4, $5, dir, NR
  }' "${pr_rows}" |
    xargs -d '\n' -P 8 -I{} "${worker_script}" {}

  shopt -s nullglob
  local pr_line_files=("${pr_lines_dir}"/*.line)
  shopt -u nullglob
  if [ "${#pr_line_files[@]}" -gt 0 ]; then
    cat "${pr_line_files[@]}" >>"${PRS_RAW}"
  fi
}

redaction_hits() {
  local source_path
  local scan_dir
  local scan_file
  local status

  source_path="$1"
  scan_dir="$(mktemp -d "${TMPDIR:-/tmp}/oc-standup-gitleaks.XXXXXX")"
  scan_file="${scan_dir}/scan-target"
  cp "${source_path}" "${scan_file}"
  if gitleaks dir \
    --config "${REDACT_CONFIG_PATH}" \
    --no-banner \
    "${scan_dir}" >/dev/null 2>&1; then
    status=0
  else
    status=$?
  fi
  rm -rf -- "${scan_dir}"
  case "${status}" in
  1)
    return 0
    ;;
  0)
    return 1
    ;;
  *)
    echo "oc-standup: gitleaks failed while scanning ${source_path}" >&2
    exit 1
    ;;
  esac
}

redact_source_or_placeholder() {
  local source_path
  local section_name
  local dest_path

  source_path="$1"
  section_name="$2"
  dest_path="$3"

  if [ ! -s "${source_path}" ]; then
    printf '[no %s activity in selected window]\n' "${section_name}" >"${dest_path}"
    return
  fi

  if redaction_hits "${source_path}"; then
    printf '[redacted: %s source omitted]\n' "${section_name}" >"${dest_path}"
    return
  fi

  cp "${source_path}" "${dest_path}"
}

build_digest() {
  local digest_path
  local redacted_atuin
  local redacted_sessions
  local redacted_git
  local redacted_prs

  digest_path="$1"
  redacted_atuin="${TMP_DIR}/atuin.redacted.txt"
  redacted_sessions="${TMP_DIR}/sessions.redacted.txt"
  redacted_git="${TMP_DIR}/git.redacted.txt"
  redacted_prs="${TMP_DIR}/prs.redacted.txt"

  redact_source_or_placeholder "${ATUIN_RAW}" "atuin" "${redacted_atuin}"
  redact_source_or_placeholder "${SESSIONS_RAW}" "sessions" "${redacted_sessions}"
  redact_source_or_placeholder "${GIT_RAW}" "git" "${redacted_git}"
  redact_source_or_placeholder "${PRS_RAW}" "prs" "${redacted_prs}"

  {
    printf 'standup_window_start=%s\n' "${START}"
    printf 'standup_window_end=%s\n\n' "${END}"

    printf '## Atuin summary\n'
    sed -n "1,${MAX_SECTION_LINES}p" "${redacted_atuin}"
    printf '\n## Session summary\n'
    sed -n "1,${MAX_SECTION_LINES}p" "${redacted_sessions}"
    printf '\n## Git summary\n'
    sed -n "1,${MAX_SECTION_LINES}p" "${redacted_git}"
    printf '\n## Open PR summary\n'
    sed -n "1,${MAX_SECTION_LINES}p" "${redacted_prs}"
  } >"${digest_path}"
}

summarize_digest() {
  local digest_path
  local output_path
  local prompt

  digest_path="$1"
  output_path="$2"
  prompt="Write a concise markdown standup note for the provided activity digest. Start directly with the section headings (## Yesterday, ## In Progress, ## Next) — do not include any top-level # heading or title; the wrapper adds it. Use only information grounded in the attached digest. Do not mention secrets, tokens, or raw command noise."

  if [ "${NO_LLM}" = "1" ]; then
    {
      printf '## Yesterday\n'
      printf '%s\n\n' '- LLM summarization skipped (--no-llm)'
      printf '## In Progress\n'
      printf '%s\n\n' '- Review attached digest manually.'
      printf '## Next\n'
      printf '%s\n' '- Re-run without --no-llm for a generated summary.'
    } >"${output_path}"
    return
  fi

  opencode run "${prompt}" -f "${digest_path}" >"${output_path}"
}

render_final_note() {
  local model_output_path
  local final_note_path

  model_output_path="$1"
  final_note_path="$2"

  {
    printf '# Standup %s\n\n' "${TODAY}"
    cat "${model_output_path}"
    printf '\n'
  } >"${final_note_path}"
}

ensure_notes_repo_ready() {
  local target_rel
  local target_status

  if ! git -C "${NOTES_REPO}" symbolic-ref -q HEAD >/dev/null 2>&1; then
    echo "oc-standup: notes repo is on detached HEAD" >&2
    exit 1
  fi

  if [ -d "${NOTES_REPO}/.git/rebase-merge" ] || [ -d "${NOTES_REPO}/.git/rebase-apply" ] || [ -f "${NOTES_REPO}/.git/MERGE_HEAD" ]; then
    echo "oc-standup: notes repo is mid-merge or rebase" >&2
    exit 1
  fi

  target_rel="standup/${TODAY}.md"
  target_status="$(git -C "${NOTES_REPO}" status --porcelain --untracked-files=all -- "${target_rel}")"
  if [ -n "${target_status}" ] && printf '%s' "${target_status}" | grep -qv '^?? '; then
    echo "oc-standup: target standup file already has local modifications" >&2
    exit 1
  fi
}

write_note_atomically() {
  local rendered_path
  local destination_path
  local destination_dir

  rendered_path="$1"
  destination_path="$2"
  destination_dir="$(dirname "${destination_path}")"

  mkdir -p "${destination_dir}"
  if [ -f "${destination_path}" ] && cmp -s "${rendered_path}" "${destination_path}"; then
    rm -f -- "${rendered_path}"
    return 1
  fi

  mv -f "${rendered_path}" "${destination_path}"
}

commit_and_maybe_push() {
  local relative_path
  local commit_message

  relative_path="standup/${TODAY}.md"
  commit_message="standup: ${TODAY}"

  git -C "${NOTES_REPO}" add -- "${relative_path}"
  if git -C "${NOTES_REPO}" diff --cached --quiet -- "${relative_path}"; then
    return 1
  fi

  git -C "${NOTES_REPO}" commit --only -m "${commit_message}" -- "${relative_path}"

  if [ "${DO_PUSH}" = "1" ] && [ "${VISIBILITY:-}" = "private" ]; then
    git -C "${NOTES_REPO}" push
  fi
}

collect_atuin
collect_sessions
collect_git
collect_prs

echo "atuin_raw=${ATUIN_RAW}"
echo "sessions_raw=${SESSIONS_RAW}"
echo "git_raw=${GIT_RAW}"
echo "prs_raw=${PRS_RAW}"

if [ "${DRY_RUN}" = "1" ]; then
  echo "dry-run: collectors complete; write/commit/push skipped"
  exit 0
fi

DIGEST_PATH="${TMP_DIR}/digest.txt"
MODEL_OUTPUT_PATH="${TMP_DIR}/model-output.md"

build_digest "${DIGEST_PATH}"
summarize_digest "${DIGEST_PATH}" "${MODEL_OUTPUT_PATH}"

if redaction_hits "${MODEL_OUTPUT_PATH}"; then
  echo "oc-standup: model output failed redaction gate" >&2
  exit 1
fi

ensure_notes_repo_ready
mkdir -p "${STANDUP_DIR}"
FINAL_NOTE_TMP="$(mktemp "${STANDUP_DIR}/.${START}.XXXXXX.tmp")"
render_final_note "${MODEL_OUTPUT_PATH}" "${FINAL_NOTE_TMP}"

if ! write_note_atomically "${FINAL_NOTE_TMP}" "${OUTPUT_PATH}"; then
  echo "no-op: standup note unchanged"
  exit 0
fi

if ! commit_and_maybe_push; then
  echo "no-op: nothing staged for commit"
  exit 0
fi

printf 'wrote=%s\n' "${OUTPUT_PATH}"
