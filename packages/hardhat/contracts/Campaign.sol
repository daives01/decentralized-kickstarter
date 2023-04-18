pragma solidity 0.8.19;
//SPDX-License-Identifier: MIT


contract Campaign {
    address creator;
    uint goal;
    uint totalPledged;
    uint endAt;
    bool claimed;

    mapping(address => uint) pledgedAmount; //Maps user address to amount pledged

    event Pledge(address _address, uint _amount);
    event Claim(address _address, uint _amount);
    event Refund(address _address, uint _amount);

    constructor(address _creator, uint _goal, uint _endAt) {
        creator = _creator;
        goal = _goal;
        totalPledged = 0;
        endAt = _endAt;
        claimed = false;

    }


    function pledge() external payable {
        require(block.timestamp < endAt, "Campaign has ended");
        pledgedAmount[msg.sender] += msg.value;
        totalPledged += msg.value;
        emit Pledge(msg.sender, msg.value);
    }


    function claim() external {
        require(block.timestamp > endAt, "Campaign has not ended");
        require(msg.sender == creator, "Only creator can claim");
        require(totalPledged >= goal, "Goal not reached");
        require(!claimed, "Already claimed");
        claimed = true;
        payable(creator).transfer(address(this).balance);
        emit Claim(msg.sender, address(this).balance);
    }

    function refund() external {
        require(block.timestamp > endAt, "Campaign has not ended");
        require(totalPledged < goal, "Goal reached");
        require(pledgedAmount[msg.sender] > 0, "No pledge to refund");
        uint amount = pledgedAmount[msg.sender];
        pledgedAmount[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Refund(msg.sender, amount);
    }
    

    //Getters
    function getGoal() public view returns (uint) {
        return goal;
    }

    function getTotalPledged() public view returns (uint) {
        return totalPledged;
    }

    function getEndAt() public view returns (uint) {
        return endAt;
    }

    function getCreator() public view returns (address) {
        return creator;
    }

    function getClaimed() public view returns (bool) {
        return claimed;
    }

    function getPledgedAmount(address _address) public view returns (uint) {
        return pledgedAmount[_address];
    }
}