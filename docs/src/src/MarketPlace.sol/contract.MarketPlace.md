# MarketPlace
[Git Source](https://github.com/ucsbjonas/decentralance/blob/a1837323322f4307c5092470c02764cda1d03147/src/MarketPlace.sol)


## State Variables
### listings

```solidity
mapping(uint256 => Listing) public listings;
```


## Functions
### constructor


```solidity
constructor();
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
function confirmListing(uint256 listing_id) public;
```

### fufill_current_stage


```solidity
function fufill_current_stage(uint256 listing_id) public returns (bool);
```

### pay_current_stage


```solidity
function pay_current_stage(uint256 listing_id) public returns (bool);
```

### listing_lookup


```solidity
function listing_lookup(uint256 _listing_id) public view returns (Listing);
```

