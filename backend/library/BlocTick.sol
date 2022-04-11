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
        EventVisibility visibility;
        VenueType venue_type;
        string venue;
        string cover_image_url;
    }
    struct Ticket {
        string name;
        string description;
        TicketType ticket_type;
        uint256 quantity_available;
        uint256 price;
    }
    struct SuccessfulPurchase {
        string purchaseId;
        address buyer;
        uint256 tokenId;
        uint256 ticketId;
        uint256 cost;
    }
    struct TicketPurchase {
        string purchaseId;
        uint256 ticketId;
        string tokenURI;
        address buyer;
        uint256 cost;
    }
    event NewEvent(address);
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
    enum EventVisibility {
        Private,
        Public
    }
}
