// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../library/TicketManager.sol";

contract Event is ERC721URIStorage {
    using Counters for Counters.Counter;
    using TicketManager for TicketManager.Manager;
    Counters.Counter tokenCounter;
    TicketManager.Manager ticketManager;
    address public _owner;
    string public _status;
    address public _factory;

    modifier onlyFactory() {
        require(msg.sender == _factory, "You need to use the factory");
        _;
    }

    modifier onlyEventCreator(address caller) {
        require(caller == _owner, "Access restricted!");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address __owner
    ) ERC721(name, symbol) {
        _factory = msg.sender;
        _owner = __owner;
        _status = "active";
    }

    function purchaseTickets(BlocTick.TicketPurchase[] memory purchases)
        external
        payable
    {
        require(
            msg.value >= ticketManager._getTotalCost(purchases),
            "The tickets cost more"
        );
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            uint256 _tokenId = tokenCounter.current();
            _safeMint(address(this), _tokenId);
            tokenCounter.increment();
            _setTokenURI(_tokenId, purchase.tokenURI);
            safeTransferFrom(address(this), purchase.buyer, _tokenId); //nft to user
            ticketManager._sales.push(
                BlocTick.SuccessfulPurchase(
                    purchase.purchaseId,
                    purchase.buyer,
                    _tokenId,
                    purchase.ticketId,
                    purchase.cost
                )
            );
            unchecked {
                i++;
            }
        }
    }

    function getEventTickets()
        external
        view
        returns (BlocTick.Ticket[] memory)
    {
        return ticketManager.getTickets();
    }

    function storeTickets(BlocTick.Ticket[] memory tickets, address caller)
        external
        onlyFactory
        onlyEventCreator(caller)
    {
        ticketManager._storeTickets(tickets);
    }

    function setStatus(string memory __status) external onlyFactory {
        _status = __status;
    }

    function getMyTickets(address caller)
        external
        view
        returns (BlocTick.SuccessfulPurchase[] memory result)
    {
        uint256 counter = 0;
        if (balanceOf(caller) == 0) {
            return result;
        }
        for (uint256 i = 0; i <= tokenCounter.current(); ) {
            BlocTick.SuccessfulPurchase memory sale = ticketManager._sales[i];
            if (ownerOf(sale.tokenId) == caller) {
                result[counter] = sale;
                unchecked {
                    counter++;
                }
            }
            unchecked {
                i++;
            }
        }
        return result;
    }
}
