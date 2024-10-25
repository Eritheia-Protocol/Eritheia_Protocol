// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/IPLicensing.sol";

contract CreateIPNFT is ERC721, Ownable {
    struct CreativeWork {
        string title;
        string metadataURI;
    }

    uint256 private _tokenIds;
    mapping(uint256 => CreativeWork) private _creativeWorks;

    constructor() ERC721("IPOwnershipNFT", "IPONFT") Ownable(msg.sender) {}

    function mintCreativeWork(
        address recipient,
        string memory _title,
        string memory _metadataURI
    ) public onlyOwner returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;

        _creativeWorks[newItemId] = CreativeWork(_title, _metadataURI);
        _safeMint(recipient, newItemId);

        return newItemId;
    }

    function getCreativeWork(
        uint256 tokenId
    ) public view returns (string memory title, string memory metadataURI) {
        require(_exists(tokenId), "Creative work does not exist");
        CreativeWork memory work = _creativeWorks[tokenId];
        return (work.title, work.metadataURI);
    }

    function _exists(uint256 tokenId) public view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }
}
