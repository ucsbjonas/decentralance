// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Listing} from "../src/Listing.sol";

contract MarketPlace {
    struct ClientInfo{
        uint256 abandon_count;
        uint256 fullpay_count;
        uint256 total_paid; //in eth
    }
    struct ContractorInfo{
        uint256 abandon_count;
        uint256 fufilled_count;
        uint256 amount_earned;
    }

    //state variables
    mapping(uint256 => Listing) public listings;
    mapping(address => ClientInfo) public clients;
    mapping(address => ContractorInfo) public contractors;

    //errors
    error LateFulfill();
    error LatePayment();
    error InsufficientFund();
    error DeletedListing();
    error WrongClient();
    error WrongContractor();

    //constructor
    constructor() {}

    //functions (virtual to mark not implemented)
    function add_contractor(address _contractor) public {}
    function add_client(address _client) public {}
    function extend_delivery_date(uint256 listing_id, uint256 stage, uint256 new_date) public {}
    function client_lookup(address client) public returns(ClientInfo memory c){}
    function contractor_lookup(address contractor) public returns(ContractorInfo memory c){}
    function delete_listing(uint256 listing_id) public {}
    function transfer_listing_new_client(uint256 listing_id, address new_client) public {}
    function transfer_listing_contractor(uint256 listing_id, address new_contractor) public {}
    function totalValue(uint256 listing_id) public returns(uint256) {}




    function addListing(Listing new_listing) public returns (uint256) {
        uint256 listing_id = uint256(uint160(address(new_listing)));
        listings[listing_id] = new_listing;
        return listing_id;
    }


    function acceptListing(uint256 listing_id) public {
        Listing listing = listings[listing_id];
        listing.acceptListing(msg.sender);
    }

    function confirmListing(uint256 listing_id, address confirm_addr) public {
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