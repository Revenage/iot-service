"use strict";
module.exports = (sequelize, DataTypes) => {
  const UserDevice = sequelize.define(
    "UserDevice",
    {
      userId: DataTypes.INTEGER,
      deviceId: DataTypes.STRING
    },
    {}
  );
  UserDevice.associate = models => {
    // associations can be defined here
  };
  return UserDevice;
};
