const { getById } = require("api/devices/service");
const { timeout } = require("config");

// routes
const subscribers = new Map();

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitTimes(t, cb) {
  t--;
  try {
    return await cb();
  } catch (err) {
    if (t) {
      return await waitTimes(t, cb);
    }

    throw err;
  }
}

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

module.exports = {
  subscribe: async function(req, res) {
    const {
      params: { id }
    } = req;
    try {
      const device = await getById(id);
      if (device) {
        const t = setTimeout(() => {
          subscribers.delete(id);
          res.json({ status: "time out" });
        }, timeout);

        subscribers.set(id, async function back(data) {
          clearTimeout(t);
          subscribers.delete(id);
          await res.json(data);
        });
      } else {
        throw `Device ${id} is not registred`;
      }
    } catch (error) {
      res.status(404).send({ error });
    }
  },
  publish: async function(req, res) {
    const {
      params: { id },
      user: { id: userId }
    } = req;

    try {
      const device = await getById(id);
      if (device) {
        const user = device.users.find(({ id }) => id === userId);
        if (!user) {
          throw `You has not rights to access device ${id}`;
        }
        if (subscribers.has(id)) {
          const pollRes = subscribers.get(id);
          await pollRes(req.body);
          // await waitTimes(1000, async () => {
          //   await delay(100);
          //   const d = subscribers.has(id);
          //   if (!subscribers.has(id)) {
          //     throw "not device";
          //   }
          //   return d;
          // });

          await res.json({ status: "ok" });
        } else {
          throw `Device ${id} is offline`;
        }
      } else {
        throw `Device ${id} is not registred`;
      }
    } catch (error) {
      console.log("error", error);
      res.status(404).send({ error });
    }
  },
  publishToAll: async function(req, res, next) {
    try {
      await publishAll(req.body, subscribers);
    } catch (error) {
      res.status(404).send({ error });
    }

    res.json({ status: "ok" });
  }
};
