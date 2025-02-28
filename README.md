# Decentralized KYC Platform

A secure, privacy-preserving Know Your Customer (KYC) system built on blockchain technology that allows for decentralized identity verification.

## Overview

This smart contract implements a decentralized KYC system where:

1. Authorized verifiers can validate user identities
2. Users can submit their information for verification
3. Third parties can check if a user is verified
4. Users maintain control over their identity data

## Features

- **Multiple Verification Levels**: Support for basic, advanced, and premium verification tiers
- **Verifier Management**: Contract owner can add or remove authorized verifiers
- **User Control**: Users can self-revoke their verification at any time
- **Privacy Preservation**: Only cryptographic hashes of user data are stored on-chain
- **Flexible Verification**: Verifiers can update verification levels for users

## Verification Levels

| Level | Description | Use Cases |
|-------|-------------|-----------|
| 1     | Basic       | Simple identity verification, low-risk applications |
| 2     | Advanced    | Enhanced verification for financial services |
| 3     | Premium     | Comprehensive verification for high-value transactions |

## Contract Functions

### Read-Only Functions

- `is-verifier`: Check if an address is an authorized verifier
- `get-verifier`: Get verifier status
- `is-user-verified`: Check if a user is verified
- `get-user-verification`: Get user verification details
- `get-user-verification-level`: Get user verification level

### Public Functions

- `add-verifier`: Add a new verifier (contract owner only)
- `remove-verifier`: Remove a verifier (contract owner only)
- `verify-user`: Verify a user (authorized verifiers only)
- `revoke-verification`: Revoke verification for a user
- `self-revoke-verification`: Allow users to remove their own verification
- `update-verification-level`: Update verification level (authorized verifiers only)

## Security Considerations

- Input validation for all user-provided data
- Access controls for critical functions
- Privacy-preserving design that only stores hashes of identity data on-chain
- Protection against common smart contract vulnerabilities

## Getting Started

### Prerequisites

- [Clarity language](https://clarity-lang.org/) understanding
- Access to a Stacks blockchain environment

### Deployment

Deploy the contract to the Stacks blockchain using the Clarinet CLI:

```bash
clarinet deploy --network testnet
```

## Example Usage

### Verifying a User

```clarity
(contract-call? .kyc-contract verify-user 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  u2 
  0x54686973206973206120746573742068617368
)
```

### Checking User Verification

```clarity
(contract-call? .kyc-contract is-user-verified 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
)
```
