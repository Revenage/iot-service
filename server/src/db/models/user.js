"use strict";
module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define(
    "User",
    {
      id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
      username: { type: DataTypes.STRING, allowNull: false, unique: true },
      password: { type: DataTypes.STRING, allowNull: false },
      email: { type: DataTypes.STRING, allowNull: false, unique: true },
      firstName: { type: DataTypes.STRING },
      lastName: { type: DataTypes.STRING }
    },
    {}
  );
  User.associate = function(models) {
    User.belongsToMany(models.Device, {
      through: models.UserDevice,
      as: "devices",
      foreignKey: "userId"
    });
    // associations can be defined here
  };
  return User;
};
