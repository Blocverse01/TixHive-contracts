// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./BlocTick.sol";

contract Event is ERC721URIStorage {
    uint256 private COUNTER;
    address public _owner;
    uint256 public _created_at;
    string public _status;
    address private _factory;
    BlocTick.Ticket[] public _tickets;
    mapping(uint256 => BlocTick.SuccessfulPurchase) public _sales;
    BlocTick.EventData public _eventData;

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
        string memory ticker,
        address __owner
    ) ERC721(name, ticker) {
        _factory = msg.sender;
        _owner = __owner;
    }

    function _trade(uint256 _id, address __owner) internal {
        _transfer(address(this), __owner, _id); //nft to user
    }

    function purchaseTickets(BlocTick.TicketPurchase[] memory purchases)
        external
        payable
        onlyFactory
    {
        require(msg.value >= _getTotalCost(purchases), "The tickets cost more");
        for (uint256 i = 0; i < purchases.length; i++) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            uint256 _tokenId = COUNTER;
            _mint(address(this), _tokenId);
            COUNTER++;
            _setTokenURI(_tokenId, purchase.tokenURI);
            _sales[_tokenId] = BlocTick.SuccessfulPurchase(
                purchase.purchaseId,
                purchase.owner,
                _tokenId,
                _tickets[purchase.ticketId],
                purchase.cost
            );
            _validate(_tokenId);
            _trade(_tokenId, purchase.owner);
        }
    }

    function setEventData(BlocTick.EventData memory eventData) external {
        _eventData = eventData;
    }

    function _getTotalCost(BlocTick.TicketPurchase[] memory purchases)
        internal
        view
        returns (uint256)
    {
        uint256 total = 0;
        for (uint256 i = 0; i < purchases.length; i++) {
            BlocTick.Ticket memory ticket = _tickets[purchases[i].ticketId];
            if (ticket.ticket_type == BlocTick.TicketType.Donation) {
                continue;
            }
            total += ticket.price;
        }
        return total;
    }

    function storeTickets(BlocTick.Ticket[] memory tickets, address caller)
        external
        onlyFactory
        onlyEventCreator(caller)
    {
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
            _tickets.push(
                BlocTick.Ticket(
                    ticket.name,
                    ticket.description,
                    ticket.ticket_type,
                    ticket.quantity_available,
                    ticket.max_per_order,
                    ticket.price
                )
            );
        }
    }

    function setStatus(string memory __status) external onlyFactory {
        _status = __status;
    }

    function _validate(uint256 _id) internal view returns (bool) {
        require(_exists(_id), "Error, wrong Token id");
        return true;
    }

    function getMyTickets(address caller)
        external
        view
        returns (BlocTick.SuccessfulPurchase[] memory)
    {
        BlocTick.SuccessfulPurchase[]
            memory result = new BlocTick.SuccessfulPurchase[](
                balanceOf(caller)
            );
        uint256 counter = 0;
        if (balanceOf(caller) == 0) {
            return result;
        }
        for (uint256 i = 0; i <= COUNTER; i++) {
            if (ownerOf(i) == caller) {
                result[counter] = _sales[i];
                counter++;
            }
        }
        return result;
    }
}
