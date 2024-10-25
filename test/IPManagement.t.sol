// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/IPManagement.sol";

contract CreativeNFTTest is Test {
    CreateIPNFT nft;
    address owner;
    address recipient = address(0x123);

    function setUp() public {
        owner = address(this);
        nft = new CreateIPNFT();
    }

    function testMintNFT() public {
        string memory title = "Artwork";
        string memory uri = "https://ipfs.io/ipfs/metadata";

        uint256 tokenId = nft.mintCreativeWork(recipient, title, uri);
        (string memory retrievedTitle, string memory retrievedURI) = nft
            .getCreativeWork(tokenId);

        assertEq(retrievedTitle, title);
        assertEq(retrievedURI, uri);
        assertEq(nft.ownerOf(tokenId), recipient);
    }
}
