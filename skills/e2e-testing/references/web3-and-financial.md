# Wallet / Web3 and Financial Flow Testing

> Reference for the [e2e-testing](../SKILL.md) skill.
> Apply only when the project has wallet integration or financial flows.

## Wallet Connection (Mock Provider)

```typescript
test('wallet connection', async ({ page, context }) => {
  await context.addInitScript(() => {
    window.ethereum = {
      isMetaMask: true,
      request: async ({ method }) => {
        if (method === 'eth_requestAccounts') {
          return ['0x1234567890123456789012345678901234567890']
        }
        if (method === 'eth_chainId') return '0x1'
      },
    }
  })

  await page.goto('/')
  await page.locator('[data-testid="connect-wallet"]').click()
  await expect(page.locator('[data-testid="wallet-address"]'))
    .toContainText('0x1234')
})
```

`addInitScript` injects the mock before any page script runs — guarantees the
app sees the mock provider on first read.

## Financial / Critical Flow

```typescript
test('trade execution', async ({ page }) => {
  // NEVER run real-money tests against production
  test.skip(process.env.NODE_ENV === 'production', 'Skip on production')

  await page.goto('/markets/test-market')
  await page.locator('[data-testid="position-yes"]').click()
  await page.locator('[data-testid="trade-amount"]').fill('1.0')

  const preview = page.locator('[data-testid="trade-preview"]')
  await expect(preview).toContainText('1.0')

  await page.locator('[data-testid="confirm-trade"]').click()
  await page.waitForResponse(
    resp => resp.url().includes('/api/trade') && resp.status() === 200,
    { timeout: 30000 }
  )

  await expect(page.locator('[data-testid="trade-success"]')).toBeVisible()
})
```

## Safety Rules for Financial E2E

- **Always have a `test.skip(...)` for prod** — environment misconfiguration
  must not move real money.
- **Use a dedicated test wallet / account** with known small balance.
- **Pin the chain** to a testnet (Goerli / Sepolia / Solana devnet).
- **Idempotent setup**: tests that run multiple times must not corrupt state.
- **No long timeouts hiding bugs**: 30s for blockchain confirmation is OK; 5m
  is hiding a real problem.
