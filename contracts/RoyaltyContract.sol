// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LicensingContract.sol";

contract RoyaltyContract is LicensingContract {
    mapping(uint => uint) public totalRevenues;

    function distributeRoyalties(uint tokenId, uint totalRevenue) public payable {
        require(
            licenses[tokenId].duration > block.timestamp - licenses[tokenId].startTime,
            "License expired"
        );

        uint royaltyAmount = (totalRevenue * licenses[tokenId].royaltyPercentage) / 100;
        address owner = ownerOf(tokenId);

        (bool success, ) = owner.call{value: royaltyAmount}("");
        require(success, "Royalty payment failed");

        totalRevenues[tokenId] += totalRevenue;
    }

    // Fallback function to accept ether
    receive() external payable {}
}
