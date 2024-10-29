pragma solidity ^0.8.0;

contract VotingSystem {
    error WrongVotingState(VoteState actual, VoteState expected);
    error MinimumCandidatesCountNotReached(uint actual, uint expected);
    error VotingEndTimeNotReached();
    error VotingEndTimeReached();

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    enum VoteState {
        NEW,
        STARTED,
        ENDED,
        WINNER_CHOSEN
    }

    address public owner;
    mapping(uint => Candidate) private candidates;
    mapping(address => bool) public hasVoted;
    uint public candidatesCount;
    Candidate public winner;

    uint public minCandidatesCount;
    uint public votingLength;
    uint public voteStartTimestamp;
    uint public voteEndTimestamp;
    VoteState public voteState = VoteState.NEW;

    event CandidateAdded(uint candidateId, string name);
    event VoteCasted(uint candidateId, address voter);
    event WinnerChosen(uint candidateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyInVoteState(VoteState _voteState) {
        if(voteState != _voteState) {
            revert WrongVotingState(voteState, _voteState);
        }
        _;
    }

    constructor(uint256 _minCandidatesCount, uint256 _votingLength) {
        owner = msg.sender;
        minCandidatesCount = _minCandidatesCount;
        votingLength = _votingLength;
    }

    function addCandidate(string memory _name) public onlyOwner onlyInVoteState(VoteState.NEW) {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }

    function startVoting() external onlyOwner onlyInVoteState(VoteState.NEW) {
        if(minCandidatesCount > candidatesCount) {
            revert MinimumCandidatesCountNotReached(candidatesCount, minCandidatesCount);
        }
        voteState = VoteState.STARTED;
        voteStartTimestamp = block.timestamp;
        voteEndTimestamp = block.timestamp + votingLength;
    }

    function vote(uint _candidateId) public onlyInVoteState(VoteState.STARTED) {
        require(!hasVoted[msg.sender], "Voter has already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        if(block.timestamp > voteEndTimestamp) {
            revert VotingEndTimeReached();
        }

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;

        emit VoteCasted(_candidateId, msg.sender);
    }

    function endVoting() external onlyOwner onlyInVoteState(VoteState.STARTED) {
        if(voteEndTimestamp > block.timestamp) {
            revert VotingEndTimeNotReached();
        }
        voteState = VoteState.ENDED;
    }

    function chooseTheWinner() public onlyOwner onlyInVoteState(VoteState.ENDED) {
        uint winnerId;
        uint highestVoteCount;
        Candidate memory currentCandidate;
        for(uint i = 1; i <= candidatesCount; i++) { //index should be from 1 and <= candidatesCount
            currentCandidate = candidates[i];
            if(currentCandidate.voteCount > highestVoteCount) {
                highestVoteCount = currentCandidate.voteCount;
                winnerId = currentCandidate.id;
            }
        }
        winner = candidates[winnerId];
        voteState = VoteState.WINNER_CHOSEN;
        emit WinnerChosen(winnerId);
    }

    function getCandidateVoteCount(uint _candidateId) public view onlyOwner returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }
}