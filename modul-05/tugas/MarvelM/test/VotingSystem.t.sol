// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { VotingSystem } from "../src/VotingSystem.sol";

contract VotingSystemBaseTest is Test {
    VotingSystem votingSystem;

    uint internal minCandidateCount;
    uint internal votingLength;

    function setUp() public {
        minCandidateCount = 2;
        votingLength = 3600;
        votingSystem = new VotingSystem(minCandidateCount, votingLength); // Min 2 candidates, 1-hour voting length
    }


    function startVoting() internal {
        for(uint i = 0; i < minCandidateCount; i++) {
            votingSystem.addCandidate("Candidate Name"); 
        }
        votingSystem.startVoting();
    }

    function endVoting() internal {
        vm.warp(votingSystem.voteEndTimestamp());
        votingSystem.endVoting();
    }

    function expectRevertWhenNotOwner() internal {
        vm.expectRevert("Only owner can perform this action");
        vm.prank(address(0x123));
    }
}

contract AddCandidateTest is VotingSystemBaseTest {
    address nonOwner = address(0x123); // A non-owner address for testing

    function addTwoCandidateHelper() internal {
        votingSystem.addCandidate("Candidate 1");
        votingSystem.addCandidate("Candidate 2");
    }

    function test_CountIncreases() public {
        // Ensure initial candidatesCount is 0
        assertEq(votingSystem.candidatesCount(), 0);
        addTwoCandidateHelper();
        // Verify candidatesCount increases to 2
        assertEq(votingSystem.candidatesCount(), 2);
    }

    function test_VoteCountEqualsZero() public {
        // Ensure initial candidatesCount is 0
        assertEq(votingSystem.candidatesCount(), 0);
        addTwoCandidateHelper();
        // Verify vote count remains 0
        assertEq(votingSystem.getCandidateVoteCount(1), 0);
        assertEq(votingSystem.getCandidateVoteCount(2), 0);
    }

    function test_RevertWhen_NotOwner() public {
        // Ensure initial candidatesCount is 0
        assertEq(votingSystem.candidatesCount(), 0);
        vm.prank(nonOwner); // Use a non-owner address
        vm.expectRevert("Only owner can perform this action"); // Expect revert with correct message
        votingSystem.addCandidate("Unauthorized Candidate");
    }

    function test_VoteStateStillNew() public {
        // Ensure initial candidatesCount is 0
        assertEq(votingSystem.candidatesCount(), 0);
        addTwoCandidateHelper();
        // Verify vote state remains NEW after adding candidates
        assertEq(uint256(votingSystem.voteState()), 0); // VoteState.NEW == 0
    }

    function test_EventCandidateAdded() public {
        // Ensure initial candidatesCount is 0
        vm.expectEmit(true, true, true, true);
        emit VotingSystem.CandidateAdded(1, "Budi");
        votingSystem.addCandidate("Budi");
    }
}

// Add Candidate Tests
contract VotingSystemAddCandidateTests is VotingSystemBaseTest {
    //[Happy Path] Add Candidate
    function testFuzz_AddCandidate(string calldata _name) public {
        vm.expectEmit(false, false, false, true);
        emit VotingSystem.CandidateAdded(votingSystem.candidatesCount() + 1, _name);
        votingSystem.addCandidate(_name);
    }

    //[Unhappy Path] Test Revert When Not Owner
    function test_AddCandidate_NotOwner() public {
        expectRevertWhenNotOwner();
        votingSystem.addCandidate("Unauthorized Candidate");
    }

    //[Unhappy Path] Test Revert When Not In Required State
    function test_RevertWhen_NotInRequiredState() public {
        startVoting();
        vm.expectRevert(
            abi.encodeWithSelector(
                VotingSystem.WrongVotingState.selector,
                VotingSystem.VoteState.STARTED,
                VotingSystem.VoteState.NEW
            )
        );
        votingSystem.addCandidate("Candidate Name");
    }
}

// Start Voting Tests
contract VotingSystemStartVotingTests is VotingSystemBaseTest {
    //[Happy Path] Start Voting
    function test_StartVoting() public {
        startVoting();

        assertEq(uint(votingSystem.voteState()), uint(VotingSystem.VoteState.STARTED), "Vote state should be STARTED");
        assertEq(votingSystem.voteStartTimestamp(), block.timestamp);
        assertEq(votingSystem.voteEndTimestamp(), block.timestamp + votingLength);
    }

    //[Unhappy Path Start Voting] Candidates count below minimum
    function test_RevertWhen_CandidatesCountNotGreaterThanMinimumCandidateCount() public {
        votingSystem.addCandidate("Candidate Name"); //Add 1 candidate

        vm.expectRevert(
            abi.encodeWithSelector(
                VotingSystem.MinimumCandidatesCountNotReached.selector,
                1,
                minCandidateCount
            )
        );
        votingSystem.startVoting(); // Error: need more than 5 candidates
    }

    //[Unhappy Path] Test Revert When Not Owner
    function test_RevertWhen_NotOwner() public {
        expectRevertWhenNotOwner();
        votingSystem.startVoting();
    }

    //[Unhappy Path] Test Revert When Not In Required State
    function test_RevertWhen_NotInRequiredState() public {
        startVoting();

        vm.expectRevert(
            abi.encodeWithSelector(
                VotingSystem.WrongVotingState.selector,
                VotingSystem.VoteState.STARTED,
                VotingSystem.VoteState.NEW
            )
        );

        votingSystem.startVoting();
    }
}

