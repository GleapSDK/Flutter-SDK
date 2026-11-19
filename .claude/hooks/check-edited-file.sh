#!/bin/sh
# After every edit of a Dart file: tool/check_new.sh on that file. If the file must be formatted (new on the branch,
# or formatted where the branch left the base), dart format formats it; analyzer issues in the lines the branch adds
# and new `// ignore:` comments go back to the agent. The tests wait for the stop hook. Exit 2 with stderr reaches
# the agent; a note on exit 0 goes out as JSON, since plain stdout reaches no one.
command -v jq >/dev/null 2>&1 || exit 0
command -v flutter >/dev/null 2>&1 || exit 0
file=$(jq -r '.tool_input.file_path // empty')
case "$file" in *.g.dart) exit 0 ;; *.dart) ;; *) exit 0 ;; esac
[ -f "$file" ] || exit 0
# The file's own checkout, in whichever worktree it is.
root=$(cd "$(dirname "$file")" && git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
[ -f tool/check_new.sh ] || exit 0
rel=${file#"$root"/}
dart="$(dirname "$(command -v flutter)")/dart"

output=$(sh tool/check_new.sh "$rel" 2>&1)
code=$?
[ "$code" -eq 0 ] && exit 0
[ "$code" -eq 1 ] || exit 0 # check_new could not run (no merge base, no pub get): the stop hook reports it

note=
if printf '%s\n' "$output" | grep -qF "$rel: not formatted"; then
  if ! formatted=$("$dart" format "$rel" 2>&1); then
    printf 'The edit is on disk, but dart format cannot parse %s. Fix it before you continue:\n%s\n' "$rel" "$formatted" >&2
    exit 2
  fi
  note="dart format reformatted $rel. Read it again before the next edit."
  output=$(sh tool/check_new.sh "$rel" 2>&1) && code=0 || code=$?
fi
if [ "$code" -eq 1 ]; then
  printf 'The edit is on disk, but what this branch adds to %s has problems. Fix them before you continue (old code elsewhere in the file is not judged):\n%s\n%s\n' "$rel" "$output" "$note" >&2
  exit 2
fi
[ -z "$note" ] || jq -n --arg note "$note" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $note}}'
exit 0
