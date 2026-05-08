---
name: mcp-server-patterns
id: mcp-server-patterns
description: Use when implementing or maintaining an MCP (Model Context Protocol) server — defining tools, resources, prompts; choosing stdio vs Streamable HTTP transport; using the Node / TypeScript SDK with Zod validation; debugging registration or transport issues; upgrading the SDK. Activates on MCP server, Model Context Protocol, registerTool, registerResource, stdio transport, Streamable HTTP, MCP TypeScript SDK, MCP tool, MCP resource. Skip for MCP client / consumer questions (calling an MCP from an app) — that's the consumer side, not server implementation.
category: architecture
version: 1.1.0
triggers:
  positive:
    - MCP server
    - Model Context Protocol
    - registerTool
    - registerResource
    - stdio transport
    - Streamable HTTP
    - MCP TypeScript SDK
    - MCP tool
    - MCP resource
  negative:
    - MCP client usage
    - calling an MCP from app
requires:
  bin: [node]
---

# MCP Server Patterns

The Model Context Protocol (MCP) lets AI assistants call tools, read resources,
and use prompts from your server. Use this skill when building or maintaining
MCP servers. The SDK API evolves — check Context7 (`query-docs` for "MCP") or
the official MCP documentation for current method names and signatures.

For the broader routing decision of when a capability should be a rule, a skill,
MCP, or a plain CLI / API workflow, see
[docs/capability-surface-selection.md](../../docs/capability-surface-selection.md).

## Contract

Inputs:
- Tool / resource / prompt capability to expose.
- Runtime, transport, SDK language / version, auth, rate / cost, deployment constraints.

Outputs:
- MCP server shape, schemas, transport choice, implementation plan or patch.
- Tool / resource descriptions with input and output contracts.
- Verification steps for local client connection and handler behavior.

Verification:
- Check current SDK docs before relying on method signatures.
- Keep business logic transport-independent; validate every tool input.

## When to Use

- Implementing a new MCP server
- Adding tools or resources to an existing MCP server
- Choosing stdio vs HTTP transport
- Upgrading the SDK across major versions
- Debugging MCP registration or transport issues

## Core Concepts

- **Tools**: actions the model can invoke (e.g. search, run a command). Register with `registerTool()` or `tool()` depending on SDK version.
- **Resources**: read-only data the model can fetch (e.g. file contents, API responses). Register with `registerResource()` or `resource()`. Handlers typically receive a `uri` argument.
- **Prompts**: reusable, parameterised prompt templates the client can surface (e.g. in Claude Desktop). Register with `registerPrompt()` or equivalent.
- **Transport**: stdio for local clients (e.g. Claude Desktop); Streamable HTTP is preferred for remote (Cursor, cloud). Legacy HTTP / SSE is for backward compatibility.

The Node / TypeScript SDK may expose `tool()` / `resource()` or `registerTool()` /
`registerResource()` — the official SDK has changed over time. Always verify
against the current [MCP docs](https://modelcontextprotocol.io) or Context7.

## Connecting with stdio

For local clients, create a stdio transport and pass it to your server's
`connect` method. The exact API varies by SDK version (constructor vs factory).
See the official MCP documentation or query Context7 for "MCP stdio server"
for the current pattern.

Keep server logic (tools + resources) **independent of transport** so you can
plug in stdio or HTTP in the entrypoint without rewriting handlers.

## Remote (Streamable HTTP)

For Cursor, cloud, or other remote clients, use **Streamable HTTP** (single
MCP HTTP endpoint per current spec). Support legacy HTTP / SSE only when
backward compatibility is required.

## Examples

### Install and server setup

```bash
npm install @modelcontextprotocol/sdk zod
```

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js"
import { z } from "zod"

const server = new McpServer({ name: "my-server", version: "1.0.0" })
```

Register tools and resources using the API your SDK version provides: some
versions use `server.tool(name, description, schema, handler)` (positional args),
others use `server.tool({ name, description, inputSchema }, handler)` or
`registerTool()`. Same for resources — include a `uri` in the handler when
the API provides it. Check the official MCP docs or Context7 for the current
`@modelcontextprotocol/sdk` signatures to avoid copy-paste errors.

Use **Zod** (or the SDK's preferred schema format) for input validation.

## Best Practices

- **Schema first**: define input schemas for every tool; document parameters and return shape.
- **Errors**: return structured errors or messages the model can interpret; avoid raw stack traces.
- **Idempotency**: prefer idempotent tools where possible so retries are safe.
- **Rate and cost**: for tools that call external APIs, consider rate limits and cost; document in the tool description.
- **Versioning**: pin SDK version in `package.json`; check release notes when upgrading.
- **Auth**: for HTTP transport, document and enforce auth at the transport layer (Bearer token, API key) — don't push it into individual tool handlers.
- **Logging**: log tool calls (with redacted args), latency, and outcome — MCP clients give little visibility otherwise.

## Official SDKs and Docs

- **JavaScript / TypeScript**: `@modelcontextprotocol/sdk` (npm). Use Context7 with library name "MCP" for current registration and transport patterns.
- **Go**: Official Go SDK on GitHub (`modelcontextprotocol/go-sdk`).
- **C#**: Official C# SDK for .NET.
