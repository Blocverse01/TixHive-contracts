// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./BlocTick.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract EventFactory is Ownable {
    Event[] internal _events;
    address immutable tokenImplementation;
    uint256 public platform_percent = 50;
    uint256 public feesEarned;
    event NewEvent(address contractAddress);

    constructor(address _tokenImplementation) {
        tokenImplementation = _tokenImplementation;
    }

    function allEvents() external view returns (Event[] memory) {
        return _events;
    }

    function addEvent(
        string memory name,
        string memory symbol,
        BlocTick.Ticket[] memory tickets
    ) external {
        address clone = Clones.clone(tokenImplementation);
        Event e = Event(clone);
        e.initialize(name, symbol, msg.sender);
        e.storeTickets(tickets, msg.sender);
        _events.push(e);
        emit NewEvent(clone);
    }

    function setPlatformPercent(uint256 fee) external onlyOwner {
        platform_percent = fee;
    }

    function mintTickets(Event e, BlocTick.TicketPurchase[] memory purchases)
        external
        payable
    {
        feesEarned += e.purchaseTickets{value: msg.value}(purchases);
    }
}
