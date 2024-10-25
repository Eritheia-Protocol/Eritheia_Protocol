// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IACP77SubnetMessaging {
    function sendMessageToSubnet(
        string calldata destinationSubnet, 
        address token, 
        address recipient, 
        uint256 amount
    ) external returns (bool);

    function receiveMessageFromSubnet(
        string calldata sourceSubnet, 
        address token, 
        address recipient, 
        uint256 amount
    ) external returns (bool);
}

contract CrossSubnetAssetMovement is ReentrancyGuard {
    
    address public messagingSystem;
    
    // Mapping for locked assets
    mapping(address => mapping(address => uint256)) public lockedAssets;

    event AssetLocked(address indexed user, address indexed token, uint256 amount, string destinationSubnet);
    event AssetUnlocked(address indexed user, address indexed token, uint256 amount, string sourceSubnet);

    constructor(address _messagingSystem) {
        require(_messagingSystem != address(0), "Invalid messaging system");
        messagingSystem = _messagingSystem;
    }
    
    function lockAsset(address tokenAddress, uint256 amount, string memory destinationSubnet) external nonReentrant {
        require(amount > 0, "Amount must be greater than zero");
        require(tokenAddress != address(0), "Invalid token address");

        // Transfer the token to the contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        
        // Store the locked assets
        lockedAssets[msg.sender][tokenAddress] += amount;

        // Send a message to the destination subnet
        IACP77SubnetMessaging(messagingSystem).sendMessageToSubnet(destinationSubnet, tokenAddress, msg.sender, amount);
        
        emit AssetLocked(msg.sender, tokenAddress, amount, destinationSubnet);
    }

    function unlockAsset(
        address tokenAddress, 
        uint256 amount, 
        string memory sourceSubnet, 
        address user
    ) internal nonReentrant {
        require(msg.sender == messagingSystem, "Unauthorized access");
        require(lockedAssets[user][tokenAddress] >= amount, "Insufficient locked balance");

        // Unlock the asset on the destination subnet
        IERC20(tokenAddress).transfer(user, amount);
        
        // Deduct the locked balance
        lockedAssets[user][tokenAddress] -= amount;

        emit AssetUnlocked(user, tokenAddress, amount, sourceSubnet);
    }

    function receiveUnlockRequest(
        string calldata sourceSubnet, 
        address tokenAddress, 
        uint256 amount, 
        address user
    ) external nonReentrant {
        require(
            IACP77SubnetMessaging(messagingSystem).receiveMessageFromSubnet(sourceSubnet, tokenAddress, user, amount), 
            "Unlock failed"
        );
        unlockAsset(tokenAddress, amount, sourceSubnet, user);
    }
}
