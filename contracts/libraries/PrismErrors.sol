// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library PrismErrors {
    error Unauthorized();
    error ContextExpired();
    error SpendingLimitExceeded();
    error ContractNotAllowed();
    error ContextRevoked();
    error AlreadyRegistered();
    error AgentNotFound();
    error InvalidURI();
    error ZeroAddress();
}
