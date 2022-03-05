// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Event is ERC721URIStorage, Ownable {
    address public _owner;
    uint256 private COUNTER;
    string private _category;
    uint256 private _network_id;
    string private _visibility;
    string private _cover_image_url;
    string private _description;

    struct Ticket {
        string name;
        string description;
        string ticket_type;
        uint256 quantity_available;
        uint256 max_per_order;
        uint256 price;
    }
    Ticket[] private _tickets;
    struct TicketPurchase {
        uint256 ticketId;
        string tokenURI;
        address owner;
    }
    struct SuccessfulPurchase {
        uint256 id;
        address owner;
        uint256 ticketId;
    }
    SuccessfulPurchase[] _sales;

    constructor(
        string memory _name,
        string memory _ticker,
        uint256 _networkId,
        Ticket[] memory tickets
    ) ERC721(_name, _ticker) {
        _owner = msg.sender;
        _network_id = _networkId;
        storeTickets(tickets);
    }

    function _trade(uint256 _id, address owner) internal {
        _transfer(address(this), owner, _id); //nft to user
    }

    function mint(TicketPurchase[] memory purchases) public payable {
        uint256 totalCost = _getTotalCost(purchases);
        require(msg.value >= totalCost, "The tickets cost more");
        for (uint256 i = 0; i < purchases.length; i++) {
            TicketPurchase memory purchase = purchases[i];
            uint256 _tokenId = COUNTER;
            _mint(address(this), _tokenId);
            _setTokenURI(_tokenId, purchase.tokenURI);
            SuccessfulPurchase memory sale = SuccessfulPurchase(
                _tokenId,
                purchase.owner,
                purchase.ticketId
            );
            _sales.push(sale);
            _validate(_tokenId);
            _trade(_tokenId, purchase.owner);
            COUNTER++;
        }
        payable(_owner).transfer(msg.value); //eth to owner
    }

    function category() public view returns (string memory) {
        return _category;
    }

    function network() public view returns (uint256) {
        return _network_id;
    }

    function visibility() public view returns (string memory) {
        return _visibility;
    }

    function cover_image_url() public view returns (string memory) {
        return _cover_image_url;
    }

    function created_tickets() public view returns (Ticket[] memory) {
        return _tickets;
    }

    function _getTotalCost(TicketPurchase[] memory purchases)
        internal
        view
        returns (uint256)
    {
        uint256 total = 0;
        for (uint256 i = 0; i < purchases.length; i++) {
            Ticket memory ticket = _tickets[purchases[i].ticketId];
            total += ticket.price;
        }
        return total;
    }

    function storeTickets(Ticket[] memory tickets) public {
        for (uint256 i = 0; i < tickets.length; i++) {
            Ticket memory ticket = tickets[i];

            bool isNotPaid = keccak256(abi.encodePacked(ticket.ticket_type)) !=
                keccak256(abi.encodePacked("paid"));
            bool isNotFree = keccak256(abi.encodePacked(ticket.ticket_type)) !=
                keccak256(abi.encodePacked("free"));

            if (isNotFree && isNotPaid) {
                ticket.ticket_type = "free";
            }

            if (
                keccak256(abi.encodePacked(ticket.ticket_type)) ==
                keccak256(abi.encodePacked("free"))
            ) {
                ticket.price = 0;
            }

            _tickets.push(
                Ticket(
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

    function _validate(uint256 _id) internal view returns (bool) {
        require(_exists(_id), "Error, wrong Token id");
        return true;
    }

    function getTicketsForAddress(address _address)
        public
        view
        returns (SuccessfulPurchase[] memory)
    {
        SuccessfulPurchase[] memory result = new SuccessfulPurchase[](
            balanceOf(_address)
        );
        uint256 counter = 0;
        for (uint256 i = 0; i < _sales.length; i++) {
            if (ownerOf(i) == _address) {
                result[counter] = _sales[i];
                counter++;
            }
        }
        return result;
    }
}
