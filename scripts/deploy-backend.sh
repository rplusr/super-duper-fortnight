#!/bin/bash

set -e

echo "🚀 Deploying Backend to Railway..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo "📝 Please log in to Railway:"
    railway login
fi

cd "$(dirname "$0")/../apps/backend"

# Link to Railway project (if not already linked)
if [ ! -f ".railway/config.json" ]; then
    echo "🔗 Linking to Railway project..."
    echo "Please select or create a project:"
    railway link
fi

# Deploy
echo "📦 Deploying..."
railway up --detach

echo "✅ Deployment initiated!"
echo ""
echo "📋 Next steps:"
echo "1. Set environment variables in Railway dashboard:"
echo "   - DATABASE_URL (Railway provides PostgreSQL addon)"
echo "   - JWT_SECRET (generate a secure random string)"
echo "   - JWT_EXPIRES_IN (e.g., 15m)"
echo "   - JWT_REFRESH_EXPIRES_IN (e.g., 7d)"
echo "   - AFTERSHIP_API_KEY (optional)"
echo "   - FIREBASE_SERVICE_ACCOUNT (optional, JSON string)"
echo ""
echo "2. Add PostgreSQL database:"
echo "   railway add --plugin postgresql"
echo ""
echo "3. Run database migrations:"
echo "   railway run pnpm prisma migrate deploy"
echo ""
echo "4. View logs:"
echo "   railway logs"
echo ""
echo "5. Get deployment URL:"
echo "   railway open"
