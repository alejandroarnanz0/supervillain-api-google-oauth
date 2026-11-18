BASE=${BASE:-https://supervillain-api-google-oauth-efdj.onrender.com}
TOKEN=${TOKEN:-PONER TU TOKEN JWT AQUI}
curl -sS -i "$BASE/api/users/secure" -H "Authorization: Bearer $TOKEN"
# 200: perfil del usuario autenticado
echo; echo

curl -sS -i -X POST "$BASE/api/villains" \
  -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"name":"Gru","alias":"El Ladrón de la Luna","evilLevel":8000}'
# 201; la misma petición sin Authorization devuelve 401
echo; echo

curl -sS -i "$BASE/api/villains"
# 200: excepción docente pendiente; tras el ejercicio debe ser 401
echo; echo

###########################################################################################
###########################################################################################
#######AÑADE LA SALIDA DE ALGUN OTRO ENDPOINT SECURIZADO DE OTRO RECURSO
#######################MÁS QUE HAYAS IMPLEMENTADO##########################################
###########################################################################################

# Recurso nuevo: /api/arsenal (todas las máquinas del juicio final), protegido con JWT

curl -sS -i "$BASE/api/arsenal" -H "Authorization: Bearer $TOKEN"
# 200: listado del arsenal
echo; echo

curl -sS -i "$BASE/api/arsenal?status=Lista" -H "Authorization: Bearer $TOKEN"
# 200: solo las máquinas listas
echo; echo

DEVICE_ID=$(curl -sS "$BASE/api/arsenal" -H "Authorization: Bearer $TOKEN" | grep -o '"_id":"[a-f0-9]\{24\}"' | head -1 | cut -d'"' -f4)
curl -sS -i "$BASE/api/arsenal/$DEVICE_ID" -H "Authorization: Bearer $TOKEN"
# 200: una máquina concreta
echo; echo

curl -sS -i "$BASE/api/arsenal"
# 401: sin token
echo; echo

curl -sS -i "$BASE/api/arsenal" -H "Authorization: Bearer token.falso"
# 401: token inválido
echo; echo

curl -sS -i "$BASE/api/arsenal/no-es-un-id" -H "Authorization: Bearer $TOKEN"
# 400: id mal formado
echo
