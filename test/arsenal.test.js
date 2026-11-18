// Recurso extra /api/arsenal: protegido con JWT.
const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const { connect, disconnect, authenticate } = require('./helpers');
const request = require('supertest');
const app = require('../app');

let token, device;
const auth = (r) => r.set('Authorization', `Bearer ${token}`);

before(async () => {
  await connect();
  token = await authenticate(app);
  const villain = (await auth(request(app).post('/api/villains')).send({ name: 'Nefario', alias: 'Doc', evilLevel: 7 })).body.data;
  const lair = (await auth(request(app).post(`/api/villains/${villain._id}/lairs`)).send({ name: 'Laboratorio' })).body.data;
  device = (await auth(request(app).post(`/api/villains/${villain._id}/lairs/${lair._id}/devices`)).send({ name: 'Rayo', status: 'Lista' })).body.data;
});
after(disconnect);

test('sin token o con token inválido: 401', async () => {
  await request(app).get('/api/arsenal').expect(401);
  await request(app).get(`/api/arsenal/${device._id}`).expect(401);
  await request(app).get('/api/arsenal').set('Authorization', 'Bearer incorrecto').expect(401);
});

test('con token: lista, filtro, una máquina, 404 y 400', async () => {
  let r = await auth(request(app).get('/api/arsenal')).expect(200);
  assert.equal(r.body.total, 1);
  assert.equal(r.body.data[0].lair.name, 'Laboratorio');
  r = await auth(request(app).get('/api/arsenal?status=Cargando')).expect(200);
  assert.equal(r.body.total, 0);
  r = await auth(request(app).get(`/api/arsenal/${device._id}`)).expect(200);
  assert.equal(r.body.name, 'Rayo');
  await auth(request(app).get('/api/arsenal/64b7f0f2f2f2f2f2f2f2f2f2')).expect(404);
  await auth(request(app).get('/api/arsenal/no-es-un-id')).expect(400);
});
