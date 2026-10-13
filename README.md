# Ayoub-Chaieb-Resume

[![Build resume PDFs](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml/badge.svg)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml)
[![main branch](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml/badge.svg?branch=main)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml?query=branch%3Amain)
[![devops-sre-master branch](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml/badge.svg?branch=devops-sre-master)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml?query=branch%3Adevops-sre-master)
[![Push builds](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml/badge.svg?event=push)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml?query=event%3Apush)
[![Manual builds](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml/badge.svg?event=workflow_dispatch)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml?query=event%3Aworkflow_dispatch)
[![Pull request builds](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml/badge.svg?event=pull_request)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/actions/workflows/build-pdfs.yml?query=event%3Apull_request)
[![Latest PDFs](https://img.shields.io/github/v/release/ayoub-chaieb/Ayoub-Chaieb-Resume?label=latest%20PDFs&display_name=tag)](https://github.com/ayoub-chaieb/Ayoub-Chaieb-Resume/releases/latest)

LaTeX resumes tailored per job title, built to be ATS-friendly and one page.

## Files
- `src/preamble.tex` shared ATS-safe settings (single column, no icons or tables, no ligatures, no hyphenation). Edit once, every resume follows.
- `src/personal.tex` name and contact details.
- `src/*_resume_*.tex` one file per target role. `Master` is the long-form source of truth; do not submit it.
- `src/*Cover Letter*.tex` reusable letters. They contain NO company names. The company is typed into the build form (see below), so these files never need editing per application.

## Get PDFs automatically
Every push to `main` builds all resumes. Download them from the **latest** release (right side of the repo page) or from the run's **Artifacts**.

## Get PDFs for the files you choose
1. Open the repo on GitHub, click **Actions**.
2. Click **Build resume PDFs** (left list), then **Run workflow** (right side).
3. In **Which files?** type `all`, or name parts separated by commas, for example `Cloud, IT Support` or `Master DevOps SRE`. The wording is flexible: `devops-sre-master` finds the same file.
4. For a cover letter also fill **company** and **motivation** (and optionally hiring manager).
   Example: files `Cover Letter_DevOps`, company `Acme`, motivation `your focus on reliability`.
5. Click the green **Run workflow** button, wait about 1 minute, open the finished run, download from **Artifacts**.

## Build on your own computer
Needs `texlive-xetex`, `latexmk`, `poppler-utils`.
```
bash scripts/build.sh
BUILD_FILES="Cloud,Teacher" bash scripts/build.sh
BUILD_FILES="Cover Letter_DevOps" COMPANY="Acme" MOTIVATION="your focus on reliability" bash scripts/build.sh
```
PDFs appear in `dist/`. The build fails if a targeted resume is longer than one page or the PDF text is broken.
