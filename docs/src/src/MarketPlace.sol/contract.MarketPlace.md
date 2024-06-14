# MarketPlace
[Git Source](https://github.com/ucsbjonas/decentralance/blob/39c4cd65ddd22d09546da56de08cc7911a2e6625/src/MarketPlace.sol)


## State Variables
### listings
Maps a listing id to a Listing contract
```solidity
mapping(uint256 => Listing) public listings;
```


### clients
Maps a client address to their associated ClientInfo struct
```solidity
mapping(address => ClientInfo) public clients;
```


### contractors
Maps a contractor address to their associated ContractorInfo struct
```solidity
mapping(address => ContractorInfo) public contractors;
```


## Functions
### constructor


```solidity
constructor();
```

### add_contractor


```solidity
function add_contractor(address _contractor) public;
```

### add_client


```solidity
function add_client(address _client) public;
```

### extend_delivery_date

Extend delivery date for a particular stage. Only the client is permitted to call this function.
```solidity
function extend_delivery_date(uint256 listing_id, uint256 stage, uint256 new_date) public;
```

### client_lookup


```solidity
function client_lookup(address client) public returns (ClientInfo memory c);
```

### contractor_lookup


```solidity
function contractor_lookup(address contractor) public returns (ContractorInfo memory c);
```

### delete_listing

Deletes listing. Each listing that the client or contractor deletes will reflect on their record.
```solidity
function delete_listing(uint256 listing_id) public;
```

### transfer_listing_new_client

Transfer the listing to a different client. ONly the client is permitted to call this function.
```solidity
function transfer_listing_new_client(uint256 listing_id, address new_client) public;
```

### transfer_listing_contractor

Transfter the listing to a different contractor. Only the contractor is permitted to call this function.
```solidity
function transfer_listing_contractor(uint256 listing_id, address new_contractor) public;
```

### totalValue

Returns the total value of all stages for a listing
```solidity
function totalValue(uint256 listing_id) public returns (uint256);
```

### addListing


```solidity
function addListing(Listing new_listing) public returns (uint256);
```

### acceptListing

Accept listing. If the listing is client initiated, multiple contractors can accept, and vice versa for contractor inititated (multiple clients can accept)
```solidity
function acceptListing(uint256 listing_id) public;
```

### confirmListing

If client inititated, choose contractor to work with. If contractor inititated, choose client to work with.
```solidity
function confirmListing(uint256 listing_id, address confirm_addr) public;
```

### fulfill_current_stage

Mark the current stage as fufilled (contractor calls this)
```solidity
function fulfill_current_stage(uint256 listing_id) public returns (bool);
```

### pay_current_stage

Pay the current stage in full (client call this)
```solidity
function pay_current_stage(uint256 listing_id) public payable returns (bool);
```

### listing_lookup


```solidity
function listing_lookup(uint256 _listing_id) public view returns (Listing);
```

## Errors
### LateFulfill
Raises if the contractor fufills any stage past the deadline
```solidity
error LateFulfill();
```

### LatePayment
Raises if the client pays for any stage past the deadline
```solidity
error LatePayment();
```

### InsufficientFund
Raises when client pays
```solidity
error InsufficientFund();
```

### DeletedListing
Raises when trying to take action on a previously deleted listing
```solidity
error DeletedListing();
```

### WrongClient
Each listing is associated with exactly one client
```solidity
error WrongClient();
```

### WrongContractor
Each listing is associated with exactly one contractor
```solidity
error WrongContractor();
```

## Structs
### ClientInfo

1) Number of deleted listings or listings that the client allowed to time out. (bad) \
2) The amount of listings that a client has fully paid for \
3) Total amount paid out of all listings that were fully paid for

```solidity
struct ClientInfo {
    uint256 abandon_count;
    uint256 fullpay_count;
    uint256 total_paid;
}
```

### ContractorInfo

1) Number of deleted listing or listings that the contractor allowed to time out. (bad) \
2) The amount of listing that a contractor has fulfilled to completion. \
3) Total amount of earned from all listing that were completely fufilled.

```solidity
struct ContractorInfo {
    uint256 abandon_count;
    uint256 fufilled_count;
    uint256 amount_earned;
}
```

