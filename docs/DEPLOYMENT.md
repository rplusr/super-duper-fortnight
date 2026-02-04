# Deployment Guide

This guide covers deploying the Parcel Tracker application to production.

## Table of Contents

1. [Backend Deployment (Railway)](#backend-deployment-railway)
2. [Backend Deployment (Render)](#backend-deployment-render)
3. [Backend Deployment (Docker)](#backend-deployment-docker)
4. [Mobile App Builds](#mobile-app-builds)
5. [Environment Variables](#environment-variables)
6. [CI/CD Setup](#cicd-setup)

---

## Backend Deployment (Railway)

Railway is the recommended platform for quick deployments.

### Prerequisites

- [Railway CLI](https://docs.railway.app/develop/cli) installed
- Railway account

### Quick Deploy

```bash
# Run the deployment script
./scripts/deploy-backend.sh
```

### Manual Steps

1. **Install Railway CLI:**
   ```bash
   npm install -g @railway/cli
   ```

2. **Login to Railway:**
   ```bash
   railway login
   ```

3. **Create a new project:**
   ```bash
   cd apps/backend
   railway init
   ```

4. **Add PostgreSQL database:**
   ```bash
   railway add --plugin postgresql
   ```

5. **Set environment variables:**
   ```bash
   railway variables set JWT_SECRET="your-secure-secret"
   railway variables set JWT_EXPIRES_IN="15m"
   railway variables set JWT_REFRESH_EXPIRES_IN="7d"
   railway variables set NODE_ENV="production"
   ```

6. **Deploy:**
   ```bash
   railway up
   ```

7. **Run migrations:**
   ```bash
   railway run pnpm prisma migrate deploy
   ```

8. **Get your deployment URL:**
   ```bash
   railway open
   ```

---

## Backend Deployment (Render)

### Steps

1. Connect your GitHub repository to Render
2. Create a new Web Service
3. Configure:
   - **Build Command:** `cd apps/backend && pnpm install && pnpm prisma generate && pnpm build`
   - **Start Command:** `cd apps/backend && pnpm prisma migrate deploy && node dist/main`
4. Add a PostgreSQL database
5. Set environment variables (see below)

---

## Backend Deployment (Docker)

### Using Docker Compose (Local/Self-hosted)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### Building the Docker Image

```bash
cd apps/backend
docker build -t parcel-tracker-api .

# Run the container
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://user:pass@host:5432/db" \
  -e JWT_SECRET="your-secret" \
  parcel-tracker-api
```

---

## Mobile App Builds

### Android

```bash
# Debug build
./scripts/build-android.sh

# Release build (requires signing key)
./scripts/build-android.sh --release
```

#### Setting up Android Signing

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `apps/mobile/android/key.properties`:
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. Build release APK:
   ```bash
   cd apps/mobile
   flutter build apk --release
   ```

### iOS

```bash
# Debug build (macOS only)
./scripts/build-ios.sh

# Release build
./scripts/build-ios.sh --release
```

#### Setting up iOS Signing

1. Open Xcode:
   ```bash
   open apps/mobile/ios/Runner.xcworkspace
   ```

2. Configure signing:
   - Select the Runner target
   - Go to "Signing & Capabilities"
   - Select your team and provisioning profile

3. Archive and distribute:
   - Product > Archive
   - Distribute App

---

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | Secret for JWT signing | `your-super-secret-key-min-32-chars` |
| `JWT_EXPIRES_IN` | Access token expiry | `15m` |
| `JWT_REFRESH_EXPIRES_IN` | Refresh token expiry | `7d` |
| `NODE_ENV` | Environment | `production` |
| `PORT` | Server port | `3000` |

### Optional Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `AFTERSHIP_API_KEY` | AfterShip API key for tracking | `your-api-key` |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase credentials JSON | `{"type":"service_account",...}` |
| `CORS_ORIGIN` | Allowed CORS origins | `https://yourapp.com` |

### Generating a Secure JWT Secret

```bash
# Using OpenSSL
openssl rand -base64 32

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

---

## CI/CD Setup

### GitHub Actions

The repository includes pre-configured GitHub Actions workflows:

- `.github/workflows/backend-ci.yml` - Backend CI/CD
- `.github/workflows/mobile-ci.yml` - Mobile app CI/CD

### Required GitHub Secrets

#### Backend Secrets

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password |

#### Mobile Secrets (Android)

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoded keystore file |
| `ANDROID_KEY_ALIAS` | Keystore key alias |
| `ANDROID_KEY_PASSWORD` | Keystore key password |
| `ANDROID_STORE_PASSWORD` | Keystore store password |

To encode your keystore:
```bash
base64 -i upload-keystore.jks | pbcopy  # macOS
base64 upload-keystore.jks | xclip       # Linux
```

---

## Health Checks

The backend exposes a health endpoint:

```bash
curl https://your-api-url.com/api/health
```

Response:
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

---

## Monitoring & Logs

### Railway

```bash
railway logs
```

### Docker

```bash
docker-compose logs -f backend
```

### Render

View logs in the Render dashboard.

---

## Troubleshooting

### Database Connection Issues

1. Verify `DATABASE_URL` is correct
2. Check if database is accessible from the deployment platform
3. Ensure SSL is configured correctly for production databases

### Migration Issues

```bash
# Reset database (CAUTION: destroys data)
railway run pnpm prisma migrate reset

# Apply migrations
railway run pnpm prisma migrate deploy
```

### Build Failures

1. Check Node.js version (requires 20+)
2. Verify all dependencies are installed
3. Check for TypeScript compilation errors

---

## Security Checklist

- [ ] Strong JWT_SECRET (min 32 characters)
- [ ] HTTPS enabled
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] Database credentials rotated
- [ ] Firebase credentials secured
- [ ] API keys not exposed in client code
