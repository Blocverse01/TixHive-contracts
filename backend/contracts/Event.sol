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
    uint256 public _created_at;
    string public _status;
    address private _factory;
    BlocTick.EventData _eventData;

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
        require(
            msg.value >= ticketManager._getTotalCost(purchases),
            "The tickets cost more"
        );
        for (uint256 i = 0; i < purchases.length; i++) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            uint256 _tokenId = tokenCounter.current();
            _mint(address(this), _tokenId);
            tokenCounter.increment();
            _setTokenURI(_tokenId, purchase.tokenURI);
            ticketManager._sales[_tokenId] = BlocTick.SuccessfulPurchase(
                purchase.purchaseId,
                purchase.buyer,
                _tokenId,
                purchase.ticketId,
                purchase.cost
            );
            _validate(_tokenId);
            _trade(_tokenId, purchase.buyer);
        }
    }

    function setEventData(BlocTick.EventData memory eventData) external {
        _eventData = eventData;
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

    function _validate(uint256 _id) internal view returns (bool) {
        require(_exists(_id), "Error, wrong Token id");
        return true;
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
        for (uint256 i = 0; i <= tokenCounter.current(); i++) {
            if (ownerOf(i) == caller) {
                result[counter] = ticketManager._sales[i];
                counter++;
            }
        }
        return result;
    }
}
