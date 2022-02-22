const Contract = artifacts.require("CustomCollection");

module.exports = async function (callback) {
    try {
        const collection = await Contract.deployed();
        console.log(collection);
    } catch(error) {

    }
}