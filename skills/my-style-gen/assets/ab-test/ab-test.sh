#!/usr/bin/env bash
#
# Run one task twice - once without the generated style skill, once with it - and
# write both answers side by side so the difference can be read directly.
#
# Each arm runs in its own empty workspace with only project settings loaded, so the
# skill under test is the only thing that differs between them.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: ab-test.sh [options]

  --task <path>    task prompt file, or a directory of .md task files
                   (default: <skill>/ab-test/tasks, written when the skill was
                   generated)
  --skill <path>   skill folder to test (default: my-style, looked up in
                   ./.claude/skills, ./.agents/skills, ~/.claude/skills)
  --out <dir>      where to write the results (default: ./ab-test-<timestamp>)
  --model <name>   model for both arms (default: whatever claude is configured with)
  --compare        run a third pass that compares the two answers rule by rule
  --natural        do not tell the styled arm to use the skill; let its description
                   trigger it, which tests triggering as well as content
  -h, --help       this

Both arms get the same prompt, the same model and read-only tools. The styled arm
additionally has the skill installed in its workspace.
EOF
}

skill_path=""
task_arg=""
out_dir=""
model=""
compare=0
invoke="explicit"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)    task_arg="${2:-}"; shift 2 ;;
    --skill)   skill_path="${2:-}"; shift 2 ;;
    --out)     out_dir="${2:-}"; shift 2 ;;
    --model)   model="${2:-}"; shift 2 ;;
    --compare) compare=1; shift ;;
    --natural) invoke="natural"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ab-test: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

command -v claude >/dev/null 2>&1 || {
  echo "ab-test: the claude CLI is not on PATH" >&2
  exit 1
}

if [[ -z "$skill_path" ]]; then
  for candidate in \
    "$PWD/.claude/skills/my-style" \
    "$PWD/.agents/skills/my-style" \
    "$HOME/.claude/skills/my-style"
  do
    if [[ -f "$candidate/SKILL.md" ]]; then skill_path="$candidate"; break; fi
  done
fi

[[ -n "$skill_path" ]] || {
  echo "ab-test: no skill found - pass --skill <path>" >&2
  exit 1
}
[[ -f "$skill_path/SKILL.md" ]] || {
  echo "ab-test: $skill_path has no SKILL.md" >&2
  exit 1
}

skill_path="$(cd "$skill_path" && pwd)"
skill_name="$(basename "$skill_path")"

task_arg="${task_arg:-$skill_path/ab-test/tasks}"
[[ -e "$task_arg" ]] || {
  echo "ab-test: no such task path: $task_arg" >&2
  echo "ab-test: pass --task, or have my-style-gen write the tasks" >&2
  exit 1
}

