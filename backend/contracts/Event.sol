// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./TicketManager.sol";
import "./BlocTick.sol";
import "./Enumerable.sol";

contract Event is ERC721URIStorage {
    using Counters for Counters.Counter;
    using TicketManager for TicketManager.Manager;
    using Enumerable for Enumerable.Enumerator;
    Counters.Counter private tokenCounter;
    TicketManager.Manager private ticketManager;
    Enumerable.Enumerator private enumerator;

    address public _owner;
    bool public saleIsActive = true;
    uint256 private totalSold;
    address private _factory;

    modifier onlyFactory() {
        require(msg.sender == _factory, "Access denied");
        _;
    }

    modifier onlyEventCreator(address caller) {
        require(caller == _owner, "Access denied");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address __owner
    ) ERC721(name, symbol) {
        _factory = msg.sender;
        _owner = __owner;
    }

    function purchaseTickets(
        BlocTick.TicketPurchase[] memory purchases,
        uint256 platform_fee
    ) external payable onlyFactory {
        require(saleIsActive);
        require(
            msg.value + platform_fee >= ticketManager.getTotalCost(purchases),
            "Less"
        );
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            uint256 _tokenId = tokenCounter.current();
            _mint(address(this), _tokenId);
            tokenCounter.increment();
            _setTokenURI(_tokenId, purchase.tokenURI);
            _transfer(address(this), purchase.buyer, _tokenId); //nft to user
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
        payable(_owner).transfer(msg.value);
        totalSold += msg.value;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to && from != address(0)) {
            enumerator._removeTokenFromOwnerEnumeration(
                from,
                tokenId,
                balanceOf(from)
            );
        }
        if (to != from && to != address(0)) {
            enumerator._addTokenToOwnerEnumeration(to, tokenId, balanceOf(to));
        }
    }

    function getInfo()
        external
        view
        returns (uint256, BlocTick.SuccessfulPurchase[] memory)
    {
        return (totalSold, ticketManager.getSales());
    }

    function storeTickets(BlocTick.Ticket[] memory tickets, address caller)
        external
        onlyFactory
        onlyEventCreator(caller)
    {
        ticketManager._storeTickets(tickets);
    }

    function setSaleIsActive(bool _saleIsActive)
        external
        onlyEventCreator(msg.sender)
    {
        saleIsActive = _saleIsActive;
    }

    function ownerTokens(address caller)
        external
        view
        returns (uint256[] memory)
    {
        uint256 callerBalance = balanceOf(caller);
        uint256[] memory result = new uint256[](callerBalance);
        if (callerBalance == 0) {
            return result;
        }
        for (uint256 i = 0; i < callerBalance; ) {
            result[i] = enumerator._ownedTokens[caller][i];
            unchecked {
                i++;
            }
        }
        return result;
    }
}
