const app = require("../src/app");
const http = require("http");
const ip = require("ip");
const models = require("../src/db/models");

// @ts-ignore
const { port } = require("../src/config");

app.set("port", port);
const server = http.createServer(app);

models.sequelize
  // .sync({ force: true })
  .sync()
  .then(function() {
    server.listen(port, function() {
      console.log(`Example app listening on port ${ip.address()}:${port}`);
    });
    server.on("error", onError);
    server.on("listening", onListening);
  });

/**
 * Event listener for HTTP server "error" event.
 * @param {*} error
 */
function onError(error) {
  if (error.syscall !== "listen") {
    throw error;
  }

  var bind = typeof port === "string" ? "Pipe " + port : "Port " + port;

  // handle specific listen errors with friendly messages
  switch (error.code) {
    case "EACCES":
      console.error(bind + " requires elevated privileges");
      process.exit(1);
      break;
    case "EADDRINUSE":
      console.error(bind + " is already in use");
      process.exit(1);
      break;
    default:
      throw error;
  }
}

/**
 * Event listener for HTTP server "listening" event.
 */

function onListening() {
  var addr = server.address();
  var bind = typeof addr === "string" ? "pipe " + addr : "port " + addr.port;
  console.log("Listening on " + bind);
}
