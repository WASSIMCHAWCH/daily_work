const express = require("express");
const fs = require("fs");
const { MerkleTree } = require("merkletreejs");
const { ethers } = require("ethers");

const app = express();

app.use(express.json());

const data = JSON.parse(fs.readFileSync("uri's.json"));
console.log(data);

const leaves = data.map((x) =>
  ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(["string", "uint"], [x.uri, x.id])
  )
);

const tree = new MerkleTree(leaves, ethers.utils.keccak256, {
  sortPairs: true,
});

const root = tree.getHexRoot().toString("hex");

app.get("/root", (req, res) => {
  res.send(root);
});

app.get("/proof", (req, res) => {
  const { uri, id } = req.body;

  const leaf = ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(["string", "uint"], [uri, id])
  );

  const proof = tree.getHexProof(leaf);

  res.send(proof);
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
