#!/bin/sh
# Before a turn ends: tool/check_new.sh and flutter test, once the branch changes Dart, native or package files. Red
# means the turn is not done. Both take seconds. `--no-pub` keeps flutter test from rewriting pubspec.lock with a
# local Flutter other than the one CI uses (AGENTS.md).
command -v jq >/dev/null 2>&1 || exit 0
command -v flutter >/dev/null 2>&1 || exit 0
active=$(jq -r '.stop_hook_active // false')
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
[ -f tool/check_new.sh ] || exit 0

fork=$(git merge-base origin/main HEAD 2>/dev/null) || exit 0
changed=$( (git diff --name-only "$fork" -- '*.dart' android/src ios/gleap_sdk pubspec.yaml analysis_options.yaml
  git ls-files -o --exclude-standard -- '*.dart') 2>/dev/null)
[ -n "$changed" ] || exit 0

# The agent was told once and changed nothing since: another block would only burn a turn.
state="$(git rev-parse --git-dir)/claude-stop-gate"
key=$( (git rev-parse HEAD; git diff HEAD; git ls-files -o --exclude-standard -- '*.dart' | xargs cat 2>/dev/null) | git hash-object --stdin)
if [ "$active" = true ] && [ "$(cat "$state" 2>/dev/null)" = "$key" ]; then
  exit 0
fi

failures=
step() { # name, command...
  name=$1
  shift
  if ! output=$("$@" 2>&1 </dev/null); then
    failures="$failures
## $name
$(printf '%s\n' "$output" | tail -n 80)
"
  fi
}
step "sh tool/check_new.sh" sh tool/check_new.sh
step "flutter test --no-pub" flutter test --no-pub --suppress-analytics --reporter failures-only

if [ -z "$failures" ]; then
  rm -f "$state"
  exit 0
fi
printf '%s\n' "$key" >"$state"
printf 'Fix this before you finish, or report BLOCKED with the reason:\n%s\n' "$failures" >&2
exit 2
