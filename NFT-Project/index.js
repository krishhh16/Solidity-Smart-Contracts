const ethers = require('ethers');

// Private key
const privateKey = 'db44f793b849fdbe97d746c021c768facd074a9b879e22f06ab6b3b49e7868d6';

// Create a wallet instance
const wallet = new ethers.Wallet(privateKey);

// Get the address
console.log(wallet.address);
