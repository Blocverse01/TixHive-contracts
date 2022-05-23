const EventFactory = artifacts.require("EventFactory");
const TicketManager = artifacts.require("TicketManager");
const BlocTick = artifacts.require("BlocTick");
const Event = artifacts.require("Event");
module.exports = async (deployer) => {
  await deployer.deploy(TicketManager);
  await deployer.deploy(BlocTick);
  await deployer.link(BlocTick, [Event, EventFactory]);
  await deployer.link(TicketManager, [Event, EventFactory]);
  await deployer.deploy(Event);
  await deployer.deploy(EventFactory, Event.address);
};
