#!/bin/bash
v1_count=0
v2_count=0
for i in {1..100}; do
  response=$(curl -s http://localhost:80/hello)
  if echo "$response" | grep -q "Backend: v1"; then
    ((v1_count++))
  elif echo "$response" | grep -q "Backend: v2"; then
    ((v2_count++))
  fi
done
echo "backend-v1 responses: $v1_count"
echo "backend-v2 responses: $v2_count"