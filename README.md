# Recursive Systems Operations Platform

A self-hosted Elixir/Phoenix platform for managing Recursive Systems LLC operations.

## Features

### Core Platform
- **Authentication**: Session-based user authentication
- **Multi-tenant**: Organization-scoped data
- **Audit Logging**: All changes tracked
- **Mobile Responsive**: Works on all devices

### Finance Module
- **Tax Filing Dashboard**: Track tax years, tasks, and deadlines
- **Transaction Management**: Import, categorize, and manage transactions
- **Mercury API Integration**: Auto-sync checking/savings accounts
- **Google Drive Integration**: Document upload and storage
- **Schedule C Categories**: Pre-configured tax categories
- **Document Management**: Receipts, 1099s, and tax documents
- **CSV Import**: Support for Mercury IO card exports

## Tech Stack

- **Backend**: Elixir/Phoenix with LiveView
- **Database**: PostgreSQL
- **Frontend**: Tailwind CSS + DaisyUI
- **Deployment**: Docker + Docker Compose
- **Auth**: Bcrypt password hashing

## Quick Start (Development)

```bash
# Clone the repository
git clone https://github.com/recursive-systems/ops-platform.git
cd ops-platform

# Install dependencies
mix deps.get

# Setup database
mix ecto.setup

# Start server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000)

## Docker Deployment

```bash
# Start with Docker Compose
docker-compose up -d

# Run migrations
docker-compose exec app mix ecto.migrate

# Create initial user
docker-compose exec app mix run priv/repo/seeds.exs
```

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `SECRET_KEY_BASE` | 64-byte secret for sessions | Yes |
| `MERCURY_API_KEY` | Mercury Bank API token | No |
| `GOOGLE_DRIVE_TOKEN` | Google Drive OAuth token | No |
| `GOOGLE_DRIVE_FOLDER_ID` | Target Drive folder | No |
| `PHX_HOST` | Hostname for URLs | Yes |

### Mercury API Setup

1. Get API key from Mercury dashboard
2. Set `MERCURY_API_KEY` environment variable
3. Use "Sync Accounts" button in Finance section

### Google Drive Setup

1. Create OAuth credentials in Google Cloud Console
2. Enable Google Drive API
3. Set `GOOGLE_DRIVE_TOKEN` and `GOOGLE_DRIVE_FOLDER_ID`

## Precommit Checks

```bash
# Run all checks
mix precommit

# Individual checks
mix compile --warnings-as-errors
mix format
mix credo --strict
mix test
```

## Roadmap

### v1.0 (Current)
- [x] Database schema (organizations, users, transactions, tax years)
- [x] Authentication system
- [x] Finance dashboard
- [x] Transaction management
- [x] Mercury API integration
- [x] Google Drive document sync
- [x] Tax filing checklist
- [x] Mobile responsive UI
- [x] Docker deployment

### v1.1 (Planned)
- [ ] Email receipt auto-import
- [ ] Estimated tax calculator
- [ ] Recurring transaction rules
- [ ] Bank reconciliation
- [ ] Advanced reporting

### Future Modules
- [ ] Projects/Time tracking
- [ ] CRM (Clients/Contacts)
- [ ] Invoicing
- [ ] Contract management

## License

Private - Recursive Systems LLC
