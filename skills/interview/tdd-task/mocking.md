# When to Mock

Mock only system boundaries that are expensive, non-deterministic, or outside the process:

- External APIs (payment, email, HTTP, message brokers)
- Databases, when a real test database is too heavy for the stage
- Time, when the clock affects behaviour
- Randomness, when deterministic tests need fixed values
- File system, when JUnit `@TempDir` is not enough

Don't mock:

- Your own classes / modules
- Internal collaborators
- Anything you control

Prefer real or deterministic boundary replacements when they are simpler than Mockito:

- Time: inject `InstantSource` or `Clock` with a fixed instant.
- Randomness: inject a `RandomGenerator` or seeded generator.
- File system: use JUnit `@TempDir`.
- Database: use a real repository/test DB when setup is cheap enough.

## Designing for mockability

Inject stable dependencies through constructors rather than constructing them internally:

```java
// Easy to mock
class CheckoutService {
    private final PaymentClient paymentClient;

    CheckoutService(PaymentClient paymentClient) {
        this.paymentClient = paymentClient;
    }

    Receipt process(Order order) {
        PaymentResult result = paymentClient.charge(PaymentRequest.forOrder(order));
        return Receipt.from(result);
    }
}

// Hard to mock
class CheckoutService {
    Receipt process(Order order) {
        var client = new StripeClient(System.getenv("STRIPE_KEY"));
        PaymentResult result = client.charge(PaymentRequest.forOrder(order));
        return Receipt.from(result);
    }
}
```

Prefer a **specific interface per external operation** over one generic call, so each mock returns one shape with no conditional logic in the test setup.

## Mockito use

- Use Mockito for boundary protocols: stub the external response, then assert the public result with AssertJ.
- Verify a boundary call only when the interaction is the observable behaviour, such as "charges the payment provider once".
- Prefer simple `when(...).thenReturn(...)` stubs. Avoid deep stubs, lenient stubs, and mock setup with branches.
- Use `ArgumentCaptor` sparingly for boundary request objects, then assert captured values with AssertJ.
- Avoid static, constructor, and final-class mocking in interview tasks unless the project already has it configured. On modern Java it can require extra Mockito inline/agent setup, and scoped static/constructor mocks must be closed with try-with-resources.

```java
@Test
void shouldChargePaymentProviderOnce() {
    when(paymentClient.charge(any())).thenReturn(PaymentResult.approved());
    ArgumentCaptor<PaymentRequest> request = ArgumentCaptor.forClass(PaymentRequest.class);

    Receipt receipt = checkout.process(order);

    assertThat(receipt.status()).isEqualTo(Status.CONFIRMED);
    verify(paymentClient).charge(request.capture());
    assertThat(request.getValue().amount()).isEqualTo(order.total());
}
```

## Official docs

- Mockito latest javadocs: [`Mockito`](https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/Mockito.html), [`MockitoExtension`](https://javadoc.io/doc/org.mockito/mockito-junit-jupiter/latest/org.mockito.junit.jupiter/org/mockito/junit/jupiter/MockitoExtension.html), [`@InjectMocks`](https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/InjectMocks.html), [`ArgumentCaptor`](https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/ArgumentCaptor.html)
- JUnit 6.1: [built-in extensions / `@TempDir`](https://docs.junit.org/6.1.0/writing-tests/built-in-extensions.html), [`@TempDir` API](https://docs.junit.org/6.1.0/api/org.junit.jupiter.api/org/junit/jupiter/api/io/TempDir.html)
- Java deterministic boundaries: [`InstantSource`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/time/InstantSource.html), [`Clock`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/time/Clock.html), [`RandomGenerator`](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/random/RandomGenerator.html)
