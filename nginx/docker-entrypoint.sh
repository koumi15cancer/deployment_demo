#!/bin/sh

: "${BACKEND_V1_HOST:?Must set BACKEND_V1_HOST}"
: "${BACKEND_V2_HOST:?Must set BACKEND_V2_HOST}"

exec openresty -g "daemon off;"
