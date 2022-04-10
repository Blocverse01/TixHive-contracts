// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";

contract EventFactory {
    Event[] public _events;
    uint256 EVENT_COUNTER;
    enum EventVisibility {
        Private,
        Public
    }

    function allEvents() public view returns (Event[] memory) {
        return _events;
    }

    function addEvent(
        BlocTick.EventData memory eventData,
        BlocTick.Ticket[] memory tickets
    ) external returns (Event) {
        if (
            eventData.visibility != EventVisibility.Private &&
            eventData.visibility != EventVisibility.Public
        ) {
            eventData.visibility = EventVisibility.Public;
        }
        Event e = new Event(eventData.name, eventData.ticker, msg.sender);
        e.storeTickets(tickets, msg.sender);
        e.setEventData(eventData);
        _events.push(e);
        return e;
    }
}
