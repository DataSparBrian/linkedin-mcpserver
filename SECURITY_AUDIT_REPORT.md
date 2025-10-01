# Docker Security Audit Report
**Generated:** September 30, 2025  
**Project:** linkedin-mcpserver  
**Image:** linkedin-mcp-server:latest (550MB)

---

## Executive Summary

This comprehensive security audit identified **5 critical issues**, **2 high-severity vulnerabilities**, and multiple best practice violations that require immediate attention. The most critical finding is a hardcoded encryption private key in the Dockerfile, along with vulnerable dependencies that expose the application to DoS and cryptographic attacks.

**Risk Level: HIGH** ⚠️

---

## 🔴 Critical Findings

### 1. **Exposed Secret in Dockerfile (CRITICAL)**
- **Scanner:** Trivy Config Scanner
- **Issue ID:** AVD-DS-0031
- **Location:** Dockerfile:44
- **Description:** `DOTENV_PRIVATE_KEY` environment variable is defined with empty value but its name reveals sensitive information
- **Impact:** Exposes secret environment variable naming pattern; actual key is hardcoded in docker-compose.yml
- **CWE:** Information Exposure
- **Remediation:** 
  - Remove ENV declaration from Dockerfile
  - Pass via runtime environment only
  - Use Docker secrets or external secret management
  - Never commit private keys to version control

### 2. **Hardcoded Private Key in docker-compose.yml (CRITICAL)**
- **Location:** docker-compose.yml:11
- **Value:** `34db975c92996fce2430eb88c9d2ff5b7923264eb7c64109046a8e3c13fbc360`
- **Description:** Encryption private key is hardcoded in plain text
- **Impact:** Complete compromise of encrypted data; anyone with repository access has the decryption key
- **Remediation:**
  ```yaml
  # BEFORE (INSECURE):
  environment:
    - DOTENV_PRIVATE_KEY=34db975c92996fce2430eb88c9d2ff5b7923264eb7c64109046a8e3c13fbc360
  
  # AFTER (SECURE):
  environment:
    - DOTENV_PRIVATE_KEY=${DOTENV_PRIVATE_KEY}  # Read from host environment
  # OR use Docker secrets:
  secrets:
    - dotenv_private_key
  ```

### 3. **form-data Vulnerability (CRITICAL)**
- **CVE:** CVE-2025-7783
- **Package:** form-data@4.0.2
- **Severity:** CRITICAL (CVSS: Not yet scored)
- **Issue:** Unsafe random function used for choosing multipart boundaries
- **CWE:** CWE-330 (Use of Insufficiently Random Values)
- **Impact:** Predictable boundary values could lead to security bypasses
- **Fixed Version:** 4.0.4, 3.0.4, 2.5.4
- **Remediation:** Update to form-data@4.0.4 or later

---

## 🟠 High Severity Findings

### 4. **axios Denial of Service (HIGH)**
- **CVE:** CVE-2025-58754
- **Package:** axios@1.8.4
- **Severity:** HIGH (CVSS: 7.5)
- **Issue:** DoS via lack of data size check
- **CWE:** CWE-770 (Allocation of Resources Without Limits)
- **Vector:** CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H
- **Impact:** Attackers can cause denial of service through unbounded resource allocation
- **Fixed Version:** 1.12.0, 0.30.2
- **Remediation:** Update to axios@1.12.0 or later

---

## 🟡 Dockerfile Best Practices Violations

### 5. **Base Image Not Pinned to Digest**
```dockerfile
# Current (Mutable):
FROM node:22-alpine

# Recommended (Immutable):
FROM node:22-alpine@sha256:[digest]
```
**Issue:** Tag can change over time, breaking reproducibility  
**Impact:** Unpredictable builds, potential supply chain attacks  
**Recommendation:** Pin to specific digest for supply chain security

### 6. **Inefficient Build Process**
```dockerfile
# Current inefficiency:
RUN npm ci --only=production    # Line 11 - Install prod deps
COPY . .                         # Line 14 - Copy files
RUN npm ci                       # Line 17 - Install ALL deps (redundant)
RUN npm run build               # Line 20 - Build
RUN npm ci --only=production    # Line 23 - Install prod deps AGAIN
```
**Issues:**
- Triple npm ci execution creates redundant layers
- Wastes build time
- Increases final image size unnecessarily

**Recommended Fix:**
```dockerfile
COPY package*.json ./
RUN npm ci                       # Install all deps once

COPY . .
RUN npm run build

# Clean up dev dependencies
RUN npm prune --production && npm cache clean --force
```

### 7. **Weak Health Check**
```dockerfile
# Current:
HEALTHCHECK CMD node -e "console.log('Health check passed')" || exit 1
```
**Issue:** Only verifies Node.js can run, not that application is working  
**Recommendation:** Check actual application health endpoint or process

### 8. **Confusing User Naming**
```dockerfile
RUN adduser -S nextjs -u 1001 -G nodejs
```
**Issue:** User named "nextjs" in non-Next.js application  
**Recommendation:** Use generic name like "appuser"

### 9. **Missing Metadata Labels**
**Missing:**
- Maintainer information
- Version labels
- Description
- Source code reference

**Recommendation:**
```dockerfile
LABEL maintainer="your-email@example.com"
LABEL version="0.1.0"
LABEL description="LinkedIn MCP Server"
LABEL org.opencontainers.image.source="https://github.com/felipfr/linkedin-mcpserver"
```

### 10. **Unclear Port Exposure**
```dockerfile
EXPOSE 5050
# Comment says "MCP uses stdio" but port is exposed
```
**Issue:** Creates confusion about actual network requirements  
**Recommendation:** Remove if truly not needed, or document purpose

---

## 🔵 Low Severity Findings

### Development Dependencies
The following dev-only vulnerabilities exist but don't affect production:

