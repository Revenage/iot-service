const express = require("express");
const router = express.Router();

const users = require("./users/routes");
const devices = require("./devices/routes");

router.use("/users", users);
router.use("/devices", devices);

module.exports = router;
