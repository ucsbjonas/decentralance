# MarketPlace
[Git Source](https://github.com/ucsbjonas/decentralance/blob/39c4cd65ddd22d09546da56de08cc7911a2e6625/src/MarketPlace.sol)


## State Variables
### listings

```solidity
mapping(uint256 => Listing) public listings;
```


### clients

```solidity
mapping(address => ClientInfo) public clients;
```


### contractors

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


```solidity
function delete_listing(uint256 listing_id) public;
```

### transfer_listing_new_client


```solidity
function transfer_listing_new_client(uint256 listing_id, address new_client) public;
```

### transfer_listing_contractor


```solidity
function transfer_listing_contractor(uint256 listing_id, address new_contractor) public;
```

### totalValue


```solidity
function totalValue(uint256 listing_id) public returns (uint256);
```

### addListing


```solidity
function addListing(Listing new_listing) public returns (uint256);
```

### acceptListing


```solidity
function acceptListing(uint256 listing_id) public;
```

### confirmListing


```solidity
function confirmListing(uint256 listing_id, address confirm_addr) public;
```

### fulfill_current_stage


```solidity
function fulfill_current_stage(uint256 listing_id) public returns (bool);
```

### pay_current_stage


```solidity
function pay_current_stage(uint256 listing_id) public payable returns (bool);
```

### listing_lookup


```solidity
function listing_lookup(uint256 _listing_id) public view returns (Listing);
```

## Errors
### LateFulfill

```solidity
error LateFulfill();
```

### LatePayment

```solidity
error LatePayment();
```

### InsufficientFund

```solidity
error InsufficientFund();
```

### DeletedListing

```solidity
error DeletedListing();
```

### WrongClient

```solidity
error WrongClient();
```

### WrongContractor

```solidity
error WrongContractor();
```

## Structs
### ClientInfo

```solidity
struct ClientInfo {
    uint256 abandon_count;
    uint256 fullpay_count;
    uint256 total_paid;
}
```

### ContractorInfo

```solidity
struct ContractorInfo {
    uint256 abandon_count;
    uint256 fufilled_count;
    uint256 amount_earned;
}
```

