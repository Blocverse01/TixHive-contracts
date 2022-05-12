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

contract Event is
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    ERC721EnumerableUpgradeable
{
    using Counters for Counters.Counter;
    using TicketManager for TicketManager.Manager;
    Counters.Counter private tokenCounter;
    TicketManager.Manager private ticketManager;

    address public _owner;
    bool public saleIsActive = true;
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
        string memory name,
        string memory symbol,
        address __owner
    ) public initializer {
        _factory = msg.sender;
        _owner = __owner;
        __ERC721_init(name, symbol);
         __Ownable_init();
        transferOwnership(__owner);
    }

    function purchaseTickets(
        BlocTick.TicketPurchase[] memory purchases,
        uint256 platform_fee
    ) external payable onlyFactory {
        require(saleIsActive);
        require(
            msg.value + platform_fee >= ticketManager.getTotalCost(purchases),
            "ERR_UNDERPRICED"
        );
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            ticketManager.stillAvailable(purchase.ticketId);
            uint256 _tokenId = tokenCounter.current();
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
        payable(_owner).transfer(msg.value);
        totalSold += msg.value;
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
        returns (uint256, BlocTick.SuccessfulPurchase[] memory, BlocTick.Ticket[] memory)
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
