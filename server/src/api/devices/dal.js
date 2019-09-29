const { User, Device } = require("../../db/models");
const omitSensetive = require("helpers/omitSensetive");

module.exports = {
  create: async function(data) {
    try {
      const deviceData = await Device.create(data);
      const device = deviceData.get({ plain: true });
      return device;
    } catch (error) {
      throw error;
    }
  },
  updateById: async function({ body, uid }) {
    try {
      const [_id] = await Device.update({ ...body }, { where: { uid } });
      return omitSensetive({ uid: _id, ...body });
    } catch (error) {
      throw error;
    }
  },
  deleteById: async function({ params: { uid } }) {
    try {
      await Device.destroy({ where: { uid } });
      return { uid };
    } catch (error) {
      throw error;
    }
  },
  getById: async function(uid) {
    try {
      const deviceData = await Device.findByPk(uid, {
        include: [
          {
            model: User,
            required: false,
            as: "users",
            attributes: ["id", "username", "email"],
            through: { attributes: [] }
          }
        ]
      });
      const device = deviceData.get({ plain: true });
      return omitSensetive(device);
    } catch (error) {
      throw error;
    }
  },
  all: async function() {
    try {
      const device = await Device.findAll({ raw: true });
      return device;
    } catch (error) {
      throw error;
    }
  }
};
