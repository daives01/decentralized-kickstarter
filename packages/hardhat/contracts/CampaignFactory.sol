pragma solidity 0.8.19;
// SPDX-License-Identifier: MIT

import "./Campaign.sol";


contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint _goal, uint _endAt) public {
        address newCampaign = address(new Campaign(msg.sender, _goal, _endAt));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}