const Device = require("./dal");
// const subscribeJWTToken = require("helpers/auth/subscribeJWTToken");

module.exports = {
  create: async function({ uid, email, password }) {
    try {
      const device = await Device.create({ uid, email, password });
      if (device) {
        // const token = subscribeJWTToken(user.id);
        const { password, ...userWithoutPassword } = device;
        return {
          ...userWithoutPassword
          // token
        };
      }

      throw "Device hast't created";
    } catch (error) {
      throw error;
    }
  },
  getById: async function(uid) {
    try {
      const device = await Device.getById(uid);
      return device;
    } catch (error) {
      throw error;
    }
  },
  updateById: async function name({ body, id }) {
    try {
      const device = Device.updateById({ body, id });
      return device;
    } catch (error) {
      throw error;
    }
  },
  deleteById: async function name(req) {
    try {
      const device = Device.deleteById(req);
      return device;
    } catch (error) {
      throw error;
    }
  },

  allDevices: async function() {
    try {
      const device = await Device.all();
      return device;
    } catch (error) {
      throw error;
    }
  }
};
