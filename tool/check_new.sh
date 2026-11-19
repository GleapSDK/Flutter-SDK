#!/bin/sh
# dart analyze and dart format on what this branch adds compared with where it left $BASE (default origin/main),
# committed or not. Old code may stay as it is; what the branch adds must be clean. With file arguments, only those
# files are judged. Exit 0 clean, 1 findings, 2 when it cannot run.
#
#   sh tool/check_new.sh                        # the whole branch
#   sh tool/check_new.sh lib/gleap_sdk.dart     # one file (the edit hook)
#   BASE=origin/some-branch sh tool/check_new.sh
#
# Fails on:
# - any analyzer issue (infos included) on a line the branch adds or changes,
# - a new `// ignore:` or `// ignore_for_file:` comment,
# - a Dart file that is not formatted, if the branch adds it or it was formatted where the branch left the base.
#   Files that were unformatted there already are left alone: formatting them is a change of its own.
# Generated `*.g.dart` files are not judged.

base=${BASE:-origin/main}
root=$(git rev-parse --show-toplevel) || exit 2
cd "$root" || exit 2
# The Dart SDK that comes with Flutter: a standalone `dart` earlier on the PATH may be years older.
flutter=$(command -v flutter) || { echo "check_new: flutter is not on the PATH" >&2; exit 2; }
dart=${DART:-$(dirname "$flutter")/dart}
fork=$(git merge-base "$base" HEAD 2>/dev/null) || { echo "check_new: no merge base with $base (git fetch origin?)" >&2; exit 2; }
tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT

: >"$tmp/only"
for f in "$@"; do printf '%s\n' "${f#"$root"/}" >>"$tmp/only"; done
# Keeps the paths on stdin that the file arguments name, or all of them without arguments.
only() { if [ -s "$tmp/only" ]; then grep -Fx -f "$tmp/only"; else cat; fi; }

git diff -U0 --no-color --no-ext-diff "$fork" -- '*.dart' ':(exclude)*.g.dart' >"$tmp/diff" || exit 2
git ls-files -o --exclude-standard -- '*.dart' ':(exclude)*.g.dart' | only >"$tmp/untracked"
{ git diff --name-only --diff-filter=AMR "$fork" -- '*.dart' ':(exclude)*.g.dart'; cat "$tmp/untracked"; } |
  sort -u | only >"$tmp/files"
[ -s "$tmp/files" ] || exit 0

# Lines the branch adds, as path:line. An untracked file is added whole.
awk '/^\+\+\+ b\// { f = substr($0, 7); next }
  /^@@/ { split(substr($3, 2), a, ","); n = (a[2] == "") ? 1 : a[2]; for (i = 0; i < n; i++) print f ":" (a[1] + i) }' \
  "$tmp/diff" >"$tmp/added"
while read -r f; do awk -v f="$f" '{ print f ":" NR }' "$f"; done <"$tmp/untracked" >>"$tmp/added"

# 1. Analyzer issues of any severity on an added line. Exit codes 0-3 are the analyzer's verdicts; others mean it
# did not run.
if [ -s "$tmp/only" ]; then
  "$dart" analyze --format=machine $(cat "$tmp/files") >"$tmp/issues" 2>&1
else
  "$dart" analyze --format=machine . >"$tmp/issues" 2>&1
fi
code=$?
if [ "$code" -gt 3 ]; then
  cat "$tmp/issues" >&2
  echo "check_new: dart analyze could not run (exit $code). Run flutter pub get first?" >&2
  exit 2
fi
awk -F'|' -v root="$root/" 'NR == FNR { added[$0] = 1; next }
  NF >= 8 {
    f = $4; if (index(f, root) == 1) f = substr(f, length(root) + 1)
    if (!((f ":" $5) in added)) next
    msg = $8; for (i = 9; i <= NF; i++) msg = msg "|" $i
    print f ":" $5 ":" $6 ": " tolower($1) " " tolower($3) ": " msg
  }' "$tmp/added" "$tmp/issues" >"$tmp/found"

# 2. A new suppression hides an issue instead of fixing it.
awk 'NR == FNR { keep[$0] = 1; next }
  /^\+\+\+ b\// { f = substr($0, 7); next }
  /^@@/ { split(substr($3, 2), a, ","); l = a[1]; next }
  /^\+/ { if ((f in keep) && $0 ~ /\/\/ *ignore(_for_file)? *:/) print f ":" l ": new // ignore comment: fix the issue instead"; l++ }' \
  "$tmp/files" "$tmp/diff" >>"$tmp/found"
while read -r f; do
  grep -nE '// *ignore(_for_file)? *:' "$f" | sed "s|^\([0-9]*\):.*|$f:\1: new // ignore comment: fix the issue instead|"
done <"$tmp/untracked" >>"$tmp/found"

# 3. Formatting, per file.
while read -r f; do
  [ -f "$f" ] || continue
  "$dart" format --output=none --set-exit-if-changed "$f" >/dev/null 2>&1 && continue
  if git cat-file -e "$fork:$f" 2>/dev/null &&
    ! git show "$fork:$f" | "$dart" format --output=none --set-exit-if-changed --stdin-name="$f" >/dev/null 2>&1; then
    continue
  fi
  echo "$f: not formatted (dart format $f)"
done <"$tmp/files" >>"$tmp/found"

[ -s "$tmp/found" ] || exit 0
cat "$tmp/found"
exit 1
