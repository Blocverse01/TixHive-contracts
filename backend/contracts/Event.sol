// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./TicketManager.sol";
import "./BlocTick.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "./EventFactory.sol";

contract Event is
    Initializable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    ERC721EnumerableUpgradeable
{
    using Counters for Counters.Counter;
    using TicketManager for TicketManager.Manager;
    Counters.Counter private tokenCounter;
    TicketManager.Manager private ticketManager;
    uint256 internal PERCENTS_DIVIDER;

    address public _owner;
    bool public saleIsActive;
    uint256 private totalSold;
    address private _factory;

    modifier onlyFactory() {
        require(msg.sender == _factory, "ERR_ACCESS");
        _;
    }

    modifier onlyEventCreator(address caller) {
        require(caller == _owner, "ERR_ACCESS");
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        address __owner
    ) public initializer {
        __ERC721_init(_name, _symbol);
        _factory = msg.sender;
        _owner = __owner;
        PERCENTS_DIVIDER = 1000;
        saleIsActive = true;
        __Ownable_init();
        transferOwnership(__owner);
    }

    function purchaseTickets(BlocTick.TicketPurchase[] memory purchases)
        external
        payable
        onlyFactory
        returns (uint256)
    {
        require(saleIsActive);
        uint256 totalCost = ticketManager.getTotalCost(purchases);
        EventFactory factory = EventFactory(_factory);
        uint256 feesEarned = 0;
        require(msg.value >= totalCost, "ERR_INSUFFICIENT_FUNDS");
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            if (!ticketManager.stillAvailable(purchase.ticketId)) continue;
            uint256 _tokenId = tokenCounter.current();
            uint256 ticketCost = ticketManager.getCost(purchase.ticketId);
            uint256 platform_fee = (factory.platform_percent() * ticketCost) /
                PERCENTS_DIVIDER;
            uint256 creator_fee = ticketCost - platform_fee;
            bool shouldPay = false;
            require(
                msg.value >= ticketCost ||
                    ticketManager.isDonation(purchase.ticketId)
            );
            if (ticketManager.isPaid(purchase.ticketId)) {
                shouldPay = true;
            } else if (
                ticketManager.isDonation(purchase.ticketId) &&
                purchase.cost >= ticketCost
            ) {
                shouldPay = true;
            }
            if (shouldPay) {
                payable(_owner).transfer(creator_fee);
                totalSold += creator_fee;
                payable(factory.owner()).transfer(platform_fee);
                feesEarned += platform_fee;
            }
            _mint(purchase.buyer, _tokenId);
            ticketManager.reduceQty(purchase.ticketId);
            tokenCounter.increment();
            _setTokenURI(_tokenId, purchase.tokenURI);
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
        return feesEarned;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getInfo()
        external
        view
        returns (
            uint256,
            BlocTick.SuccessfulPurchase[] memory,
            BlocTick.Ticket[] memory
        )
    {
        return (totalSold, ticketManager._sales, ticketManager._tickets);
    }

    function storeTickets(BlocTick.Ticket[] memory tickets, address caller)
        external
        onlyFactory
        onlyEventCreator(caller)
    {
        ticketManager._storeTickets(tickets);
    }

    function setSaleIsActive(bool _saleIsActive) external onlyOwner {
        saleIsActive = _saleIsActive;
    }

    function ownerTokens(address caller)
        external
        view
        returns (uint256[] memory)
    {
        uint256 ownerBalance = balanceOf(caller);
        uint256[] memory result = new uint256[](ownerBalance);
        if (ownerBalance == 0) {
            return result;
        }
        for (uint256 i = 0; i < ownerBalance; ) {
            result[i] = tokenOfOwnerByIndex(caller, i);
            unchecked {
                i++;
            }
        }
        return result;
    }
}
