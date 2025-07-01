#!/bin/bash

echo "🔒 Testing GRADEX Nginx Proxy..."
echo "================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $description... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✓ OK ($response)${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL ($response, expected $expected_status)${NC}"
        return 1
    fi
}

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# Test cases
echo ""
echo "Testing Security Headers..."
test_endpoint "http://localhost/nginx-health" "Nginx Health Check"

echo ""
echo "Testing Main Routes..."
test_endpoint "http://localhost/" "Frontend Root"
test_endpoint "http://localhost/graphql" "GraphQL Endpoint" 405  # Expected 405 for GET

echo ""
echo "Testing Security Blocks..."
test_endpoint "http://localhost/.env" "Hidden files block" 403
test_endpoint "http://localhost/config.sql" "SQL files block" 403
test_endpoint "http://localhost/backup.bak" "Backup files block" 403

echo ""
echo "Testing Rate Limiting..."
echo -n "Rate limiting test (10 requests)... "
failed_requests=0
for i in {1..10}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/nginx-health" 2>/dev/null)
    if [ "$response" != "200" ]; then
        failed_requests=$((failed_requests + 1))
    fi
done

if [ $failed_requests -eq 0 ]; then
    echo -e "${GREEN}✓ OK (All requests passed)${NC}"
else
    echo -e "${YELLOW}! Some requests rate limited ($failed_requests/10)${NC}"
fi

echo ""
echo "Testing Security Headers..."
headers=$(curl -s -I "http://localhost/nginx-health" 2>/dev/null)

check_header() {
    local header=$1
    local description=$2
    
    echo -n "  $description... "
    if echo "$headers" | grep -qi "$header"; then
        echo -e "${GREEN}✓ Present${NC}"
    else
        echo -e "${RED}✗ Missing${NC}"
    fi
}

check_header "X-Frame-Options" "X-Frame-Options"
check_header "X-Content-Type-Options" "X-Content-Type-Options"  
check_header "X-XSS-Protection" "X-XSS-Protection"
check_header "Content-Security-Policy" "Content-Security-Policy"
check_header "X-API-Gateway" "API Gateway Header"

echo ""
echo -e "${GREEN}🔒 Proxy security testing completed!${NC}"
echo "=================================" 