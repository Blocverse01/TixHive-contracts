const Platform = artifacts.require("Platform");
const EventFactory = artifacts.require("EventFactory");
const BlocTick = artifacts.require("BlocTick");
const TicketManager = artifacts.require("TicketManager");
const Counter = artifacts.require("Counters");
module.exports = async (deployer) => {
  await deployer.deploy(BlocTick);
  await deployer.deploy(TicketManager);
  await deployer.deploy(Counter);
  deployer.link(BlocTick, [Platform, EventFactory]);
  deployer.link(TicketManager, [EventFactory]);
  deployer.link(Counter, [EventFactory]);
  await deployer.deploy(Platform);
  await deployer.deploy(EventFactory);
};
