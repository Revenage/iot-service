const express = require("express");
const router = express.Router();

const { subscribe, publish, publishToAll } = require("./controller");

router.get("/subscribe/:id", subscribe);

router.post("/publish/:id", publish);

router.post("/publish", publishToAll);
// router.use("/devices", getAllUsers);

module.exports = router;
