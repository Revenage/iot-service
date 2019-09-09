const express = require("express");
const router = express.Router();

const users = require("./users/routes");

router.use("/users", users);
// router.use("/devices", getAllUsers);

module.exports = router;
