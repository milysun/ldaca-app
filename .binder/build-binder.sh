#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔨 Building BinderHub-compatible LDaCA image...${NC}"

# Build the BinderHub image
docker build -f .binder/Dockerfile -t ldaca-binder:latest .

echo -e "${GREEN}✅ BinderHub image built successfully!${NC}"

echo -e "${BLUE}🚀 Testing BinderHub image locally...${NC}"

# Run the BinderHub image locally for testing
docker run -d \
  --name ldaca-binder-test \
  -p 8080:8080 \
  ldaca-binder:latest

echo -e "${GREEN}✅ BinderHub test container started!${NC}"
echo -e "${BLUE}📱 Access the application at: http://localhost:8080${NC}"
echo -e "${BLUE}🔍 Check logs with: docker logs ldaca-binder-test${NC}"
echo -e "${BLUE}🛑 Stop with: docker stop ldaca-binder-test && docker rm ldaca-binder-test${NC}"
