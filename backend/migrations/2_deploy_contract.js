const EventFactory = artifacts.require("EventFactory");
const TicketManager = artifacts.require("TicketManager");
const BlocTick = artifacts.require("BlocTick");
const Enumerable = artifacts.require("Enumerable");
module.exports = async (deployer) => {
  await deployer.deploy(TicketManager);
  await deployer.deploy(BlocTick);
  await deployer.deploy(Enumerable);
  await deployer.link(BlocTick, EventFactory);
  await deployer.link(TicketManager, EventFactory);
  await deployer.link(Enumerable, EventFactory);
  await deployer.deploy(EventFactory);
};
