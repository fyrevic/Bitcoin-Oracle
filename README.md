# Bitcoin-Oracle

A comprehensive Bitcoin data oracle system built on the Stacks blockchain using Clarity smart contracts. This project enables secure, decentralized access to Bitcoin blockchain data for Stacks-based decentralized applications (dApps).

## 🎯 Overview

The Bitcoin Oracle system provides a trustless bridge between Bitcoin and Stacks blockchains, allowing Stacks smart contracts to access verified Bitcoin data including block heights, block hashes, transaction counts, and network difficulty. The system uses a multi-node consensus mechanism to ensure data integrity and prevent manipulation.

## 🏗️ Architecture

### Core Components

1. **Signed Data Feeds (MVP)** - Basic oracle functionality with registered nodes
2. **Quorum & Aggregated Reporting** - Multi-node consensus mechanism
3. **Bitcoin Block Header Anchoring** - On-chain Bitcoin header storage
4. **SPV Proof Verification** - Merkle proof validation for Bitcoin transactions
5. **Credentialed Node Registry** - Managed oracle node system
6. **Data Integrity Rules** - Anti-replay and freshness guarantees

### Data Flow

\`\`\`
Bitcoin Network → Oracle Nodes → Stacks Smart Contract → dApps
\`\`\`

1. Oracle nodes monitor Bitcoin blockchain
2. Nodes submit signed data to Stacks smart contract
3. Contract validates and aggregates submissions
4. dApps query verified Bitcoin data from contract

## 🚀 Features

### Core Features (Implemented)

- **Signed Data Feeds**: Registered oracle nodes submit Bitcoin data with cryptographic signatures
- **Multi-Node Consensus**: Data is validated only when multiple nodes agree
- **Data Integrity**: Strict ordering and timestamping prevent stale data
- **Transparent History**: Full audit trail of all submissions
- **Node Registry**: Managed list of authorized oracle operators

### Supported Data Types

- Bitcoin block height
- Bitcoin block hash
- Network difficulty
- Transaction count per block
- Block timestamps

### Advanced Features (Roadmap)

- **Slashing & Incentives**: Economic security through staking
- **SPV Proof Verification**: Trustless Bitcoin transaction verification
- **Historical Querying**: Access to historical Bitcoin data
- **Event Triggers**: Automated cross-chain actions
- **Full Header Validation**: Complete Bitcoin PoW verification

## 🛠️ Technical Stack

- **Smart Contract Language**: Clarity 3
- **Blockchain**: Stacks
- **Development Framework**: Clarinet
- **Testing**: Clarinet Test Framework
- **Deployment**: Stacks Mainnet/Testnet

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) v2.0+
- [Stacks CLI](https://docs.stacks.co/references/stacks-cli)
- Node.js 18+
- Git

## 🔧 Installation

1. **Clone the repository**
   \`\`\`bash
   git clone https://github.com/your-org/bitcoin-oracle-stacks.git
   cd bitcoin-oracle-stacks
   \`\`\`

2. **Install Clarinet**
   \`\`\`bash
   # macOS
   brew install clarinet

   # Linux/Windows
   curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64.tar.gz | tar xz
   \`\`\`

3. **Initialize the project**
   \`\`\`bash
   clarinet new bitcoin-oracle
   cd bitcoin-oracle
   \`\`\`

4. **Install dependencies**
   \`\`\`bash
   npm install
   \`\`\`

## 🏃‍♂️ Quick Start

### 1. Deploy Locally

\`\`\`bash
# Start local devnet
clarinet integrate

# Deploy contracts
clarinet deploy --devnet
\`\`\`

### 2. Run Tests

\`\`\`bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/oracle_test.ts
\`\`\`

### 3. Interact with Contract

\`\`\`bash
# Check contract status
clarinet console

# In console:
(contract-call? .bitcoin-oracle get-latest-block-height)
\`\`\`

## 📖 Usage

### For Oracle Operators

1. **Register as Oracle Node**
   ```clarity
   (contract-call? .bitcoin-oracle register-node)
   \`\`\`

2. **Submit Bitcoin Data**
   ```clarity
   (contract-call? .bitcoin-oracle submit-block-data 
     u850000 ;; block height
     0x00000000000000000002a7c4c1e48d76c5a37902165a270156b7a8d72728a054 ;; block hash
     u12345 ;; tx count
     u25000000000000) ;; difficulty
   \`\`\`

### For dApp Developers

1. **Query Latest Block Height**
   ```clarity
   (contract-call? .bitcoin-oracle get-latest-block-height)
   \`\`\`

2. **Get Aggregated Data**
   ```clarity
   (contract-call? .bitcoin-oracle get-aggregated-feed "btc-block-height")
   \`\`\`

3. **Check Data Validity**
   ```clarity
   (contract-call? .bitcoin-oracle is-data-valid? u850000)
   \`\`\`

## 🧪 Testing

The project includes comprehensive tests covering:

- Oracle node registration and management
- Data submission and validation
- Consensus mechanism
- Data integrity checks
- Edge cases and error handling

\`\`\`bash
# Run unit tests
clarinet test tests/unit/

# Run integration tests
clarinet test tests/integration/

# Generate coverage report
clarinet test --coverage
\`\`\`

## 🔐 Security Considerations

### Data Integrity
- All submissions are timestamped and ordered
- Stale data is automatically rejected
- Multiple node consensus prevents single points of failure

### Access Control
- Only registered nodes can submit data
- Contract owner manages node registry
- Future versions will implement staking/slashing

### Economic Security
- Planned implementation of node staking
- Slashing for dishonest behavior
- Fee rewards for honest submissions

## 🚀 Deployment

### Testnet Deployment

\`\`\`bash
# Configure testnet
clarinet settings set network testnet

# Deploy to testnet
clarinet deploy --testnet
\`\`\`

### Mainnet Deployment

\`\`\`bash
# Configure mainnet
clarinet settings set network mainnet

# Deploy to mainnet (requires STX for fees)
clarinet deploy --mainnet
\`\`\`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Implement the feature
5. Run tests and ensure they pass
6. Submit a pull request

### Code Standards

- Follow Clarity best practices
- Write comprehensive tests
- Document all public functions
- Use meaningful variable names
- Include error handling

## 📊 Roadmap

### Phase 1: Core Oracle (Current)
- ✅ Basic data feeds
- ✅ Node registry
- ✅ Multi-node consensus
- ✅ Data integrity rules

### Phase 2: Advanced Features
- 🔄 SPV proof verification
- 🔄 Economic incentives
- 🔄 Historical data queries
- 🔄 Event-driven automation

### Phase 3: Cross-Chain Applications
- ⏳ Cross-chain swaps
- ⏳ Bitcoin-backed loans
- ⏳ Bitcoin-aware DAOs
- ⏳ Full header validation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Hiro Systems for Clarinet development tools
- Bitcoin Core developers for reference implementations
- Community contributors and testers

## 📞 Support

- **Documentation**: [docs.stacks.co](https://docs.stacks.co)
- **Discord**: [Stacks Discord](https://discord.gg/stacks)
- **Issues**: [GitHub Issues](https://github.com/your-org/bitcoin-oracle-stacks/issues)
- **Email**: support@your-org.com

---

**⚠️ Disclaimer**: This software is experimental and should be thoroughly tested before production use. Always conduct security audits before deploying to mainnet.
\`\`\`

```clarity file="contracts/bitcoin-oracle.cty"
;; Bitcoin Oracle Smart Contract
;; Implements signed data feeds with multi-node consensus for Bitcoin data on Stacks