tasks=()
if [[ -d "$task_arg" ]]; then
  while IFS= read -r f; do tasks+=("$f"); done < <(find "$task_arg" -maxdepth 1 -name '*.md' | sort)
  [[ ${#tasks[@]} -gt 0 ]] || { echo "ab-test: no .md task files in $task_arg" >&2; exit 1; }
else
  tasks=("$task_arg")
fi

out_dir="${out_dir:-$PWD/ab-test-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out_dir"
out_dir="$(cd "$out_dir" && pwd)"

# The arms run outside any project the user has. Claude walks up from the working
# directory looking for a project root, so a workspace sitting under a repository
# would inherit that repository's skills - which is exactly what is being measured.
# Each arm also gets its own .claude, which stops the walk at the workspace.
sandbox="$(mktemp -d "${TMPDIR:-/tmp}/ab-test.XXXXXX")"
trap 'rm -rf "$sandbox"' EXIT

# CLAUDECODE is set inside an interactive session and blocks nesting; a headless
# subprocess is safe, so drop it for the child runs only.
# Ticks on stderr while the run is alive; the elapsed seconds go to stdout for the
# caller. A pass can take minutes, and silence reads as a hang.
run_arm() {
  local label="$1" cwd="$2" prompt_file="$3" response_file="$4" log_file="$5"
  local started elapsed pid
  started=$SECONDS
  (
    cd "$cwd"
    # shellcheck disable=SC2086
    env -u CLAUDECODE claude -p "$(cat "$prompt_file")" \
      --setting-sources project \
      --allowedTools "Read Glob Grep" \
      ${model:+--model "$model"} \
      >"$response_file" 2>"$log_file"
  ) &
  pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    printf '\r   %-8s ... %ds' "$label" $(( SECONDS - started )) >&2
    sleep 2
  done

  wait "$pid" || {
    printf '\r   %-8s ... failed, see %s\n' "$label" "$log_file" >&2
    return 1
  }

  elapsed=$(( SECONDS - started ))
  printf '\r   %-8s ... %ds' "$label" "$elapsed" >&2
  echo "$elapsed"
}

echo "skill:  $skill_path"
echo "out:    $out_dir"
echo

for task_file in "${tasks[@]}"; do
  task_name="$(basename "${task_file%.md}")"
  case_dir="$out_dir/$task_name"
  work="$sandbox/$task_name"
  mkdir -p "$case_dir/baseline" "$case_dir/styled" \
           "$work/baseline/.claude" "$work/styled/.claude/skills"
  cp "$task_file" "$case_dir/task.md"
  cp -R "$skill_path" "$work/styled/.claude/skills/$skill_name"
  # the tasks travel with the skill; keep them out of the arm that answers one
  rm -rf "$work/styled/.claude/skills/$skill_name/ab-test"

  cp "$case_dir/task.md" "$case_dir/baseline/prompt.md"
  cp "$case_dir/task.md" "$case_dir/styled/prompt.md"

  # both arms get this, identically, so the comparison stays fair
  for arm in baseline styled; do
    cat >>"$case_dir/$arm/prompt.md" <<'EOF'

---
Deliver the work in your reply. This workspace is read-only - create no files, run
nothing, and ask for no permissions. Code goes in fenced blocks with its file path on
the line above. Anything you would have put in a file, put in the reply instead.
EOF
  done

  if [[ "$invoke" == "explicit" ]]; then
    cat >>"$case_dir/styled/prompt.md" <<EOF
Read .claude/skills/$skill_name/SKILL.md and the references it points at, and follow
them for this task.
EOF
  fi

  echo "== $task_name"
  run_arm baseline "$work/baseline" "$case_dir/baseline/prompt.md" \
          "$case_dir/baseline/response.md" "$case_dir/baseline/run.log" >/dev/null
  echo "  $(wc -w <"$case_dir/baseline/response.md" | tr -d ' ') words"

  run_arm styled "$work/styled" "$case_dir/styled/prompt.md" \
          "$case_dir/styled/response.md" "$case_dir/styled/run.log" >/dev/null
  echo "  $(wc -w <"$case_dir/styled/response.md" | tr -d ' ') words"

  if [[ $compare -eq 1 ]]; then
    judge="$work/compare"
    mkdir -p "$judge/.claude" "$judge/baseline" "$judge/styled"
    cp "$case_dir/task.md" "$judge/task.md"
    cp "$case_dir/baseline/response.md" "$judge/baseline/response.md"
    cp "$case_dir/styled/response.md" "$judge/styled/response.md"
    # the skill sits outside .claude/skills here - the judge reads it, never follows it
    cp -R "$work/styled/.claude/skills/$skill_name" "$judge/skill"
    brief="$(cat "$here/compare-brief.md")"
    brief="${brief//\{\{skill_name\}\}/$skill_name}"
    brief="${brief//\{\{skill_dir\}\}/skill}"
    printf '%s' "$brief" >"$case_dir/compare-prompt.md"
    run_arm compare "$judge" "$case_dir/compare-prompt.md" \
            "$case_dir/comparison.md" "$case_dir/compare.log" >/dev/null
    echo
    echo
    sed 's/^/   /' "$case_dir/comparison.md"
  fi
  echo
done

echo "Read the pairs with:"
echo "  diff -y --width=200 $out_dir/<task>/baseline/response.md $out_dir/<task>/styled/response.md"
