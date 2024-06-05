// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketPlace} from "../src/MarketPlace.sol";
import {Listing} from "../src/Listing.sol";
import "forge-std/Vm.sol";
contract VariousTest is Test{

        function test_invalid_delivery_dates() public{



    }
    function test_extend_delivery_dates() public {



    }
    function test_overpayment() public{



    }
    function test_underpayment() public {



    }
    function test_downpayment() public {



    }    
    function test_deletelisting() public {



    }
    function test_transferlisting() public {



    }
    function test_contractor_attributeupdate_fufill() public {



    }
    function test_client_attributeupdate_fullpayment() public {



    }
    function test_contractor_abandonment() public {



    }
    function test_client_abandonment() public {



    }
    function test_listing_immutables() public {



    }
    function test_wrong_client() public {



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
}
