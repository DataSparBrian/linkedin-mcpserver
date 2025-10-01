# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
- `npm run start:dev` - Run development server with environment variables loaded
- `npm run build` - Build TypeScript to JavaScript in build/ directory and make index.js executable
- `npm run inspector` - Debug with MCP Inspector (browser-based interface for monitoring requests/responses)

### Linting and Code Quality
- Uses ESLint with TypeScript parser and Prettier integration
- **No console.log allowed** - use LoggerService instead (enforced by ESLint rule)
- Semicolons are forbidden (enforced by ESLint and Prettier config)
- Trailing commas are forbidden

## Architecture

### MCP (Model Context Protocol) Server
This is a LinkedIn API integration server following the Model Context Protocol standard. The server exposes LinkedIn API functionality as MCP tools that can be used by AI assistants.

### Dependency Injection Pattern
- Uses **TSyringe** for dependency injection throughout the application
- Container setup in [src/container.ts](src/container.ts) registers all services as singletons
- All services use `@injectable()` decorator and constructor injection with `@inject()`

### Core Services Architecture
- **LinkedInMcpServer** ([src/server.ts](src/server.ts)) - Main server class that registers MCP tools
- **ClientService** ([src/services/client.service.ts](src/services/client.service.ts)) - Handles all LinkedIn API requests with automatic token management
- **TokenService** ([src/services/token.service.ts](src/services/token.service.ts)) - Manages LinkedIn OAuth authentication
- **AuthConfig** ([src/auth/auth.config.ts](src/auth/auth.config.ts)) - Validates and provides LinkedIn API credentials
- **LoggerService** ([src/services/logger.service.js](src/services/logger.service.js)) - Structured logging with Pino
- **MetricsService** ([src/services/metrics.service.ts](src/services/metrics.service.ts)) - Tracks API usage and performance metrics

### Schema Validation
- Uses **Zod** for runtime validation
- Environment variables validated in [src/schemas/env.schema.ts](src/schemas/env.schema.ts)
- LinkedIn API parameters defined in [src/schemas/linkedin.schema.ts](src/schemas/linkedin.schema.ts)

### MCP Tools
The server exposes these LinkedIn API operations as MCP tools:
- `search-people` - Search LinkedIn profiles with filters (company, industry, location, keywords)
- `get-profile` - Get detailed profile by public ID or URN ID
- `search-jobs` - Search job postings with criteria
- `send-message` - Send messages to LinkedIn connections
- `get-my-profile` - Get current user's profile
- `get-network-stats` - Get network statistics
- `get-connections` - Get user's connections

### Environment Configuration
The application automatically loads environment variables from `.env` file using dotenv.

Required environment variables (defined in [.env.example](.env.example)):
- `LINKEDIN_CLIENT_ID` - LinkedIn application client ID
- `LINKEDIN_CLIENT_SECRET` - LinkedIn application client secret
- `LINKEDIN_ACCESS_TOKEN` - LinkedIn access token (if available, bypasses OAuth flow)
- Optional: `MCP_SERVER_NAME`, `MCP_SERVER_VERSION`, `MCP_SERVER_PORT`

### TypeScript Configuration
- ES2020 target with NodeNext modules
- Experimental decorators enabled for TSyringe
- Strict mode enabled with unused locals checking
- Source maps generated for debugging