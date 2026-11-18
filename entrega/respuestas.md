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

- `salida-npm-test.txt` y `salida-test-exercise.txt`: salida de los tests (29/29 y 4/4).
- `callback-local.png`: respuesta del callback (token tapado).
- `comprobaciones-local.txt`: peticiones con curl. El token caducado lo genero firmándolo con el mismo secreto pero con la fecha de expiración ya pasada.
- URL de Render: https://supervillain-api-google-oauth-efdj.onrender.com
- `comprobaciones-render.txt`: las mismas peticiones contra Render. Solo están las que no necesitan token, porque Chrome bloquea el dominio de Render como "sitio peligroso" al ir al login de Google (`render-chrome-aviso.png`), así que no pude sacar un token allí. En local sí está todo probado con token.
