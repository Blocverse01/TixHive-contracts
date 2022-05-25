// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721RoyaltyUpgradeable.sol";
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
    ERC721EnumerableUpgradeable,
    ERC721RoyaltyUpgradeable
{
    using Counters for Counters.Counter;
    using TicketManager for TicketManager.Manager;
    Counters.Counter private tokenCounter;
    TicketManager.Manager private ticketManager;

    address public _owner;
    bool public saleIsActive;
    uint256 private totalSold;
    int256 public paymentMethod;
    address private _factory;

    modifier onlyFactory() {
        require(msg.sender == _factory, "ERR_ACCESS");
        _;
    }

    modifier onlyEventCreator(address caller) {
        require(caller == _owner, "ERR_ACCESS");
        _;
    }

    function isApprovedForAll(address __owner, address _operator)
        public
        view
        override(ERC721Upgradeable, IERC721Upgradeable)
        returns (bool isOperator)
    {
        // if OpenSea's ERC721 Proxy Address is detected, auto-return true
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return ERC721Upgradeable.isApprovedForAll(__owner, _operator);
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        address __owner,
        int256 _paymentMethod
    ) public initializer {
        __ERC721_init(_name, _symbol);
        _factory = msg.sender;
        _owner = __owner;
        paymentMethod = _paymentMethod >= 0 ? _paymentMethod : -1;
        saleIsActive = true;
        __Ownable_init();
        transferOwnership(__owner);
        _setDefaultRoyalty(__owner, 1000);
    }

    function mintTicket(
        BlocTick.TicketPurchase memory purchase,
        uint256 creator_fee
    ) public onlyFactory {
        uint256 _tokenId = tokenCounter.current();
        _mint(purchase.buyer, _tokenId);
        ticketManager.reduceQty(purchase.ticketId);
        tokenCounter.increment();
        _setTokenURI(_tokenId, purchase.tokenURI);
        ticketManager._sales.push(
            BlocTick.SuccessfulPurchase(
                purchase.buyer,
                _tokenId,
                purchase.ticketId,
                purchase.cost
            )
        );
        totalSold += creator_fee;
    }

    /* function purchaseTickets(BlocTick.TicketPurchase[] memory purchases)
        external
        payable
        onlyFactory
        returns (uint256)
    {
        uint256 totalCost = ticketManager.getTotalCost(purchases);
        EventFactory factory = EventFactory(_factory);
        address factoryDeployer = factory.owner();
        uint256 feesEarned;
        require(msg.value >= totalCost, "ERR_INSUFFICIENT_FUNDS");
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            if (!ticketManager.stillAvailable(purchase.ticketId)) continue;
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
                if (paymentMethod >= 0) {
                    factory.handlePayment(
                        _owner,
                        uint256(paymentMethod),
                        creator_fee
                    );
                    factory.handlePayment(
                        factory.owner(),
                        uint256(paymentMethod),
                        platform_fee
                    );
                } else {
                    payable(_owner).transfer(creator_fee);
                    payable(factoryDeployer).transfer(platform_fee);
                }
                feesEarned += platform_fee;
            }

            unchecked {
                i++;
            }
        }
        return feesEarned;
    } */

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(
            ERC721Upgradeable,
            ERC721URIStorageUpgradeable,
            ERC721RoyaltyUpgradeable
        )
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
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721RoyaltyUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getInfo()
        external
        view
        returns (
            uint256,
            BlocTick.Ticket[] memory,
            BlocTick.SuccessfulPurchase[] memory
        )
    {
        return (totalSold, ticketManager._tickets, ticketManager._sales);
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
