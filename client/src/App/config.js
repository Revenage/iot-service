const config = {
  development: {
    host: "http://localhost:3000",
    defaultLanguage: "en"
  },
  production: {
    host: "/",
    defaultLanguage: "en"
  }
};

const exp = config[process.env.NODE_ENV];

export default exp;
