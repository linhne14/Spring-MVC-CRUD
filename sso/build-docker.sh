#!/bin/bash

# Build Docker image
echo "Building Docker image for SSO application..."
docker build -t sso-application:latest .

if [ $? -eq 0 ]; then
    echo "✓ Docker image built successfully!"
    echo "Image name: sso-application:latest"
    
    echo ""
    echo "To run the container:"
    echo "  docker run -p 8080:8080 sso-application:latest"
    echo ""
    echo "Or use docker-compose:"
    echo "  docker-compose up -d"
else
    echo "✗ Failed to build Docker image"
    exit 1
fi