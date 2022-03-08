// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./Administrator.sol";

contract EventFactory is Administrator {
    Event[] public _events;
    uint256 public_event = 1;
    uint256 private_event = 0;

    function addEvent(
        BlocTick.EventData memory eventData,
        BlocTick.Ticket[] memory tickets
    ) external {
        if (
            eventData.visibility != private_event &&
            eventData.visibility != public_event
        ) {
            eventData.visibility = public_event;
        }
        Event e = new Event(eventData.name, eventData.ticker, msg.sender);
        _events.push(e);
        e.storeTickets(tickets, msg.sender);
    }
}