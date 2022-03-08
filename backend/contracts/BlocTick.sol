// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

library BlocTick {
    struct EventData {
        string name;
        string ticker;
        string host_name;
        uint256 networkId;
        uint256 event_time;
        string category;
        string description;
        uint256 visibility;
        string cover_image_url;
    }
    struct Ticket {
        string name;
        string description;
        uint256 ticket_type;
        uint256 quantity_available;
        uint256 max_per_order;
        uint256 price;
    }
    struct SuccessfulPurchase {
        uint256 id;
        address owner;
        uint256 ticketId;
    }
    struct TicketPurchase {
        uint256 ticketId;
        string tokenURI;
        address owner;
    }
    event NewEvent(address contractAddress);
    modifier restrictedTo(address _owner, string memory message) {
        require(msg.sender == _owner, message);
        _;
    }
}
