// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./Administrator.sol";
import "./BlocTick.sol";

contract EventFactory is Administrator {
    address[] public _events;
    uint256 platform_percent = 20;
    uint256 constant public PERCENTS_DIVIDER = 1000;
    event NewEvent(address contractAddress);

    constructor() {
        _owner = msg.sender;
    }

    function allEvents() external view returns (address[] memory) {
        return _events;
    }

    function addEvent(
        string memory name,
        string memory symbol,
        BlocTick.Ticket[] memory tickets
    ) external {
        Event e = new Event(name, symbol, msg.sender);
        e.storeTickets(tickets, msg.sender);
        address eventAddress = address(e);
        _events.push(eventAddress);
        emit NewEvent(eventAddress);
    }

    function setPlatformPercent(uint256 fee) external onlyAdministrator {
        platform_percent = fee;
    }

    function mintTickets(
        address eventContract,
        BlocTick.TicketPurchase[] memory purchases
    ) external payable {
        Event e = Event(eventContract);
        uint256 platform_fee = ((platform_percent * msg.value) / PERCENTS_DIVIDER);
        feesEarned += platform_fee;
        e.purchaseTickets{value: msg.value}(purchases, (msg.value - platform_fee));
    }
}
