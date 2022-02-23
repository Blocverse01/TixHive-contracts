const CustomCollection = artifacts.require("CustomCollection.sol");
const Platform = artifacts.require("Platform.sol");
const Migrations = artifacts.require("Migrations");

module.exports = async function (deployer, callback) {
  try {
    const collection = await CustomCollection.deployed();
    console.log(collection);
    } catch(error) {

    }
}
