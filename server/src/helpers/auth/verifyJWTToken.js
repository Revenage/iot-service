const { secret } = require("config");
const jwt = require("jsonwebtoken");

function verifyJWTToken(token) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, secret, (err, decodedToken) => {
      if (err || !decodedToken) {
        return reject(err);
      }
      resolve(decodedToken);
    });
  });
}

module.exports = verifyJWTToken;
