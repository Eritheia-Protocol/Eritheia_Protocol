// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CrossSubnetAssetMovement.sol";

contract MockERC20 is IERC20 {
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(balances[from] >= amount, "Insufficient balance");
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");
        balances[from] -= amount;
        balances[to] += amount;
        allowances[from][msg.sender] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }
}

contract MockSubnetMessaging is IACP77SubnetMessaging {
    function sendMessageToSubnet(
        string calldata,
        address,
        address,
        uint256
    ) external pure override returns (bool) {
        return true;
    }

    function receiveMessageFromSubnet(
        string calldata,
        address,
        address,
        uint256
    ) external pure override returns (bool) {
        return true;
    }
}

contract CrossSubnetAssetMovementTest is Test {
    CrossSubnetAssetMovement public assetMovement;
    MockERC20 public token;
    MockSubnetMessaging public messagingSystem;
    address public user;

    // Re-declare the events in the test contract scope
    event AssetLocked(
        address indexed user,
        address indexed token,
        uint256 amount,
        string destinationSubnet
    );
    event AssetUnlocked(
        address indexed user,
        address indexed token,
        uint256 amount,
        string sourceSubnet
    );

    function setUp() public {
        user = address(0x123);
        token = new MockERC20();
        messagingSystem = new MockSubnetMessaging();
        assetMovement = new CrossSubnetAssetMovement(address(messagingSystem));

        // Mint tokens for the user
        token.mint(user, 1000 ether);
    }

    function testLockAsset() public {
        vm.startPrank(user);

        // Approve contract to transfer tokens
        token.approve(address(assetMovement), 500 ether);

        // Expect the AssetLocked event
        vm.expectEmit(true, true, true, true);
        emit AssetLocked(user, address(token), 500 ether, "SubnetA");

        // Lock asset
        assetMovement.lockAsset(address(token), 500 ether, "SubnetA");

        // Check balances and locked amounts
        assertEq(token.balanceOf(user), 500 ether); // Initial balance was 1000 ether
        assertEq(assetMovement.lockedAssets(user, address(token)), 500 ether);

        vm.stopPrank();
    }

    // Example test setup (assuming you're using Foundry)
    function testUnlockAsset() public {
        // Arrange
        uint256 amount = 500 ether;
        address user = address(0x123);
        string memory sourceSubnet = "SubnetA";

        // Approve and lock asset
        token.approve(address(assetMovement), amount);
        assetMovement.lockAsset(address(token), amount, "SubnetB");

        // Simulate receiving an unlock request
        assetMovement.receiveUnlockRequest(
            sourceSubnet,
            address(token),
            amount,
            user
        );

        // Act
        // (Assuming some logic here to simulate the message passing between subnets)

        // Assert
        assertEq(
            token.balanceOf(user),
            amount,
            "User should have received the unlocked amount"
        );
    }
}
