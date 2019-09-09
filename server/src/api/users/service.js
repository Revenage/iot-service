const config = require("config");
const jwt = require("jsonwebtoken");
const User = require("./dal");
const subscribeJWTToken = require("helpers/auth/subscribeJWTToken");

module.exports = {
  create: async function({ username, email, password }) {
    try {
      const user = await User.create({ username, email, password });
      if (user) {
        const token = subscribeJWTToken(user.id);
        const { password, ...userWithoutPassword } = user;
        return {
          ...userWithoutPassword,
          token
        };
      }

      throw "User hast't created";
    } catch (error) {
      throw error;
    }
  },
  allUsers: async function() {
    try {
      const users = await User.all();
      return users;
    } catch (error) {
      throw error;
    }
  },
  getById: async function(id) {
    try {
      const user = await User.getById(id);
      return user;
    } catch (error) {
      throw error;
    }
  },
  updateById: async function name({ body, id }) {
    try {
      const user = User.updateById({ body, id });
      return user;
    } catch (error) {
      throw error;
    }
  },
  deleteById: async function name(req) {
    try {
      const user = User.deleteById(req);
      return user;
    } catch (error) {
      throw error;
    }
  }
};
