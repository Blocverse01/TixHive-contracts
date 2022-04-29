const { utils } = require("ethers");
const { assert } = require("chai");

const EventFactory = artifacts.require("./EventFactory.sol")
const Event = artifacts.require("./Event.sol");

require("chai")
    .use(require("chai-as-promised"))
    .should()

contract('EventFactory', ([contractOwner, secondAddress, thirdAddress]) => {
    let eventFactory
    // this would attach the deployed smart contract and its methods 
    // to the `eventFactory` variable before all other tests are run
    before(async () => {
        eventFactory = await EventFactory.deployed()
    })

    // check if deployment goes smooth
    describe('deployment', () => {
        // check if the smart contract is deployed 
        // by checking the address of the smart contract
        it('deploys successfully', async () => {
            const address = await eventFactory.address
            assert.notEqual(address, '')
            assert.notEqual(address, undefined)
            assert.notEqual(address, null)
            assert.notEqual(address, 0x0)
        })
    })

    describe('event', () => {
        // check if event gets created, check if addEvent works
        it('creates event', async () => {
            // set tickets and create event
            const tickets = [{
                name: "VIP",
                description: "Ticket For VIPS",
                ticket_type: 1,
                quantity_available: 1000,
                price: 1
            }, {
                name: "VIP 2",
                description: "Ticket For Bigger VIPS",
                ticket_type: 1,
                quantity_available: 1000,
                price: 2
            }]
            await eventFactory.addEvent('Web 3 Ladies', 'W3L', tickets, { from: secondAddress })
            // `from` helps us identify by any address in the test

            // check new event
            const createdEvent = await eventFactory._events(0)
            assert.isDefined(createdEvent)
        })
    })

    describe('tickets', () => {
        // check if tickets gets minted, check if mintTickets works
        it('mints tickets', async () => {
            // mint tickets
            const eventAddress = await eventFactory._events(0);
            const purchases = [{
                purchaseId: "VIPXdareggye",
                ticketId: 0,
                tokenURI: "https://ipfs.moralis.io:2053/ipfs/QmSCPLQbw54vZUpPcVu3VpeZJjXqpHAVQatQq4JwtUt4P2",
                buyer: thirdAddress,
                cost: "1.0 ETH"
            }, {
                purchaseId: "VIPXXXdaregfff",
                ticketId: 1,
                tokenURI: "https://ipfs.moralis.io:2053/ipfs/QmSCPLQbw54vZUpPcVu3VpeZJjXqpHAVQatQq4JwtUt4P2",
                buyer: thirdAddress,
                cost: "2.0 ETH"
            }]
            await eventFactory.mintTickets(eventAddress, purchases, { from: thirdAddress, value: utils.parseEther("3.0") })
            // `from` helps us identify by any address in the test

            // check owner balance
            const eventContract = await Event.at(eventAddress)
            const ownerBalance = await eventContract.balanceOf(thirdAddress);
            assert.isAbove(ownerBalance.toNumber(), 0);
        })
    })

    describe('platform_percent', () => {
        it('sets platform_percent', async () => {
            console.log(await eventFactory._owner(), contractOwner)
            await eventFactory.setPlatformPercent(50, { from: contractOwner });
        })

        // make sure only owner can setPlatformPercent and no one else
        it('address that is not the owner fails to set platform percent', async () => {
            await eventFactory.setPlatformPercent(50, { from: secondAddress })
                .should.be.rejected
            // this tells Chai that the test should pass if the setPlatformPercent function fails.
        })
    })
})