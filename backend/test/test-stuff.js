const Contract = artifacts.require("Platform");

module.exports = async function (callback) {
    try {
        const platform = await Contract.deployed();
        console.log(platform);
    } catch(error) {

    }
}