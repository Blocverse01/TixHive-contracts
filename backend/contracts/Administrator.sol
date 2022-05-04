// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

abstract contract Administrator {
    address payable internal _owner;

    constructor() {
        _owner = payable(msg.sender);
    }

    modifier onlyAdministrator() {
        require(payable(msg.sender) == _owner, "No access");
        _;
    }
}
