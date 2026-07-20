# Contributing

Thank you for contributing to Cloud Task Manager. This repository uses a pull-request workflow so every change is reviewable, testable, and traceable.

## Workflow

1. Start from an up-to-date `main` branch.
2. Create a focused feature branch.
3. Make and test one logical change.
4. Commit with a semantic message.
5. Push the branch and open a pull request.
6. Complete the pull-request checklist and review the changed files.
7. Merge only after required checks and conversations are complete.

Do not push changes directly to `main`.

## Branch Names

Use lowercase, hyphenated names with a clear category:

- `feature/short-description`
- `fix/short-description`
- `docs/short-description`
- `chore/short-description`

## Commit Messages

Use an imperative summary in this format:

```text
<type>: <short description>
```

Common types:

- `feat`: a new capability
- `fix`: a defect correction
- `docs`: documentation only
- `test`: test changes
- `refactor`: internal code restructuring
- `chore`: maintenance or tooling

Example:

```text
feat: add PostgreSQL health check
```

## Local Verification

Run the checks relevant to the change before opening a pull request:

```text
python -m pytest
docker compose config
docker compose build
```

Document any check that is not applicable or cannot be run.

## Pull Requests

Pull requests must:

- explain what changed and why
- remain focused on one objective
- include verification evidence
- identify security and AWS cost impact
- update documentation when behaviour or operations change
- avoid secrets, credentials, personal data, and generated local files

## Issues

Use the bug form for reproducible failures and the feature form for proposed improvements. Report security vulnerabilities through GitHub Security Advisories rather than a public issue.
