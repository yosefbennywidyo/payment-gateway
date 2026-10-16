package rail.ledger.paymentgateway.client;

/**
 * ledger-service reported HTTP 409: a request with this idempotency key is
 * genuinely still being processed by another concurrent request. Distinct
 * from {@link LedgerServiceException} (a definitive business rejection) and
 * {@link LedgerServiceUnavailableException} (connectivity) because, like
 * those, it changes what PaymentService does with the outcome — this one
 * must never be cached, the same way a 502 isn't.
 */
public class LedgerServiceConflictException extends RuntimeException {

    public LedgerServiceConflictException(String message) {
        super(message);
    }
}
