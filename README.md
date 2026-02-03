# Fashion Boutique - Monorepo

A modern, full-stack luxury fashion e-commerce platform built as a monorepo with Flutter mobile app, NestJS backend, and Next.js web application.

## Architecture

This project is organized as a pnpm monorepo with the following structure:

```
.
├── apps/
│   ├── mobile/          # Flutter mobile app
│   ├── backend/         # NestJS API server
│   └── web/             # Next.js web application
├── packages/
│   └── shared/          # Shared utilities and types
├── package.json         # Root package.json
├── pnpm-workspace.yaml  # Workspace configuration
└── tsconfig.base.json   # Base TypeScript config
```

## Tech Stack

### Mobile App (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Riverpod + flutter_hooks
- **Networking**: Dio
- **Navigation**: go_router
- **Theming**: Material 3 with light/dark mode support

### Backend (NestJS)
- **Framework**: NestJS 10
- **Database**: PostgreSQL with Prisma ORM
- **API Documentation**: Swagger/OpenAPI
- **Validation**: class-validator + class-transformer

### Web App (Next.js)
- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Payments**: Stripe integration
- **CMS**: JSON-based file system

## Getting Started

### Prerequisites

- Node.js 20+
- pnpm 9+
- Flutter 3.x (for mobile development)
- PostgreSQL (for backend)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd super-duper-fortnight
```

2. Install dependencies:
```bash
pnpm install
```

3. Set up environment variables:
```bash
# Backend
cp apps/backend/.env.example apps/backend/.env
# Edit with your database credentials

# Web
cp .env.example .env
# Add your Stripe keys
```

4. Set up the database:
```bash
cd apps/backend
pnpm prisma:generate
pnpm prisma:migrate
```

### Development

```bash
# Run all apps in development mode
pnpm dev

# Run specific apps
pnpm dev:web      # Next.js web app
pnpm dev:backend  # NestJS backend

# For Flutter mobile app
cd apps/mobile
flutter pub get
flutter run
```

### Building

```bash
# Build all apps
pnpm build

# Build specific apps
pnpm build:web
pnpm build:backend
```

### Linting and Formatting

```bash
# Lint all projects
pnpm lint

# Fix lint issues
pnpm lint:fix

# Format code
pnpm format

# Check formatting
pnpm format:check
```

## Project Structure

### Mobile App (`apps/mobile`)

```
lib/
├── core/
│   ├── constants/       # App and API constants
│   ├── extensions/      # Dart extensions
│   ├── router/          # Navigation configuration
│   ├── theme/           # Material 3 theming
│   └── utils/           # Utility functions
├── features/
│   ├── auth/            # Authentication feature
│   ├── home/            # Home screen
│   └── settings/        # Settings screen
└── shared/
    ├── models/          # Shared data models
    ├── providers/       # Global providers
    ├── services/        # API and other services
    └── widgets/         # Reusable widgets
```

### Backend (`apps/backend`)

```
src/
├── common/
│   ├── decorators/      # Custom decorators
│   ├── filters/         # Exception filters
│   ├── guards/          # Auth guards
│   ├── interceptors/    # Request interceptors
│   └── pipes/           # Validation pipes
├── config/              # Configuration
├── modules/
│   ├── health/          # Health check endpoint
│   └── users/           # User management
└── prisma/              # Prisma service
```

### Web App (`apps/web`)

```
├── app/                 # Next.js App Router pages
├── components/          # React components
├── lib/                 # Utilities and configurations
└── cms/                 # JSON-based CMS data
```

## API Documentation

When running the backend in development mode, Swagger documentation is available at:
```
http://localhost:3000/api/docs
```

## Environment Variables

### Backend (`apps/backend/.env`)

| Variable | Description |
|----------|-------------|
| `NODE_ENV` | Environment (development/production) |
| `PORT` | Server port (default: 3000) |
| `DATABASE_URL` | PostgreSQL connection string |
| `CORS_ORIGIN` | Allowed CORS origin |
| `JWT_SECRET` | JWT signing secret |
| `JWT_EXPIRES_IN` | JWT expiration time |

### Web (`.env`)

| Variable | Description |
|----------|-------------|
| `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | Stripe publishable key |
| `STRIPE_SECRET_KEY` | Stripe secret key |
| `NEXT_PUBLIC_APP_URL` | Application URL |

## Scripts

| Script | Description |
|--------|-------------|
| `pnpm dev` | Run all apps in development mode |
| `pnpm build` | Build all apps |
| `pnpm lint` | Lint all projects |
| `pnpm format` | Format all code |
| `pnpm clean` | Clean all build artifacts |

## License

MIT
