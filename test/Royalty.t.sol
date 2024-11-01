// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Royalty.sol";

contract RoyaltyDistributionTest is Test {
    RoyaltyDistribution royalty;
    address payable[] recipients;
    uint256[] percentages;

    function setUp() public {
        recipients.push(payable(address(0x123)));
        recipients.push(payable(address(0x456)));
        percentages.push(60);
        percentages.push(40);

        royalty = new RoyaltyDistribution();

        require(recipients.length > 0, "Royalty addresses array is empty");
    }

    function testDistributeRoyalties() public {
        uint256 tokenId = 1;
        royalty.setRoyaltyShares(tokenId, recipients, percentages);

        uint256 initialBalance1 = address(recipients[0]).balance;
        uint256 initialBalance2 = address(recipients[1]).balance;

        royalty.distributeRoyalties{value: 1 ether}(tokenId);

        assertEq(
            address(recipients[0]).balance,
            initialBalance1 + (1 ether * 60) / 100
        );
        assertEq(
            address(recipients[1]).balance,
            initialBalance2 + (1 ether * 40) / 100
        );
    }
}
