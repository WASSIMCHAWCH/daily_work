const proof = [
  "0x857898d823266e60a34ec407a650c3fe3adb1ccc96d4e1567054ca583fef039a",
  "0xa1933f4952afdf527c2b6b441f4991f364c2fcc8eed9375c7859104e7943c95b",
  "'0x37467e328d63a845fc901f577cc3f2ae93487ad3f428dc03560685d248a65a27'",
];

// Convert the array to a string
const proofString = JSON.stringify(proof);
console.log(proofString);

// Remove the spaces from the string
const proofStringNoSpaces = proofString.replace(/\'/g, "");
console.log(proofStringNoSpaces);
