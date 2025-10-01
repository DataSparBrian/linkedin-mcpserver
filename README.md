# 🔗 LinkedIn MCP Server

A Model Context Protocol (MCP) server that provides LinkedIn API integration for AI assistants like Claude Desktop, enabling AI-powered LinkedIn profile searches, job searches, messaging, and network analytics.

## 📋 Overview

LinkedIn MCP Server bridges the gap between AI assistants and LinkedIn's professional network through the Model Context Protocol. This TypeScript-based server enables AI agents to search profiles, discover jobs, manage connections, send messages, and access network statistics—all through a standardized protocol.

**What is MCP?** The Model Context Protocol is an open standard that allows AI applications to securely connect to external data sources and tools. Think of it as a universal connector that lets AI assistants like Claude interact with various services in a standardized way.

## ✨ Features

### 🛠️ Available Tools

The server provides 7 LinkedIn API tools:

1. **search-people** - Search for LinkedIn profiles with advanced filtering
   - Search by keywords, location, industry, and more
   - Returns profile results with key information

2. **get-profile** - Retrieve detailed profile information
   - Get comprehensive data about a specific LinkedIn profile
   - Supports lookup by public ID or URN ID

3. **search-jobs** - Discover job opportunities
   - Search with keywords, location, and other criteria
   - Returns job postings with details

4. **send-message** - Send messages to LinkedIn connections
   - Communicate with your professional network
   - Requires recipient URN

5. **get-my-profile** - Get your own LinkedIn profile
   - Retrieve the current authenticated user's profile
   - No parameters required

6. **get-network-stats** - Access connection statistics
   - View network analytics and connection metrics
   - No parameters required

7. **get-connections** - List your connections
   - Retrieve your LinkedIn connections
   - No parameters required

### 🏗️ Technical Architecture

- **TypeScript** - Built with modern TypeScript for type safety
- **MCP SDK** - Implements the Model Context Protocol standard
- **Dependency Injection** - Uses TSyringe for clean, testable code
- **Structured Logging** - Comprehensive logging with Pino
- **Environment Management** - Secure credential handling with dotenvx
- **Schema Validation** - Input validation with Zod
- **REST Integration** - Axios-powered API client with token management

## 📦 Installation

### Prerequisites

- **Docker & Docker Compose** (recommended) OR Node.js 20+
- LinkedIn Developer Account with API credentials

### Method 1: Docker Installation (Recommended)

Docker provides the simplest and most reliable installation method:

```bash
# Clone the repository
git clone https://github.com/yourusername/linkedin-mcp-server.git
cd linkedin-mcp-server

# Copy and configure environment file
cp .env.example .env
# Edit .env with your LinkedIn credentials (see Step 2 below)

# Build and start with Docker Compose
docker-compose up -d

# Verify it's running
docker-compose ps
```

### Method 2: Manual Node.js Installation

If you prefer not to use Docker:

```bash
# Clone the repository
git clone https://github.com/yourusername/linkedin-mcp-server.git
cd linkedin-mcp-server

# Install dependencies
npm install

# Build the server
npm run build
```

### Step 2: LinkedIn API Setup

1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/apps)
2. Create a new application
3. Configure your app with required permissions:
   - `r_liteprofile` - Read basic profile information
   - `r_emailaddress` - Read email address
   - `w_member_social` - Post and interact on behalf of user
   - `r_1st_connections_size` - View connection count
4. Copy your **Client ID** and **Client Secret**
5. Optionally, generate an **Access Token** (or the server will handle OAuth)

### Step 3: Configure Environment Variables

Create a `.env` file in the project root:

```bash
# Copy the example file
cp .env.example .env
```

Edit `.env` with your credentials:

```bash
# MCP Server Configuration (Optional - defaults shown)
MCP_SERVER_NAME='linkedin-mcp-server'
MCP_SERVER_VERSION='0.1.0'
MCP_SERVER_PORT=5050

# Node Environment
NODE_ENV=production

# LinkedIn API Configuration (Required)
LINKEDIN_CLIENT_ID='your_actual_client_id'
LINKEDIN_CLIENT_SECRET='your_actual_client_secret'

# LinkedIn Access Token (Optional - if not provided, OAuth flow is used)
LINKEDIN_ACCESS_TOKEN='your_access_token'
```

### Step 4: Configure Claude Desktop

Add the server to your Claude Desktop configuration:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

#### For Docker Installation:

```json
{
  "mcpServers": {
    "linkedin": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "linkedin-mcp-server",
        "node",
        "build/index.js"
      ]
    }
  }
}
```

#### For Manual Node.js Installation:

```json
{
  "mcpServers": {
    "linkedin": {
      "command": "node",
      "args": [
        "/absolute/path/to/linkedin-mcp-server/build/index.js"
      ]
    }
  }
}
```

**Important**: For manual installation, replace `/absolute/path/to/linkedin-mcp-server` with the actual full path to your installation directory.

### Step 5: Restart Claude Desktop

After updating the configuration, restart Claude Desktop completely for the changes to take effect.

