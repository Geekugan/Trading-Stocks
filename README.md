# TrackingStocks

Modern stock tracking and trading demo consisting of a Spring Boot REST API and a React frontend.

## Contents
- `backend/stockTracker`: Java Spring Boot API (MySQL)
- Frontend (React) at repository root (`src`, `public`)

## Features
- Market data integration (live price fetch by ticker)
- Watchlist management (add/remove tracked symbols)
- Portfolio overview (value, gains) and holdings
- Order management (buy/sell; validations and basic rules)
- Dashboard with Top Performers and Order History

## Prerequisites
- Java 17+
- Maven 3.8+
- Node.js 18+ and npm
- MySQL 8+

## Quick start

1) Start the backend

Windows (PowerShell):
```powershell
cd backend\stockTracker
.\mvnw.cmd spring-boot:run
```

macOS/Linux:
```bash
cd backend/stockTracker
./mvnw spring-boot:run
```

The API will run at `http://localhost:8080/api` by default.

2) Start the frontend (in a new terminal from repo root)

Windows (PowerShell):
```powershell
$env:REACT_APP_API_URL="http://localhost:8080/api"
npm install
npm start
```

macOS/Linux:
```bash
export REACT_APP_API_URL="http://localhost:8080/api"
npm install
npm start
```

The app opens at `http://localhost:3000`.

## Configuration
Backend is configured via `backend/stockTracker/src/main/resources/application.properties` and environment variables.

- Database
  - `DB_URL` (default `jdbc:mysql://localhost:3306/stock_portfolio_tracker`)
  - `DB_USERNAME` (default `root`)
  - `DB_PASSWORD` (set to your local password)
- Server
  - `SERVER_PORT` (default `8080`)
- Market data
  - `MARKETDATA_BASE_URL` (base URL for external market data)
- Scheduling
  - `STOCKS_UPDATE_MS` (interval for scheduled stock updates)

Frontend configuration:
- `REACT_APP_API_URL` must point to the backend, e.g. `http://localhost:8080/api`

## Common API endpoints
- Stocks
  - `GET /api/stock` — user-held stocks (volume > 0)
  - `GET /api/stock/watchlist` — all tracked stocks (including zero volume)
  - `GET /api/stock/symbols` — available symbols
  - `GET /api/stock/live/{ticker}` — live price snapshot
  - `POST /api/stock/{ticker}` — add a ticker to watchlist/tracked
- Orders
  - `GET /api/order` — list orders (newest first in UI)
  - `POST /api/order` — place an order
- Portfolio
  - `GET /api/portfolio` — portfolio metrics
  - `GET /api/portfolio/holdings` — holdings breakdown
- Account
  - `GET /api/account` — cash balance
  - `POST /api/account/credit` — add funds

## Development tips
- Java dependencies are handled with the included Maven Wrapper (`mvnw`).
- React dev server proxies API calls via `REACT_APP_API_URL`; ensure it’s set before `npm start`.
- If MySQL is empty, the backend will create schema tables automatically (JPA `ddl-auto=update`).

## Testing (backend)
```bash
cd backend/stockTracker
./mvnw test
```

## Troubleshooting
- “Cannot connect to database”
  - Verify MySQL is running and `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` are correct
  - Confirm the database `stock_portfolio_tracker` exists
- “CORS” errors
  - Ensure `REACT_APP_API_URL` is correct and reachable from the browser
- “Port already in use”
  - Change `SERVER_PORT` for the backend or stop the conflicting process

## Security and production notes
- Use strong, non-default database credentials via environment variables
- Change `spring.jpa.hibernate.ddl-auto` to `validate` or `none` in production
- Enforce HTTPS and configure CORS allowed origins explicitly
- Consider rate limiting and input validation at the API layer
- Set proper timeouts (`HTTP_CONNECT_TIMEOUT_MS`, `HTTP_READ_TIMEOUT_MS`)

