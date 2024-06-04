// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Listing {
    //storage variables
    address public client;
    uint256[2] public amounts; //make it size 2 for now, not sure about workaround for dynammic sized arrays
    uint256[2] public delivery_dates;
    string public description;
    address public contractor;
    bool public accepted;
    bool public fulfilled;
    uint256 public curr_stage;

    //constructor
    constructor(address _client, uint256[2] memory initial_amounts, uint256[2] memory initial_delivery_dates, string memory initial_description) {
        client = _client;
        amounts = initial_amounts;
        delivery_dates = initial_delivery_dates;
        description = initial_description;
        accepted = false;
        fulfilled = false;
        curr_stage = 0;

    }

}