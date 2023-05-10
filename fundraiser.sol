// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fundraiser {
    struct Donation {
        address donor;
        uint amount;
    }

    address public fundraiserCreator;
    address payable public beneficiary;
    uint public goal;
    uint public totalDonated;
    mapping(address => Donation) public donations;
    uint public donationCount;

    event DonationReceived(address indexed donor, uint amount);
    event FundraiserSuccessful(uint totalDonated);
    event FundraiserFailed();

    constructor(address payable _beneficiary, uint _goal) {
        fundraiserCreator = msg.sender;
        beneficiary = _beneficiary;
        goal = _goal;
    }

    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(totalDonated + msg.value <= goal, "Fundraiser has already reached its goal");

        donationCount++;
        donations[msg.sender] = Donation(msg.sender, msg.value);
        totalDonated += msg.value;
        emit DonationReceived(msg.sender, msg.value);

        if (totalDonated == goal) {
            emit FundraiserSuccessful(totalDonated);
            beneficiary.transfer(totalDonated);
        } else if (totalDonated > goal) {
            emit FundraiserSuccessful(totalDonated);
            uint excess = totalDonated - goal;
            beneficiary.transfer(goal);
            payable(msg.sender).transfer(excess);
        }
    }

    function withdraw() external {
        require(msg.sender == fundraiserCreator, "Only the fundraiser creator can withdraw funds");
        require(totalDonated < goal, "Fundraiser must be unsuccessful to withdraw funds");
        emit FundraiserFailed();
        payable(fundraiserCreator).transfer(address(this).balance);
    }
}
