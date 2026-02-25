#!/bin/bash
# ops-platform health check script
# Usage: ./health-check.sh

URL="http://100.125.46.74:4000"

echo "=== Ops Platform Health Check ==="
echo "Target: $URL"
echo ""

# Check HTTP response (no redirects - we're testing raw response)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null)
CURL_EXIT=$?

if [ $CURL_EXIT -ne 0 ]; then
    echo "❌ FAIL: Cannot connect to $URL (curl exit: $CURL_EXIT)"
    exit 1
fi

case "$HTTP_CODE" in
    200)
        echo "✅ PASS: HTTP $HTTP_CODE"
        ;;
    301|302)
        LOCATION=$(curl -sI --max-time 5 "$URL" 2>/dev/null | grep -i location | head -1)
        echo "⚠️  WARN: HTTP $HTTP_CODE redirect to: $LOCATION"
        echo "    (force_ssl is enabled but HTTPS not configured)"
        ;;
    *)
        echo "⚠️  WARN: HTTP $HTTP_CODE (unexpected)"
        ;;
esac

# Check container status
echo ""
echo "=== Container Status ==="
cd ~/dev/ops-platform && podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | grep -E "(NAME|ops-platform)" || echo "Containers not running"

# Check logs for errors
echo ""
echo "=== Recent Errors ==="
cd ~/dev/ops-platform && podman logs ops-platform_app_1 --since 5m 2>&1 | grep -i "error\|crash\|fail" | tail -5 || echo "No recent errors"

echo ""
echo "=== Health Check Complete ==="
