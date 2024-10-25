// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//import "./IPManagement.sol";

contract Licensing {
    //CreateIPNFT public _createIPNFT;
    struct License {
        address licensee;
        uint256 startTime;
        uint256 endTime;
        uint256 royaltyPercentage;
    }

    mapping(uint256 => License) public licenses;
    //mapping(uint256 => address) public originalOwner;

    event LicenseIssued(
        uint256 indexed tokenId,
        address indexed licensee,
        uint256 startTime,
        uint256 endTime,
        uint256 royaltyPercentage
    );

    function issueLicense(
        uint256 tokenId,
        address _licensee,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _royaltyPercentage
    ) public {
        //uint256 _startTime = block.timestamp;

        require(_royaltyPercentage <= 100, "Invalid royalty percentage");
        require(_startTime < _endTime, "Invalid time range");

        licenses[tokenId] = License(
            _licensee,
            _startTime,
            _endTime,
            _royaltyPercentage
        );

        emit LicenseIssued(
            tokenId,
            _licensee,
            _startTime,
            _endTime,
            _royaltyPercentage
        );
    }

    function validLicense(uint256 tokenId) public view returns (bool) {
        License memory license = licenses[tokenId];
        return
            block.timestamp >= license.startTime &&
            block.timestamp <= license.endTime;
    }
}
