# Docker Configuration Fix

## The Problems

1. **Redundant volume mount**: The `.env` file is already copied into the container during build, so mounting it is unnecessary
2. **stdout pollution**: `dotenvx run` outputs version info to stdout, breaking MCP's JSON-RPC communication

## The Solution

### Fixed Dockerfile
Changed from:
```dockerfile
CMD ["npx", "dotenvx", "run", "--", "node", "build/index.js"]
```

To:
```dockerfile
CMD ["node", "build/index.js"]
```

Since `src/index.ts` already imports `@dotenvx/dotenvx/config`, it will decrypt the `.env` file without polluting stdout.

### Simplified MCP Configuration

```json
{
  "linkedin": {
    "command": "docker",
    "args": [
      "run",
      "-i",
      "--rm",
      "-e",
      "DOTENV_PRIVATE_KEY=your_key_here",
      "DataSparBrian/mcp-linkedin-server:latest"
    ]
  }
}
```

**That's it.** No volume mount needed, no wrapper scripts required.

## Rebuilding the Container

After updating the Dockerfile:

```bash
docker build -t DataSparBrian/mcp-linkedin-server:latest .
```

## Optional: Secure Key Storage

If you want to avoid storing the key in your config file, you can use the wrapper scripts in `/scripts`:

1. Run `./scripts/setup-linkedin-mcp-keychain.sh` to store the key in macOS Keychain
2. Update your MCP config to use `./scripts/start-linkedin-mcp.sh` as the command

But for most users, the simple config above is sufficient.
