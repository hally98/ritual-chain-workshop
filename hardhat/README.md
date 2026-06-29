# Commit-Reveal Bounty System

## What Problem Does This Solve?

In a normal bounty system, answers are public on-chain. Anyone can read your answer and submit a slightly improved version before judging. That's unfair.

This system uses a commit-reveal pattern to keep answers secret until after the submission deadline.

---

## The Lifecycle (Step by Step)

1. SETUP — Owner creates bounty + puts ETH reward → createBounty()
2. COMMIT — Participants submit a hash of their answer → submitCommitment()
3. REVEAL — After commit deadline, everyone reveals real answer → revealAnswer()
4. JUDGE — AI reads all answers and picks winner → judgeAll()
5. FINALIZE — Winner gets paid → finalizeWinner()

---

## How Commitments Work

A commitment hash is like a fingerprint of your answer. You create it BEFORE submitting:

commitment = keccak256(answer + salt + yourAddress + bountyId)

- answer — your actual answer
- salt — a random secret number you make up
- yourAddress — prevents others from copying your hash
- bountyId — ties it to a specific bounty

You submit ONLY the commitment hash. Nobody can reverse it to find your answer.
When you reveal, the contract re-runs the same formula and checks it matches.

---

## Contract Functions

### createBounty(question, commitDeadline, revealDeadline)
- Called by the bounty owner
- Must send ETH with the call as the reward

### submitCommitment(bountyId, commitment)
- Called by participants during the commit phase
- Only the hash is stored — answer is secret

### revealAnswer(bountyId, answer, salt)
- Called AFTER commit deadline, BEFORE reveal deadline
- Contract verifies the hash matches

### judgeAll(bountyId, llmInput)
- Called by bounty owner after reveal deadline
- Collects all valid revealed answers for AI judging

### finalizeWinner(bountyId, winnerIndex)
- Called by owner after AI returns winner
- Pays out the reward to the winning address

---

## Architecture Note

| What | Where stored | Visible? |
|------|-------------|---------|
| Commitment hash | On-chain | Yes — but unreadable |
| Actual answer | Off-chain | No — until reveal |
| Revealed answer | On-chain | Yes |
| Winner + payment | On-chain | Yes |

---

## Reflection

In a bounty system, the commitment hash and deadlines should be fully public so anyone can verify the process is fair. The actual answers must stay hidden during the submission phase to prevent copying — this is exactly what the commit-reveal pattern achieves. The winner selection should be decided by AI because it removes human bias and can process many answers consistently at once. However, humans should decide the bounty question, reward amount, and deadlines, since these require judgment about value and context. The payment execution should be on-chain and automatic once a winner is selected, removing the possibility of the owner refusing to pay. Dispute resolution should involve human review since edge cases require nuanced judgment. The ideal system combines AI objectivity for judging with human intent-setting and blockchain enforcement for payment.
