const axios = require("axios");

const url =
  "https://cmpscan.io/api?module=nft&action=getnfts&apikey=YourApiKeyToken&owner=0xab4ac15f46cc0d815da7aad30ff31060c0171dce&withMetadata=true&pageSize=10";
const express = require("express");
const app = express();

app.get("/nft", async (req, res) => {
  try {
    const response = await axios.get(url);

    const data = response.data;
    console.log(response);

    res.json(data);
  } catch (error) {
    console.error(error);
    res.status(500).send("Internal server error");
  }
});

app.listen(3000, () => {
  console.log("Server listening on port 3000");
});
