const { User } = require("../../db/models");
const omitSensetive = require("helpers/omitSensetive");

module.exports = {
  create: async function(data) {
    try {
      const { dataValues } = await User.create(data);
      return omitSensetive(dataValues);
    } catch (error) {
      throw error;
    }
  },
  getById: async function(id) {
    try {
      const { dataValues } = await User.findByPk(id);
      return omitSensetive(dataValues);
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
