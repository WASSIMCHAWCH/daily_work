const Web3 = require("web3");
const abi = require("./ABI.json");

const web3 = new Web3(
  new Web3.providers.HttpProvider(
    "https://eth-mainnet.g.alchemy.com/v2/MRrj_w64aNWZ23CDp51H3G-e1anoAgtm"
  )
);
const contract = new web3.eth.Contract(abi, "contract address");

const account = "account address";
const privateKey = "private key";

let tokenId = 0;

const txObject = {
  from: account,
  to: contract.options.address,
  gas: web3.utils.toHex(200000),
  data: contract.methods.revealed(tokenId, "proofs", "URI").encodeABI(),
};

web3.eth.accounts.signTransaction(txObject, privateKey, (err, signedTx) => {
  if (err) {
    console.error(err);
  } else {
    web3.eth
      .sendSignedTransaction(signedTx.rawTransaction)
      .on("receipt", (receipt) => {
        console.log("Transaction successful!");
        console.log(receipt);
      })
      .on("error", (error) => {
        console.error("Transaction failed!");
        console.error(error);
      });
  }
});
