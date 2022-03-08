const Platform = artifacts.require("Platform");
const EventFactory = artifacts.require("EventFactory");
const BlocTick = artifacts.require("BlocTick");
module.exports = async (deployer) => {
  await deployer.deploy(BlocTick);
  deployer.link(BlocTick, [Platform, EventFactory]);
  await deployer.deploy(Platform);
  await deployer.deploy(EventFactory);
};
