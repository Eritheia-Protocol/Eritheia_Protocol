// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IPLicensing.sol";
import "../src/IPManagement.sol";

contract LicensingTest is Test {
    CreateIPNFT public _createIPNFT;
    Licensing license;

    address owner;
    address recepient = address(0x123);

    function setUp() public {
        owner = address(this);
        _createIPNFT = new CreateIPNFT();
        license = new Licensing(address(_createIPNFT));
    }

    function testIssueLicense() public {
        vm.prank(owner);
        string memory title = "Artwork";
        string memory uri = "https://ipfs.io/ipfs/metadata";
        uint256 tokenId = _createIPNFT.mintCreativeWork(recepient, title, uri);

        vm.prank(recepient);
        uint256 endTime = block.timestamp + 1 days;
        uint256 royaltyPercentage = 10;

        license.issueLicense(tokenId, endTime, royaltyPercentage);

        bool validLicense = license.validLicense(tokenId);

        assertTrue(validLicense);
    }
}
