// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./Administrator.sol";
import "./BlocTick.sol";

contract EventFactory is Administrator {
    Event[] internal _events;
    uint256 internal platform_percent = 20;
    uint256 private constant PERCENTS_DIVIDER = 1000;
    uint256 public feesEarned;
    event NewEvent(address contractAddress);

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
        emit NewEvent(address(e));
    }

    function setPlatformPercent(uint256 fee) external onlyAdministrator {
        platform_percent = fee;
    }

    function mintTickets(Event e, BlocTick.TicketPurchase[] memory purchases)
        external
        payable
    {
        uint256 platform_fee = ((platform_percent * msg.value) /
            PERCENTS_DIVIDER);
        _owner.transfer(platform_fee);
        feesEarned += platform_fee;
        e.purchaseTickets{value: msg.value - platform_fee}(
            purchases,
            platform_fee
        );
    }
}
