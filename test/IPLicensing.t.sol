// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IPLicensing.sol";

//import "../src/IPManagement.sol";

contract LicensingTest is Test {
    Licensing license;
    uint256 tokenId = 1;
    address licensee = address(0x123);

    function setUp() public {
        license = new Licensing();
    }

    function testIssueLicense() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = block.timestamp + 1 days;
        uint256 royaltyPercentage = 10;

        license.issueLicense(
            tokenId,
            licensee,
            startTime,
            endTime,
            royaltyPercentage
        );

        bool validLicense = license.validLicense(tokenId);

        assertTrue(validLicense);
    }
}
