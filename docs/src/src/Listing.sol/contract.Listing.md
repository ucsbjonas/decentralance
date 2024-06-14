# Listing
[Git Source](https://github.com/ucsbjonas/decentralance/blob/39c4cd65ddd22d09546da56de08cc7911a2e6625/src/Listing.sol)


## State Variables
### client

```solidity
address public client;
```


### amounts

```solidity
uint256[] public amounts;
```


### delivery_dates

```solidity
uint256[] public delivery_dates;
```


### description

```solidity
string public description;
```


### contractor

```solidity
address public contractor;
```


### accepted

```solidity
bool public accepted;
```


### fulfilled

```solidity
bool public fulfilled;
```


### confirmed

```solidity
bool public confirmed;
```


### curr_stage

```solidity
uint256 public curr_stage;
```


### client_initiated

```solidity
bool public client_initiated;
```


## Functions
### constructor


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

```solidity
error NotMarketPlace();
```