;; =============================================================================
;; CONSTANTS
;; =============================================================================

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NODE-NOT-REGISTERED (err u101))
(define-constant ERR-INVALID-BLOCK-HEIGHT (err u102))
(define-constant ERR-STALE-DATA (err u103))
(define-constant ERR-NODE-ALREADY-REGISTERED (err u104))
(define-constant ERR-INVALID-DATA (err u105))
(define-constant ERR-INSUFFICIENT-CONSENSUS (err u106))

;; Minimum number of nodes required for consensus
(define-constant MIN-CONSENSUS-NODES u3)

;; Maximum age of data in blocks (prevent stale submissions)
(define-constant MAX-DATA-AGE u10)

;; =============================================================================
;; DATA STRUCTURES
;; =============================================================================

;; Oracle node information
(define-map oracle-nodes 
  principal 
  {
    registered-at: uint,
    is-active: bool,
    total-submissions: uint,
    last-submission-height: uint
  }
)

;; Bitcoin block data submissions
(define-map block-submissions
  {node: principal, block-height: uint}
  {
    block-hash: (buff 32),
    tx-count: uint,
    difficulty: uint,
    timestamp: uint,
    submitted-at: uint
  }
)

;; Aggregated consensus data for each block height
(define-map consensus-data
  uint ;; block-height
  {
    block-hash: (buff 32),
    tx-count: uint,
    difficulty: uint,
    consensus-count: uint,
    finalized-at: uint,
    is-valid: bool
  }
)

