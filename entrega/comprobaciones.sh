#!/usr/bin/env bash
# Uso: TOKEN='...' bash entrega/comprobaciones.sh > entrega/comprobaciones-local.txt 2>&1
# Para Render: BASE=https://... TOKEN='...' bash entrega/comprobaciones.sh
BASE=${BASE:-http://localhost:3000}
TOKEN=${TOKEN:-}

# el email del usuario se tapa en la salida
req() { echo "### $1"; shift; curl -sS -i "$@" | sed -E 's/"email":"[^"]*"/"email":"***"/'; echo; echo; }

echo "VillainLair - comprobaciones contra $BASE"
echo

req "1. GET /health sin token -> 200" "$BASE/health"
echo "### 2. GET /api/auth/google -> 302 a Google"
curl -sS -o /dev/null -w 'HTTP %{http_code} -> %{redirect_url}\n' "$BASE/api/auth/google" | sed 's/?.*/?.../'
echo
req "3. GET /api/villains sin token -> 401" "$BASE/api/villains"
req "4. GET /api/villains con 'Bearer incorrecto' -> 401" "$BASE/api/villains" -H 'Authorization: Bearer incorrecto'

if [ -z "$TOKEN" ]; then
  echo "### (5-8 omitidas: falta TOKEN)"
  exit 0
fi

# token caducado: mismo sub y mismo secreto, pero exp en el pasado
EXPIRED=$(TOKEN="$TOKEN" node --env-file-if-exists=.env -e '
  const jwt = require("jsonwebtoken");
  const { sub } = jwt.decode(process.env.TOKEN);
  process.stdout.write(jwt.sign(
    { provider: "google", sub, iss: "villainlair-api", aud: "villainlair-client" },
    process.env.TOKEN_SECRET, { algorithm: "HS256", expiresIn: -1 }));')
req "5. GET /api/villains con token caducado -> 401" "$BASE/api/villains" -H "Authorization: Bearer $EXPIRED"
req "6. GET /api/villains con token valido -> 200" "$BASE/api/villains" -H "Authorization: Bearer $TOKEN"
req "7. GET /api/users/secure con token -> 200" "$BASE/api/users/secure" -H "Authorization: Bearer $TOKEN"
req "8. GET /api/users/secure sin token -> 401" "$BASE/api/users/secure"
