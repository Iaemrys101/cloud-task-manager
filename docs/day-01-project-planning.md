# Day 1: Project Planning and Architecture

## Objective

Define the project before building it.

Today is about understanding what we are building, what we are not building, and how the future cloud architecture will fit together.

## What We Are Building

Cloud Task Manager is a simple task application used as a realistic deployment target.

The application will eventually include:

- a FastAPI backend
- a React frontend
- PostgreSQL database storage
- optional S3 file uploads
- secure login

The app itself is intentionally simple because the main focus is cloud deployment and operations.

## What We Are Learning

Today introduces these engineering ideas:

- Project scope
- Architecture planning
- Production thinking
- Secure network boundaries
- Managed AWS services
- Documentation as part of engineering
- Working in daily deliverables

## Why Planning Comes First

Professional teams do not start by randomly creating cloud resources.

They first ask:

- What problem are we solving?
- What services are required?
- Which components are public?
- Which components must stay private?
- Where will secrets live?
- How will we deploy changes?
- How will we observe failures?
- How will we control cost?
- How will we safely remove resources?

This prevents expensive, insecure, and hard-to-maintain infrastructure.

## Key Decisions

### Decision 1: Keep the application simple

The app is only a deployment target.

The main portfolio value comes from showing that you can deploy, secure, monitor, and operate infrastructure professionally.

### Decision 2: Use one GitHub repository

The whole project should live in one repository.

This gives employers one place to inspect:

- app code
- Terraform code
- CI/CD workflows
- documentation
- architecture diagrams
- pull requests
- commit history

### Decision 3: Use daily branches and pull requests

Each day should produce a small, reviewable change.

Example branch:

```bash
feature/day-01-project-planning
```

Example commit:

```bash
docs: add project planning and architecture
```

Example pull request title:

```text
docs: define project scope and production architecture
```

### Decision 4: Do not create AWS resources yet

Day 1 is documentation only.

This keeps cost at 0 while we prepare the project properly.

## Files Created Today

### README.md

The main entry point for the repository.

It explains the project goal, learning approach, milestones, and current status.

### docs/architecture.md

The first version of the target production architecture.

It explains the AWS services, network boundaries, and security direction.

### docs/day-01-project-planning.md

This learning guide.

It records what Day 1 is about and why these decisions matter.

### .gitignore

Prevents temporary files, secrets, build outputs, and local environment files from being committed.

## Common Mistakes

- Building too much app logic before understanding the deployment target.
- Creating AWS resources before knowing how to destroy them.
- Putting secrets in Git.
- Treating documentation as something to do only at the end.
- Uploading one finished project instead of showing progress through commits and pull requests.

## Testing Instructions

Because Day 1 creates documentation only, testing means checking that:

- the project folder exists
- the README is readable
- the architecture document includes a diagram
- no AWS resources have been created
- no secrets are present
- Git can track the new files

Useful command:

```bash
git status
```

## Completion Checklist

- [ ] Project folder exists
- [ ] README created
- [ ] Architecture document created
- [ ] Day 1 guide created
- [ ] Git repository initialized
- [ ] Day 1 files staged
- [ ] Day 1 commit created
- [ ] Ready to push to GitHub later

## Interview Explanation

If asked why the project starts with planning, you can say:

```text
I started with project scope and architecture because production cloud work should be designed before infrastructure is created. I wanted to define public and private boundaries, identify managed AWS services, plan how secrets and monitoring would work, and avoid creating resources without understanding cost or cleanup.
```

