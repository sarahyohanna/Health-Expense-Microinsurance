# 🏥 Health Expense Microinsurance

*A decentralized insurance pool for emergency medical expenses on the Stacks blockchain* 💊

## 🌟 Overview

Health Expense Microinsurance is a community-driven smart contract that enables individuals to pool their funds together for protection against emergency medical costs. By contributing to a shared insurance pool, members can submit claims for medical expenses and receive financial support when they need it most.

## ✨ Key Features

- 💰 **Pooled Contributions**: Members contribute STX to build a shared insurance fund
- 🏥 **Medical Claims**: Submit claims for emergency medical expenses with descriptions
- ✅ **Claim Processing**: Contract owner reviews and approves/rejects claims
- 📊 **Coverage Calculation**: Fair coverage based on contribution percentage
- ⚙️ **Configurable Settings**: Adjustable minimum contributions and maximum claim amounts
- 🚨 **Emergency Controls**: Owner can deactivate members and emergency withdraw funds

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) for testing
- STX tokens for contributions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Health-Expense-Microinsurance
```

2. Install dependencies:
```bash
npm install
```

3. Run tests:
```bash
clarinet test
```

## 📖 Usage Guide

### 👥 For Members

#### 1. Join the Insurance Pool
```clarity
(contract-call? .health-expense-microinsurance join-pool u2000000) ;; 2 STX minimum
```

#### 2. Make Additional Contributions
```clarity
(contract-call? .health-expense-microinsurance contribute-to-pool u1000000) ;; 1 STX
```

#### 3. Submit a Medical Claim
```clarity
(contract-call? .health-expense-microinsurance submit-claim u5000000 "Emergency room visit for broken arm")
```

#### 4. Check Your Coverage
```clarity
(contract-call? .health-expense-microinsurance calculate-member-coverage tx-sender)
```

### 👑 For Contract Owner

#### 1. Approve Claims
```clarity
(contract-call? .health-expense-microinsurance approve-claim u1) ;; Approve claim ID 1
```

#### 2. Reject Claims
```clarity
(contract-call? .health-expense-microinsurance reject-claim u2) ;; Reject claim ID 2
```

#### 3. Update Settings
```clarity
(contract-call? .health-expense-microinsurance update-minimum-contribution u1500000) ;; 1.5 STX
(contract-call? .health-expense-microinsurance update-maximum-claim u10000000) ;; 10 STX max
```

## 📋 Contract Functions

### 🔍 Read-Only Functions

| Function | Description | Returns |
|----------|-------------|----------|
| `get-pool-balance` | Current total pool balance | `uint` |
| `get-member-info` | Member details and contribution history | `{contribution, join-block, active}` |
| `is-member` | Check if address is active member | `bool` |
| `get-claim-info` | Detailed information about a claim | `{claimant, amount, description, status, submit-block, process-block}` |
| `get-member-claims` | List of claim IDs for a member | `(list 50 uint)` |
| `get-contract-settings` | Current contract configuration | `{minimum-contribution, maximum-claim-amount, claim-period-blocks, total-members, claim-counter}` |
| `get-pending-claims` | List of all pending claim IDs | `(list uint)` |
| `calculate-member-coverage` | Maximum coverage based on contributions | `uint` |
| `get-claim-statistics` | Summary of all claim statuses | `{total-claims, pending-claims, approved-claims, rejected-claims}` |

### ✍️ Public Functions

| Function | Description | Access |
|----------|-------------|--------|
| `join-pool` | Join insurance pool with initial contribution | Anyone |
| `contribute-to-pool` | Add funds to existing membership | Members only |
| `submit-claim` | Submit medical expense claim | Members only |
| `approve-claim` | Approve pending claim for payout | Owner only |
| `reject-claim` | Reject pending claim | Owner only |
| `deactivate-member` | Remove member from pool | Owner only |
| `update-minimum-contribution` | Change minimum joining amount | Owner only |
| `update-maximum-claim` | Change maximum claim amount | Owner only |
| `update-claim-period` | Change claim expiration period | Owner only |
| `emergency-withdraw` | Withdraw all funds (emergency only) | Owner only |

## ⚙️ Configuration

### Default Settings
- **Minimum Contribution**: 1 STX (1,000,000 microSTX)
- **Maximum Claim Amount**: 50 STX (50,000,000 microSTX)  
- **Claim Period**: 4,320 blocks (~30 days)

### Error Codes
- `u100`: Owner only operation
- `u101`: Not a member or inactive
- `u102`: Insufficient pool funds
- `u103`: Invalid amount
- `u104`: Claim not found
- `u105`: Claim already processed
- `u106`: Invalid claim
- `u107`: Member already exists
- `u108`: Claim expired

## 🧪 Testing

Run the test suite to verify contract functionality:

```bash
clarinet test
```

Tests cover:
- ✅ Pool joining and contributions
- ✅ Claim submission and processing
- ✅ Access control and permissions
- ✅ Edge cases and error handling

## 🔐 Security Considerations

- 🛡️ **Access Control**: Critical functions restricted to contract owner
- 💰 **Fund Safety**: All transfers use secure STX transfer functions
- ⏰ **Claim Expiration**: Claims expire after set period to prevent stale requests
- 🚨 **Emergency Controls**: Owner can withdraw funds in emergency situations

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License.

## 🎯 Roadmap

- [ ] 🤖 Automated claim processing with oracles
- [ ] 🗳️ Democratic governance for claim approvals
- [ ] 📱 Web interface for easy interaction
- [ ] 📊 Advanced analytics and reporting
- [ ] 🔗 Integration with health data providers

---

*Built with ❤️ on Stacks blockchain*
