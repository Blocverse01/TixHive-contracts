const ethers = require("ethers");
const { assert } = require("chai");

const EventFactory = artifacts.require("./EventFactory.sol");
const Event = artifacts.require("./Event.sol");
const TestERC20Token = artifacts.require("TestERC20Token");

require("chai").use(require("chai-as-promised")).should();

contract("EventFactory", ([contractOwner, secondAddress, thirdAddress]) => {
  let eventFactory;
  let eventAddress;
  let eventContract;
  let testERC20Token;
  // this would attach the deployed smart contract and its methods
  // to the `eventFactory` variable before all other tests are run
  before(async () => {
    eventFactory = await EventFactory.deployed();
    testERC20Token = await TestERC20Token.deployed();
    await testERC20Token.approve(eventFactory.address, web3.utils.toWei("106000"));
    await eventFactory.transferERC20(testERC20Token.address, thirdAddress, web3.utils.toWei("500"));
    console.log(web3.utils.fromWei(await testERC20Token.balanceOf(thirdAddress)));
    await eventFactory.transferERC20(testERC20Token.address, secondAddress, web3.utils.toWei("500"))
    console.log(web3.utils.fromWei(await testERC20Token.balanceOf(secondAddress)));

    // Monitor Events
    eventFactory.NewEvent({}, async (error, result) => {
      if (error) console.error(error);
      console.log(`[NEWEVENT] => [address] : ${result.args.contractAddress}`);
      eventAddress = result.args.contractAddress;
      eventContract = await Event.at(eventAddress);
    });
  });

  // check if deployment goes smooth
  describe("deployment", () => {
    // check if the smart contract is deployed
    // by checking the address of the smart contract
    it("deploys successfully", async () => {
      const address = await eventFactory.address;
      assert.notEqual(address, "");
      assert.notEqual(address, undefined);
      assert.notEqual(address, null);
      assert.notEqual(address, 0x0);
    });
  });

  describe("event", () => {
    // check if event gets created, check if addEvent works
    it("creates event with multiple tickets", async () => {
      // set tickets and create event
      const tickets = [
        {
          name: "VIP",
          description: "Ticket For VIPS",
          ticket_type: 1,
          quantity_available: 1000,
          price: ethers.utils.parseEther("10"),
        },
        {
          name: "VIP 2",
          description: "Ticket For Bigger VIPS",
          ticket_type: 1,
          quantity_available: 1000,
          price: ethers.utils.parseEther("10"),
        },
      ];
      await eventFactory.addEvent("Web 3 Ladies", "W3L", tickets, 0, { from: secondAddress });
      // `from` helps us identify by any address in the test
      console.log(eventAddress);
      assert.isDefined(eventAddress);
    });
  });

  describe("event-management", () => {
    it("event creator can close sale", async () => {
      await eventContract.setSaleIsActive(false, { from: secondAddress });
      const saleIsActive = await eventContract.saleIsActive();
      assert.equal(saleIsActive, false);
    });
    it("event creator can open sale", async () => {
      await eventContract.setSaleIsActive(true, { from: secondAddress });
      const saleIsActive = await eventContract.saleIsActive();
      assert.equal(saleIsActive, true);
    });
    it("only event creator can open sale", async () => {
      await eventContract.setSaleIsActive(true, { from: thirdAddress }).should.be.rejected;
    });
    it("only event creator can close sale", async () => {
      await eventContract.setSaleIsActive(false, { from: thirdAddress }).should.be.rejected;
    });
  })

  describe("tickets", () => {
    // check if tickets gets minted, check if mintTickets works
    it("mints tickets", async () => {
      // mint tickets
      const initialCreatorBalance = web3.utils.fromWei(await testERC20Token.balanceOf(secondAddress));
      const initialPlatformBalance = web3.utils.fromWei(await testERC20Token.balanceOf(contractOwner));
      const purchases = [
        {
          ticketId: 0,
          tokenURI: "https://ipfs.moralis.io:2053/ipfs/QmSCPLQbw54vZUpPcVu3VpeZJjXqpHAVQatQq4JwtUt4P2",
          buyer: contractOwner,
          cost: ethers.utils.parseEther("10"),
        },
        {
          ticketId: 1,
          tokenURI: "https://ipfs.moralis.io:2053/ipfs/QmSCPLQbw54vZUpPcVu3VpeZJjXqpHAVQatQq4JwtUt4P2",
          buyer: contractOwner,
          cost: ethers.utils.parseEther("10"),
        },
      ];
      await eventFactory.mintTickets(process.env.AUTH_KEY, eventContract.address, purchases, {
        from: contractOwner,
        value: ethers.utils.parseEther("20"),
      });
      // `from` helps us identify by any address in the test

      // check owner balance
      const ownerBalance = await eventContract.balanceOf(contractOwner);

      //check creator and platform balance
      const finalCreatorBalance = web3.utils.fromWei(await testERC20Token.balanceOf(secondAddress));
      const finalPlatformBalance = web3.utils.fromWei(await testERC20Token.balanceOf(contractOwner));

      console.log(finalCreatorBalance, initialCreatorBalance);
      console.log(finalPlatformBalance, initialPlatformBalance);
      assert.isAbove(ownerBalance.toNumber(), 0);
      assert.notEqual(finalCreatorBalance, initialCreatorBalance);
      assert.notEqual(finalPlatformBalance, initialPlatformBalance);
    });

    it("can read ticket sales info", async () => {
      const info = await eventContract.getInfo();
      const totalSold = info["0"];
      const sales = info["1"];
      const callerTickets = await eventContract.ownerTokens(contractOwner);
      assert.isDefined(totalSold.toString());
      assert.isDefined(sales);
      assert.isNotEmpty(callerTickets);
    });
    it("can read ticket royalty info", async () => {
      const royalty = await eventContract.royaltyInfo(0, web3.utils.toWei("100"));
      assert.equal(royalty["0"], secondAddress)
      assert.notEqual(royalty["1"], "0");
    })
  });

  describe("platform_percent", () => {
    it("sets platform_percent", async () => {
      await eventFactory.setPlatformPercent(1000, { from: contractOwner });
    });

    // make sure only owner can setPlatformPercent and no one else
    it("address that is not the owner fails to set platform percent", async () => {
      await eventFactory.setPlatformPercent(10, { from: secondAddress }).should.be.rejected;
      // this tells Chai that the test should pass if the setPlatformPercent function fails.
    });
  });

  describe("platform_fees_earned", () => {
    it("factory earns fees", async () => {
      const platformFees = web3.utils.fromWei((await eventFactory.feesEarned()).toString());
      console.log(platformFees);
      assert.notEqual(platformFees, "0");
    });
  });
});
