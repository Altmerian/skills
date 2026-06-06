# Good Tests

Test observable behaviour through public interfaces with real domain objects. Use mocks only at system boundaries.

## Good shape

```java
import org.assertj.core.api.SoftAssertions;

@Test
void shouldConfirmCheckoutWithValidCart() {
    Cart cart = new Cart();
    cart.add(product);

    Receipt receipt = checkout.process(cart, paymentMethod);

    SoftAssertions.assertSoftly(softly -> {
        softly.assertThat(receipt.status()).isEqualTo(Status.CONFIRMED);
        softly.assertThat(receipt.total()).isEqualTo(cart.total());
    });
}
```

Good tests:

- Name the behaviour callers care about: condition -> observable outcome.
- Arrange and verify through the public API.
- Survive internal refactors.
- Assert one observable behaviour per test. Multiple assertions are fine when they describe one result.
- Prefer AssertJ `assertThat(...)` for readable, type-specific assertions.

## Assertion choices

- Values and objects: `assertThat(actual).isEqualTo(expected)`.
- Collections: `assertThat(items).extracting(Item::id).containsExactly(...)`; use `containsExactlyInAnyOrder(...)` only when order is not part of the spec.
- Multiple fields of one result: AssertJ `SoftAssertions.assertSoftly(...)` or JUnit `assertAll(...)`.
- Exceptions: `assertThatThrownBy(() -> service.create(invalid)).isInstanceOf(...).hasMessageContaining(...)`; use JUnit `assertThrowsExactly(...)` when exact exception type is the behaviour.
- DTO/value snapshots: `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)`, but ignore only irrelevant volatile fields and avoid comparing whole mutable domain graphs by accident.
- Equivalent edge cases: use `@ParameterizedTest` instead of duplicating near-identical tests.
- File-system behaviour: use JUnit `@TempDir` rather than hard-coded paths.

## Bad shape

Coupled to internal structure.

```java
// BAD: tests an implementation detail
@Test
void checkoutCallsPaymentServiceProcess() {
    PaymentService payment = mock(PaymentService.class);
    checkout.process(cart, payment);
    verify(payment).process(cart.total());
}
```

Red flags:

- Mocking internal collaborators.
- Testing private methods.
- Verifying internal calls, call order, or counts when the public result already proves the behaviour.
- Breaks when refactoring without a behaviour change.
- Name describes HOW, not WHAT.
- Bypassing the interface to inspect storage when the interface exposes the observable result.

Prefer:

```java
@Test
void shouldMakeCreatedUserRetrievable() {
    User user = service.createUser("Alice");

    assertThat(service.getUser(user.id()).name()).isEqualTo("Alice");
}
```

## Official docs

- JUnit 6.1: [overview](https://docs.junit.org/6.1.0/overview.html), [assertions](https://docs.junit.org/6.1.0/writing-tests/assertions.html), [exception handling](https://docs.junit.org/6.1.0/writing-tests/exception-handling.html), [parameterized classes and tests](https://docs.junit.org/6.1.0/writing-tests/parameterized-classes-and-tests.html), [built-in extensions / `@TempDir`](https://docs.junit.org/6.1.0/writing-tests/built-in-extensions.html)
- JUnit 6.1 API: [`Assertions`](https://docs.junit.org/6.1.0/api/org.junit.jupiter.api/org/junit/jupiter/api/Assertions.html), [`@ParameterizedTest`](https://docs.junit.org/6.1.0/api/org.junit.jupiter.params/org/junit/jupiter/params/ParameterizedTest.html), [`@TempDir`](https://docs.junit.org/6.1.0/api/org.junit.jupiter.api/org/junit/jupiter/api/io/TempDir.html)
- AssertJ Core: [documentation](https://assertj.github.io/doc/#assertj-core), [latest javadoc](https://www.javadoc.io/doc/org.assertj/assertj-core/latest/index.html), [soft assertions](https://assertj.github.io/doc/#assertj-core-soft-assertions), [recursive comparison](https://assertj.github.io/doc/#assertj-core-recursive-comparison)
