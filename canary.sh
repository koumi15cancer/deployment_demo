#!/bin/bash
v1_count=0
v2_count=0
total_requests=200
URL="https://nginx-production-1cfb.up.railway.app/hello"
THREADS=10  # Number of parallel jobs

# Create temp files for results
tmpdir=$(mktemp -d)
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

echo "Testing canary deployment with $total_requests requests on $URL using $THREADS threads..."

run_request() {
  i=$1
  fake_ip="1.2.3.$i"
  response=$(curl -s -H "X-Forwarded-For: $fake_ip" "$URL")
  if command -v jq >/dev/null 2>&1; then
    version=$(echo "$response" | jq -r '.version' 2>/dev/null)
  else
    version=$(echo "$response" | grep -o '"version":"[^\"]*"' | cut -d'"' -f4)
  fi
  echo "$version" >> "$tmpdir/results"
}

export -f run_request
export URL tmpdir

# Run requests in parallel
seq 1 $total_requests | xargs -n1 -P$THREADS -I{} bash -c 'run_request "$@"' _ {}

# Aggregate results
v1_count=$(grep -c '^1.0$' "$tmpdir/results")
v2_count=$(grep -c '^2.0$' "$tmpdir/results")

echo "=================================================="
echo "Results:"
echo "backend-v1 responses: $v1_count"
echo "backend-v2 responses: $v2_count"
echo "Total requests: $total_requests"
echo "V1 percentage: $((v1_count * 100 / total_requests))%"
echo "V2 percentage: $((v2_count * 100 / total_requests))%"