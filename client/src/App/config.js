const config = {
  development: {
    host: "http://localhost:3000"
  },
  production: {
    host: "/"
  }
};

const exp = config[process.env.NODE_ENV];

export default exp;
