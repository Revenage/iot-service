const axios = require("axios");

const host = "http://localhost:3000/poll/connect/" + process.env.N;

async function app() {
  async function poll() {
    try {
      const { data } = await axios(host);
      console.log("%j", "response", data);
      poll();
    } catch (error) {
      console.log("%j", "error", error.message);

      setTimeout(() => {
        poll();
      }, 1000);
    }
  }

  poll();
}

app();
