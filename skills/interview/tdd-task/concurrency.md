# Concurrency

Use this guide when the spec involves shared mutable state or an explicit guarantee such as atomicity, uniqueness, ordering, or isolation under concurrent access. Start from a failing concurrency test, then choose the simplest correct implementation using the Java concurrency docs below.

The test should create real contention, surface worker failures, and assert an **invariant** on the final state. No `Thread.sleep`-based race tests.

## Test harness

```java
@Test
void shouldPreserveInvariantUnderConcurrentAccess() throws Exception {
    int threads = 16;
    int operationsPerThread = 1_000;
    SharedCounter subject = new SharedCounter(); // replace with the public API under test

    ExecutorService pool = Executors.newFixedThreadPool(threads);
    CountDownLatch ready = new CountDownLatch(threads);
    CountDownLatch start = new CountDownLatch(1);

    try {
        List<Future<?>> futures = new ArrayList<>();
        for (int t = 0; t < threads; t++) {
            futures.add(pool.submit(() -> {
                ready.countDown();
                start.await(); // release workers together to maximise contention

                for (int i = 0; i < operationsPerThread; i++) {
                    subject.increment();
                }
                return null;
            }));
        }

        assertTrue(ready.await(2, TimeUnit.SECONDS), "workers did not become ready");
        start.countDown();

        for (Future<?> future : futures) {
            future.get(10, TimeUnit.SECONDS); // surfaces worker exceptions + bounds time
        }
    } finally {
        pool.shutdownNow();
        assertTrue(pool.awaitTermination(2, TimeUnit.SECONDS), "worker pool did not terminate");
    }

    assertEquals(threads * operationsPerThread, subject.value()); // invariant: no lost updates
}
```

## Harness choices

- **Assert the invariant, not the timing.** Pick a property that must hold for every interleaving (final balance, set size, monotonic counter) — never that a specific order occurred.
- **Surface failures.** Always `get()` every `Future`, so an exception or failed assertion on a worker thread fails the test instead of being swallowed.
- **Bound the test.** Use `Future.get(timeout)` for worker completion and `shutdownNow()` + `awaitTermination()` in `finally` for cleanup.
- **Repeat to expose races.** Raise thread/op counts or use `@RepeatedTest` when one run is too lenient; a race that passes once may still be real.

## Synchronizer chooser

| Need | Tool |
| --- | --- |
| One-shot start/done gate | `CountDownLatch` |
| Fixed parties released together, reusable | `CyclicBarrier` |
| Phased or variable-party coordination | `Phaser` |

## JUnit caveats

- `@RepeatedTest` repeats a test method; if JUnit parallel execution is enabled, add `@Execution(SAME_THREAD)` so repetitions are not themselves parallelised.
- Prefer `Future.get(timeout)` and ordinary `@Timeout` over `assertTimeoutPreemptively()`; preemptive timeouts run test code on a different thread and can break ThreadLocal-sensitive code.
- JUnit parallel execution is separate from application concurrency. If this test touches static state, system properties, files, or other suite-level shared resources, protect the test with `@ResourceLock` or `@Isolated`.

## Implementation choices

- Use `AtomicLong` / `AtomicInteger` for exact single-value state such as IDs, sequence numbers, or decisions.
- Use `LongAdder` for high-contention statistics when the value is read after workers are quiescent, not for fine-grained synchronization control.
- Use `ConcurrentHashMap` / concurrent collections for independent per-key or collection operations; use their atomic operations (`compute`, `merge`, `putIfAbsent`) for compound map updates.
- Use `synchronized` / `ReentrantLock` for multi-field invariants. `volatile` alone is not enough for compound read-modify-write operations.
- Avoid hand-rolled lock-free code unless the spec explicitly demands that performance tradeoff.

## Java 21+ notes

- `Executors.newVirtualThreadPerTaskExecutor()` is useful for many blocking tasks; do not pool virtual threads just to limit concurrency — use a `Semaphore` or another limiter.
- A fixed platform-thread pool is still a clear default for small contention tests where you want a known number of simultaneous workers.
- Keep `StructuredTaskScope` out of interview-task code unless the project explicitly enables preview features.

## Official docs

- Java implementation: [`java.util.concurrent`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/package-summary.html), [`java.util.concurrent.atomic`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/atomic/package-summary.html), [`java.util.concurrent.locks`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/locks/package-summary.html)
- Executors and task results: [`ExecutorService`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/ExecutorService.html), [`Executors`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/Executors.html), [`Future`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/Future.html)
- Synchronizers for tests and implementation: [`CountDownLatch`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/CountDownLatch.html), [`CyclicBarrier`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/CyclicBarrier.html), [`Phaser`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/Phaser.html), [`Semaphore`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/concurrent/Semaphore.html)
- Java 21 virtual threads: [Virtual Threads guide](https://docs.oracle.com/en/java/javase/21/core/virtual-threads.html), [`Thread`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Thread.html)
- JUnit concurrency-related test docs: [`@RepeatedTest`](https://docs.junit.org/6.1.0/writing-tests/repeated-tests.html), [timeouts](https://docs.junit.org/6.1.0/writing-tests/timeouts.html), [parallel execution](https://docs.junit.org/6.1.0/writing-tests/parallel-execution.html)
