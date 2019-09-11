const { secret } = require("config");
const jwt = require("jsonwebtoken");

function subscribeJWTToken(id) {
  return jwt.sign({ id }, secret /*{ expiresIn: "1m" }*/);
}

module.exports = subscribeJWTToken;
