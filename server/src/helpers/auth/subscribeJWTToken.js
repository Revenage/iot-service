const { secret } = require("config");
const jwt = require("jsonwebtoken");

function subscribeJWTToken(id) {
  return jwt.sign({ id }, secret);
}

module.exports = subscribeJWTToken;
