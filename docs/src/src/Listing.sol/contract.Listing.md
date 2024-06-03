# Listing
[Git Source](https://github.com/ucsbjonas/decentralance/blob/a1837323322f4307c5092470c02764cda1d03147/src/Listing.sol)


## State Variables
### client

```solidity
address public client;
```


### amounts

```solidity
uint256[2] public amounts;
```


### delivery_dates

```solidity
uint256[2] public delivery_dates;
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


### curr_stage

```solidity
uint256 public curr_stage;
```


## Functions
### constructor


```solidity
constructor(
    address _client,
    uint256[2] memory initial_amounts,
    uint256[2] memory initial_delivery_dates,
    string memory initial_description
);
```

