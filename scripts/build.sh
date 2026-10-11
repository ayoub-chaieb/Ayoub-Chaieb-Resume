#!/usr/bin/env bash
# Compile every .tex in src/ with XeLaTeX and run ATS sanity checks.
# Usage: scripts/build.sh        (same script runs locally and in GitHub Actions)
set -uo pipefail
cd "$(dirname "$0")/.."
BUILD=build; DIST=dist
rm -rf "$BUILD" "$DIST"; mkdir -p "$BUILD" "$DIST"
fail=0

for path in src/*.tex; do
  f=$(basename "$path"); name="${f%.tex}"
  case "$f" in preamble.tex|personal.tex) continue;; esac

  if grep -q "FILL IN" "$path"; then
    echo "SKIP  $f (still has FILL IN placeholders)"; continue
  fi

  if ! (cd src && latexmk -xelatex -interaction=nonstopmode -halt-on-error -outdir="../$BUILD" "$f") >"$BUILD/$name.log" 2>&1; then
    echo "FAIL  $f (compile error)"; tail -25 "$BUILD/$name.log"; fail=1; continue
  fi

  pdf="$BUILD/$name.pdf"
  pages=$(pdfinfo "$pdf" | awk '/^Pages:/{print $2}')
  text=$(pdftotext "$pdf" -)
  problems=()

  # One page for every targeted resume (the Master CV is the long-form source and exempt)
  if [[ "$f" == *"_resume_"* && "$f" != *"_Master"* && "$pages" != "1" ]]; then
    problems+=("is $pages pages (target: 1)")
  fi
  # ATS text-layer checks
  grep -q "ayoubchaieb75@gmail.com" <<<"$text" || problems+=("email missing from text layer")
  LC_ALL=C.UTF-8 grep -qP '[\x{FB00}-\x{FB06}\x{FFFD}]' <<<"$text" && problems+=("ligature or broken glyph in text layer")
  grep -q "Experience\|EXPERIENCE" <<<"$text" || [[ "$f" == *"Cover Letter"* ]] || problems+=("no Experience heading found")

  if ((${#problems[@]})); then
    echo "FAIL  $f: ${problems[*]}"; fail=1
  else
    echo "OK    $f ($pages page(s))"
  fi
  cp "$pdf" "$DIST/${name// /_}.pdf"
done

echo; echo "PDFs written to $DIST/"; ls -1 "$DIST"
exit $fail
