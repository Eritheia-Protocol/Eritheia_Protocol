// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../src/IPLicensing.sol";

contract CreateIPNFT is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    struct CreativeWork {
        string title;
        string metadataURI;
    }

    uint256 private _tokenIds;
    mapping(uint256 => CreativeWork) private _creativeWorks;

    constructor() ERC721("IPOwnershipNFT", "IPONFT") Ownable(msg.sender) {
        // The default admin role which can manage other roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mintCreativeWork(
        address recipient,
        string memory _title,
        string memory _metadataURI
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;

        _creativeWorks[newItemId] = CreativeWork(_title, _metadataURI);
        _safeMint(recipient, newItemId);

        return newItemId;
    }

    function burnCreativeWork(uint256 _tokenId) onlyRole(MINTER_ROLE) {
        require(_exists(_tokenId), "Creative work does not exist");

        delete _creativeWorks[_tokenId];
        _burn(tokenId);
    }

    // Admin function to add minter
    function addMinter(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, _minter);
    }

    // Admin function to remove minter
    function revokeMinter(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, _minter);
    }

    function getCreativeWork(
        uint256 tokenId
    ) public view returns (string memory title, string memory metadataURI) {
        require(_exists(tokenId), "Creative work does not exist");
        CreativeWork memory work = _creativeWorks[tokenId];
        return (work.title, work.metadataURI);
    }

    function noOfMintedCreativeWork() public returns (uint256) {
        return _tokenIds;
    }

    function _exists(uint256 tokenId) public view returns (bool) {
        return ownerOf(tokenId) != address(0);
    }
}
