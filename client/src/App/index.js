import { Elm } from "./Main.elm";
import config from "./config.js";

// const storageKey = "store";
// const flags = localStorage.getItem(storageKey);

const token = localStorage.getItem("token") || "";

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: {
    config,
    token
  }
});

app.ports.localStorage.subscribe(function(data) {
  Object.keys(data).forEach(key => localStorage.setItem(key, data[key]));
});

// var mqtt = require("mqtt");
// var client = mqtt.connect("ws://test.mosquitto.org:8080/mqtt");

// client.on("connect", function(c) {
//   console.log("connect", c);
//   client.subscribe("$SYS/broker/clients/# ", function(err) {
//     if (!err) {
//       // client.publish("presence", "Hello mqtt");
//     }
//   });
// });

// client.on("message", function(topic, message) {
//   // message is Buffer
//   console.log(message.toString(), topic, message);
//   client.end();
// });
