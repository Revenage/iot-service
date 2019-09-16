"use strict";
module.exports = (sequelize, DataTypes) => {
  const Device = sequelize.define(
    "Device",
    {
      uid: { type: DataTypes.STRING, primaryKey: true }
    },
    {}
  );
  Device.associate = function(models) {
    Device.belongsToMany(models.User, {
      through: models.UserDevice,
      as: "users",
      foreignKey: "deviceId"
    });
  };
  return Device;
};
