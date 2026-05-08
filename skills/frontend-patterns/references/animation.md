# Animation Patterns

> Reference for the [frontend-patterns](../SKILL.md) skill.

## Framer Motion: List Animations

```typescript
import { motion, AnimatePresence } from 'framer-motion'

export function AnimatedMarketList({ markets }: { markets: Market[] }) {
  return (
    <AnimatePresence>
      {markets.map(market => (
        <motion.div
          key={market.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.3 }}
        >
          <MarketCard market={market} />
        </motion.div>
      ))}
    </AnimatePresence>
  )
}
```

## Framer Motion: Modal Animation

```typescript
export function Modal({ isOpen, onClose, children }: ModalProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            className="modal-overlay"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />
          <motion.div
            className="modal-content"
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
          >
            {children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
```

## Performance Notes

- Animate `transform` and `opacity` only — they are GPU-accelerated and don't trigger layout.
- Avoid animating `width`, `height`, `top`, `left` — they cause layout thrashing.
- Respect `prefers-reduced-motion`: pass `transition={{ duration: 0 }}` when set.
- Use `layout` prop sparingly — it animates layout changes but is expensive on long lists.
