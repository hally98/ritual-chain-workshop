// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CommitRevealBounty {

    struct Bounty {
        address owner;
        string question;
        uint256 reward;
        uint256 commitDeadline;
        uint256 revealDeadline;
        bool finalized;
        address[] participants;
    }

    struct Submission {
        bytes32 commitment;
        string answer;
        bool committed;
        bool revealed;
    }

    uint256 public bountyCount;
    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => mapping(address => Submission)) public submissions;

    event BountyCreated(uint256 indexed bountyId, address owner, string question, uint256 reward);
    event CommitmentSubmitted(uint256 indexed bountyId, address participant);
    event AnswerRevealed(uint256 indexed bountyId, address participant, string answer);
    event WinnerFinalized(uint256 indexed bountyId, address winner, uint256 reward);
    event JudgingStarted(uint256 indexed bountyId, address[] participants, string[] answers);

    modifier bountyExists(uint256 bountyId) {
        require(bountyId < bountyCount, "Bounty does not exist");
        _;
    }

    function createBounty(
        string calldata question,
        uint256 commitDeadline,
        uint256 revealDeadline
    ) external payable returns (uint256 bountyId) {
        require(msg.value > 0, "Must send ETH as reward");
        require(commitDeadline > block.timestamp, "Commit deadline must be in the future");
        require(revealDeadline > commitDeadline, "Reveal deadline must be after commit deadline");

        bountyId = bountyCount++;

        bounties[bountyId] = Bounty({
            owner: msg.sender,
            question: question,
            reward: msg.value,
            commitDeadline: commitDeadline,
            revealDeadline: revealDeadline,
            finalized: false,
            participants: new address[](0)
        });

        emit BountyCreated(bountyId, msg.sender, question, msg.value);
    }

    function submitCommitment(
        uint256 bountyId,
        bytes32 commitment
    ) external bountyExists(bountyId) {
        Bounty storage bounty = bounties[bountyId];
        require(block.timestamp <= bounty.commitDeadline, "Commit phase is over");
        require(!submissions[bountyId][msg.sender].committed, "Already committed");

        submissions[bountyId][msg.sender] = Submission({
            commitment: commitment,
            answer: "",
            committed: true,
            revealed: false
        });

        emit CommitmentSubmitted(bountyId, msg.sender);
    }

    function revealAnswer(
        uint256 bountyId,
        string calldata answer,
        bytes32 salt
    ) external bountyExists(bountyId) {
        Bounty storage bounty = bounties[bountyId];
        require(block.timestamp > bounty.commitDeadline, "Commit phase not over yet");
        require(block.timestamp <= bounty.revealDeadline, "Reveal phase is over");

        Submission storage sub = submissions[bountyId][msg.sender];
        require(sub.committed, "You never submitted a commitment");
        require(!sub.revealed, "Already revealed");

        bytes32 expectedCommitment = keccak256(
            abi.encodePacked(answer, salt, msg.sender, bountyId)
        );
        require(sub.commitment == expectedCommitment, "Commitment does not match");

        sub.answer = answer;
        sub.revealed = true;
        bounty.participants.push(msg.sender);

        emit AnswerRevealed(bountyId, msg.sender, answer);
    }

    function judgeAll(
        uint256 bountyId,
        bytes calldata llmInput
    ) external bountyExists(bountyId) {
        Bounty storage bounty = bounties[bountyId];
        require(msg.sender == bounty.owner, "Only bounty owner can judge");
        require(block.timestamp > bounty.revealDeadline, "Reveal phase not over yet");
        require(!bounty.finalized, "Already finalized");
        require(bounty.participants.length > 0, "No valid submissions to judge");

        string[] memory answers = new string[](bounty.participants.length);
        for (uint256 i = 0; i < bounty.participants.length; i++) {
            answers[i] = submissions[bountyId][bounty.participants[i]].answer;
        }

        llmInput;

        emit JudgingStarted(bountyId, bounty.participants, answers);
    }

    function finalizeWinner(
        uint256 bountyId,
        uint256 winnerIndex
    ) external bountyExists(bountyId) {
        Bounty storage bounty = bounties[bountyId];
        require(msg.sender == bounty.owner, "Only bounty owner can finalize");
        require(!bounty.finalized, "Already finalized");
        require(winnerIndex < bounty.participants.length, "Invalid winner index");

        bounty.finalized = true;
        address winner = bounty.participants[winnerIndex];
        uint256 reward = bounty.reward;

        (bool success, ) = winner.call{value: reward}("");
        require(success, "Payment failed");

        emit WinnerFinalized(bountyId, winner, reward);
    }

    function getParticipants(uint256 bountyId)
        external
        view
        bountyExists(bountyId)
        returns (address[] memory)
    {
        return bounties[bountyId].participants;
    }

    function computeCommitment(
        string calldata answer,
        bytes32 salt,
        address participant,
        uint256 bountyId
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(answer, salt, participant, bountyId));
    }
}
