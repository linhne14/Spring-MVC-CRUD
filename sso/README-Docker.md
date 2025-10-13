# SSO Application with Docker

Ứng dụng Spring Boot SSO với Keycloak được containerized sử dụng Docker và Docker Compose.

## 🚀 Quick Start

### 1. Chạy ứng dụng với Docker Compose

```bash
# Windows
.\run-docker.cmd

# Linux/Mac
./run-docker.sh
```

### 2. Setup Keycloak

```bash
# Windows
.\setup-keycloak.cmd

# Linux/Mac
./setup-keycloak.sh
```

## 📋 Services

- **Keycloak**: http://localhost:8081
  - Username: `admin`
  - Password: `admin123`
- **SSO Application**: http://localhost:8080

## 🔧 Configuration Profiles

### Local Development (`application-oauth2.properties`)
- Sử dụng khi chạy ứng dụng local với Keycloak external
- Keycloak URL: `http://localhost:8081`

### Docker Environment (`application-docker.properties`)
- Tự động được sử dụng trong Docker container
- Keycloak URL: `http://keycloak:8080` (Docker service name)

### No OAuth2 (`application-no-oauth2.properties`)
- Chạy ứng dụng mà không cần Keycloak
- Tắt OAuth2 auto-configuration

## 🛠️ Manual Docker Commands

### Build image
```bash
docker build -t sso-application:latest .
```

### Run với Docker Compose
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Run individual container
```bash
docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=no-oauth2 sso-application:latest
```

## 🔑 Keycloak Setup Steps

1. **Access Admin Console**: http://localhost:8081
   - Username: `admin`
   - Password: `admin123`

2. **Create Realm**: `spring-boot-sso`

3. **Create Client**: `spring-boot-client`
   - Client authentication: ON
   - Standard flow: ON
   - Valid redirect URIs: `http://localhost:8080/login/oauth2/code/keycloak`

4. **Get Client Secret** và cập nhật trong `application-docker.properties`

5. **Create Users** để test authentication

## 📁 File Structure

```
├── Dockerfile                     # Multi-stage build cho Spring Boot
├── docker-compose.yml             # Orchestration cho Keycloak + App  
├── .dockerignore                  # Exclude files from build context
├── build-docker.cmd/.sh           # Build Docker image
├── run-docker.cmd/.sh             # Start services với Docker Compose
├── setup-keycloak.cmd/.sh         # Keycloak setup instructions
├── src/main/resources/
│   ├── application.properties
│   ├── application-oauth2.properties    # Local development
│   ├── application-docker.properties    # Docker environment  
│   └── application-no-oauth2.properties # No OAuth2 mode
└── README-Docker.md
```

## 🐛 Troubleshooting

### Application không start được
- Kiểm tra Keycloak đã running: `curl http://localhost:8081/realms/master`
- Xem logs: `docker-compose logs -f sso-app`

### Connection refused to Keycloak
- Ensure Keycloak container đang chạy: `docker-compose ps`
- Check network connectivity: `docker-compose logs keycloak`

### Profile configuration issues
- Kiểm tra environment variables: `docker-compose exec sso-app env | grep SPRING`
- Verify correct profile được load trong application logs

## 🔄 Development Workflow

1. **Development**: Sử dụng `application-oauth2.properties` với external Keycloak
2. **Docker Testing**: Sử dụng `docker-compose up` với profile `docker`
3. **Production**: Deploy với appropriate environment variables

## 📝 Notes

- Keycloak data được persist trong Docker volume `keycloak_data`
- Application logs được mount tới `./logs` directory
- Health checks được configure cho cả services
- Services sử dụng custom network `sso-network` để communicate