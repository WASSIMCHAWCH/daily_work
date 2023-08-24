const axios = require("axios");
const ethers = require("ethers");
const abi = require("./ABI.json");
const uris = require("./uri's.json");

const contractAddress = "0xF4f65813bCb1b1442aba24f6F342672CfaC43a22";

const provider = new ethers.getDefaultProvider("goerli");
const signer = new ethers.Wallet(
  "fb0bfa30198583b52d4bb8f44c5297a6e8feafaedf4dd6288271f3526acb63c6",
  provider
);

const contract = new ethers.Contract(contractAddress, abi, signer);

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

let i = 0;

async function preveal() {
  while (i < 5) {
    i++;

    let URI = "";
    const x = uris.map((x) => {
      if (x.id == i) URI = x.uri;
    });

    axios
      .get("http://localhost:3000/proof", {
        params: {
          uri: URI,
          id: i,
        },
      })
      .then((response) => {
        const proofs = response.data;
        console.log("proof:", proofs);

        if (proofs[0].length > 0) {
          contract
            .reveal(URI, proofs, i)
            .then((tx) => {
              console.log("Transaction hash:", tx.hash);
              return tx.wait();
            })
            .then((receipt) => {
              console.log("Transaction receipt:", receipt);
              const events = receipt.events;
              if (events.length > 0) {
                console.log("Events:", events);
              }
            })
            .catch((error) => {
              console.error("Error from smart contract:", error);
            });
        }
      })
      .catch((error) => {
        console.error("Error from express server:", error);
      });
    await sleep(20000);
  }
}

preveal();