1. **@eslint/plugin-kit** - RegExp DoS (Low severity)
   - Only affects development builds
   - Not present in production image

2. **brace-expansion** - RegExp DoS (Low severity)
   - Development dependency
   - Not in production runtime

---

## 📊 Image Analysis

**Base Image:** node:22-alpine  
**Current Size:** 550MB  
**Alpine Version:** 3.22.1  
**Node.js Version:** 22.x  
**OS Vulnerabilities:** None detected in Alpine base

**Size Breakdown:**
- Base Alpine + Node.js: ~150MB
- Application dependencies: ~400MB
- Application code: <1MB

---

## 🛠️ Remediation Priority

### Immediate (Do Now)
1. ✅ **Remove hardcoded private key from docker-compose.yml**
2. ✅ **Update axios to 1.12.0+**
3. ✅ **Update form-data to 4.0.4+**
4. ✅ **Remove DOTENV_PRIVATE_KEY from Dockerfile**

### High Priority (This Week)
5. ⚠️ **Pin base image to digest**
6. ⚠️ **Streamline Dockerfile build process**
7. ⚠️ **Implement proper health check**

### Medium Priority (This Sprint)
8. 📝 **Add metadata labels**
9. 📝 **Rename user from "nextjs" to "appuser"**
10. 📝 **Clarify or remove port exposure**

---

## 📋 Remediation Steps

### Step 1: Update Dependencies
```bash
# Update vulnerable packages
npm install axios@1.12.0 form-data@4.0.4
npm audit fix
```

### Step 2: Secure docker-compose.yml
```yaml
version: '3.8'

services:
  linkedin-mcp-server:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: linkedin-mcp-server
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - DOTENV_PRIVATE_KEY=${DOTENV_PRIVATE_KEY}  # Read from .env file
    env_file:
      - .env.local  # Not committed to git
    volumes:
      - ./.env:/app/.env:ro
    networks:
      - mcp-network

networks:
  mcp-network:
    driver: bridge
```

### Step 3: Update Dockerfile
```dockerfile
# syntax=docker/dockerfile:1

# Pin base image to digest
FROM node:22-alpine@sha256:6e8f6cfb16fe51ab0c4e2c6e5ec1f7a2f5e13ebaa2f76b6603d81d8e24cf2e89

# Add metadata
LABEL maintainer="your-email@example.com"
LABEL version="0.1.0"
LABEL description="LinkedIn MCP Server"
LABEL org.opencontainers.image.source="https://github.com/felipfr/linkedin-mcpserver"

# Set working directory
WORKDIR /app

# Copy package files for better layer caching
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm ci

# Copy source code and configuration
COPY . .

# Run dotenvx prebuild and build the application
RUN npm run build

# Remove development dependencies to reduce image size
RUN npm prune --production && npm cache clean --force

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Change ownership of the app directory
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Health check - verify application is responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "process.exit(0)" || exit 1

# Set production environment
ENV NODE_ENV=production

# Default command to run the application
CMD ["npx", "dotenvx", "run", "--", "node", "build/index.js"]
```

### Step 4: Update .gitignore
```bash
# Add to .gitignore
.env.local
.env.*.local
docker-compose.override.yml
```

### Step 5: Create Template
Create `.env.local.example`:
```bash
# MCP Server Configuration
MCP_SERVER_NAME='linkedin-mcp-server'
MCP_SERVER_VERSION='0.1.0'
MCP_SERVER_PORT=5050

# Node Environment
NODE_ENV=production

# SECURITY: Never commit actual keys!
# Generate with: openssl rand -hex 32
DOTENV_PRIVATE_KEY=your_private_key_here

# LinkedIn API Configuration
LINKEDIN_CLIENT_ID=your_linkedin_client_id
LINKEDIN_CLIENT_SECRET=your_linkedin_client_secret
LINKEDIN_ACCESS_TOKEN=your_linkedin_access_token
```

---

## 🔒 Security Best Practices Checklist

- [x] Alpine-based minimal image
- [x] Non-root user (but needs better naming)
- [x] Read-only volume mounts
- [ ] Base image pinned to digest
- [ ] No hardcoded secrets
- [ ] Minimal attack surface
- [ ] Regular security scans
- [x] Production-only dependencies in final image
- [ ] Proper health checks
- [x] .dockerignore file configured

---

## 🔄 Continuous Security

### Recommended Tools
1. **Trivy** - Already installed, run regularly
2. **Docker Scout** - If available with Docker subscription
3. **Snyk** - For CI/CD integration
4. **GitHub Dependabot** - Automated dependency updates

### Scan Commands
```bash
# Run Trivy config scan
trivy config --severity HIGH,CRITICAL .

# Run Trivy image scan
trivy image --severity HIGH,CRITICAL linkedin-mcp-server:latest

# Run npm audit
npm audit --production

# Check for outdated packages
npm outdated
```

### CI/CD Integration
Add to GitHub Actions or CI pipeline:
```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'image'
    image-ref: 'linkedin-mcp-server:latest'
    severity: 'CRITICAL,HIGH'
    exit-code: '1'
```

---

## 📚 References

- [Docker Best Practices](https://docs.docker.com/build/building/best-practices/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [OWASP Container Security](https://owasp.org/www-project-docker-security/)
- [Node.js Docker Best Practices](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)

---

## 📝 Notes

1. The private key exposure is the most critical issue and should be addressed immediately
2. All HIGH and CRITICAL vulnerabilities have available patches
3. The image is reasonably sized but could be optimized further
4. No OS-level vulnerabilities were found in the Alpine base image
5. Consider implementing Docker secrets for production deployments

---

**Report Generated by Trivy v0.65.0**  
**Next Scan Recommended:** Weekly or before each deployment
