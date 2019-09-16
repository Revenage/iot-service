// var Heros = require('./heros.controller');

// module.exports = function(router) {
//     router.post('/create', Heros.createHero);
//     router.get('/get', Heros.getHeros);
//     router.get('/get/:name', Heros.getHero);
//     router.put('/update/:id', Heros.updateHero);
//     router.delete('/remove/:id', Heros.removeHero);
// }

const express = require("express");
const router = express.Router();

const {
  register,
  getDevices,
  createDevice,
  getDevice,
  updateDevice,
  deleteDevice
} = require("./controller");

router.post("/auth/register", register);
// router.post("/auth/login", login);
// router.post("/auth/logout", logout);
// router.get("/auth/me", me);

router.get("/", getDevices);
router.post("/", createDevice);
router.get("/:uid", getDevice);
router.put("/:uid", updateDevice);
router.delete("/:uid", deleteDevice);

module.exports = router;
