// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OwnershipContract.sol";

contract LicensingContract is OwnershipContract {
    struct License {
        string licenseType;
        uint royaltyPercentage;
        uint duration;
        uint startTime;
    }

    mapping(uint => License) public licenses;

    function createLicense(
        uint tokenId,
        string memory licenseType,
        uint royaltyPercentage,
        uint duration
    ) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can license this token");
        licenses[tokenId] = License(licenseType, royaltyPercentage, duration, block.timestamp);
    }

    function getLicenseDetails(uint tokenId) public view returns (string memory, uint, uint, uint) {
        License memory license = licenses[tokenId];
        return (license.licenseType, license.royaltyPercentage, license.duration, license.startTime);
    }
}
