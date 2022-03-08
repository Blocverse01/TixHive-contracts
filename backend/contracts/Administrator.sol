// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

abstract contract Administrator {
    address public _owner;
    modifier onlyAdministrator() {
        require(msg.sender == _owner, "Access restricted!");
        _;
    }
}
