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
