# Blockchain Security (Solana)

> Reference for the [security-review](../SKILL.md) skill.
> Load only when reviewing Solana / wallet integration code.

## Wallet Verification

```typescript
import { verify } from '@solana/web3.js'

async function verifyWalletOwnership(
  publicKey: string,
  signature: string,
  message: string,
) {
  try {
    return verify(
      Buffer.from(message),
      Buffer.from(signature, 'base64'),
      Buffer.from(publicKey, 'base64'),
    )
  } catch {
    return false
  }
}
```

The signed message should include a server-issued nonce and a timestamp so
captured signatures cannot be replayed.

## Transaction Verification

```typescript
async function verifyTransaction(transaction: Transaction) {
  if (transaction.to !== expectedRecipient) {
    throw new Error('Invalid recipient')
  }
  if (transaction.amount > maxAmount) {
    throw new Error('Amount exceeds limit')
  }
  const balance = await getBalance(transaction.from)
  if (balance < transaction.amount) {
    throw new Error('Insufficient balance')
  }
  return true
}
```

`expectedRecipient` and `maxAmount` are placeholders — supply real values from
your application's policy. Hard-coding them in the example does not mean they
are universally correct.

## Verification Steps

- [ ] Wallet signatures verified with a fresh nonce per request (no replay)
- [ ] Signed messages include domain / origin to prevent cross-app reuse
- [ ] Transaction recipient validated against allow-list
- [ ] Amount within configured per-transaction and per-day limits
- [ ] Balance check before submitting
- [ ] No blind transaction signing (UI shows what is being signed)
- [ ] Front-running considerations for high-value txs (use commit-reveal or private mempools where applicable)
