# KidCurious – Project Guidelines for Junie

## Overview
KidCurious is a Q&A AI application designed for children, providing safe, educational and engaging answers to their questions. The platform is hosted on Fly.io and accessible at `https://kidcurious.click` (frontend) and `https://api.kidcurious.click` (API).

## Technology Stack
- **Backend**: Laravel 12 (PHP 8.3) with Octane for performance. The backend follows a Domain‑Driven Design structure. OpenAI API is used for generating answers, and Redis is used for caching and queueing. Supabase PostgreSQL serves as the database. Authentication is delegated to Supabase Auth (JWT tokens).
- **Frontend**: React (TypeScript) built with Vite and styled using Tailwind CSS 4.0. It communicates with the backend via Axios and uses Supabase JS for authentication and user management.
- **Database**: Supabase PostgreSQL cluster. No local DB is required in development or production; the backend uses Supabase credentials via environment variables.
- **Hosting**: Fly.io. The backend runs on port 8080 behind Nginx, and the frontend is served statically. TLS is terminated by Fly.io.

## Domain Structure
The backend is organized into the following packages under `packages/`:
- `auth-service`: handles Supabase-based registration, login and JWT verification.
- `question-service`: models questions and answers and provides endpoints to submit questions.
- `moderation-service`: filters AI responses to ensure child safety.
- `llm-gateway`: integrates with the OpenAI API and passes results to the moderation service.
- `media-service`: (planned) handles audio and image uploads from users.

Each package should include its own service classes, repositories, controllers and Pest tests.

## Environment Configuration
- The API base URL should be `https://api.kidcurious.click/api`.
- The frontend URL is `https://kidcurious.click`.
- Supabase environment variables: `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` and `SUPABASE_ANON_KEY` must be provided in `.env` for both backend and frontend.
- Database configuration variables in `.env` should point to Supabase Postgres (host, port, database, user, password). No local database is expected.
- Redis connection variables: `REDIS_HOST=redis`, `REDIS_PORT=6379`.

## Development Workflow
1. Start containers with `docker-compose up --build`. This will build and run the backend on port 8000 locally and frontend on port 5173.
2. Install PHP dependencies via Composer and NPM dependencies in the frontend container if they are missing.
3. Run tests using Pest: `composer run test`. Add tests for each new feature [oai_citation:0‡raw.githubusercontent.com](https://raw.githubusercontent.com/d3vlab-org/kidcurious/main/.junie/guidelines.md#:~:text=%23%23%23%20Running%20Tests%20,directly%3A%20php%20artisan%20test).
4. Run Pint before committing to enforce code style [oai_citation:1‡raw.githubusercontent.com](https://raw.githubusercontent.com/d3vlab-org/kidcurious/main/.junie/guidelines.md#:~:text=%23%23%23%20Backend%20,bash%20.%2Fvendor%2Fbin%2Fpint).
5. Use Vite (`npm run dev`) to develop the frontend with hot reload.
6. For production, deploy via Fly.io using `fly deploy`. Ensure environment variables (Supabase and OpenAI keys, `APP_URL`, `FRONTEND_URL`) are set in Fly secrets.

## Coding Best Practices
- Follow Domain‑Driven Design principles. Keep business logic inside domain services and avoid bloated controllers.
- Store credentials and secrets only in environment variables; never commit them to the repository.
- Write small, focused prompts to Junie. Large prompts can be broken down into follow‑ups.
- Use context from this guidelines file whenever instructing Junie, e.g., “use Supabase Auth”, “backend uses Laravel 12 with Octane”, “frontend uses React with Tailwind”, etc.

## Additional Tips
- Because Junie can run commands and modify files [oai_citation:2‡jetbrains.com](https://www.jetbrains.com/help/junie/get-started-with-junie.html#:~:text=,progress%20of%20the%20task%20completion), avoid prompts that could cause destructive operations. Always review changes before committing.
- If Junie shows unexpected behaviour, refine the guidelines or add clarifications. The guidelines file is re‑read each time, so updates will take effect immediately [oai_citation:3‡jetbrains.com](https://www.jetbrains.com/guide/ai/article/junie/intellij-idea/#:~:text=If%20you%20notice%20Junie%20doing,more%20effectively%20within%20your%20project).