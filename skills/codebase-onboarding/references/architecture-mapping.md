# Phase 2: Architecture Mapping

> Reference for the [codebase-onboarding](../SKILL.md) skill.

From the reconnaissance data, identify the following.

## Tech Stack

- Language(s) and version constraints
- Framework(s) and major libraries
- Database(s) and ORMs
- Build tools and bundlers
- CI / CD platform

## Architecture Pattern

- Monolith, monorepo, microservices, or serverless
- Frontend / backend split or full-stack
- API style: REST, GraphQL, gRPC, tRPC

## Key Directories

Map the top-level directories to their purpose. Example for a React project
(replace with detected directories):

```
src/components/  → React UI components
src/api/         → API route handlers
src/lib/         → Shared utilities
src/db/          → Database models and migrations
tests/           → Test suites
scripts/         → Build and deployment scripts
```

## Data Flow

Trace one request from entry to response:

- Where does a request enter? (router, handler, controller)
- How is it validated? (middleware, schemas, guards)
- Where is business logic? (services, models, use cases)
- How does it reach the database? (ORM, raw queries, repositories)

A single end-to-end trace beats abstract architecture diagrams for onboarding —
new team members can follow a known path.
