# BitWise - Next-Generation Bitcoin Prediction Markets

[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-purple)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-blue)](https://clarity-lang.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

BitWise is a revolutionary decentralized prediction platform that empowers users to monetize Bitcoin market insights through sophisticated prediction mechanics. Built on the Stacks blockchain, BitWise transforms cryptocurrency forecasting into a profitable, transparent prediction ecosystem where traders can stake STX tokens on Bitcoin price movements and earn proportional rewards based on prediction accuracy.

## Features

### 🎯 Core Functionality

- **Decentralized Prediction Markets**: Create and participate in Bitcoin price prediction markets
- **Transparent Settlement**: Oracle-driven automated settlement mechanisms
- **Proportional Rewards**: Earn rewards based on prediction accuracy and market participation
- **Real-time Integration**: Seamless oracle integration for accurate price feeds

### 🔒 Security & Governance

- **Institutional-Grade Security**: Comprehensive error handling and validation
- **Access Control**: Multi-level authorization system
- **Transparent Fees**: Dynamic fee structures with clear distribution
- **Decentralized Operations**: Non-custodial design with user fund protection

### 💰 Economic Model

- **Minimum Stake**: 1 STX minimum participation requirement
- **Platform Fee**: 2% protocol fee for platform sustainability
- **Proportional Distribution**: Winnings distributed based on stake percentage
- **Treasury Management**: Automated fee collection and withdrawal system

## Technical Architecture

### Smart Contract Structure

```
BitWise Contract
├── Market Management
│   ├── Market Creation
│   ├── Market Settlement
│   └── Market Queries
├── Prediction System
│   ├── Prediction Submission
│   ├── Stake Management
│   └── Position Tracking
├── Reward Distribution
│   ├── Proportional Calculation
│   ├── Fee Distribution
│   └── Claim Processing
└── Administration
    ├── Oracle Management
    ├── Parameter Updates
    └── Treasury Operations
```

### Data Structures

#### Market Registry

```clarity
{
  initial-btc-price: uint,      ;; Opening Bitcoin price
  final-btc-price: uint,        ;; Oracle-settled closing price
  bullish-stake-total: uint,    ;; Total STX staked on "up"
  bearish-stake-total: uint,    ;; Total STX staked on "down"
  market-start-height: uint,    ;; Market opening block
  market-end-height: uint,      ;; Market closing block
  settlement-completed: bool    ;; Settlement status
}
```

#### Trader Positions

```clarity
{
  direction: (string-ascii 4),  ;; "up" or "down"
  staked-amount: uint,          ;; STX committed
  rewards-claimed: bool         ;; Payout status
}
```

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development tool
- [Node.js](https://nodejs.org/) - JavaScript runtime
- [TypeScript](https://www.typescriptlang.org/) - For testing

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/bright-folorunsho/bitwise.git
   cd bitwise
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Verify contract integrity**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Project Structure

```
bitwise/
├── contracts/
│   ├── bitwise.clar          # Main contract implementation
│   └── 1.clar               # Contract alias
├── tests/
│   └── bitwise.test.ts       # Comprehensive test suite
├── settings/
│   ├── Devnet.toml          # Development network config
│   ├── Testnet.toml         # Testnet configuration
│   └── Mainnet.toml         # Mainnet configuration
├── Clarinet.toml            # Project configuration
├── package.json             # Node.js dependencies
├── tsconfig.json            # TypeScript configuration
└── vitest.config.js         # Testing configuration
```

## Usage

### Market Creation

Only contract owners can create new prediction markets:

```clarity
(contract-call? .bitwise initialize-market
  u50000000  ;; Opening BTC price (50,000 USD)
  u1000      ;; Start block height
  u2000      ;; End block height
)
```

### Submitting Predictions

Users can stake STX on Bitcoin price direction:

```clarity
(contract-call? .bitwise submit-prediction
  u0         ;; Market ID
  "up"       ;; Price direction ("up" or "down")
  u1000000   ;; Stake amount (1 STX)
)
```

### Market Settlement

Oracle settles markets with final Bitcoin price:

```clarity
(contract-call? .bitwise settle-market
  u0         ;; Market ID
  u55000000  ;; Final BTC price (55,000 USD)
)
```

### Claiming Rewards

Winners can claim proportional rewards:

```clarity
(contract-call? .bitwise claim-rewards u0) ;; Market ID
```

### Query Functions

Access market and position data:

```clarity
;; Get market information
(contract-call? .bitwise get-market-data u0)

;; Get trader position
(contract-call? .bitwise get-trader-position u0 'ST1TRADER...)

;; Get platform settings
(contract-call? .bitwise get-platform-settings)

;; Get treasury balance
(contract-call? .bitwise get-treasury-balance)
```

## Administration

### Oracle Management

Update oracle address for price feeds:

```clarity
(contract-call? .bitwise update-oracle-address 'ST1NEWORACLE...)
```

### Parameter Configuration

Adjust platform parameters:

```clarity
;; Update minimum stake
(contract-call? .bitwise update-minimum-stake u2000000)

;; Update platform fee (percentage)
(contract-call? .bitwise update-fee-rate u3)
```

### Treasury Operations

Withdraw accumulated platform fees:

```clarity
(contract-call? .bitwise withdraw-treasury u1000000)
```

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR_UNAUTHORIZED | Access denied |
| u101 | ERR_RESOURCE_NOT_FOUND | Resource unavailable |
| u102 | ERR_INVALID_PREDICTION | Prediction format error |
| u103 | ERR_MARKET_INACTIVE | Market closed/expired |
| u104 | ERR_REWARDS_CLAIMED | Already distributed |
| u105 | ERR_INSUFFICIENT_FUNDS | Balance too low |
| u106 | ERR_INVALID_PARAMS | Parameter validation failed |

## Testing

### Run Test Suite

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Check contract syntax
clarinet check
```

### Test Categories

- **Market Creation Tests**: Validate market initialization
- **Prediction Tests**: Test prediction submission logic
- **Settlement Tests**: Verify oracle settlement mechanics
- **Reward Tests**: Validate proportional reward distribution
- **Administrative Tests**: Test governance functions
- **Edge Case Tests**: Handle error conditions and edge cases

## Security Considerations

### Access Control

- Contract owner permissions for market creation and administration
- Oracle-only settlement authorization
- User-specific reward claiming

### Validation Mechanisms

- Comprehensive parameter validation
- Market timing enforcement
- Balance verification before transfers
- Double-spending prevention

### Economic Security

- Minimum stake requirements
- Platform fee sustainability
- Proportional reward distribution
- Treasury protection mechanisms

## Development

### Local Development

1. **Start local environment**

   ```bash
   clarinet console
   ```

2. **Deploy contracts**

   ```clarity
   ::deploy_contracts
   ```

3. **Interact with contracts**

   ```clarity
   (contract-call? .bitwise get-platform-settings)
   ```

### Testing Strategy

- **Unit Tests**: Individual function validation
- **Integration Tests**: End-to-end workflow testing
- **Edge Case Tests**: Error condition handling
- **Performance Tests**: Gas optimization verification

## Roadmap

### Phase 1: Core Platform ✅

- [x] Basic prediction market mechanics
- [x] Oracle integration
- [x] Reward distribution system
- [x] Administrative functions

### Phase 2: Enhanced Features (Q1 2025)

- [ ] Multi-asset prediction markets
- [ ] Advanced prediction types (price ranges, time-based)
- [ ] Liquidity mining programs
- [ ] Community governance integration

### Phase 3: Ecosystem Expansion (Q2 2025)

- [ ] Mobile application
- [ ] API for third-party integrations
- [ ] Advanced analytics dashboard
- [ ] Institutional trading features

### Phase 4: Advanced DeFi (Q3 2025)

- [ ] Prediction market derivatives
- [ ] Cross-chain integration
- [ ] Automated market making
- [ ] Insurance mechanisms

## Contributing

We welcome contributions to BitWise! Please follow these guidelines:

1. **Fork the repository**
2. **Create feature branch** (`git checkout -b feature/amazing-feature`)
3. **Write tests** for new functionality
4. **Ensure all tests pass** (`npm test`)
5. **Commit changes** (`git commit -m 'Add amazing feature'`)
6. **Push to branch** (`git push origin feature/amazing-feature`)
7. **Open Pull Request**

### Development Guidelines

- Follow Clarity best practices
- Maintain comprehensive test coverage
- Document all public functions
- Use clear, descriptive variable names
- Implement proper error handling

## Documentation

### API Reference

- [Contract Functions](docs/api.md)
- [Error Handling](docs/errors.md)
- [Testing Guide](docs/testing.md)

### Tutorials

- [Getting Started](docs/quickstart.md)
- [Market Creation](docs/markets.md)
- [Oracle Integration](docs/oracles.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
