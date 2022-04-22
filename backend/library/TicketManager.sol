// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./BlocTick.sol";

library TicketManager {
    struct Manager {
        BlocTick.Ticket[] _tickets;
        BlocTick.SuccessfulPurchase[] _sales;
    }

    function getTickets(Manager storage manager)
        external
        view
        returns (BlocTick.Ticket[] storage)
    {
        return manager._tickets;
    }

    function getSales(Manager storage manager)
        external
        view
        returns (BlocTick.SuccessfulPurchase[] storage)
    {
        return manager._sales;
    }

    function _storeTickets(
        Manager storage manager,
        BlocTick.Ticket[] memory tickets
    ) external {
        for (uint8 i = 0; i < tickets.length; ) {
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
            unchecked {
                i++;
            }
        }
    }

    function _getTotalCost(
        Manager storage manager,
        BlocTick.TicketPurchase[] memory purchases
    ) internal view returns (uint256 total) {
        for (uint8 i = 0; i < purchases.length; ) {
            BlocTick.Ticket memory ticket = manager._tickets[
                purchases[i].ticketId
            ];
            if (ticket.ticket_type == BlocTick.TicketType.Donation) {
                continue;
            }
            total += ticket.price;
            unchecked {
                i++;
            }
        }
        return total;
    }
}
