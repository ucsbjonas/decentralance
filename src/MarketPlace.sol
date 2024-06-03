// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Listing} from "../src/Listing.sol";

contract MarketPlace{

    //state variables
    mapping(uint256 => Listing) public listings;

    //constructor
    constructor(){}

    function addListing(Listing new_listing) public returns (uint256) {}
    function acceptListing(uint256 listing_id) public {}
    function confirmListing(uint256 listing_id) public {}
    function fufill_current_stage(uint256 listing_id) public returns (bool) {}
    function pay_current_stage(uint256 listing_id) public returns (bool) {}
    function listing_lookup(uint256 _listing_id) public view returns (Listing) {return listings[_listing_id];}


    
}