# Ayoub-Chaieb-Resume

LaTeX resumes tailored per job title, built to be ATS-friendly and one page.

## Layout
- `src/preamble.tex` shared ATS-safe settings (single column, no icons or tables, no ligatures, no hyphenation). Edit once, every resume follows.
- `src/personal.tex` name and contact details.
- `src/*_resume_*.tex` one file per target role. `Master` is the long-form source of truth; do not submit it.
- `src/*Cover Letter*.tex` set `CompanyName`, `YourMotivation` (and review `JobKeywords`) at the top of each letter. CI skips any letter that still contains `FILL IN`.

## Build
- Compiler: **XeLaTeX** (same as Papeeria).
- Locally: `scripts/build.sh` (needs `texlive-xetex`, `latexmk`, `poppler-utils`). PDFs land in `dist/`.
- CI: `.github/workflows/build-pdfs.yml` compiles on every push and PR, fails if a targeted resume exceeds one page or the PDF text layer is broken, uploads PDFs as an artifact, and refreshes the **latest** release on `main`.
