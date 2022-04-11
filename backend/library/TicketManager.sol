// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./BlocTick.sol";

library TicketManager {
    struct Manager {
        BlocTick.Ticket[] _tickets;
        mapping(uint256 => BlocTick.SuccessfulPurchase) _sales;
    }

    function getSales(Manager storage manager)
        external
        view
        returns (mapping(uint256 => BlocTick.SuccessfulPurchase) storage _sales)
    {
        return manager._sales;
    }

    function getTickets(Manager storage manager)
        external
        view
        returns (BlocTick.Ticket[] memory _tickets)
    {
        return manager._tickets;
    }

    function _storeTickets(
        Manager storage manager,
        BlocTick.Ticket[] memory tickets
    ) internal {
        for (uint256 i = 0; i < tickets.length; i++) {
            BlocTick.Ticket memory ticket = tickets[i];
            if (
                ticket.ticket_type < BlocTick.TicketType.Free &&
                ticket.ticket_type > BlocTick.TicketType.Donation
            ) {
                ticket.ticket_type = BlocTick.TicketType.Free;
            }
            if (ticket.ticket_type == BlocTick.TicketType.Free) {
                ticket.price = 0;
            }
            manager._tickets.push(ticket);
        }
    }

    function _getTotalCost(
        Manager storage manager,
        BlocTick.TicketPurchase[] memory purchases
    ) internal view returns (uint256 total) {
        for (uint256 i = 0; i < purchases.length; i++) {
            BlocTick.Ticket memory ticket = manager._tickets[
                purchases[i].ticketId
            ];
            if (ticket.ticket_type == BlocTick.TicketType.Donation) {
                continue;
            }
            total += ticket.price;
        }
        return total;
    }
}
