const {
  create,
  allDevices,
  getById,
  updateById,
  deleteById
} = require("./service");
const { getByEmail } = require("../users/service");

// routes

module.exports = {
  register: async function(req, res, next) {
    try {
      const { body } = req;
      const { email, password } = body;
      console.log("%j", "register", body);
      const user = await getByEmail(email);
      const { password: userPassword } = user;
      if (user) {
        if (password === userPassword) {
          try {
            const device = await create(req.body);
            if (device) {
              try {
                user.addDevice(device.uid);
                console.log("%j", "addDevice", device);
                return res.json(device);
              } catch (error) {
                next(error);
              }
            }
          } catch (error) {
            next(error);
          }
        } else {
          throw "Password is incorrect";
        }
      } else {
        throw "User is incorrect";
      }
    } catch (error) {
      next(error);
    }
  },
  // me: async function(req, res, next) {
  //   try {
  //     const { id } = req.devi;
  //     if (id) {
  //       const user = await getById(id);
  //       return res.json(user);
  //     }
  //   } catch (error) {
  //     next(error);
  //   }
  // },
  createDevice: async function(req, res, next) {
    try {
      const device = await create(req.body);
      return res.json(device);
    } catch (error) {
      next(error);
    }
  },
  getDevice: async function(req, res, next) {
    const {
      params: { uid }
    } = req;
    try {
      const device = await getById(uid);
      return res.json(device);
    } catch (error) {
      next(error);
    }
  },
  updateDevice: async function(req, res, next) {
    try {
      const {
        body,
        params: { uid }
      } = req;
      const device = await updateById({ body, uid });
      return res.json(device);
    } catch (error) {
      next(error);
    }
  },
  deleteDevice: async function(req, res, next) {
    try {
      const device = await deleteById(req);
      return res.json(device);
    } catch (error) {
      next(error);
    }
  },

  getDevices: async function(req, res, next) {
    try {
      const devices = await allDevices();
      return res.json(devices);
    } catch (error) {
      next(error);
    }
  }
};
