// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

library BlocTick {
    struct EventData {
        string name;
        string ticker;
        string host_name;
        string starts_on;
        string ends_on;
        string category;
        string description;
        uint256 visibility;
        VenueType venue_type;
        string venue;
        string cover_image_url;
    }
    struct Ticket {
        string name;
        string description;
        TicketType ticket_type;
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
    enum VenueType {
        Physical,
        Virtual
    }
    enum TicketType {
        Free,
        Paid,
        Donation
    }
}
