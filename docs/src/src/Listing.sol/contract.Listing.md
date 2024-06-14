# Listing
[Git Source](https://github.com/ucsbjonas/decentralance/blob/39c4cd65ddd22d09546da56de08cc7911a2e6625/src/Listing.sol)


## State Variables
### client

The 'customer' or 'consumer' of the listing. Pays the contractor for each fufilled stage.

```solidity
address public client;
```


### amounts
A list of the required amounts to pay for each stage. Determined when the listing is instansiated (set in the constructor)
```solidity
uint256[] public amounts;
```


### delivery_dates
A list of deadlines that the contractor must meet for each stage. Determined when the listing is instansiated (set in the constructor)
```solidity
uint256[] public delivery_dates;
```


### description
An explanation of the specific details of the listing in plain text. For example, if a client comissions an artwork, they may set `description` to "A magnificent landscape"
```solidity
string public description;
```


### contractor
Address of the contractor
```solidity
address public contractor;
```


### accepted
Whether at least one counterparty has accepted the listing after the listing was listed on the marketplace.
```solidity
bool public accepted;
```


### fulfilled
Whether or not the listing has been fully filled (i.e. all stages fufilled)
```solidity
bool public fulfilled;
```


### confirmed
Must be true in order for fufillment to begin.
```solidity
bool public confirmed;
```


### curr_stage
The current stage of the fufillment of the listing. Indexes `delivery_dates` and `amounts`
```solidity
uint256 public curr_stage;
```


### client_initiated
If true, the client is comissioning a listing. If false, a contractor is offering a listing
```solidity
bool public client_initiated;
```


## Functions
### constructor

Sets `amounts`, `delivery_dates` and `description`
```solidity
constructor(
    address _client,
    uint256[] memory initial_amounts,
    uint256[] memory initial_delivery_dates,
    string memory initial_description
);
```

### acceptListing


```solidity
function acceptListing(address _contractor) public;
```

### fulfill_current_stage


```solidity
function fulfill_current_stage() public;
```

### pay_current_stage


```solidity
function pay_current_stage() public payable;
```

### get_current_stage


```solidity
function get_current_stage() public view returns (uint256);
```

## Errors
### NotMarketPlace
This error is raised when an address other than the listing's associated marketplace contract calls any function in `Listing.sol`
```solidity
error NotMarketPlace();
```

