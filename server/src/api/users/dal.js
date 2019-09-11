const { User } = require("../../db/models");
const omitSensetive = require("helpers/omitSensetive");

module.exports = {
  create: async function(data) {
    try {
      const userData = await User.create(data);
      const user = userData.get({ plain: true });
      return omitSensetive(user);
    } catch (error) {
      throw error;
    }
  },
  getById: async function(id) {
    try {
      const userData = await User.findByPk(id);
      const user = userData.get({ plain: true });
      return omitSensetive(user);
    } catch (error) {
      throw error;
    }
  },
  authenticate: async function(email, password) {
    try {
      const userData = await User.findOne({
        where: { email }
      });
      const user = userData.get({ plain: true });

      if (password !== user.password) {
        throw new Error("Invalid password");
      }
      return omitSensetive(user);
    } catch (error) {
      throw error;
    }
  },
  updateById: async function({ body, id }) {
    try {
      const [_id] = await User.update({ ...body }, { where: { id } });
      return omitSensetive({ id: _id, ...body });
    } catch (error) {
      throw error;
    }
  },
  deleteById: async function({ params: { id } }) {
    try {
      const _id = await User.destroy({ where: { id } });
      return { id: _id };
    } catch (error) {
      throw error;
    }
  },
  all: async function() {
    try {
      const users = await User.findAll({ raw: true });
      return users;
    } catch (error) {
      throw error;
    }
  }
};
