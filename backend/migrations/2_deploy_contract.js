const Platform = artifacts.require("Platform");

module.exports = async (deployer) => {
  await deployer.deploy(Platform);
};
