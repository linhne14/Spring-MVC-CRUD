#!/bin/bash

# Run SSO application with Docker Compose
echo "Starting SSO application with Docker Compose..."

# Build and start services
docker-compose up -d --build

if [ $? -eq 0 ]; then
    echo "✓ Application started successfully!"
    echo ""
    echo "Application is running at: http://localhost:8080"
    echo ""
    echo "Useful commands:"
    echo "  View logs:        docker-compose logs -f"
    echo "  Stop application: docker-compose down"
    echo "  Restart:          docker-compose restart"
    echo "  View status:      docker-compose ps"
else
    echo "✗ Failed to start application"
    exit 1
fi