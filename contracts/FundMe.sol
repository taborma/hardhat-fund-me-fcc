// Purpose of this smart contract is to:
// Get funds from the users
// Set a minimum funding value in USD

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "contracts/PriceConverter.sol";
// gas 966,342
// gas 943,891 after constant
// gas 916,913 after immutable
// gas 888,041 after replacing 1 require for error

// we need to add contract neem before the error so we can identifiy which is throwing error
error FundMe__NotOwner();

/// @title A contract for crowd funding
/// @author cleverandrebel
/// @notice This contract is to demo a sample funding contract
/// @dev This implements price feeds as our library

contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // State Variables

    uint256 public constant MIN_USD = 50 * 1e18;

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    // immutable should be used when you not assigning a variable in the same place as declaring it
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        } // this saves a lot of gas because we don't have to store string as an array
        _; // _ represents doing the rest of the code in modified function
    }

    constructor(address s_priceFeedAddress) {
        // when we deploy this contract we automatically assign creator to be an owner --> important when withdraw()
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
    }

    // receive()
    receive() external payable {
        fund();
    }

    // fallback()
    fallback() external payable {
        fund();
    }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds
     */
    function fund() public payable {
        // we are not passing any value to getConverionRate because msg.value is considered as a first parameter
        // if we had second parameter in getConversionRate we would have to pass it
        require(
            msg.value.getConversionRate(s_priceFeed) >= MIN_USD,
            "Didn't send enough"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        //using modifier here; we want to make sure that only owner can withdraw
        // for loop very similar to C++ loop (starting point, ending point, incremental)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex = funderIndex + 1
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //completely resetting the funders array
        s_funders = new address[](0);
        //actually withdrawing the funds
        // there are 3 ways of withdrawing the funds: 1) transfer 2) send 3) call
        // transfer from different contract to each other
        //payable(msg.sender).transfer(address(this).balance);
        // if not sufficient gas it will revert and throw an error
        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send faild");
        // you need to add require in order to revert the transaction in case of error. Without it transaction will not be reverted
        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // returns 2 variables
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        require(callSuccess);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
    // What happens if someone sends this contract eth without calling the fund function
}
