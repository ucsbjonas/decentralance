// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {Listing} from "../src/Listing.sol";
import "forge-std/Vm.sol";
contract VariousTest is Test{

    MarketPlace public marketPlace;
    Listing public new_listing;

    address contractor = address(0x10);
    address client = address(0x11);

    uint256[] public amounts;
    uint256[] public delivery_dates;

    uint256 listing_id;
    function setUp() public {

        vm.deal(contractor, 100 ether);
        vm.deal(client, 100 ether);

        marketPlace = new MarketPlace();

        amounts.push(1 ether);
        amounts.push(5 ether);
        delivery_dates.push(vm.getBlockTimestamp() + 100);
        delivery_dates.push(vm.getBlockTimestamp() + 250);


        //struct contractor/client
        // address of the client/contractor  (address)
        // orders fufilled / fully payed for (int)
        // orders accepted and not fufilled / confirmed but not paid fully (past the deadline) (int)

        marketPlace.add_contractor(address(contractor));
        marketPlace.add_client(address(client));
        //create listing
        vm.startBroadcast(client);
        new_listing = new Listing(msg.sender, 
                                amounts,
                                delivery_dates,
                                "a commission for you");
        listing_id = marketPlace.addListing(new_listing);
        vm.stopBroadcast();
        //contractor accepts
        vm.startBroadcast(contractor);
        marketPlace.acceptListing(listing_id);
        vm.stopBroadcast();
        //client confirms
        vm.startBroadcast(client);
        marketPlace.confirmListing(listing_id, address(contractor));
        vm.stopBroadcast(contractor);
    }
    //does the two parties' balance change correctly?
    function balance_update() public {
        vm.startBroadcast(contractor);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast(contractor);

        vm.startBroadcast(client);
        bool success1 = marketPlace.pay_current_stage(listing_id);
        assertEq(client.balance() == 100 ether - 1 ether);
        assertEx(contractor.balance() == 100 ether + 1 ether);
        vm.stopBroadcast();
    }
    //test not ontime delivery by the contractor
    function test_late_devliery() public{

        vm.startBroadcast(contractor);
        vm.warp(vm.getBlockTimestamp() + 101);
        vm.expectRevert(CustomError.Late_Fufill);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast(contractor);

    }

    //test noontime payment by the client

    function test_late_payment() public {

        vm.startBroadcast(contractor);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        vm.warp(vm.getBlockTimestamp() + 101);
        vm.expectRevert(CustomError.Late_Payment);
        bool success1 = marketPlace.pay_current_stage{value: 1 ether}(listing_id);
        vm.stopBroadcast();

    }

    //test client can extend delivery date
    function test_extend_delivery_dates() public {

        vm.startBroadcast(client);
        stage = 0; new_date = vm.getBlockTimestamp() + 150;
        marketPlace.extend_delivery_date(listing_id, stage, new_date);
        vm.stopBroadcast();

        vm.startBroadcast(contractor);
        vm.warp(vm.getBlockTimestamp() + 149);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        assertEq(success, true);
        vm.stopBroadcast();


    }
    function test_overpayment() public{

        vm.startBroadcast(contractor);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        bool success = marketPlace.pay_current_stage{value: 2 ether}(listing_id);
        assertEq(client.balance() == 100 ether - 1 ether);
        assertEx(contractor.balance() == 100 ether + 1 ether);
        vm.stopBroadcast();

    }
    function test_underpayment() public {

        vm.startBroadcast(contractor);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        bool success = marketPlace.pay_current_stage{value: 0.99 ether}(listing_id);
        vm.expectRevert(CustomError.Insufficient_Fund);
        vm.stopBroadcast();

    }

    //optional: client can make an initial downpayment
    function test_downpayment() public {}

    //client deletes listing, and check action cannot be taken on deleted listing
    // a deleted listing is marked with curr_stage = type(uint256).max
    function test_deletelisting_client() public {

        vm.startBroadcast(client);
        _abandon_count = marketPlace.client_lookup(address(client)).abandon_count;

        marketPlace.delete_listing(listing_id);
        deleted_listing = marketPlace.listing_lookup(listing_id);
        assertEq(deleted_listing.curr_stage, type(uint256).max);
        assertEq(marketPlace.client_lookup(address(client).abandon_count), _abandon_count + 1);
        vm.stopBroadcast();

        vm.startBroadcast(contractor);
        vm.expectRevert(CustomError.Deleted_Listing);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

    }

    function test_deletelisting_contractor() public {

        vm.startBroadcast(contractor);
        _abandon_count = marketPlace.contractor_lookup(address(contractor)).abandon_count;

        marketPlace.delete_listing(listing_id);
        deleted_listing = marketPlace.listing_lookup(listing_id);
        assertEq(deleted_listing.curr_stage, type(uint256).max);
        assertEq(marketPlace.contractor_lookup(address(contractor).abandon_count), _abandon_count + 1);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        vm.expectRevert(CustomError.Deleted_Listing);
        bool success = marketPlace.pay_current_stage{value: 100 ether}(listing_id);
        vm.stopBroadcast();

    }
    //fufill track 1 spec
    function test_transferlisting_newclient() public {
        address new_client = address(0x12);
        vm.startBroadcast(client);
        marketPlace.transfer_listing_new_client(listing_id, new_client);
        assertEq(marketPlace.listing_lookup(listing_id).client, new_client);
        vm.stopBroadcast();

    }

    //fufill track 1 spec
    function test_transferlisting_newclient() public {
        address new_contractor = address(0x14);
        vm.startBroadcast(client);
        marketPlace.transfer_listing_contractor(listing_id, new_contractor);
        assertEq(marketPlace.listing_lookup(listing_id).contractor, new_contractor);
        vm.stopBroadcast();


    }
    function test_contractor_attributeupdate_fufill() public {

        //go through a full cycle and increment orders fufilled

    }
    function test_client_attributeupdate_fullpayment() public {

        //go through a full cycle and increment orders fully paid

    }

    //test that only the one and only client associated with the listing can make certain calls
    function test_wrong_client() public {


    //test that only the one and only client associated with the listing can make certain calls 
    }
    function test_wrong_contractor() public {



    }
    function test_no_ethtransfer_toMarketPlace () public {



    }
    function test_no_ethtransfer_Listing() public {



    }
    //test the last two specifications (the others are implied)
    // Items purchased by a buyer can be put on sell again.
    function test_cancel_listing() public{

    }
    // Within the same block, if one or more buyers pay for the same item, the one who pays more will eventually own it.
    function test_same_block() public{

    }

    function test_reentrancy_fufill() public {


    }

    function test_reentrancy_payment() public {

        
    }
}
