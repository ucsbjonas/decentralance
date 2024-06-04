// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Listing} from "../src/Listing.sol";

contract MarketPlace {

    //state variables
    mapping(uint256 => Listing) public listings;

    //constructor
    constructor() {}

    //functions
    function addListing(Listing new_listing) public returns (uint256) {
        uint256 listing_id = uint256(uint160(address(new_listing)));
        listings[listing_id] = new_listing;
        return listing_id;
    }

    function acceptListing(uint256 listing_id) public {
        return;
    }

    function confirmListing(uint256 listing_id) public {
        return;
    }

    function fulfill_current_stage(uint256 listing_id) public returns (bool) {
        return true;
    }

    function pay_current_stage(uint256 listing_id) public returns (bool) {
        return true;
    }

    function listing_lookup(uint256 _listing_id) public view returns (Listing) {
        return listings[_listing_id];
    }
}