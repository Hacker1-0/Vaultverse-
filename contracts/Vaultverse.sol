// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Vaultverse
 * @notice A secure vault system for storing and managing digital assets or data entries with admin-controlled access.
 */
contract Vaultverse {

    address public admin;
    uint256 public vaultCount;

    struct VaultEntry {
        uint256 id;
        address creator;
        string dataHash;
        string metadataURI;
        uint256 timestamp;
        bool locked;
    }

    mapping(uint256 => VaultEntry) public vaults;
    mapping(address => uint256[]) public userVaults;

    event VaultCreated(uint256 indexed id, address indexed creator, string dataHash, string metadataURI);
    event VaultLocked(uint256 indexed id);
    event VaultUnlocked(uint256 indexed id);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Vaultverse: NOT_ADMIN");
        _;
    }

    modifier vaultExists(uint256 id) {
        require(id > 0 && id <= vaultCount, "Vaultverse: VAULT_NOT_FOUND");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createVault(string calldata dataHash, string calldata metadataURI) external returns (uint256) {
        require(bytes(dataHash).length > 0, "Vaultverse: EMPTY_HASH");

        vaultCount++;
        vaults[vaultCount] = VaultEntry({
            id: vaultCount,
            creator: msg.sender,
            dataHash: dataHash,
            metadataURI: metadataURI,
            timestamp: block.timestamp,
            locked: false
        });

        userVaults[msg.sender].push(vaultCount);

        emit VaultCreated(vaultCount, msg.sender, dataHash, metadataURI);
        return vaultCount;
    }

    function lockVault(uint256 id) external onlyAdmin vaultExists(id) {
        VaultEntry storage v = vaults[id];
        v.locked = true;
        emit VaultLocked(id);
    }

    function unlockVault(uint256 id) external onlyAdmin vaultExists(id) {
        VaultEntry storage v = vaults[id];
        v.locked = false;
        emit VaultUnlocked(id);
    }

    function getVault(uint256 id) external view vaultExists(id) returns (VaultEntry memory) {
        return vaults[id];
    }

    function getUserVaults(address user) external view returns (uint256[] memory) {
        return userVaults[user];
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Vaultverse: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
