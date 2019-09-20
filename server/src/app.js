const express = require("express");
const app = express();

const cors = require("cors");
const bodyParser = require("body-parser");
const ErrorMiddleware = require("middlewares/error");
const HttpLoggerMiddleware = require("middlewares/logger");
const ApiRoutes = require("api");
const PollRoutes = require("poll");
const JWTMiddleware = require("middlewares/jwt");

app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use(HttpLoggerMiddleware);

app.use("/api", JWTMiddleware(), ApiRoutes);
app.use("/poll", /*JWTMiddleware(),*/ PollRoutes);

app.use(ErrorMiddleware);

module.exports = app;
