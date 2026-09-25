# payment-gateway

Payment rail for [Ledger & Rail](https://github.com/yosefbennywidyo/ledger-rail),
written in Java (Spring Boot) with Redis. Accepts a payment, turns it into a
balanced debit/credit pair, and posts it to `ledger-service`. Outcomes are
cached in Redis per `idempotency_key` (24h TTL) so client retries never
double-apply a payment.

Design notes: [`BEST_PRACTICES.md`](BEST_PRACTICES.md).

## Run

Needs Redis and a running `ledger-service`. From the `ledger-rail`
superproject root, `docker compose up -d redis` provides Redis.

```bash
mise exec java maven -- mvn spring-boot:run
```

| Env var | Default |
|---|---|
| `LEDGER_SERVICE_BASE_URL` | `http://localhost:8080` |
| `REDIS_HOST` | `localhost` |
| `REDIS_PORT` | `6379` |

The HTTP port is `8081` (`server.port` in `src/main/resources/application.properties`).

## API

| Method | Path | Notes |
|---|---|---|
| `GET` | `/healthz` | `200` when up |
| `POST` | `/payments` | `201` completed; `422` rejected by ledger-service (e.g. insufficient balance); `502` ledger-service unreachable; `400` invalid body |

```bash
curl -i -X POST localhost:8081/payments -H 'content-type: application/json' -d '{
  "idempotency_key": "demo-2",
  "payer_account": "alice",
  "payee_account": "bob",
  "amount_cents": 2500
}'
```

`201` and `422` are cached and replayed for the same key; `502` is not, so a
retry after ledger-service recovers is processed normally.

## Test

```bash
mise exec java maven -- mvn test
```

Unit tests need no Redis or ledger-service. End-to-end tests live in the
superproject's [`e2e/`](https://github.com/yosefbennywidyo/ledger-rail/tree/main/e2e).

## Docker

```bash
docker build -t payment-gateway .
```

The superproject's `docker-compose.yml` builds and wires this image
(`docker compose up -d payment-gateway`).
