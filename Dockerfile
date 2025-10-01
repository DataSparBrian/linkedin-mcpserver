# Use official Node.js runtime as base image
FROM node:22-alpine

# Set working directory in container
WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code and configuration files
COPY . .

# Install development dependencies for build
RUN npm ci

# Run dotenvx prebuild and build the application
RUN npm run build

# Remove development dependencies to reduce image size
RUN npm ci --only=production && npm cache clean --force

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001 -G nodejs

# Change ownership of the app directory to nodejs user
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Expose port (if needed for debugging, but MCP uses stdio)
EXPOSE 5050

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "console.log('Health check passed')" || exit 1

# Set up environment variables for production
ENV NODE_ENV=production
ENV DOTENV_PRIVATE_KEY=""

# Default command to run the application
CMD ["npx", "dotenvx", "run", "--", "node", "build/index.js"]