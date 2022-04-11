// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";

contract EventFactory {
    Event[] public _events;

    function allEvents() public view returns (Event[] memory) {
        return _events;
    }

    function addEvent(
        BlocTick.EventData memory eventData,
        BlocTick.Ticket[] memory tickets
    ) external returns (Event) {
        if (
            eventData.visibility < BlocTick.EventVisibility.Private &&
            eventData.visibility > BlocTick.EventVisibility.Public
        ) {
            eventData.visibility = BlocTick.EventVisibility.Public;
        }
        Event e = new Event(eventData.name, eventData.ticker, msg.sender);
        e.storeTickets(tickets, msg.sender);
        e.setEventData(eventData);
        _events.push(e);
        return e;
    }
}
