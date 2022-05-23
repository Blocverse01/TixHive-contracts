// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "./Event.sol";
import "./BlocTick.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract EventFactory is Ownable {
    Event[] internal _events;
    address immutable tokenImplementation;
    uint256 public platform_percent = 50;
    uint256 public feesEarned;
    string private platform_auth_key;
    event NewEvent(address contractAddress);
    ERC20PaymentMethods[] erc20PaymentMethods;
    struct ERC20PaymentMethods {
        IERC20 implementation;
        string symbol;
    }

    constructor(address _tokenImplementation, string memory _platform_auth_key)
    {
        tokenImplementation = _tokenImplementation;
        platform_auth_key = _platform_auth_key;
    }

    function allEvents() external view returns (Event[] memory) {
        return _events;
    }

    function addEvent(
        string memory name,
        string memory symbol,
        BlocTick.Ticket[] memory tickets,
        uint256 paymentMethod
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
        feesEarned += e.purchaseTickets{value: msg.value}(purchases);
    }

    function handlePayment(
        address _sendto,
        int256 paymentMethod,
        uint256 value
    ) public payable {
        if (paymentMethod >= 0) {
            erc20PaymentMethods[uint256(paymentMethod)].implementation.transfer(
                    _sendto,
                    value
                );
        } else {
            payable(_sendto).transfer(value);
        }
    }
}
