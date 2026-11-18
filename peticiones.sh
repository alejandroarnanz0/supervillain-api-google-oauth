BASE=${BASE:-https://supervillain-api-google-oauth-efdj.onrender.com}
TOKEN=${TOKEN:-PONER TU TOKEN JWT AQUI}

echo "=========================================================="
echo " VillainLair API (OAuth 2.0 con Google + JWT) - $BASE"
echo "=========================================================="
echo

echo "### 1. GET /api/users/secure CON token -> 200 (perfil del usuario autenticado)"
curl -sS -i "$BASE/api/users/secure" -H "Authorization: Bearer $TOKEN"
# 200: perfil del usuario autenticado
echo; echo

echo "### 2. POST /api/villains CON token -> 201 (crear villano)"
curl -sS -i -X POST "$BASE/api/villains" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"name":"Gru","alias":"El Ladr\u00f3n de la Luna","evilLevel":8000}'
# 201; la misma petición sin Authorization devuelve 401
echo; echo

echo "### 3. GET /api/villains SIN token -> 401 (antes era la excepción docente con 200; ya protegido con tokenVerify)"
curl -sS -i "$BASE/api/villains"
# 200: excepción docente pendiente; tras el ejercicio debe ser 401
echo; echo

###########################################################################################
###########################################################################################
#######AÑADE LA SALIDA DE ALGUN OTRO ENDPOINT SECURIZADO DE OTRO RECURSO
#######################MÁS QUE HAYAS IMPLEMENTADO##########################################
###########################################################################################

# Recurso nuevo: /api/arsenal (todas las máquinas del juicio final), protegido con JWT

echo "=========================================================="
echo " ENDPOINT SECURIZADO ADICIONAL: recurso /api/arsenal"
echo " (todas las máquinas del juicio final; exige JWT)"
echo "=========================================================="
echo

echo "### 4. GET /api/arsenal CON token -> 200 (listado completo)"
curl -sS -i "$BASE/api/arsenal" -H "Authorization: Bearer $TOKEN"
# 200: listado del arsenal
echo; echo

echo "### 5. GET /api/arsenal?status=Cargando CON token -> 200 (filtro por estado)"
curl -sS -i "$BASE/api/arsenal?status=Cargando" -H "Authorization: Bearer $TOKEN"
# 200: solo las máquinas cargando
echo; echo

DEVICE_ID=$(curl -sS "$BASE/api/arsenal" -H "Authorization: Bearer $TOKEN" | grep -o '"_id":"[a-f0-9]\{24\}"' | head -1 | cut -d'"' -f4)
echo "### 6. GET /api/arsenal/$DEVICE_ID CON token -> 200 (una máquina concreta)"
curl -sS -i "$BASE/api/arsenal/$DEVICE_ID" -H "Authorization: Bearer $TOKEN"
# 200: una máquina concreta
echo; echo

echo "### 7. GET /api/arsenal SIN token -> 401"
curl -sS -i "$BASE/api/arsenal"
# 401: sin token
echo; echo

echo "### 8. GET /api/arsenal con token INVÁLIDO -> 401"
curl -sS -i "$BASE/api/arsenal" -H "Authorization: Bearer token.falso"
# 401: token inválido
echo; echo

echo "### 9. GET /api/arsenal/no-es-un-id CON token -> 400 (id mal formado)"
curl -sS -i "$BASE/api/arsenal/no-es-un-id" -H "Authorization: Bearer $TOKEN"
# 400: id mal formado
echo
