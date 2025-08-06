#!/bin/bash
set -euo pipefail

echo "🚀 Starting LDaCA with BinderHub compatibility..."

# Start LDaCA application first
/usr/local/bin/start-ldaca.sh &

# Give it time to start
sleep 5

# Create a simple redirect page for users to find the app (in writable directory)
cat > /tmp/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>LDaCA Web Application</title>
    <meta http-equiv="refresh" content="0; url=http://localhost:8080">
</head>
<body>
    <h1>Redirecting to LDaCA...</h1>
    <p>If you're not redirected automatically, <a href="http://localhost:8080">click here</a>.</p>
</body>
</html>
EOF

# Keep the process alive
echo "✅ LDaCA started, keeping container alive..."
tail -f /dev/null