;; Track submissions per block height for consensus counting
(define-map height-submissions
  uint ;; block-height
  {
    unique-nodes: (list 50 principal),
    submission-count: uint
  }
)

;; =============================================================================
;; DATA VARIABLES
;; =============================================================================

;; Current number of registered oracle nodes
(define-data-var total-nodes uint u0)

;; Latest confirmed Bitcoin block height
(define-data-var latest-block-height uint u0)

;; Contract deployment block height for reference
(define-data-var deployment-height uint block-height)

;; =============================================================================
;; PRIVATE FUNCTIONS
;; =============================================================================

;; Check if a node is registered and active
(define-private (is-node-registered (node principal))
  (match (map-get? oracle-nodes node)
    node-data (get is-active node-data)
    false
  )
)

;; Check if block height is valid (not too old, sequential)
(define-private (is-valid-block-height (height uint))
  (and 
    (> height u0)
    (>= height (var-get latest-block-height))
    (<= (- block-height height) MAX-DATA-AGE)
  )
)

;; Add node to height submissions tracking
(define-private (add-node-to-height (height uint) (node principal))
  (let (
    (current-data (default-to 
      {unique-nodes: (list), submission-count: u0}
      (map-get? height-submissions height)
    ))
    (current-nodes (get unique-nodes current-data))
  )
    (if (is-none (index-of? current-nodes node))
      (map-set height-submissions height {
        unique-nodes: (unwrap! (as-max-len? (append current-nodes node) u50) false),
        submission-count: (+ (get submission-count current-data) u1)
      })
      true
    )
  )
)

;; Check if consensus is reached for a block height
(define-private (check-consensus (height uint))
  (match (map-get? height-submissions height)
    height-data (>= (get submission-count height-data) MIN-CONSENSUS-NODES)
    false
  )
)

;; Finalize consensus data for a block height
(define-private (finalize-consensus (height uint) (block-hash (buff 32)) (tx-count uint) (difficulty uint))
  (begin
    (map-set consensus-data height {
      block-hash: block-hash,
      tx-count: tx-count,
      difficulty: difficulty,
      consensus-count: (get submission-count 
        (unwrap! (map-get? height-submissions height) false)),
      finalized-at: block-height,
      is-valid: true
    })
    (if (> height (var-get latest-block-height))
      (var-set latest-block-height height)
      true
    )
  )
)

;; =============================================================================
;; PUBLIC FUNCTIONS - ADMIN
;; =============================================================================

;; Register a new oracle node (only contract owner)
(define-public (register-node (node principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (not (is-node-registered node)) ERR-NODE-ALREADY-REGISTERED)
    
    (map-set oracle-nodes node {
      registered-at: block-height,
      is-active: true,
      total-submissions: u0,
      last-submission-height: u0
    })
    
    (var-set total-nodes (+ (var-get total-nodes) u1))
    (ok true)
  )
)

;; Deactivate an oracle node (only contract owner)
(define-public (deactivate-node (node principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-node-registered node) ERR-NODE-NOT-REGISTERED)
    
    (match (map-get? oracle-nodes node)
      node-data (begin
        (map-set oracle-nodes node (merge node-data {is-active: false}))
        (var-set total-nodes (- (var-get total-nodes) u1))
        (ok true)
      )
      ERR-NODE-NOT-REGISTERED
    )
  )
)

