// SPDX-License-Identifier: GPL-3.0
pragma solidity ^ 0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract fundMe {
    uint256 public minimumUsd = 50 * 1e10;
    address[] public funders;  //This array stores the address of everybody that called the contract or performed a transaction (depositors)
    mapping(address => uint256) public addressToAmountFunded; //This code maps the address to the amount they deposited to the contract. implement in line 15.
    
    
    function deposit() public payable {
        require (getConversionRate(msg.value) >= minimumUsd, "Didn't send enough :)");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value; //this is where the msg.sender address is mapped to the amount paid. NB. it is [] and not ().
    }


    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
         (, int price,,,) = priceFeed.latestRoundData();
         return uint256(price * 1e10); //which is same as 1**10. bceoz msg.value is in wei and 1*18 wei make 1 eth. whiles chainlink only returns 1*8 in terms of ETH USD price.
//The above is the ETH to USD pricefeed from chainlink.
    }

//fromt the above I need external contract;
        // ABI so I imported it.
        //and Address to connect with it. : 0x694AA1769357215DE4FAC081bf1f309aDC325306
    function getConversionRate(uint256 ethAmount)public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
 modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
