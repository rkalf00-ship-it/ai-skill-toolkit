# State Management

> Reference for the [frontend-patterns](../SKILL.md) skill.

## Decision Guide

| Scope | Recommended |
|-------|-------------|
| Single component | `useState` |
| Component + immediate children | Lift state to parent |
| Coordinated multi-state with actions | `useReducer` |
| Cross-cutting app state, low frequency | Context + `useReducer` |
| Cross-cutting app state, high frequency | Zustand / Jotai (avoid Context re-renders) |
| Server state (cache, refetch) | React Query / SWR (NOT Context or Redux) |

## Context + Reducer Pattern

```typescript
interface State {
  markets: Market[]
  selectedMarket: Market | null
  loading: boolean
}

type Action =
  | { type: 'SET_MARKETS'; payload: Market[] }
  | { type: 'SELECT_MARKET'; payload: Market }
  | { type: 'SET_LOADING'; payload: boolean }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'SET_MARKETS':    return { ...state, markets: action.payload }
    case 'SELECT_MARKET':  return { ...state, selectedMarket: action.payload }
    case 'SET_LOADING':    return { ...state, loading: action.payload }
    default:               return state
  }
}

const MarketContext = createContext<{
  state: State
  dispatch: Dispatch<Action>
} | undefined>(undefined)

export function MarketProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(reducer, {
    markets: [],
    selectedMarket: null,
    loading: false
  })
  return (
    <MarketContext.Provider value={{ state, dispatch }}>
      {children}
    </MarketContext.Provider>
  )
}

export function useMarkets() {
  const context = useContext(MarketContext)
  if (!context) throw new Error('useMarkets must be used within MarketProvider')
  return context
}
```

## Anti-pattern: Context for Hot State

Context value changes re-render every consumer. For state that updates frequently
(e.g. cursor position, scroll, form input across the tree), use a store with
selector subscription (Zustand, Jotai, Valtio) instead.
