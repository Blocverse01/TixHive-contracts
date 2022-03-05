// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

contract Platform {
    uint256 COUNTER;
    struct Event {
        uint256 id;
        string name;
        string ticker;
        string contractAddress;
        string status;
        string owner;
        string description;
    }

    Event[] _events;

    function addEvent(
        string memory name,
        string memory ticker,
        string memory contractAddress,
        string memory owner,
        string memory description
    ) public {
        require(msg.sender == address(this));
        Event memory newEvent = Event(
            COUNTER,
            name,
            ticker,
            contractAddress,
            "active",
            owner,
            description
        );
        _events.push(newEvent);
        COUNTER++;
    }

    function getEvents() public view returns (Event[] memory) {
        return _events;
    }

    function getEvents(uint256 _id) public view returns (Event memory) {
        return _events[_id];
    }
}
