const EventFactory = artifacts.require("EventFactory");
const TicketManager = artifacts.require("TicketManager");
module.exports = async (deployer) => {
  await deployer.deploy(TicketManager);
  await deployer.link(TicketManager, EventFactory);
  await deployer.deploy(EventFactory);
};
