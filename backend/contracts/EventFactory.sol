// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";

contract EventFactory {
    Event[] _events;

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
}
