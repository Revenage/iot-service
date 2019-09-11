const expressJwt = require("express-jwt");
const config = require("config");

function JWTMiddleware() {
  const { secret } = config;
  return expressJwt({ secret }).unless({
    path: ["/api/users/auth/signup", "/api/users/auth/login"]
  });
}

module.exports = JWTMiddleware;
