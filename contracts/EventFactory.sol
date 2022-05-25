// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./BlocTick.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./TicketManager.sol";

contract EventFactory is Ownable {
    Event[] internal _events;
    address immutable tokenImplementation;
    uint256 public platform_percent = 500;
    uint256 public feesEarned;
    bytes32 private platform_auth_key =
        0xbe2b55d62d0b934d235dae24ceddc97da4742c3b8603eecd163b78f3763334a1;
    event NewEvent(address contractAddress);
    uint256 internal PERCENTS_DIVIDER = 10000;
    ERC20PaymentMethods[] public erc20PaymentMethods;
    struct ERC20PaymentMethods {
        IERC20 implementation;
        string symbol;
    }

    constructor(address _tokenImplementation) {
        tokenImplementation = _tokenImplementation;
    }

    function allEvents() external view returns (Event[] memory) {
        return _events;
    }

    function addEvent(
        string memory name,
        string memory symbol,
        BlocTick.Ticket[] memory tickets,
        int256 paymentMethod
    ) external {
        address clone = Clones.clone(tokenImplementation);
        Event e = Event(clone);
        e.initialize(name, symbol, msg.sender, paymentMethod);
        e.storeTickets(tickets, msg.sender);
        _events.push(e);
        emit NewEvent(clone);
    }

    function setPlatformPercent(uint256 fee) external onlyOwner {
        platform_percent = fee;
    }

    function mintTickets(
        string memory auth_key,
        Event e,
        BlocTick.TicketPurchase[] memory purchases
    ) external payable {
        require((sha256(bytes(auth_key)) == platform_auth_key), "ERR_ACCESS");
        require(e.saleIsActive());
        BlocTick.Ticket[] memory availableTickets;
        (, availableTickets, ) = e.getInfo();
        uint256 totalCost = getPurchasesCost(purchases, availableTickets);
        require(msg.value >= totalCost, "ERR_INSUFFICIENT_FUNDS");
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.TicketPurchase memory purchase = purchases[i];
            BlocTick.Ticket memory ticket = availableTickets[purchase.ticketId];
            if ((ticket.quantity_available > 0) != true) continue;
            uint256 ticketCost = ticket.price;
            uint256 platform_fee = (platform_percent * ticketCost) /
                PERCENTS_DIVIDER;
            uint256 creator_fee = ticketCost - platform_fee;
            bool shouldPay = false;
            require(
                msg.value >= ticketCost ||
                    ticket.ticket_type == BlocTick.TicketType.Donation
            );
            if (ticket.ticket_type == BlocTick.TicketType.Paid) {
                shouldPay = true;
            } else if (
                (ticket.ticket_type == BlocTick.TicketType.Donation) &&
                purchase.cost >= ticketCost
            ) {
                shouldPay = true;
            }
            if (shouldPay) {
                uint256 paymentMethod = uint256(e.paymentMethod());
                if (paymentMethod >= 0) {
                    IERC20 erc20PaymentToken = erc20PaymentMethods[
                        paymentMethod
                    ].implementation;
                    transferERC20(erc20PaymentToken, e.owner(), creator_fee);
                    transferERC20(
                        erc20PaymentToken,
                        Ownable.owner(),
                        platform_fee
                    );
                } else {
                    payable(e.owner()).transfer(creator_fee);
                    payable(Ownable.owner()).transfer(platform_fee);
                }
                feesEarned += platform_fee;
            }
            e.mintTicket(purchase, shouldPay ? creator_fee : 0);
            unchecked {
                i++;
            }
        }
    }

    function getPurchasesCost(
        BlocTick.TicketPurchase[] memory purchases,
        BlocTick.Ticket[] memory tickets
    ) internal pure returns (uint256 total) {
        for (uint256 i = 0; i < purchases.length; ) {
            BlocTick.Ticket memory ticket = tickets[purchases[i].ticketId];
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

    function transferERC20(
        IERC20 token,
        address to,
        uint256 amount
    ) public {
        require(
            amount <= token.balanceOf(msg.sender),
            "ERR_INSUFFICIENT_FUNDS"
        );
        address from = msg.sender;
        token.transferFrom(from, to, amount);
    }

    function addERC20PaymentMethod(IERC20 implementation, string memory symbol)
        external
        onlyOwner
    {
        erc20PaymentMethods.push(
            ERC20PaymentMethods(IERC20(implementation), symbol)
        );
    }
}
