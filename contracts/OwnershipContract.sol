// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OwnershipContract is ERC721, Ownable {
    struct OwnershipToken {
        string metadataURI;
        address creator;
        uint creationTime;
    }

    mapping(uint => OwnershipToken) public tokens;
    uint public nextTokenId;

    constructor() ERC721("IP Ownership", "IPO") {}

    function mintOwnershipToken(address to, string memory metadataURI) public onlyOwner {
        uint tokenId = nextTokenId;
        tokens[tokenId] = OwnershipToken(metadataURI, to, block.timestamp);
        _mint(to, tokenId);
        nextTokenId++;
    }

    function getTokenMetadata(uint tokenId) public view returns (string memory) {
        return tokens[tokenId].metadataURI;
    }
}
