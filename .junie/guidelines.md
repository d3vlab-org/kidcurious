# KidCurious - Kids Q&A AI Application Guidelines

## Project Overview

KidCurious is a production-ready Kids Q&A AI application designed to provide safe, educational, and engaging responses to children's questions. The application uses Domain-Driven Architecture with a modular approach to ensure scalability and maintainability.

### Key Features
- AI-powered question answering for kids
- Content moderation for child safety
- Real-time communication via WebSockets
- Media handling capabilities
- Authentication and authorization system

## Architecture & Technology Stack

### Backend (KidCurious-backend)
- **Framework**: Laravel 12.0 with PHP 8.3
- **Architecture**: Domain-Driven Design with modular packages
- **Performance**: Laravel Octane for enhanced performance
- **Database**: PostgreSQL 15
- **Cache**: Redis (via Predis)
- **AI Integration**: OpenAI API client
- **External APIs**: Google API client
- **Real-time**: WebSockets (Laravel WebSockets, Pusher, Ratchet/Pawl)
- **Testing**: Pest PHP testing framework
- **Code Quality**: Laravel Pint for code formatting

### Frontend
- **Primary**: Laravel + Vite integration with TailwindCSS 4.0
- **Secondary**: React/TypeScript application (KidCurious-front) - in development
- **Styling**: TailwindCSS 4.0
- **HTTP Client**: Axios
- **Database**: Supabase integration

### Infrastructure
- **Containerization**: Docker with docker-compose
- **Services**: Backend (port 8000), Frontend (port 5173), PostgreSQL (port 5432)

## Project Structure

```
KidCurious/
├── KidCurious-backend/          # Laravel backend application
│   ├── app/                     # Main application code
│   ├── packages/                # Custom domain packages
│   │   ├── auth-service/        # Authentication & authorization
│   │   ├── question-service/    # Question handling logic
│   │   ├── moderation-service/  # Content moderation
│   │   ├── llm-gateway/         # AI/LLM integration
│   │   └── media-service/       # Media processing
│   ├── tests/                   # Test files
│   └── docker/                  # Docker configuration
├── KidCurious-front/            # React frontend (in development)
│   ├── components/              # React components
│   ├── contexts/                # React contexts
│   ├── services/                # API services
│   └── utils/                   # Utility functions
└── docker-compose.yml           # Docker orchestration
```

## Development Setup

### Prerequisites
- Docker and Docker Compose
- PHP 8.3+ (for local development)
- Node.js (for frontend assets)
- Composer

### Getting Started

1. **Clone and Setup**:
   ```bash
   git clone <repository-url>
   cd KidCurious
   ```

2. **Environment Configuration**:
   - Copy `.env.example` to `.env` in backend directory
   - Configure database, API keys, and other environment variables

3. **Docker Development**:
   ```bash
   docker-compose up -d
   ```
   This will start:
   - Backend on http://localhost:8000
   - Frontend on http://localhost:5173
   - PostgreSQL on localhost:5432

4. **Local Development** (Backend):
   ```bash
   cd KidCurious-backend
   composer install
   php artisan migrate
   composer run dev  # Runs server, queue, logs, and vite concurrently
   ```

## Testing Guidelines

### Running Tests
- **Backend Tests**: Use Pest PHP framework
  ```bash
  cd KidCurious-backend
  composer run test
  # or directly: php artisan test
  ```

### Test Requirements
- Always run tests after making changes to ensure no regressions
- Write tests for new features following Pest PHP conventions
- Test coverage should include unit tests for domain logic and feature tests for API endpoints

## Code Quality & Standards

### Backend
- **Code Style**: Use Laravel Pint for consistent formatting
  ```bash
  ./vendor/bin/pint
  ```
- **Architecture**: Follow Domain-Driven Design principles
- **Packages**: Keep domain logic in respective packages under `packages/` directory
- **PSR Standards**: Follow PSR-4 autoloading and PSR-12 coding standards

### Frontend
- **Styling**: Use TailwindCSS 4.0 classes
- **TypeScript**: Use TypeScript for type safety in React components
- **Components**: Follow React best practices and component composition

## Development Workflow

### Before Submitting Changes
1. **Run Tests**: Execute `composer run test` to ensure all tests pass
2. **Code Formatting**: Run Laravel Pint to format code
3. **Build Check**: Ensure the application builds successfully with Docker
4. **Environment Variables**: Verify all required environment variables are documented

### Docker vs Local Development
- **Docker**: Recommended for full-stack development and production-like environment
- **Local**: Faster for backend-only development and debugging

### Database Migrations
- Always create migrations for database changes
- Use `php artisan migrate` for applying migrations
- Test migrations in both directions (up and down)

## Important Notes

### Directory Naming Discrepancy
- Docker Compose references `./backend` and `./frontend`
- Actual directories are `KidCurious-backend` and `KidCurious-front`
- Update docker-compose.yml paths when deploying

### AI Safety & Moderation
- All AI responses go through the moderation service
- Content filtering is critical for child safety
- Test moderation rules thoroughly

### Performance Considerations
- Laravel Octane is configured for enhanced performance
- Redis caching is available for frequently accessed data
- WebSocket connections should be monitored for resource usage
