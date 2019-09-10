module.exports = {
  development: {
    username: "root",
    password: "fa11wa11",
    database: "dev",
    host: "localhost",
    dialect: "mysql"
  },
  test: {
    username: "root",
    password: null,
    database: "database_test",
    host:
      "mysql://b0400e7e453e49:2916593f@eu-cdbr-west-02.cleardb.net/heroku_560cf6bc7ba3a74?reconnect=true",
    dialect: "mysql"
  },
  production: {
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: "mysql"
  }
};
