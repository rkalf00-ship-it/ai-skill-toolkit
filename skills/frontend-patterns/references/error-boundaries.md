# Error Boundaries

> Reference for the [frontend-patterns](../SKILL.md) skill.

Error Boundaries must be class components (no hook equivalent in React 18).
They catch render errors in their children and show a fallback UI.

```typescript
interface ErrorBoundaryState {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback?: (error: Error, reset: () => void) => React.ReactNode },
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { hasError: false, error: null }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error boundary caught:', error, errorInfo)
    // Report to error tracker (Sentry, Rollbar, etc.)
  }

  reset = () => this.setState({ hasError: false, error: null })

  render() {
    if (this.state.hasError && this.state.error) {
      if (this.props.fallback) {
        return this.props.fallback(this.state.error, this.reset)
      }
      return (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <p>{this.state.error.message}</p>
          <button onClick={this.reset}>Try again</button>
        </div>
      )
    }
    return this.props.children
  }
}

// Usage
<ErrorBoundary>
  <App />
</ErrorBoundary>
```

## What Error Boundaries DO NOT Catch

- Errors inside event handlers (use try/catch in the handler)
- Errors in async code (`setTimeout`, promises) — handle them at the source
- Errors during server-side rendering (Next.js has its own error UI)
- Errors thrown in the boundary itself

For Next.js App Router, prefer `error.tsx` files which are framework-integrated
error boundaries with automatic retry support.
