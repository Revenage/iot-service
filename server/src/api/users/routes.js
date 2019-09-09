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
  signup,
  login,
  logout,
  me,
  getUsers,
  createUser,
  getUser,
  updateUser,
  deleteUser
} = require("./controller");

router.post("/auth/signup", signup);
router.post("/auth/login", login);
router.post("/auth/logout", logout);
router.get("/auth/me", me);

router.get("/", getUsers);
router.post("/", createUser);
router.get("/:id", getUser);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

module.exports = router;
