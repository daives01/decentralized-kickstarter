pragma solidity 0.8.18;
//SPDX-License-Identifier: MIT

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}

import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract newKickstart {
    address[] public deployedCampaigns;
    IERC20 public immutable token;

    function createKickstart(uint goal, address _token, uint startAt, uint endAt) public {
        address newCampaign = new Kickstart(msg.sender, _token, goal, startAt, endAt);
        deployedCampaigns.push(newCampaign);
    }
    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}



contract Kickstart {
    address creator;
    uint goal;
    uint totalPledged;
    uint startAt;
    uint endAt;
    bool claimed;

    IERC20 public immutable token;
    uint public count; //id of campaign (move to factory contract)
    mapping(address => uint) pledgedAmount; //Maps user address to amount pledged

    event Pledge(uint id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);


    constructor(address _creator, address _token, uint _goal, uint _startAt, uint _endAt) {
        token = IERC20(_token);
        creator = _creator;
        goal = _goal;
        totalPledged = 0;
        startAt = _startAt;
        endAt = _endAt;
        claimed = false;
    }

  
  function pledge(uint _id, uint _amount) external {
        require(pledgedAmount[msg.sender] >= _amount,"You do not have enough tokens Pledged to withraw");
        totalPledged += _amount;
        pledgedAmount[msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

  
  function claim(uint _id) external {
        require(creator == msg.sender, "You did not create this Campaign");
        require(block.timestamp > endAt, "Campaign has not ended");
        require(totalPledged >= goal, "Campaign did not succed");
        require(!claimed, "Already claimed");

        claimed = true;
        token.transfer(creator, totalPledged);

        emit Claim(_id);
    }


    function refund(uint _id) external {
        require(block.timestamp > endAt, "Campaign has not ended");
        require(totalPledged < goal, "You cannot refund, Campaign has succeeded");

        uint bal = pledgedAmount[msg.sender];
        pledgedAmount[msg.sender] = 0;            //Prevents re-entrancy attack
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }
}
