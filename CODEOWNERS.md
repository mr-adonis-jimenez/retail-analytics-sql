# CODEOWNERS – Retail Analytics SQL

This repository uses **CODEOWNERS** to establish clear review ownership and accountability for critical areas of the codebase.

CODEOWNERS ensures that changes affecting high-impact or sensitive files are reviewed by the appropriate subject-matter owners before merging.

---

## Purpose

The goals of CODEOWNERS in this repository are to:

- Enforce accountability for schema and analytics changes
- Protect data quality, performance, and correctness
- Ensure CI/CD, automation, and policy files receive proper review
- Reduce risk from unreviewed or accidental changes
- Support scalable collaboration as the project grows

---

## How CODEOWNERS Works

- CODEOWNERS rules live in `.github/CODEOWNERS`
- When a pull request modifies a file or directory covered by CODEOWNERS:
  - GitHub automatically requests reviews from the designated owners
- If branch protection or rulesets require it:
  - Approval from CODEOWNERS is **mandatory** before merge

Without branch protection enabled, CODEOW
