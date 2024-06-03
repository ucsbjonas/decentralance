// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Listing{


//storage variables
address public client;
address public contractor;

uint256[2] public amounts; //make it size 2 for now, not sure about workaround for dynammic sized arrays
uint256[2] public delivery_dates;

string public description;

bool public immutable accepted;
bool public immutable fulfilled;
bool public immutable canceled;
bool public immutable downpayment_satisfy;
bool public immutable client_initiated;

uint256 public curr_stage;
uint256 public downpayment;
uint256 public immutable listing_id;


//constructor
constructor(address _client, uint256[2] memory initial_amounts, uint256[2] memory initial_delivery_dates, string memory initial_description){

}

}