// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./EventFactory.sol";
import "./Administrator.sol";

contract Platform is Administrator {
    uint256 platform_percent = 10;

    constructor() {
        _owner = msg.sender;
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

    function setPlatformPercent(uint256 fee) external onlyAdministrator {
        platform_percent = fee;
    }

    function setEventStatus(address eventContract, string memory status)
        external
        onlyAdministrator
    {
        Event(eventContract).setStatus(status);
    }
}
