# Security Fixes Implementation Guide

This guide walks you through implementing all the security fixes identified in the security audit.

## ⚠️ Before You Begin

**CRITICAL:** Make sure you have backups before proceeding!

```bash
# Backup current configuration
cp Dockerfile Dockerfile.backup
cp docker-compose.yml docker-compose.backup
cp .env .env.backup
git commit -am "Backup before security fixes"
```

---

## 🚨 Priority 1: Critical Security Fixes (Do Immediately)

### Step 1: Fix Hardcoded Secrets

#### 1.1 Create Local Environment File
```bash
# Copy the template
cp .env.local.example .env.local

# Generate a new private key
openssl rand -hex 32

# Edit .env.local and paste your actual credentials
nano .env.local  # or use your preferred editor
```

#### 1.2 Set Restrictive Permissions
```bash
chmod 600 .env.local
```

#### 1.3 Update .gitignore
```bash
# Add the contents of GITIGNORE_ADDITIONS.txt to your .gitignore
cat GITIGNORE_ADDITIONS.txt >> .gitignore

# Verify .env.local won't be committed
git status  # Should NOT show .env.local
```

#### 1.4 Replace docker-compose.yml
```bash
# Backup current file (already done above)
# Replace with secure version
mv docker-compose.yml docker-compose.yml.insecure
cp docker-compose.secure.yml docker-compose.yml

# Verify your .env.local has all required secrets
cat .env.local
```

### Step 2: Update Vulnerable Dependencies

```bash
# Update axios and form-data
npm install axios@1.12.0 form-data@4.0.4

# Run audit to check for any remaining issues
npm audit

# If there are fixable issues:
npm audit fix

# Commit the package updates
git add package.json package-lock.json
git commit -m "security: Update axios and form-data to fix vulnerabilities"
```

### Step 3: Update Dockerfile

```bash
# First, get the current digest for node:22-alpine
docker pull node:22-alpine
docker inspect node:22-alpine | grep -A1 RepoDigests

# Copy the digest and update Dockerfile.secure if needed
# Then replace your Dockerfile
mv Dockerfile Dockerfile.old
cp Dockerfile.secure Dockerfile

# Update maintainer email in Dockerfile
sed -i '' 's/your-email@example.com/YOUR_ACTUAL_EMAIL/g' Dockerfile
# On Linux use: sed -i 's/your-email@example.com/YOUR_ACTUAL_EMAIL/g' Dockerfile

# Commit the Dockerfile changes
git add Dockerfile
git commit -m "security: Apply secure Dockerfile with pinned digest and improved build process"
```

---

## ✅ Priority 2: Rebuild and Test

### Step 4: Rebuild Docker Image

```bash
# Stop existing containers
docker-compose down

# Remove old image
docker rmi linkedin-mcp-server:latest

# Rebuild with new secure configuration
docker-compose build --no-cache

# Verify the build completed successfully
docker images | grep linkedin-mcp-server
```

### Step 5: Test the Secure Setup

```bash
# Start the container with new configuration
docker-compose up -d

# Check logs for any errors
docker-compose logs -f

# Verify the container is running
docker-compose ps

# Test health check
docker inspect linkedin-mcp-server | grep -A10 Health
```

### Step 6: Re-run Security Scans

```bash
# Run Trivy configuration scan
trivy config --severity HIGH,CRITICAL .

# Run Trivy image scan
trivy image --severity HIGH,CRITICAL linkedin-mcp-server:latest

# Run npm audit
npm audit --production

# All scans should show significantly fewer issues
```

---

## 🔐 Priority 3: Cleanup and Security Hardening

### Step 7: Remove Sensitive Data from Git History

**⚠️ WARNING:** If you've already committed the hardcoded private key to git, it's in your repository history!

```bash
# Check if private key exists in git history
git log -p | grep -i "34db975c92996fce2430eb88c9d2ff5b"

# If found, you need to:
# 1. Generate a NEW private key (the old one is compromised)
openssl rand -hex 32  # Use this new key in .env.local

# 2. Re-encrypt any files that were encrypted with the old key

# 3. (Optional) Clean git history using git-filter-repo or BFG Repo Cleaner
# This is complex - see: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
```

### Step 8: Update Documentation

```bash
# Update README.md to reference new security practices
cat >> README.md << 'EOF'

## Security Setup

1. Copy `.env.local.example` to `.env.local`
2. Fill in your actual credentials
3. Never commit `.env.local` to version control
4. See `SECURITY_AUDIT_REPORT.md` for detailed security information

EOF

# Commit documentation updates
git add README.md
git commit -m "docs: Add security setup instructions"
```

---

## 📋 Verification Checklist

After completing all steps, verify:

- [ ] No secrets are hardcoded in `docker-compose.yml`
- [ ] `.env.local` exists and contains actual secrets
- [ ] `.env.local` is listed in `.gitignore`
- [ ] `git status` does NOT show `.env.local`
- [ ] `axios` is version 1.12.0 or higher
- [ ] `form-data` is version 4.0.4 or higher
- [ ] Dockerfile pins base image to digest
- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] Trivy scans show no CRITICAL issues
- [ ] Health check passes: `docker inspect linkedin-mcp-server | grep Health`

---

## 🚀 Optional Enhancements

### Add Pre-commit Hook

Prevent accidentally committing secrets:

```bash
# Install pre-commit tool
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: detect-private-key
      - id: check-added-large-files
      - id: check-merge-conflict
      
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
EOF

# Install hooks
pre-commit install

# Test
pre-commit run --all-files
```

### Set Up Automated Security Scanning

Add to `.github/workflows/security.yml`:

```yaml
name: Security Scan

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t linkedin-mcp-server:latest .
        
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'linkedin-mcp-server:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          
      - name: Upload Trivy results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

### Enable Docker Content Trust

For production deployments:

```bash
# Enable Docker Content Trust
export DOCKER_CONTENT_TRUST=1

# Sign your images
docker trust sign linkedin-mcp-server:latest

# Verify signatures
docker trust inspect linkedin-mcp-server:latest
```

---

## 🆘 Troubleshooting

### Issue: Container won't start after changes

```bash
# Check logs
docker-compose logs

# Common issues:
# 1. Missing .env.local file
# 2. Wrong DOTENV_PRIVATE_KEY
# 3. Encrypted .env file needs re-encrypting
```

### Issue: "DOTENV_PRIVATE_KEY not found"

```bash
# Verify .env.local exists and has the key
cat .env.local | grep DOTENV_PRIVATE_KEY

# Check docker-compose.yml loads it
docker-compose config | grep DOTENV_PRIVATE_KEY
```

### Issue: Build fails with digest error

```bash
# Update the digest in Dockerfile
docker pull node:22-alpine
docker inspect node:22-alpine | grep RepoDigests

# Copy the digest and update Dockerfile
# Format: node:22-alpine@sha256:DIGEST_HERE
```

---

## 📞 Support

If you encounter issues:

1. Review the `SECURITY_AUDIT_REPORT.md`
2. Check the troubleshooting section above
3. Run `docker-compose logs` for detailed error messages
4. Verify all prerequisites are met

---

## 📚 Additional Resources

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

---

## ✅ Success Criteria

You've successfully completed the security fixes when:

1. ✅ No secrets in version control
2. ✅ All CRITICAL and HIGH vulnerabilities patched
3. ✅ Docker image builds and runs successfully
4. ✅ Security scans show clean results
5. ✅ Application functions normally

**Congratulations! Your Docker setup is now significantly more secure! 🎉**

---

*Last Updated: September 30, 2025*
