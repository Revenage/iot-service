// const winston = require("winston");
// const expressWinston = require("express-winston");

const morgan = require("morgan");

// expressWinston.errorLogger({
//   transports: [new winston.transports.Console()],
//   format: winston.format.combine(
//     winston.format.colorize(),
//     winston.format.json()
//   )
// });

module.exports = morgan("dev");
