const config = {
  development: {
    secret: "qwerqwerqwerqwer",
    port: 3000
  },
  production: {
    secret: "qwerqwerqwerqwer",
    port: 3000
  }
};

const c = config[process.env.NODE_ENV];

module.exports = c;
