# KidCurious

KidCurious is a Q&A AI application designed for children, providing safe, educational and engaging answers to their questions. The platform is hosted on Fly.io and accessible at `https://kidcurious.click` (frontend) and `https://api.kidcurious.click` (API).

## Technology Stack

- **Backend**: Laravel 12 (PHP 8.3) with Octane for performance
- **Frontend**: React (TypeScript) built with Vite and styled using Tailwind CSS 4.0
- **Database**: Supabase PostgreSQL cluster
- **Authentication**: Supabase Auth (JWT tokens)
- **Hosting**: Fly.io
- **Caching/Queuing**: Redis
- **AI Integration**: OpenAI API

## Project Structure

```
KidCurious/
├── KidCurious-backend/     # Laravel backend API
├── KidCurious-front/       # React frontend application
├── docker-compose.yml      # Development environment
├── fly.toml               # Fly.io production configuration
└── README.md              # This file
```

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local frontend development)
- PHP 8.3+ (for local backend development)

### Environment Variables

Create `.env` files in both backend and frontend directories with the following variables:

#### Backend (.env)
```env
APP_NAME=KidCurious
APP_ENV=local
APP_KEY=base64:your-app-key
APP_DEBUG=true
APP_URL=http://localhost:8000
FRONTEND_URL=http://localhost:5173

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key
SUPABASE_ANON_KEY=your-anon-key

# Database (Supabase PostgreSQL)
DB_CONNECTION=pgsql
DB_HOST=db.your-project.supabase.co
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres
DB_PASSWORD=your-db-password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# OpenAI
OPENAI_API_KEY=your-openai-api-key

# CORS
CORS_ALLOWED_ORIGINS_PATTERN=http://localhost:*
```

#### Frontend (.env)
```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_BASE_URL=http://localhost:8000/api
```

### Running the Application

1. **Start the development environment:**
   ```bash
   docker-compose up --build
   ```

2. **Access the applications:**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:8000
   - PostgreSQL: localhost:5432
   - Redis: localhost:6379

3. **Install dependencies (if needed):**
   ```bash
   # Backend
   cd KidCurious-backend
   composer install
   
   # Frontend
   cd KidCurious-front
   npm install
   ```

## Production Deployment on Fly.io

### Prerequisites

1. Install the Fly CLI: https://fly.io/docs/getting-started/installing-flyctl/
2. Create a Fly.io account and login: `fly auth login`
3. Set up Supabase project with PostgreSQL database

### Backend Deployment

1. **Deploy the backend:**
   ```bash
   fly deploy
   ```

2. **Set required secrets:**
   ```bash
   # Application secrets
   fly secrets set APP_KEY="base64:your-generated-app-key"
   fly secrets set OPENAI_API_KEY="your-openai-api-key"
   
   # Supabase secrets
   fly secrets set SUPABASE_URL="https://your-project.supabase.co"
   fly secrets set SUPABASE_SERVICE_KEY="your-service-key"
   fly secrets set SUPABASE_ANON_KEY="your-anon-key"
   
   # Database secrets (Supabase PostgreSQL)
   fly secrets set DB_HOST="db.your-project.supabase.co"
   fly secrets set DB_DATABASE="postgres"
   fly secrets set DB_USERNAME="postgres"
   fly secrets set DB_PASSWORD="your-db-password"
   ```

3. **Verify deployment:**
   ```bash
   fly status
   fly logs
   ```

### Frontend Deployment

The frontend is configured to be built and served via Nginx using the production Dockerfile.

1. **Build and deploy:**
   ```bash
   cd KidCurious-front
   # The frontend will be built automatically during the Docker build process
   ```

2. **Environment variables for frontend:**
   Make sure your frontend `.env` file contains production URLs:
   ```env
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key
   VITE_API_BASE_URL=https://api.kidcurious.click/api
   ```

### Supabase Configuration

1. **Create a Supabase project:**
   - Go to https://supabase.com
   - Create a new project
   - Note down your project URL, anon key, and service key

2. **Configure authentication:**
   - Enable email/password authentication in Supabase Auth settings
   - Add `https://kidcurious.click` to allowed redirect URLs
   - Configure JWT settings if needed

3. **Database setup:**
   - The database will be automatically migrated on deployment
   - Ensure your Supabase PostgreSQL instance is accessible

### CORS Configuration

The backend is pre-configured to handle CORS properly for production:

- **Allowed Origins**: Configured via `FRONTEND_URL` environment variable
- **Allowed Origins Pattern**: Set to `https://*.kidcurious.click` via `CORS_ALLOWED_ORIGINS_PATTERN`
- **Allowed Methods**: All HTTP methods (`*`)
- **Allowed Headers**: All headers (`*`)
- **Credentials Support**: Enabled for authentication

The CORS settings are automatically applied when the environment variables are set correctly in `fly.toml`:

```toml
[env]
  APP_URL = "https://api.kidcurious.click"
  FRONTEND_URL = "https://kidcurious.click"
  CORS_ALLOWED_ORIGINS_PATTERN = "https://*.kidcurious.click"
```

### Health Checks

Both applications include health check endpoints:

- **Backend**: `GET /health` - Returns application status
- **Frontend**: `GET /health` - Returns Nginx status

### Monitoring and Logs

```bash
# View application logs
fly logs

# Monitor application status
fly status

# Scale application
fly scale count 2

# View metrics
fly dashboard
```

### Troubleshooting

1. **CORS Issues:**
   - Verify `FRONTEND_URL` is set correctly in Fly secrets
   - Check that `CORS_ALLOWED_ORIGINS_PATTERN` includes your domain
   - Ensure Supabase project allows your domain in auth settings

2. **Database Connection Issues:**
   - Verify Supabase database credentials are correct
   - Check that database is accessible from Fly.io
   - Ensure migrations have run successfully

3. **Authentication Issues:**
   - Verify Supabase keys are set correctly
   - Check JWT token validation in backend logs
   - Ensure frontend is using correct Supabase configuration

4. **Build Issues:**
   - Check that all environment variables are set
   - Verify Docker build process completes successfully
   - Review build logs for specific errors

## Testing

```bash
# Backend tests
cd KidCurious-backend
composer run test

# Frontend tests (if configured)
cd KidCurious-front
npm run test
```

## Code Style

```bash
# Backend code formatting
cd KidCurious-backend
./vendor/bin/pint
```

## Contributing

1. Follow Domain-Driven Design principles
2. Write tests for new features
3. Run code formatting before committing
4. Keep environment variables in `.env` files, never commit secrets
5. Update this README when adding new features or changing deployment process

## License

This project is proprietary software. All rights reserved.