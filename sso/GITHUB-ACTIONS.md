
# GitHub Actions CI/CD

## 🚀 Workflows

### 1. `build-push.yml` - Build and Push Docker Image
**Triggers:**
- Push to `main`, `develop` branches
- Git tags (`v*`)
- Pull requests to `main`

**Actions:**
- ✅ Build with Maven (JDK 21)
- ✅ Build multi-platform Docker image (linux/amd64, linux/arm64)
- ✅ Push to GitHub Container Registry (ghcr.io)
- ✅ Cache Maven dependencies and Docker layers

**Image Tags:**
```
ghcr.io/linhne14/spring-mvc-crud:latest          # main branch
ghcr.io/linhne14/spring-mvc-crud:main            # main branch
ghcr.io/linhne14/spring-mvc-crud:develop         # develop branch
ghcr.io/linhne14/spring-mvc-crud:main-a1b2c3d    # branch + short SHA
```

### 2. `test.yml` - Continuous Integration Tests
**Triggers:**
- Push to `main`, `develop` branches
- Pull requests to `main`

**Actions:**
- ✅ Run Maven tests
- ✅ Generate JUnit test reports
- ✅ Upload test artifacts

## 📦 Container Registry

Images are pushed to **GitHub Container Registry (GHCR)**:
- **Registry**: `ghcr.io`
- **Repository**: `ghcr.io/linhne14/spring-mvc-crud`
- **Visibility**: Public (linked to GitHub repository)

## 🔧 Setup Instructions

### 1. Enable GitHub Actions
1. Go to repository **Settings**
2. **Actions** → **General** → Allow all actions

### 2. Enable Container Registry
1. Go to repository **Settings**
2. **Actions** → **General** → **Workflow permissions**
3. Select **Read and write permissions**
4. Check **Allow GitHub Actions to create and approve pull requests**

### 3. Test Locally (Optional)
```powershell
# Test the build process locally
./test-local-build.ps1
```

### 4. Commit and Push
```bash
git add .github/
git commit -m "Add GitHub Actions workflows"
git push origin main
```

## 📊 Monitoring

### GitHub Actions Dashboard
- **URL**: `https://github.com/linhne14/Spring-MVC-CRUD/actions`
- **Build Status**: ✅ / ❌ badges on each commit
- **Logs**: Detailed build and test logs

### Container Registry
- **URL**: `https://github.com/linhne14/Spring-MVC-CRUD/pkgs/container/spring-mvc-crud`
- **Pull Command**: 
  ```bash
  docker pull ghcr.io/linhne14/spring-mvc-crud:latest
  ```

## 🛠️ Using the Built Images

### Pull and Run
```bash
# Pull latest image
docker pull ghcr.io/linhne14/spring-mvc-crud:latest

# Run container
docker run -d -p 8080:8080 ghcr.io/linhne14/spring-mvc-crud:latest

# Check health
curl http://localhost:8080/actuator/health
```

### Update Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: sso-app
        image: ghcr.io/linhne14/spring-mvc-crud:latest
        # Or use specific tag: ghcr.io/linhne14/spring-mvc-crud:main-a1b2c3d
```

## 🔍 Troubleshooting

### Build Failures
```bash
# Check GitHub Actions logs
# Go to: https://github.com/linhne14/Spring-MVC-CRUD/actions

# Test locally first
./test-local-build.ps1
```

### Permission Issues
1. Check **Settings** → **Actions** → **General** → **Workflow permissions**
2. Ensure **Read and write permissions** is selected
3. Verify **GITHUB_TOKEN** has packages:write scope

### Registry Authentication
```bash
# Login to GHCR manually
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## 📈 Workflow Features

✅ **Multi-platform builds** (AMD64 + ARM64)  
✅ **Layer caching** for faster builds  
✅ **Dependency caching** for Maven  
✅ **Automatic tagging** based on branch/PR/tag  
✅ **Test reporting** with JUnit integration  
✅ **Security scanning** (built-in GitHub)  
✅ **Artifact storage** for test results  

## 🚀 Next Steps

- [ ] Add security scanning with Trivy
- [ ] Setup staging environment deployment
- [ ] Add performance testing
- [ ] Implement semantic versioning
- [ ] Add Slack/Discord notifications