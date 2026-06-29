# Test Plan — Commit-Reveal Bounty

## Test 1: Full Successful Flow
- Owner creates bounty with ETH reward
- Alice and Bob both commit hashes
- Both reveal after commit deadline
- Owner calls judgeAll
- Owner calls finalizeWinner — Alice gets paid
- Expected: Alice receives full reward ✅

## Test 2: Commit After Deadline
- Alice tries to commit after the commit deadline
- Expected: Transaction reverts "Commit phase is over" ✅

## Test 3: Double Commitment
- Alice commits twice to same bounty
- Expected: Transaction reverts "Already committed" ✅

## Test 4: Reveal Before Commit Deadline
- Alice tries to reveal before commit deadline passes
- Expected: Transaction reverts "Commit phase not over yet" ✅

## Test 5: Reveal After Reveal Deadline
- Alice commits but reveals too late
- Expected: Transaction reverts "Reveal phase is over" ✅

## Test 6: Wrong Answer on Reveal
- Alice commits hash of "My answer"
- Alice tries to reveal "A DIFFERENT answer"
- Expected: Transaction reverts "Commitment does not match" ✅

## Test 7: Wrong Salt on Reveal
- Alice commits with saltA but reveals with saltB
- Expected: Transaction reverts "Commitment does not match" ✅

## Test 8: Reveal Without Prior Commitment
- Carol never committed but tries to reveal
- Expected: Transaction reverts "You never submitted a commitment" ✅

## Test 9: Double Reveal
- Alice reveals successfully then tries again
- Expected: Transaction reverts "Already revealed" ✅

## Test 10: Non-Owner Tries to Judge
- Alice tries calling judgeAll instead of owner
- Expected: Transaction reverts "Only bounty owner can judge" ✅

## Test 11: Judge Before Reveal Deadline
- Owner tries judgeAll before reveal deadline
- Expected: Transaction reverts "Reveal phase not over yet" ✅

## Test 12: Invalid Winner Index
- Only 2 participants but owner calls finalizeWinner(0, 5)
- Expected: Transaction reverts "Invalid winner index" ✅

## Test 13: Double Finalize
- Owner finalizes then tries again
- Expected: Transaction reverts "Already finalized" ✅

## Test 14: No Valid Submissions
- Nobody commits, owner calls judgeAll
- Expected: Transaction reverts "No valid submissions to judge" ✅
