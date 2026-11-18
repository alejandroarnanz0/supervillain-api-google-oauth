# Proteger el listado de villanos

He añadido `tokenVerify` al `GET /` de `routes/villains.js`, como en el resto de rutas:

```js
router.get('/', tokenVerify, (req, res, next) => {
```

## Preguntas

**¿Qué comprueba el middleware?**
Que venga `Authorization: Bearer <token>` y que el JWT sea válido: firma con `TOKEN_SECRET`, issuer, audience y que no haya caducado. Si falla algo devuelve 401; si no, pasa a la ruta con `next()`.

**¿Por qué el login y el callback siguen públicos?**
Porque son los que te dan el token. Si pidieran JWT no podrías entrar nunca. Además el callback lo llama el navegador al volver de Google, sin cabecera Bearer. Ya está protegido con state, PKCE y nonce.

**¿Por qué un JWT no da permiso sobre un villano concreto?**
El JWT solo dice quién eres, no qué puedes tocar. No hay roles ni dueño de cada villano, así que cualquier usuario logueado puede modificar o borrar cualquiera. Para eso habría que guardar el propietario y devolver 403.

**¿Qué pasa cuando expira el token?**
Al pasar la hora la API devuelve 401 y hay que volver a hacer login con Google. No hay refresh token.

## Entrega

URL de Render: https://supervillain-api-google-oauth-efdj.onrender.com

Tests:
- `salida-test-exercise-antes.txt`: antes del cambio, fallan 3 y pasa 1.
- `salida-test-exercise.txt`: después, pasan los 4.
- `salida-npm-test.txt`: 29/29.

Comprobaciones HTTP (`comprobaciones.sh`, mismo resultado en local y en Render):

| Petición | Local | Render |
|---|---|---|
| `/health` sin token | 200 | 200 |
| `/api/auth/google` | 302 a Google | 302 a Google |
| Listado sin token | 401 | 401 |
| Listado con `Bearer incorrecto` | 401 | 401 |
| Listado con token caducado | 401 | 401 |
| Listado con token válido | 200 | 200 |
| `/api/users/secure` con / sin token | 200 / 401 | 200 / 401 |

- `comprobaciones-local.txt` y `comprobaciones-render.txt`: salida completa. Los tokens no se imprimen y el email está tapado.
- `callback-local.png` y `callback-render.png`: respuesta del callback de Google (200 con el JWT, token tapado).
- El token caducado lo genero con el mismo `sub` y el mismo secreto pero con la expiración ya pasada, así que el 401 es por caducidad y no por firma.
