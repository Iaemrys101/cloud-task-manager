# Day 4: Git And GitHub Workflow

## Objective

Create a repeatable contribution and review workflow that protects the `main` branch and records why each change was made.

## Repository Governance Files

- `.github/pull_request_template.md` prompts authors for a summary, verification, security, cost, and review readiness.
- `.github/ISSUE_TEMPLATE/bug_report.yml` collects reproducible bug reports and sanitized evidence.
- `.github/ISSUE_TEMPLATE/feature_request.yml` captures the problem, proposal, acceptance criteria, and impact.
- `.github/ISSUE_TEMPLATE/config.yml` disables unstructured issues and routes vulnerabilities to private security advisories.
- `.github/CODEOWNERS` identifies the maintainer responsible for repository changes.
- `CONTRIBUTING.md` documents branch names, semantic commits, testing, and pull-request expectations.

## Standard Change Flow

```text
Issue -> Feature branch -> Commit -> Push -> Pull request -> Review -> Merge -> Sync main -> Delete branch
```

Feature branches isolate unfinished work. Pull requests create a review boundary and preserve the discussion, verification, and decision history. Semantic commit messages make the project history easier to scan and automate.

## Main Branch Protection

The `main` branch should require changes to arrive through pull requests, require review conversations to be resolved, and block force pushes and branch deletion.

An approving review is not required while the repository has one maintainer because an author cannot approve their own pull request. Required status checks will be enabled after the GitHub Actions pipeline is added in the CI/CD milestone.

## Security And Cost

Security reports are routed to private GitHub Security Advisories to avoid publishing vulnerability details. Pull requests and feature requests explicitly ask contributors to consider secrets, security impact, and AWS cost.

This milestone creates no AWS resources and has no AWS cost.

## Verification

- Parsed both YAML issue forms successfully.
- Confirmed all GitHub community files are under the repository-level `.github` directory.
- Checked the staged changes for whitespace errors before committing.
- Reviewed the pull-request template content and confirmed it is stored in GitHub's expected location.

## Key Learning

Professional Git practice is not only committing code. It combines small branches, consistent metadata, automated repository guidance, protected integration points, review evidence, and clean branch lifecycle management.
