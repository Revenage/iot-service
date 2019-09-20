import { Elm } from "./Main.elm";
import config from "./config.js";

// const storageKey = "store";
// const flags = localStorage.getItem(storageKey);

const token = localStorage.getItem("token") || "";

Elm.Main.init({
  node: document.querySelector("main"),
  flags: {
    config,
    token
  }
});
