// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

contract Platform {
    uint256 COUNTER;
    struct TicketCollection{
        uint256 id; 
        string name;
        string ticker;
        string contractAddress;
        string status;
        string owner;
    }

    TicketCollection[] public collections;

    function addCollection(string memory name, string memory ticker, string memory contractAddress, string memory owner) public {
        require(msg.sender == address(this));
        TicketCollection memory newCollection = TicketCollection(COUNTER, name, ticker, contractAddress, "active", owner);
        collections.push(newCollection);
        COUNTER++;
    }

    function getCollections() public view returns (TicketCollection[] memory) {
        return collections;
    }

    function getCollection(uint256 _id) public view returns (TicketCollection memory) {
        return collections[_id];
    }
}