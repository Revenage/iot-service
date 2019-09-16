const express = require("express");
const router = express.Router();
const { timeout } = require("config");

async function publishAll(data, items) {
  if (items.size) {
    const [pollResKey, ...rest] = items.keys();
    console.log("key", pollResKey, rest);
    const pollRes = items.get(pollResKey);
    pollRes(data);
    items.delete(pollResKey);
    return await publishAll(data, items);
  }
  return;
}

const subscribers = new Map();

router.get("/connect/:id", (req, res) => {
  console.log("poll for: ", req.params.id);
  const t = setTimeout(() => {
    subscribers.delete(req.params.id);
    res.json({ status: "time out" });
  }, timeout);

  subscribers.set(req.params.id, function back(data) {
    clearTimeout(t);
    subscribers.delete(req.params.id);
    res.json(data);
  });
});

router.post("/publish/:id", (req, res, next) => {
  console.log("publish to", req.params.id);
  console.log("%j", "body", req.body);

  if (subscribers.has(req.params.id)) {
    const pollRes = subscribers.get(req.params.id);
    pollRes(req.body);
    res.json({ status: "OK" });
  } else {
    throw `Device ${req.params.id} is offline`;
  }
});

router.post("/publish", async (req, res) => {
  console.log("publish all");
  console.log("%j", "body", req.body);

  try {
    await publishAll(req.body, subscribers);
  } catch (error) {
    throw error;
  }

  res.json({ status: "OK" });
});
// router.use("/devices", getAllUsers);

module.exports = router;
