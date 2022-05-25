const EventFactory = artifacts.require("EventFactory");
const TicketManager = artifacts.require("TicketManager");
const BlocTick = artifacts.require("BlocTick");
const Event = artifacts.require("Event");
const TestERC20Token = artifacts.require("TestERC20Token");
module.exports = async (deployer, network) => {
  await deployer.deploy(TicketManager);
  await deployer.deploy(BlocTick);
  await deployer.link(BlocTick, [Event, EventFactory]);
  await deployer.link(TicketManager, [Event, EventFactory]);
  await deployer.deploy(Event);
  await deployer.deploy(EventFactory, Event.address);
  if (network === "development" || network.includes("testnet")) {
    await deployer.deploy(TestERC20Token, web3.utils.toWei("100000000"));
    EventFactory.deployed().then((instance) => instance.addERC20PaymentMethod(TestERC20Token.address, "TEST"));
  }
};
