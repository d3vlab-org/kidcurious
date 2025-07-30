# KidCurious Deployment Guide

This guide covers both development and production deployment for the KidCurious monorepo (React frontend + Laravel backend).

## Prerequisites

- Docker and Docker Compose
- Fly.io CLI (for production deployment)
- Node.js 18+ (for local development)
- PHP 8.2+ (for local development)

## Development Environment

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd KidCurious
   ```

2. **Set up environment variables**:
   ```bash
   cp KidCurious-backend/.env.example KidCurious-backend/.env
   ```

3. **Start the development environment**:
   ```bash
   docker-compose up -d
   ```

This will start:
- **Backend**: Laravel API on http://localhost:8000
- **Frontend**: React dev server on http://localhost:5173
- **Database**: PostgreSQL on localhost:5432
- **Cache**: Redis on localhost:6379

### Services Overview

| Service | Port | Description |
|---------|------|-------------|
| Backend | 8000 | Laravel API with PHP 8.2 |
| Frontend | 5173 | React development server |
| PostgreSQL | 5432 | Database |
| Redis | 6379 | Cache and queues |

### Development Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild services
docker-compose up --build

# Run Laravel commands
docker-compose exec backend php artisan migrate
docker-compose exec backend php artisan tinker

# Install frontend dependencies
docker-compose exec frontend npm install

# Access database
docker-compose exec postgres psql -U postgres -d kidcurious
```

### Environment Configuration

The development environment uses these default settings:

- **Database**: PostgreSQL with database `kidcurious`, user `postgres`, password `secret`
- **Redis**: Default configuration on port 6379
- **Laravel**: Debug mode enabled, local environment
- **React**: Development server with hot reload

## Production Deployment (Fly.io)

### Initial Setup

1. **Install Fly.io CLI**:
   ```bash
   # macOS
   brew install flyctl
   
   # Linux/Windows
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly.io**:
   ```bash
   fly auth login
   ```

3. **Create Fly.io app**:
   ```bash
   fly launch
   ```
   
   This will:
   - Create a new app on Fly.io
   - Use the existing `fly.toml` configuration
   - Build and deploy the application

### Database Setup

1. **Create PostgreSQL database**:
   ```bash
   fly postgres create --name kidcurious-db --region fra
   ```

2. **Attach database to your app**:
   ```bash
   fly postgres attach --app kidcurious kidcurious-db
   ```

   This automatically sets the `DATABASE_URL` environment variable.

### Environment Variables

Set the required secrets for production:

```bash
# Generate Laravel app key
fly secrets set APP_KEY=$(php artisan key:generate --show)

# Set production URLs (replace with your actual domain)
fly secrets set APP_URL=https://kidcurious.fly.dev
fly secrets set FRONTEND_URL=https://kidcurious.fly.dev

# Set API keys (replace with your actual keys)
fly secrets set OPENAI_API_KEY=your-openai-api-key
fly secrets set GOOGLE_API_KEY=your-google-api-key

# Optional: Set custom database password
fly secrets set DB_PASSWORD=your-secure-password
```

### Deployment Commands

```bash
# Deploy to production
fly deploy

# View logs
fly logs

# Check app status
fly status

# Scale the application
fly scale count 2

# Open the application
fly open

# SSH into the container
fly ssh console
```

### Health Checks

The application includes health checks at:
- **HTTP**: `GET /health` - Returns "healthy" if the application is running
- **Laravel**: `GET /up` - Laravel's built-in health check

### Production Configuration

The production environment includes:

- **Multi-stage Docker build**: Frontend built with `npm run build`, backend with production composer install
- **Nginx**: Serves both frontend static files and Laravel API
- **PHP 8.2**: With all required extensions
- **Supervisor**: Manages Nginx and PHP-FPM processes
- **Health checks**: Automatic health monitoring
- **Auto-scaling**: Minimum 1 machine, auto-start/stop
- **HTTPS**: Automatic SSL certificates

### File Structure in Production

```
/var/www/html/
├── public/
│   ├── index.php          # Laravel entry point
│   └── frontend/          # Built React app
│       ├── index.html
│       ├── assets/
│       └── ...
├── app/                   # Laravel application
├── config/                # Laravel configuration
└── ...
```

### Routing in Production

- **Frontend routes**: `/*` → Served by React SPA
- **API routes**: `/api/*` → Handled by Laravel
- **Health check**: `/health` → Nginx health endpoint
- **Laravel health**: `/up` → Laravel health check

## Troubleshooting

### Development Issues

1. **Port conflicts**:
   ```bash
   # Check what's using the ports
   lsof -i :8000
   lsof -i :5173
   lsof -i :5432
   ```

2. **Database connection issues**:
   ```bash
   # Reset database
   docker-compose down -v
   docker-compose up -d
   ```

3. **Frontend not updating**:
   ```bash
   # Clear node_modules and reinstall
   docker-compose exec frontend rm -rf node_modules
   docker-compose exec frontend npm install
   ```

### Production Issues

1. **Check application logs**:
   ```bash
   fly logs --app kidcurious
   ```

2. **Check health status**:
   ```bash
   curl https://kidcurious.fly.dev/health
   ```

3. **Database connection issues**:
   ```bash
   # Check database status
   fly postgres list
   fly postgres connect --app kidcurious-db
   ```

4. **Redeploy application**:
   ```bash
   fly deploy --no-cache
   ```

## Monitoring

### Development
- View logs: `docker-compose logs -f`
- Database: Access via `docker-compose exec postgres psql -U postgres -d kidcurious`

### Production
- Fly.io dashboard: https://fly.io/dashboard
- Application logs: `fly logs`
- Metrics: Available in Fly.io dashboard
- Health checks: Automatic monitoring with alerts

## Security Notes

- Never commit `.env` files to version control
- Use Fly.io secrets for sensitive environment variables
- Regularly update dependencies
- Monitor application logs for security issues
- Use HTTPS in production (automatically handled by Fly.io)

## Support

For issues related to:
- **Docker**: Check Docker and Docker Compose documentation
- **Fly.io**: Check Fly.io documentation or community forum
- **Laravel**: Check Laravel documentation
- **React**: Check React and Vite documentation