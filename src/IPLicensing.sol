// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IPManagement.sol";

contract Licensing {
    CreateIPNFT public _createIPNFT;
    struct License {
        address owner;
        uint256 startTime;
        uint256 endTime;
        uint256 royaltyPercentage;
    }

    mapping(uint256 => License) public licenses;
    //mapping(uint256 => address) public originalOwner;

    event LicenseIssued(
        uint256 indexed tokenId,
        address indexed owner,
        uint256 startTime,
        uint256 endTime,
        uint256 royaltyPercentage
    );

    constructor(address createIPNFT) {
        _createIPNFT = CreateIPNFT(createIPNFT);
    }

    function issueLicense(
        uint256 tokenId,
        uint256 _endTime,
        uint256 _royaltyPercentage
    ) public {
        require(
            _createIPNFT.ownerOf(tokenId) == msg.sender,
            "Only Owner is allowed to license his/her own IP"
        );

        address _owner = msg.sender;
        uint256 _startTime = block.timestamp;

        require(_royaltyPercentage <= 100, "Invalid royalty percentage");
        require(_startTime < _endTime, "Invalid time range");

        licenses[tokenId] = License(
            _owner,
            _startTime,
            _endTime,
            _royaltyPercentage
        );

        emit LicenseIssued(
            tokenId,
            _owner,
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
