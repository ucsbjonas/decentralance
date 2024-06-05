// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Listing} from "../src/Listing.sol";

contract MarketPlace {

    //state variables
    mapping(uint256 => Listing) public listings;

    //constructor
    constructor() {}

    function addListing(Listing new_listing) public returns (uint256) {}
    function acceptListing(uint256 listing_id) public {}
    function fufill_current_stage(uint256 listing_id) public returns (bool) {}
    function pay_current_stage(uint256 listing_id) public returns (bool) {}
    function listing_lookup(uint256 _listing_id) public view returns (Listing) {return listings[_listing_id];}

    //functions
    function addListing(Listing new_listing) public returns (uint256) {
        uint256 listing_id = uint256(uint160(address(new_listing)));
        listings[listing_id] = new_listing;
        return listing_id;
    }


    function acceptListing(uint256 listing_id) public {
        Listing listing = listings[listing_id];
        listing.acceptListing(msg.sender);
    }

    function confirmListing(uint256 listing_id) public {
        Listing listing = listings[listing_id];
        listing.fulfill_current_stage();
    }

    function fulfill_current_stage(uint256 listing_id) public returns (bool) {
        Listing listing = listings[listing_id];
        listing.fulfill_current_stage();
        return true;
    }

    function pay_current_stage(uint256 listing_id) public payable returns (bool) {
        Listing listing = listings[listing_id];
        listing.pay_current_stage{value: msg.value}();
        return true;
    }

    function listing_lookup(uint256 _listing_id) public view returns (Listing) {
        return listings[_listing_id];
    }
}