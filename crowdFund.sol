// SPDX-License-Identifier: GPL-3.0
pragma solidity ^ 0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract fundMe {
    uint256 public minimumUsd = 50 * 1e10;
    address[] public funders; 
    address public owner; //This array stores the address of everybody that called the contract or performed a transaction (depositors)
    mapping(address => uint256) public addressToAmountFunded; //This code maps the address to the amount they deposited to the contract. implement in line 15.

    constructor() public {
        owner = msg.sender;
    }
    
    
    function deposit() public payable {
        require (getConversionRate(msg.value) >= minimumUsd, "Didn't send enough :)");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value; //this is where the msg.sender address is mapped to the amount paid. NB. it is [] and not ().
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        return priceFeed.version();
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
 modifier onlyOwner() {
        //is the message sender owner of the contract?
        require(msg.sender == owner);

        _;
    }
    
    
    
    
    // Explainer from: https://solidity-by-example.org/fallback/
  

     function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);

        //iterate through all the mappings and make them 0
        //since all the deposited amount has been withdrawn
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //funders array will be initialized to 0
        funders = new address[](0);
    }
}
