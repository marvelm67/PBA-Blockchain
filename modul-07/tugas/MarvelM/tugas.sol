// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract DecentralizedCrowdfunding {
    struct Campaign {
        address payable owner; 
        uint256 goal; 
        uint256 deadline;
        uint256 fundsRaised;
        bool claimed; 
        address[] contributors;
        mapping(address => uint256) contributions; 
    }

    uint256 public numCampaigns; 
    mapping(uint256 => Campaign) public campaigns; 

    mapping(address => uint256) public pendingRefunds;

    event CampaignCreated(uint256 indexed campaignId, address owner, uint256 goal, uint256 deadline);
    event ContributionMade(uint256 indexed campaignId, address contributor, uint256 amount);
    event FundsClaimed(uint256 indexed campaignId, uint256 amount);
    event RefundProcessed(uint256 indexed campaignId, address contributor, uint256 amount);

    error InvalidGoal();
    error CampaignEnded();
    error InvalidContribution();
    error NoContributionMade();
    error CampaignNotEnded();
    error GoalReached();
    error GoalNotReached();
    error FundsAlreadyClaimed();

    function createCampaign(uint256 goal, uint256 duration) public {
        if (goal == 0) revert InvalidGoal(); 
        uint256 deadline = block.timestamp + duration;
        Campaign storage newCampaign = campaigns[numCampaigns++];
        newCampaign.owner = payable(msg.sender); 
        newCampaign.goal = goal; 
        newCampaign.deadline = deadline;
        newCampaign.fundsRaised = 0;
        newCampaign.claimed = false; 
        emit CampaignCreated(numCampaigns - 1, msg.sender, goal, deadline);
    }

    function contribute(uint256 campaignId) public payable {
        Campaign storage campaign = campaigns[campaignId]; 
        if (block.timestamp >= campaign.deadline) revert CampaignEnded(); 
        if (msg.value == 0) revert InvalidContribution(); 
        
        campaign.fundsRaised += msg.value; 
        campaign.contributions[msg.sender] += msg.value;
        campaign.contributors.push(msg.sender); 
        emit ContributionMade(campaignId, msg.sender, msg.value);
    }

    function claimFunds(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId]; 
        //check validate
        if (block.timestamp < campaign.deadline) revert CampaignNotEnded(); 
        if (campaign.fundsRaised < campaign.goal) revert GoalNotReached(); 
        if (campaign.claimed) revert FundsAlreadyClaimed(); 
        //effect
        campaign.claimed = true; //mark as already claimed
        uint256 fundsToTransfer = campaign.fundsRaised; 
        campaign.fundsRaised = 0; //reset
        //interaction, transfer fund to owner
        campaign.owner.transfer(fundsToTransfer); 
        emit FundsClaimed(campaignId, fundsToTransfer); 
    }

    function withdrawContribution(uint256 campaignId) public {
        Campaign storage campaign = campaigns[campaignId]; 
        if(campaign.contributions[msg.sender] == 0) { //use check effect interaction
            revert NoContributionMade();  //check
        }

        payable(msg.sender).transfer(campaign.contributions[msg.sender]); //effect
        campaign.contributions[msg.sender] = 0;  //interaction
    }

function refundCampaign(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        
        if (block.timestamp < campaign.deadline) revert CampaignNotEnded();
        if (campaign.fundsRaised >= campaign.goal) revert GoalReached();

        uint256 contributorsCount = campaign.contributors.length;

        for (uint256 i = 0; i < contributorsCount; i++) {
            address contributorAddress = campaign.contributors[i];
            uint256 contributedAmount = campaign.contributions[contributorAddress];

            if (contributedAmount > 0) {  //beside we transfer, we can do pull over push method
                pendingRefunds[contributorAddress] += contributedAmount;
                campaign.contributions[contributorAddress] = 0; // Reset contributions
                emit RefundProcessed(_campaignId, contributorAddress, contributedAmount);
            }
        }
    }

    // Allow contributors to withdraw their refunds
    function withdrawRefund() public {
        uint256 amount = pendingRefunds[msg.sender];
        
        require(amount > 0, "No refund available");
        
        pendingRefunds[msg.sender] = 0; // Reset the pending refund before transferring
        payable(msg.sender).transfer(amount); // Transfer the refund
    }
}
