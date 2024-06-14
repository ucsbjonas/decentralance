// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {Listing} from "../src/Listing.sol";
import "forge-std/Vm.sol";

//all these tests are client initiiated (i.e. the client first creates the listing)
contract VariousTest is Test {
    //errors
    error LateFulfill();
    error LatePayment();
    error InsufficientFund();
    error DeletedListing();
    error WrongClient();
    error WrongContractor();
    error NotMarketPlace();

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

        // struct contractor/client should be added to MarketPlace.sol
        // address of the client/contractor  (address)
        // orders fufilled / fully payed for (int)
        // orders accepted and not fufilled / confirmed but not paid fully (past the deadline) (int)
        // total amount of eth earned/paid for fully fulfilled/paid orders

        marketPlace.add_contractor(address(contractor));
        marketPlace.add_client(address(client));
        //create listing
        vm.startBroadcast(client);
        new_listing = new Listing(msg.sender, amounts, delivery_dates, "a commission for you");
        listing_id = marketPlace.addListing(new_listing);
        vm.stopBroadcast();
        //contractor accepts
        vm.startBroadcast(contractor);
        marketPlace.acceptListing(listing_id);
        vm.stopBroadcast();
        //client confirms
        vm.startBroadcast(client);
        marketPlace.confirmListing(listing_id, address(contractor));
        vm.stopBroadcast();
    }
    //does the two parties' balance change correctly?

    function balance_update() public {
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        marketPlace.pay_current_stage(listing_id);
        assertEq(client.balance, 100 ether - 1 ether);
        assertEq(contractor.balance, 100 ether + 1 ether);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }
    //test not ontime delivery by the contractor

    function test_late_devliery() public {
        vm.startBroadcast(contractor);
        vm.warp(vm.getBlockTimestamp() + 101);
        vm.expectRevert(LateFulfill.selector);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //test noontime payment by the client

    function test_late_payment() public {
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        vm.warp(vm.getBlockTimestamp() + 101);
        vm.expectRevert(LatePayment.selector);
        marketPlace.pay_current_stage{value: 1 ether}(listing_id);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //test client can extend delivery date
    function test_extend_delivery_dates() public {
        vm.startBroadcast(client);
        uint256 stage = 0;
        uint256 new_date = vm.getBlockTimestamp() + 150;
        marketPlace.extend_delivery_date(listing_id, stage, new_date);
        vm.stopBroadcast();

        vm.startBroadcast(contractor);
        vm.warp(vm.getBlockTimestamp() + 149);
        bool success = marketPlace.fulfill_current_stage(listing_id);
        assertEq(success, true);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    function test_overpayment() public {
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        marketPlace.pay_current_stage{value: 2 ether}(listing_id);
        assertEq(client.balance, 100 ether - 1 ether);
        assertEq(contractor.balance, 100 ether + 1 ether);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    function test_underpayment() public {
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        marketPlace.pay_current_stage{value: 0.99 ether}(listing_id);
        vm.expectRevert(InsufficientFund.selector);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //optional: client can make an initial downpayment
    function test_downpayment() public {}

    //client deletes listing, and check action cannot be taken on deleted listing
    // a deleted listing is marked with curr_stage = type(uint256).max
    function test_deletelisting_client() public {
        vm.startBroadcast(client);
        uint256 _abandon_count = marketPlace.client_lookup(address(client)).abandon_count;

        marketPlace.delete_listing(listing_id);
        Listing deleted_listing = marketPlace.listing_lookup(listing_id);
        assertEq(deleted_listing.curr_stage(), type(uint256).max);
        assertEq(marketPlace.client_lookup(address(client)).abandon_count, _abandon_count + 1);
        vm.stopBroadcast();

        vm.startBroadcast(contractor);
        vm.expectRevert(DeletedListing.selector);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    function test_deletelisting_contractor() public {
        vm.startBroadcast(contractor);
        uint256 _abandon_count = marketPlace.contractor_lookup(address(contractor)).abandon_count;

        marketPlace.delete_listing(listing_id);
        Listing deleted_listing = marketPlace.listing_lookup(listing_id);
        assertEq(deleted_listing.curr_stage(), type(uint256).max);
        assertEq(marketPlace.contractor_lookup(address(contractor)).abandon_count, _abandon_count + 1);
        vm.stopBroadcast();

        vm.startBroadcast(client);
        vm.expectRevert(DeletedListing.selector);
        marketPlace.pay_current_stage{value: 100 ether}(listing_id);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }
    //fufill track 1 spec

    function test_transferlisting_newclient() public {
        address new_client = address(0x12);
        vm.startBroadcast(client);
        marketPlace.transfer_listing_new_client(listing_id, new_client);
        assertEq(marketPlace.listing_lookup(listing_id).client(), address(new_client));
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //fufill track 1 spec
    function test_transferlisting_newcontractor() public {
        address new_contractor = address(0x14);
        vm.startBroadcast(client);
        marketPlace.transfer_listing_contractor(listing_id, new_contractor);
        assertEq(marketPlace.listing_lookup(listing_id).contractor(), address(new_contractor));
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    function test_contractor_attributeupdate_fufill() public {
        uint256 previous_count_fufilled = marketPlace.contractor_lookup(address(contractor)).fufilled_count;
        uint256 previous_amount_earned = marketPlace.contractor_lookup(address(contractor)).amount_earned;
        //go through full user cycle
        // contractor sends partial fufillment of listing and update the contractor's amount of orders fully fulfilled
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();
        //client sends partial or full payment for (4)
        vm.startBroadcast(client);
        marketPlace.pay_current_stage{value: 1 ether}(listing_id);
        vm.stopBroadcast();
        //contractor sends partial fuillfment of listing
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        // client DOES NOT pay for final stage
        // vm.startBroadcast(client);
        // bool success3 = marketPlace.pay_current_stage{value: 5 ether}(listing_id);
        // vm.stopBroadcast();

        //but since the contractor fufilled the listing completely, they get an increment
        uint256 new_count_fufilled = marketPlace.contractor_lookup(address(contractor)).fufilled_count;
        uint256 new_amount_earned = marketPlace.contractor_lookup(address(contractor)).amount_earned;
        assertEq(new_count_fufilled, previous_count_fufilled + 1);
        assertEq(marketPlace.totalValue(listing_id), 6 ether);
        assertEq(new_amount_earned, previous_amount_earned + 6 ether);

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    function test_client_attributeupdate_fullpayment() public {
        uint256 previous_count_fullpay = marketPlace.client_lookup(address(contractor)).fullpay_count;
        uint256 previous_amount_paid = marketPlace.client_lookup(address(client)).total_paid;
        //go through a full cycle and increment orders fully paid
        vm.startBroadcast(contractor);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();
        vm.startBroadcast(client);
        marketPlace.pay_current_stage{value: 1 ether}(listing_id);
        vm.stopBroadcast();
        //for this test, assume that the contractor has not fufilled the last stage
        // vm.startBroadcast(contractor);
        // bool success2 = marketPlace.fulfill_current_stage(listing_id);
        // vm.stopBroadcast();
        // client DOES pay for final stage
        vm.startBroadcast(client);
        marketPlace.pay_current_stage{value: 5 ether}(listing_id);
        vm.stopBroadcast();

        uint256 new_count_fullpay = marketPlace.client_lookup(address(contractor)).fullpay_count;
        uint256 new_amount_paid = marketPlace.client_lookup(address(client)).total_paid;
        assertEq(previous_count_fullpay, new_count_fullpay + 1);
        assertEq(marketPlace.totalValue(listing_id), 6 ether);
        assertEq(new_amount_paid, previous_amount_paid + 6 ether);

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //note that after setup the listing has already been accepted and confirmed so the following 2 tests make sense
    //test that only the one and only client associated with the listing can make certain important function calls
    function test_wrong_client() public {
        address rouge_client = address(0x99);
        vm.startBroadcast(address(rouge_client));
        vm.expectRevert(WrongClient.selector);
        marketPlace.pay_current_stage{value: 1 ether}(listing_id);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //test that only the one and only contractor associated with the listing can make certain imporant function calls
    function test_wrong_contractor() public {
        address rogue_contractor = address(0x999);
        vm.startBroadcast(address(rogue_contractor));
        vm.expectRevert(WrongContractor.selector);
        marketPlace.fulfill_current_stage(listing_id);
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //ensure that only the marketplace contract can call function in listing.sol
    function test_listing_caller_is_only_marketplace() public {
        address random_nobody = address(0x987654);

        new_listing = new Listing(address(0), amounts, delivery_dates, "");

        vm.startBroadcast(address(random_nobody));
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.acceptListing(address(contractor));
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.fulfill_current_stage();
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.pay_current_stage();
        vm.stopBroadcast();

        vm.startBroadcast(address(client));
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.acceptListing(address(contractor));
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.fulfill_current_stage();
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.pay_current_stage();
        vm.stopBroadcast();

        vm.startBroadcast(address(contractor));
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.acceptListing(address(contractor));
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.fulfill_current_stage();
        vm.expectRevert(NotMarketPlace.selector);
        new_listing.pay_current_stage();
        vm.stopBroadcast();

        test_no_ethtransfer_MarketPlace();
        test_no_ethtransfer_Listing();
    }

    //attach these next 2 tests at the end of tests to ensure invariant that none of the .sol contracts should have an eth balance
    function test_no_ethtransfer_MarketPlace() public view {
        assertEq(address(marketPlace).balance, 0);
    }

    function test_no_ethtransfer_Listing() public view {
        assertEq(address(marketPlace).balance, 0);
    }
}
