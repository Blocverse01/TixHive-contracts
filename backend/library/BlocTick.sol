// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

library BlocTick {
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
        uint8 ticketId;
        uint256 cost;
    }
    struct TicketPurchase {
        string purchaseId;
        uint8 ticketId;
        string tokenURI;
        address buyer;
        uint256 cost;
    }
    event NewEvent(address);
    enum TicketType {
        Free,
        Paid,
        Donation
    }
}
