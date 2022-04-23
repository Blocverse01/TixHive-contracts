// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./Administrator.sol";

contract EventFactory is Administrator {
    Event[] _events;
    uint256 platform_percent = 10;

    function allEvents() external view returns (Event[] memory) {
        return _events;
    }

    function addEvent(
        string memory name,
        string memory symbol,
        BlocTick.Ticket[] memory tickets
    ) external {
        Event e = new Event(name, symbol, msg.sender);
        e.storeTickets(tickets, msg.sender);
        _events.push(e);
        emit BlocTick.NewEvent(address(e));
    }

    function setPlatformPercent(uint256 fee) external onlyAdministrator {
        platform_percent = fee;
    }

    function mintTickets(
        address eventContract,
        BlocTick.TicketPurchase[] memory purchases
    ) external payable {
        Event e = Event(eventContract);
        e.purchaseTickets(purchases);
        uint256 platform_fee = (platform_percent / 100) * msg.value;
        payable(e._owner()).transfer(msg.value - platform_fee);
        payable(_owner).transfer(platform_fee);
    }
}
