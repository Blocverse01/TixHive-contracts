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
        uint256 price;
        string identifier;
    }

    Ticket[] public tickets;

    constructor(string memory _name, string memory _ticker)
        ERC721(_name, _ticker)
    {
        _owner = msg.sender;
    }

    function mint(
        string memory _tokenURI,
        uint256 _price,
        string memory identifier
    ) public payable returns (bool) {
        uint256 _tokenId = COUNTER;
        Ticket memory newTicket = Ticket(COUNTER, _price, identifier);
        tickets.push(newTicket);
        _mint(address(this), _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        COUNTER++;
         _validate(_tokenId);
        _trade(_tokenId);        
        return true;
    }

    function _validate(uint256 _id) internal {
        require(_exists(_id), "Error, wrong Token id"); //not exists
        Ticket storage ticket = tickets[_id];
        require(msg.value >= ticket.price, "Error, Token costs more"); //costs more
    }

    function _trade(uint256 _id) internal returns (Ticket memory) {
        _transfer(address(this), msg.sender, _id); //nft to user
        payable(_owner).transfer(msg.value); //eth to owner
        Ticket storage ticket = tickets[_id];
        return ticket;
    }

    function buyTicket(uint256 _id) public payable {
        _validate(_id);
        _trade(_id);
    }

    function getTickets() public view returns (Ticket[] memory) {
        return tickets;
    }

    function getOwnerTickets(address _ownerAddress) public view returns (Ticket[] memory) {
        Ticket[] memory result = new Ticket[](balanceOf(_ownerAddress));
        uint256 counter = 0;
        for (uint256 i = 0; i < tickets.length; i++) {
            if (ownerOf(i) == _ownerAddress) {
                result[counter] = tickets[i];
                counter++;
            }
        }
        return result;
    }
}
