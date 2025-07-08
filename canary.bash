#!/bin/bash
v1_count=0
v2_count=0
total_requests=100

echo "Testing canary deployment with $total_requests requests..."

for i in {1..100}; do
  fake_ip="1.2.3.$i"
  response=$(curl -s -H "X-Forwarded-For: $fake_ip" http://localhost:80/hello)
  
  
  # Extract version from JSON response using jq (if available) or grep
  if command -v jq >/dev/null 2>&1; then
    version=$(echo "$response" | jq -r '.version' 2>/dev/null)
  else
    # Fallback to grep if jq is not available
    version=$(echo "$response" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
  fi
  
  if [ "$version" = "1.0" ]; then
    ((v1_count++))
  elif [ "$version" = "2.0" ]; then
    ((v2_count++))
  fi
done

echo "=================================================="
echo "Results:"
echo "backend-v1 responses: $v1_count"
echo "backend-v2 responses: $v2_count"
echo "Total requests: $total_requests"
echo "V1 percentage: $((v1_count * 100 / total_requests))%"
echo "V2 percentage: $((v2_count * 100 / total_requests))%"