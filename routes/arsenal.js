const express = require('express');
const Device = require('../models/Device');
const tokenVerify = require('../middleware/tokenVerify');
const router = express.Router();

// Arsenal: todas las máquinas del juicio final, de cualquier guarida.
// Es un recurso aparte de villains y entero va protegido con JWT.
router.use(tokenVerify);

// GET /api/arsenal  (opcional ?status=Lista|Cargando|Inactiva)
router.get('/', (req, res, next) => {
  const filter = req.query.status ? { status: String(req.query.status) } : {};
  Device.find(filter).populate('lair', 'name location')
    .then((devices) => res.json({ message: "Arsenal del imperio", total: devices.length, data: devices }))
    .catch(next);
});

// GET /api/arsenal/:deviceId
router.get('/:deviceId', (req, res, next) => {
  Device.findById(req.params.deviceId).populate('lair', 'name location')
    .then((device) => device ? res.json(device) : res.status(404).json({ error: "Máquina no encontrada." }))
    .catch(next);
});

module.exports = router;
