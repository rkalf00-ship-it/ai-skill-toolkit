# Background Jobs & Queues

> Reference for the [backend-patterns](../SKILL.md) skill.

## Simple In-Process Queue

```typescript
class JobQueue<T> {
  private queue: T[] = []
  private processing = false

  async add(job: T): Promise<void> {
    this.queue.push(job)
    if (!this.processing) this.process()
  }

  private async process(): Promise<void> {
    this.processing = true
    while (this.queue.length > 0) {
      const job = this.queue.shift()!
      try {
        await this.execute(job)
      } catch (error) {
        console.error('Job failed:', error)
      }
    }
    this.processing = false
  }

  private async execute(job: T): Promise<void> {
    // implement
  }
}

interface IndexJob { marketId: string }
const indexQueue = new JobQueue<IndexJob>()

export async function POST(request: Request) {
  const { marketId } = await request.json()
  await indexQueue.add({ marketId })
  return NextResponse.json({ success: true, message: 'Job queued' })
}
```

In-process is fine for fire-and-forget jobs that survive process death is OK
(re-derived state, idempotent operations). It does **not** survive restarts.

## When to Use a Real Queue

Use a managed queue (BullMQ + Redis, AWS SQS, Cloud Tasks) when you need:

- **Durability** across restarts and crashes.
- **Retries** with backoff and dead-letter queue for poison messages.
- **Scheduled / delayed** jobs (e.g. send reminder in 24h).
- **Concurrency control** beyond a single process.
- **Visibility** (which jobs ran, which failed, how long they took).

## Job Design Rules

- Make jobs **idempotent** — they may run more than once on retry.
- Pass **IDs**, not full objects — the data may have changed by the time the job runs.
- **Timeouts** on every job — long-running jobs block the worker.
- **Dead-letter queue** for jobs that fail repeatedly — surface them, don't silently drop.
