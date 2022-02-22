// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CustomNFTContract is ERC721URIStorage, Ownable {
    address public _owner;
    uint256 COUNTER;

    struct Ticket {
        uint256 id;
        uint price;
    }
    
    Ticket[] public tickets;

    constructor(string memory _name, string memory _ticker) ERC721(_name, _ticker) {
        _owner = msg.sender;
    }
    
    function mint(string memory _tokenURI, uint _price) public onlyOwner returns (bool) {
        uint _tokenId = COUNTER;    
        Ticket memory newTicket = Ticket(COUNTER, _price);
        tickets.push(newTicket);
        _mint(address(this), _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        COUNTER++;
        return true;
    }

    function buyTicket(uint _id) public returns (bool) {
        
    }

    function getTickets() public view returns (Ticket[] memory) {
        return tickets;
    }    
}