## 🚀 Usage

Once configured, you can interact with LinkedIn through Claude Desktop:

**Example prompts:**
- "Search for software engineers in San Francisco"
- "Get my LinkedIn profile information"
- "Show me my network statistics"
- "Search for product manager jobs in New York"
- "Send a message to [connection name]"
- "Get details for the LinkedIn profile [profile URL or ID]"

The AI assistant will automatically use the appropriate LinkedIn tools to fulfill your requests.

## 🔧 Development

### With Docker

```bash
# View logs
docker-compose logs -f

# Stop the server
docker-compose down

# Rebuild after code changes
docker-compose up -d --build

# Run in development mode (uncomment dev service in docker-compose.yml first)
# docker-compose up linkedin-mcp-server-dev
```

### With Node.js

```bash
# Running in Development Mode
npm run start:dev

# Building the Project
npm run build

# Running in Production Mode
npm run start:prod
```

### Debugging with MCP Inspector

The MCP Inspector provides a browser-based interface for testing and debugging:

```bash
# Launch the MCP Inspector
npm run inspector
```

This opens a web interface where you can:
- Test tool invocations
- Monitor requests and responses
- Debug authentication issues
- Inspect server behavior

## 📁 Project Structure

```
linkedin-mcp-server/
├── src/
│   ├── auth/              # Authentication configuration
│   ├── schemas/           # Zod validation schemas
│   ├── services/          # Business logic services
│   │   ├── client.service.ts    # LinkedIn API client
│   │   ├── logger.service.ts    # Logging service
│   │   ├── metrics.service.ts   # Metrics tracking
│   │   └── token.service.ts     # Token management
│   ├── types/             # TypeScript type definitions
│   ├── utils/             # Utility functions
│   ├── container.ts       # Dependency injection setup
│   ├── index.ts           # Entry point
│   └── server.ts          # MCP server implementation
├── build/                 # Compiled JavaScript output
├── .env                   # Environment variables (create this)
├── .env.example           # Environment template
├── package.json           # Project dependencies
├── tsconfig.json          # TypeScript configuration
└── README.md             # This file
```

## 🔒 Security

### Important Security Considerations

- **Credentials**: Never commit your `.env` file or expose your LinkedIn credentials
- **Access Tokens**: Rotate access tokens regularly
- **Permissions**: Only grant necessary LinkedIn API permissions
- **Environment**: Keep production credentials separate from development
- **Rate Limits**: Be aware of LinkedIn API rate limits

### Token Management

The server includes automatic token management:
- Tokens are validated on startup
- Failed authentication is logged with details
- The server will attempt to refresh tokens when needed

## 🐛 Troubleshooting

### Docker Issues

**Container not starting:**
```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs linkedin-mcp-server

# Restart container
docker-compose restart
```

**Environment variables not loading:**
1. Verify `.env` file exists and has correct values
2. Check file permissions: `chmod 644 .env`
3. Rebuild container: `docker-compose up -d --build`

### Server Not Starting (Manual Installation)

1. Check that Node.js version is 20 or higher: `node --version`
2. Verify all dependencies are installed: `npm install`
3. Ensure the project is built: `npm run build`
4. Check environment variables in `.env`

### Authentication Failures

1. Verify your LinkedIn Client ID and Client Secret
2. Check that your LinkedIn app has required permissions
3. Ensure the access token (if provided) is valid
4. Review logs for specific error messages:
   - Docker: `docker-compose logs linkedin-mcp-server`
   - Manual: Check console output

### Claude Desktop Not Detecting Server

**For Docker:**
1. Ensure container is running: `docker-compose ps`
2. Verify container name is `linkedin-mcp-server`
3. Test Docker exec access: `docker exec -i linkedin-mcp-server node -e "console.log('test')"`
4. Restart Claude Desktop completely

**For Manual Installation:**
1. Verify the absolute path in `claude_desktop_config.json`
2. Ensure the build directory exists: `ls build/index.js`
3. Check that `build/index.js` is executable
4. Restart Claude Desktop completely
5. Check Claude Desktop logs for error messages

### LinkedIn API Errors

- **Rate Limiting**: LinkedIn APIs have rate limits; wait before retrying
- **Permission Errors**: Ensure your app has the required permissions
- **Invalid URNs**: Double-check profile and connection URNs
- **Network Issues**: Check internet connectivity and firewall settings

## 📚 Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [LinkedIn API Documentation](https://docs.microsoft.com/en-us/linkedin/)
- [LinkedIn Developers Portal](https://www.linkedin.com/developers/)
- [Claude Desktop Documentation](https://claude.ai/desktop)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with:
- [@modelcontextprotocol/sdk](https://github.com/modelcontextprotocol/sdk) - MCP SDK
- [TSyringe](https://github.com/microsoft/tsyringe) - Dependency injection
- [Pino](https://github.com/pinojs/pino) - Fast logging
- [Zod](https://github.com/colinhacks/zod) - Schema validation
- [Axios](https://github.com/axios/axios) - HTTP client