// Vote Tests
contract VotingSystemVoteTests is VotingSystemBaseTest {
    //[Happy Path] Vote
    function testFuzz_Vote(uint _candidateId) public {
        startVoting();

        vm.assume(_candidateId > 0 && _candidateId <= minCandidateCount);
        uint previousVoteCount = votingSystem.getCandidateVoteCount(_candidateId);

        vm.expectEmit(false, false, false, true);
        emit VotingSystem.VoteCasted(_candidateId, msg.sender);

        vm.prank(msg.sender);
        votingSystem.vote(_candidateId);
        
        assertEq(votingSystem.hasVoted(msg.sender), true, "User should have voted");
        assertEq(previousVoteCount + 1, votingSystem.getCandidateVoteCount(_candidateId), "Vote count should increment");
    }

    //[Unhappy Path] Voter has already voted
    function test_RevertWhen_VoterHasAlreadyVoted() public {
        startVoting();
        vm.startPrank(address(0x123));
        votingSystem.vote(1);
        vm.expectRevert("Voter has already voted");
        votingSystem.vote(1);
    }

    //[Unhappy Path] Invalid candidate ID
    function test_RevertWhen_CandidateIdNotValid() public {
        startVoting();
        vm.expectRevert("Invalid candidate ID");
        votingSystem.vote(0);
        vm.expectRevert("Invalid candidate ID");
        votingSystem.vote(100);
    }

    //[Unhappy Path] Voting time has ended
    function test_RevertWhen_VotingTimeAlreadyReachEndTime() public {
        startVoting();
        vm.warp(votingSystem.voteEndTimestamp() + 1);
        vm.expectRevert(VotingSystem.VotingEndTimeReached.selector);
        votingSystem.vote(1);
    }

    //[Unhappy Path] Wrong voting state
    function test_RevertWhen_NotInRequiredState() public {
        startVoting();
        endVoting();
        vm.expectRevert(
            abi.encodeWithSelector(
                VotingSystem.WrongVotingState.selector,
                VotingSystem.VoteState.ENDED,
                VotingSystem.VoteState.STARTED
            )
        );
        votingSystem.vote(1);
    }
}

// End Voting Tests
contract VotingSystemEndVotingTests is VotingSystemBaseTest {
    //[Happy Path] End Voting
    function test_EndVoting() public {
        startVoting();
        endVoting();
        assertEq(uint(votingSystem.voteState()), uint(VotingSystem.VoteState.ENDED), "Vote state should be ENDED");
    }

    //[Unhappy Path] End voting before end time
    function test_RevertWhen_VotingTimeHaveNotReachEndTime() public {
        startVoting();
        vm.expectRevert(VotingSystem.VotingEndTimeNotReached.selector);
        votingSystem.endVoting();
    }

    //[Unhappy Path] Not owner
    function test_RevertWhen_NotOwner() public {
        expectRevertWhenNotOwner();
        votingSystem.endVoting();
    }

    //[Unhappy Path] Wrong voting state
    function test_RevertWhen_NotInRequiredState() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                VotingSystem.WrongVotingState.selector,
                VotingSystem.VoteState.NEW,
                VotingSystem.VoteState.STARTED
            )
        );
        votingSystem.endVoting();
    }
}

// Choose The Winner Tests
contract VotingSystemChooseTheWinnerTests is VotingSystemBaseTest {
    //[Happy Path] Choose The Winner
    function test_ChooseTheWinner() public {
        startVoting();
        uint _candidatesCount = votingSystem.candidatesCount();

        for (uint i = 0; i < 5; i++) {
            vm.prank(vm.addr(uint256(keccak256(abi.encodePacked(block.timestamp, i)))));
            votingSystem.vote(_candidatesCount);
        }

        endVoting();
        
        vm.expectEmit(false, false, false, true);
        emit VotingSystem.WinnerChosen(_candidatesCount);
        votingSystem.chooseTheWinner();

        assertEq(uint(votingSystem.voteState()), uint(VotingSystem.VoteState.WINNER_CHOSEN), "Vote state should be WINNER CHOSEN");
    }

    //[Unhappy Path] Not owner
    function test_RevertWhen_NotOwner() public {
        expectRevertWhenNotOwner();
        votingSystem.endVoting();
    }

    //[Unhappy Path] Wrong voting state
    function test_RevertWhen_NotInRequiredState() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                VotingSystem.WrongVotingState.selector,
                VotingSystem.VoteState.NEW,
                VotingSystem.VoteState.STARTED
            )
        );
        votingSystem.endVoting();
    }
}

// Get Candidate Vote Count Tests
contract VotingSystemGetCandidateVoteCountTests is VotingSystemBaseTest {
    //[Happy Path] Get Candidate Vote Count
    function test_GetCandidateVoteCount() public {
        startVoting();
        votingSystem.vote(1);
        assertEq(votingSystem.getCandidateVoteCount(1), 1, "Vote count should be 1");
    }

    //[Unhappy Path] Invalid candidate ID
    function test_RevertWhen_InvalidCandidateId() public {
        startVoting();
        vm.expectRevert("Invalid candidate ID");
        votingSystem.getCandidateVoteCount(0);
    }

    //[Unhappy Path] Not owner
    function test_RevertWhen_NotOwner() public {
        expectRevertWhenNotOwner();
        votingSystem.getCandidateVoteCount(1);
    }
}
