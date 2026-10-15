#!/usr/bin/env bash
# Compile .tex files in src/ with XeLaTeX and run ATS sanity checks.
#
# Settings (environment variables, all optional):
#   BUILD_FILES      "all" (default) or comma-separated name fragments, e.g. "Cloud,IT Support"
#   COMPANY          company name -> required to build a cover letter
#   HIRING_MANAGER   e.g. "Ms. Alsaadi" (default: Hiring Manager)
#   MOTIVATION       finishes the sentence "I am drawn to <company> because of ..."
#   KEYWORDS         optional: replaces the JobKeywords sentence in the letter
#
# Examples:  bash scripts/build.sh
#            BUILD_FILES="Cloud,Teacher" bash scripts/build.sh
#            BUILD_FILES="Cover Letter_DevOps" COMPANY="Acme" MOTIVATION="your focus on reliability" bash scripts/build.sh
set -uo pipefail
cd "$(dirname "$0")/.."
BUILD=build; DIST=dist
BUILD_FILES="${BUILD_FILES:-all}"
rm -rf "$BUILD" "$DIST"; mkdir -p "$BUILD" "$DIST"
fail=0; built=0; matched=0

# Turn plain text into LaTeX-safe text (handles & % $ # _ { } ~ ^ \)
tex_escape() {
  python3 -c '
import sys
m={"\\":r"\textbackslash{}","&":r"\&","%":r"\%","$":r"\$","#":r"\#","_":r"\_","{":r"\{","}":r"\}","~":r"\textasciitilde{}","^":r"\textasciicircum{}"}
print("".join(m.get(c,c) for c in sys.argv[1]),end="")' "$1"
}

# Lowercase and split on anything that is not a letter or digit
norm() { echo "$1" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' ' '; }

# A selection matches when EVERY word of it starts a word in the file name (any order, any - _ or space).
# Example: "devops-sre-master", "Master DevOps SRE" and "Master_DevOps_SRE" all match the same file.
matches() {
  [[ "$BUILD_FILES" == "all" ]] && return 0
  local words frag tok ok
  words=" $(norm "$1")"
  IFS=',' read -ra frags <<<"$BUILD_FILES"
  for frag in "${frags[@]}"; do
    ok=1; [[ -z "$(norm "$frag" | tr -d ' ')" ]] && ok=0
    for tok in $(norm "$frag"); do
      [[ "$words" == *" $tok"* ]] || { ok=0; break; }
    done
    ((ok)) && return 0
  done
  return 1
}

for path in src/*.tex; do
  f=$(basename "$path"); name="${f%.tex}"
  case "$f" in preamble.tex|personal.tex|projects.tex) continue;; esac
  matches "$f" || continue
  matched=$((matched+1))

  pretex=""; outname="$name"
  if [[ "$f" == *"Cover Letter"* ]]; then
    if [[ -z "${COMPANY:-}" ]]; then
      echo "SKIP  $f (cover letters need COMPANY; fill in the company name when you run the build)"; continue
    fi
    if [[ -z "${MOTIVATION:-}" ]]; then
      echo "FAIL  $f: MOTIVATION is required (finishes the sentence: I am drawn to $COMPANY because of ...)"; fail=1; continue
    fi
    c=$(tex_escape "$COMPANY"); h=$(tex_escape "${HIRING_MANAGER:-Hiring Manager}"); m=$(tex_escape "$MOTIVATION")
    pretex="\\newcommand{\\CompanyName}{${c}\\xspace}\\newcommand{\\HiringManager}{${h}\\xspace}\\newcommand{\\YourMotivation}{${m}\\xspace}"
    if [[ -n "${KEYWORDS:-}" ]]; then k=$(tex_escape "$KEYWORDS"); pretex+="\\newcommand{\\JobKeywords}{${k}\\xspace}"; fi
    slug=$(echo "$COMPANY" | tr -cs 'A-Za-z0-9' '_' | sed 's/^_//; s/_$//')
    outname="${name}_${slug}"
  fi

  args=(-xelatex -interaction=nonstopmode -halt-on-error -outdir="../$BUILD" -jobname="$outname")
  [[ -n "$pretex" ]] && args+=("-usepretex=$pretex")
  if ! (cd src && latexmk "${args[@]}" "$f") >"$BUILD/$outname.log" 2>&1; then
    echo "FAIL  $f (compile error)"; tail -25 "$BUILD/$outname.log"; fail=1; continue
  fi

  pdf="$BUILD/$outname.pdf"
  pages=$(pdfinfo "$pdf" | awk '/^Pages:/{print $2}')
  text=$(pdftotext "$pdf" -)
  problems=()
  if [[ "$f" == *"_resume_"* && "$f" != *"_Master"* && "$pages" != "1" ]]; then problems+=("is $pages pages (target: 1)"); fi
  grep -q "ayoubchaieb75@gmail.com" <<<"$text" || problems+=("email missing from text layer")
  LC_ALL=C.UTF-8 grep -qP '[\x{FB00}-\x{FB06}\x{FFFD}]' <<<"$text" && problems+=("ligature or broken glyph in text layer")
  grep -qi "experience" <<<"$text" || [[ "$f" == *"Cover Letter"* ]] || problems+=("no Experience heading found")
  grep -q "FILL IN" <<<"$text" && problems+=("placeholder text FILL IN is still in the PDF")

  if ((${#problems[@]})); then echo "FAIL  $f: ${problems[*]}"; fail=1
  else echo "OK    $f ($pages page(s))"; built=$((built+1)); fi
  cp "$pdf" "$DIST/${outname// /_}.pdf"
done

if ((matched==0)); then
  echo "Nothing was built: \"$BUILD_FILES\" does not match any file. Type part of a file name from this list (or all):"
  for x in src/*.tex; do y=$(basename "$x" .tex); case "$y" in preamble|personal|projects) ;; *) echo "  - $y";; esac; done
  exit 1
fi
((built==0 && fail==0)) && { echo "Nothing was built (everything selected was skipped, see SKIP lines above)."; exit 1; }
echo; echo "PDFs in $DIST/:"; ls -1 "$DIST"
exit $fail
