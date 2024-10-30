// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IPManagement.sol";

contract Licensing {
    CreateIPNFT public _createIPNFT;
    // Enum defining the license types
    enum LicenseType {
        EXCLUSIVE,
        NON_EXCLUSIVE,
        TIME_BASED,
        ROYALTY_BASED
    }

    // License structure
    struct License {
        LicenseType licenseType;
        address licensee;
        address licensor;
        uint256 startTime;
        uint256 endTime; // for TIME_BASED licenses
        uint256 royaltyRate; // for ROYALTY_BASED licenses
        bool active;
    }

    mapping(uint256 => License) public licenses;
    uint256 public licenseCount; // To track the number of licenses
    //mapping(uint256 => address) public originalOwner;

    // Event declarations
    event LicenseCreated(
        uint256 licenseId,
        LicenseType licenseType,
        address licensee,
        address licensor
    );
    event LicenseDeactivated(uint256 licenseId);

    // Modifier to check if the caller is the licensor
    modifier onlyLicensor(uint256 _licenseId) {
        require(
            licenses[_licenseId].licensor == msg.sender,
            "Caller is not the licensor."
        );
        _;
    }

    // Modifier to check if the license is still active
    modifier isActive(uint256 _licenseId) {
        require(licenses[_licenseId].active, "License is not active.");
        _;
    }

    // Function to create a new license
    function createLicense(
        LicenseType _licenseType,
        address _licensee,
        uint256 _duration, // for TIME_BASED licenses
        uint256 _royaltyRate // for ROYALTY_BASED licenses
    ) public {
        licenseCount++; // Increment the license ID

        // Set the license details
        licenses[licenseCount] = License({
            licenseType: _licenseType,
            licensee: _licensee,
            licensor: msg.sender,
            startTime: block.timestamp,
            endTime: (_licenseType == LicenseType.TIME_BASED)
                ? block.timestamp + _duration
                : 0,
            royaltyRate: (_licenseType == LicenseType.ROYALTY_BASED)
                ? _royaltyRate
                : 0,
            active: true
        });

        emit LicenseCreated(licenseCount, _licenseType, _licensee, msg.sender);
    }

    // **EXCLUSIVE License Logic**
    // Ensure no other licenses exist for the same IP for EXCLUSIVE licenses.
    function isExclusiveAvailable(
        uint256 _licenseId
    ) public view returns (bool) {
        License memory lic = licenses[_licenseId];
        if (lic.licenseType != LicenseType.EXCLUSIVE) {
            return false;
        }
        // Check if any active license for this licensor already exists
        for (uint256 i = 1; i <= licenseCount; i++) {
            if (
                licenses[i].licensor == lic.licensor &&
                licenses[i].active &&
                i != _licenseId
            ) {
                return false; // Another active license exists
            }
        }
        return true; // No other active licenses found
    }

    // **NON_EXCLUSIVE License Logic**
    // Non-exclusive licenses allow multiple licensees to use the IP.
    function addNonExclusiveLicense(
        uint256 _licenseId,
        address _newLicensee
    ) public onlyLicensor(_licenseId) isActive(_licenseId) {
        require(
            licenses[_licenseId].licenseType == LicenseType.NON_EXCLUSIVE,
            "Not a NON_EXCLUSIVE license."
        );
        licenseCount++;
        licenses[licenseCount] = License({
            licenseType: LicenseType.NON_EXCLUSIVE,
            licensee: _newLicensee,
            licensor: msg.sender,
            startTime: block.timestamp,
            endTime: 0,
            royaltyRate: 0,
            active: true
        });
        emit LicenseCreated(
            licenseCount,
            LicenseType.NON_EXCLUSIVE,
            _newLicensee,
            msg.sender
        );
    }

    // **TIME_BASED License Logic**
    // A TIME_BASED license expires after the duration set during creation.
    function checkTimeBasedLicenseValidity(
        uint256 _licenseId
    ) public view returns (bool) {
        License memory lic = licenses[_licenseId];
        if (lic.licenseType != LicenseType.TIME_BASED) {
            return false;
        }
        return block.timestamp < lic.endTime;
    }

    // **ROYALTY_BASED License Logic**
    // Royalty-based licenses require a percentage of revenue to be paid to the licensor.
    function payRoyalties(
        uint256 _licenseId,
        uint256 _salePrice
    ) public payable isActive(_licenseId) {
        License memory lic = licenses[_licenseId];
        require(
            lic.licenseType == LicenseType.ROYALTY_BASED,
            "Not a ROYALTY_BASED license."
        );
        uint256 royaltyAmount = (_salePrice * lic.royaltyRate) / 100;
        require(msg.value == royaltyAmount, "Incorrect royalty amount.");
        payable(lic.licensor).transfer(royaltyAmount);
    }

    // Deactivate a license (for example, if revoked or expired)
    function deactivateLicense(
        uint256 _licenseId
    ) public onlyLicensor(_licenseId) {
        licenses[_licenseId].active = false;
        emit LicenseDeactivated(_licenseId);
    }

    function validLicense(uint256 tokenId) public view returns (bool) {
        License memory license = licenses[tokenId];
        return
            block.timestamp >= license.startTime &&
            block.timestamp <= license.endTime;
    }
}
