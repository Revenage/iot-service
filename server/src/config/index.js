const config = {
  development: {
    secret: "qwerqwerqwerqwer",
    port: 3000,
    timeout: 30000
  },
  production: {
    secret: "qwerqwerqwerqwer",
    port: process.env.PORT || 3000,
    timeout: 29000
  }
};

const c = config[process.env.NODE_ENV];

module.exports = c;
