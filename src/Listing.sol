// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Listing {
    //storage variables
    address public client;
    uint256[] public amounts; // [totalAmount, partialAmount]
    //make it size 2 for now, not sure about workaround for dynamic sized arrays
    uint256[] public delivery_dates; // [finalDeliveryDate, intermediateDeliveryDate]
    string public description;
    address public contractor;
    bool public accepted;
    bool public fulfilled;
    bool public confirmed;
    uint256 public curr_stage; // 0 for not started, 1 for intermediate, 2 for final
    bool public client_initiated;

    error NotMarketPlace();
    //constructor

    constructor(
        address _client,
        uint256[] memory initial_amounts,
        uint256[] memory initial_delivery_dates,
        string memory initial_description
    ) {
        client = _client;
        amounts = initial_amounts;
        delivery_dates = initial_delivery_dates;
        description = initial_description;
        accepted = false;
        fulfilled = false;
        curr_stage = 0;
    }

    //functions
    function acceptListing(address _contractor) public {
        require(!accepted, "listing already accepted");
        contractor = _contractor;
        accepted = true;
    }

    function fulfill_current_stage() public {
        require(accepted, "listing not accepted yet");
        require(!fulfilled, "listing already fulfilled");
        require(msg.sender == contractor, "only contractor can fulfill");
        require(curr_stage < 2, "all stages completed");

        if (curr_stage == 0) {
            curr_stage = 1;
        } else if (curr_stage == 1) {
            curr_stage = 2;
            fulfilled = true;
        }
    }

    function pay_current_stage() public payable {
        require(accepted, "listing not accepted yet");
        require(msg.sender == client, "only client can pay");
        require(curr_stage > 0, "no stage to pay for");
        require(curr_stage <= 2, "all stages completed");

        if (curr_stage == 1) {
            require(msg.value == amounts[1], "incorrect payment amount for intermediate stage");
        } else if (curr_stage == 2) {
            require(msg.value == amounts[0] - amounts[1], "incorrect payment amount for final stage");
        }

        payable(contractor).transfer(msg.value);
    }

    function get_current_stage() public view returns (uint256) {
        return curr_stage;
    }
}
