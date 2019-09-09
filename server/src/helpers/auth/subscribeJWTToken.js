const { secret } = require("config");

function subscribeJWTToken(id) {
  return jwt.sign({ id }, secret);
}

module.exports = subscribeJWTToken;
