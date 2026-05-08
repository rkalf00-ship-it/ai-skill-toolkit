# Phase 1: Reconnaissance

> Reference for the [codebase-onboarding](../SKILL.md) skill.

Gather raw signals about the project without reading every file. Run these
checks in parallel.

```
1. Package manifest detection
   → package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml, build.gradle,
     Gemfile, composer.json, mix.exs, pubspec.yaml

2. Framework fingerprinting
   → next.config.*, nuxt.config.*, angular.json, vite.config.*,
     django settings, flask app factory, fastapi main, rails config

3. Entry point identification
   → main.*, index.*, app.*, server.*, cmd/, src/main/

4. Directory structure snapshot
   → Top 2 levels of the directory tree, ignoring node_modules, vendor,
     .git, dist, build, __pycache__, .next

5. Config and tooling detection
   → .eslintrc*, .prettierrc*, tsconfig.json, Makefile, Dockerfile,
     docker-compose*, .github/workflows/, .env.example, CI configs

6. Test structure detection
   → tests/, test/, __tests__/, *_test.go, *.spec.ts, *.test.js,
     pytest.ini, jest.config.*, vitest.config.*
```

## Output

A bullet list of detected items with file paths. Don't interpret yet — that's
Phase 2. Goal here is data collection.

## Speed Rule

Reconnaissance should take seconds, not minutes. If you find yourself reading
files at this stage, stop and switch to Glob / Grep for breadth. Read comes
later, only on ambiguous signals.
