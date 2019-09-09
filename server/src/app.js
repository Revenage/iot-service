const express = require("express");
const app = express();

const cors = require("cors");
const bodyParser = require("body-parser");
const ErrorMiddleware = require("middlewares/error");
const HttpLoggerMiddleware = require("middlewares/logger");
const ApiRoutes = require("api");
const JWTMiddleware = require("middlewares/jwt");

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cors());

app.use(HttpLoggerMiddleware);

app.use("/api", JWTMiddleware(), ApiRoutes);
// app.use("/devices", JWTMiddleware(), UserRoutes);

// app.post("/connect-device", (req, res) => {
//   console.log("%j", "body", req.body);
//   const {
//     body: { email, uid }
//   } = req;
//   res.status(201).json({
//     status: "Created",
//     message: `Device ${uid} successfuly connected to user ${email}`
//   });

//   // res.status(409).json({
//   //   status: "Conflict",
//   //   message: `Device ${uid} already connected!`
//   // });
// });

// app.use("*", (req, res) => res.sendStatus(404));

app.use(ErrorMiddleware);

module.exports = app;
