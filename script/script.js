const axios = require("axios");
const ethers = require("ethers");
const abi = require("./ABI.json");
const uris = require("./uri's.json");

const contractAddress = "0xFDE795D168AFd30b9B91422C85A62E3d241c9E05";

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
      .then(async (response) => {
        const proofs = response.data;
        console.log("proof:", proofs);
        console.log(URI);
        console.log(i);

        if (proofs[0].length > 0) {
          await contract.reveal(URI, proofs, i).then((tx) => {
            console.log("Transaction hash:", tx.hash);
            return tx.wait();
          });
        }
      })
      .catch((error) => {
        console.error(error);
      });
    await sleep(30000);
  }
}

preveal();
