// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

abstract contract TicketCollection {
    function _validate(uint256 _id) virtual internal;
    function _trade(uint256 _id) internal virtual;
}