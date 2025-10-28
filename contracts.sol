// SPDX-License-Identifier: MIT
}


// claim exactly 1% of principal. Allowed only once per 24h.
function claim() external nonReentrant {
Stake storage s = stakes[msg.sender];
require(s.exists && s.principal > 0, "no-stake");
require(block.timestamp >= s.lastClaim + 1 days, "claim-too-soon");


uint256 reward = (s.principal * 1) / ROI_BASIS; // 1%
require(reward > 0, "zero-reward");
require(stakingToken.transfer(msg.sender, reward), "reward-transfer-failed");


s.lastClaim = block.timestamp;
emit Claimed(msg.sender, reward);
}


// Unstake: pay rewards for completed 24h intervals since last claim then return principal
function unstake() external nonReentrant {
Stake storage s = stakes[msg.sender];
require(s.exists && s.principal > 0, "no-stake");


uint256 principal = s.principal;


// compute how many full 24h periods have passed since lastClaim
uint256 elapsed = block.timestamp - s.lastClaim;
uint256 fullDays = elapsed / 1 days;
uint256 reward = 0;
if (fullDays > 0) {
// reward = fullDays * 1% * principal
reward = (principal * fullDays) / ROI_BASIS;
if (reward > 0) {
require(stakingToken.transfer(msg.sender, reward), "reward-transfer-failed");
}
}


// return principal
require(stakingToken.transfer(msg.sender, principal), "unstake-transfer-failed");


// clear stake
s.principal = 0;
s.lastClaim = 0;
s.exists = false;


emit Unstaked(msg.sender, principal, reward);
}


// view helpers
function pendingReward(address user) external view returns (uint256) {
Stake memory s = stakes[user];
if (!s.exists || s.principal == 0) return 0;
// only full 24h blocks count
uint256 elapsed = block.timestamp - s.lastClaim;
uint256 fullDays = elapsed / 1 days;
return (s.principal * fullDays) / ROI_BASIS;
}
}
