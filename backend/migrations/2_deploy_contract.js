const EventFactory = artifacts.require("EventFactory");
const TicketManager = artifacts.require("TicketManager");
const BlocTick = artifacts.require("BlocTick");
module.exports = async (deployer) => {
  await deployer.deploy(TicketManager);
  await deployer.deploy(BlocTick);
  await deployer.link(BlocTick, EventFactory);
  await deployer.link(TicketManager, EventFactory);
  await deployer.deploy(EventFactory);
};