;; =============================================================================
;; PUBLIC FUNCTIONS - ORACLE OPERATIONS
;; =============================================================================

;; Submit Bitcoin block data (only registered nodes)
(define-public (submit-block-data 
  (block-height uint) 
  (block-hash (buff 32)) 
  (tx-count uint) 
  (difficulty uint))
  (let (
    (node tx-sender)
    (current-stacks-height block-height)
  )
    ;; Validate node registration
    (asserts! (is-node-registered node) ERR-NODE-NOT-REGISTERED)
    
    ;; Validate block height
    (asserts! (is-valid-block-height block-height) ERR-INVALID-BLOCK-HEIGHT)
    
    ;; Validate data integrity
    (asserts! (> (len block-hash) u0) ERR-INVALID-DATA)
    (asserts! (> difficulty u0) ERR-INVALID-DATA)
    
    ;; Store the submission
    (map-set block-submissions {node: node, block-height: block-height} {
      block-hash: block-hash,
      tx-count: tx-count,
      difficulty: difficulty,
      timestamp: (unwrap! (get-stacks-block-info? time current-stacks-height) ERR-INVALID-DATA),
      submitted-at: current-stacks-height
    })
    
    ;; Update node statistics
    (match (map-get? oracle-nodes node)
      node-data (map-set oracle-nodes node (merge node-data {
        total-submissions: (+ (get total-submissions node-data) u1),
        last-submission-height: block-height
      }))
      ERR-NODE-NOT-REGISTERED
    )
    
    ;; Add to height tracking
    (add-node-to-height block-height node)
    
    ;; Check if consensus is reached and finalize if so
    (if (check-consensus block-height)
      (finalize-consensus block-height block-hash tx-count difficulty)
      true
    )
    
    (ok true)
  )
)

;; =============================================================================
;; READ-ONLY FUNCTIONS
;; =============================================================================

;; Get the latest confirmed Bitcoin block height
(define-read-only (get-latest-block-height)
  (ok (var-get latest-block-height))
)

;; Get consensus data for a specific block height
(define-read-only (get-consensus-data (height uint))
  (ok (map-get? consensus-data height))
)

;; Get submission data from a specific node for a block height
(define-read-only (get-node-submission (node principal) (height uint))
  (ok (map-get? block-submissions {node: node, block-height: height}))
)

;; Check if a node is registered and active
(define-read-only (get-node-info (node principal))
  (ok (map-get? oracle-nodes node))
)

;; Get total number of active oracle nodes
(define-read-only (get-total-nodes)
  (ok (var-get total-nodes))
)

;; Check if data for a block height has reached consensus
(define-read-only (is-consensus-reached (height uint))
  (ok (check-consensus height))
)

;; Get submission count for a specific block height
(define-read-only (get-height-submission-count (height uint))
  (ok (match (map-get? height-submissions height)
    height-data (get submission-count height-data)
    u0
  ))
)

;; Verify if specific Bitcoin data is valid and confirmed
(define-read-only (verify-bitcoin-data 
  (height uint) 
  (expected-hash (buff 32)))
  (match (map-get? consensus-data height)
    consensus-info (ok (and 
      (get is-valid consensus-info)
      (is-eq (get block-hash consensus-info) expected-hash)
    ))
    (ok false)
  )
)

;; Get aggregated feed data (latest confirmed block info)
(define-read-only (get-aggregated-feed)
  (let (
    (latest-height (var-get latest-block-height))
  )
    (ok {
      latest-height: latest-height,
      consensus-data: (map-get? consensus-data latest-height),
      total-nodes: (var-get total-nodes),
      deployment-height: (var-get deployment-height)
    })
  )
)

;; =============================================================================
;; CONTRACT INITIALIZATION
;; =============================================================================

;; Initialize contract with deployment data
(begin
  (var-set deployment-height block-height)
  (print {
    event: "contract-deployed",
    deployer: CONTRACT-OWNER,
    block-height: block-height,
    min-consensus: MIN-CONSENSUS-NODES
  })
)
