// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//import "./IPManagement.sol";

contract RoyaltyDistribution {
    //CreateIPNFT public _createIPNFT;

    struct RoyaltyShare {
        address payable recipient;
        uint256 percentage;
    }

    mapping(uint256 => RoyaltyShare[]) public royaltyShares;

    event RoyaltiesDistributed(uint256 indexed tokenId, uint256 totalAmount);

    //constructor(address createIPNFT) {
    //    _createIPNFT = CreateIPNFT(createIPNFT);
    //}

    function setRoyaltyShares(
        uint256 tokenId,
        address payable[] memory recipients,
        uint256[] memory percentages
    ) public {
        require(recipients.length == percentages.length, "Mismatched inputs");

        delete royaltyShares[tokenId];

        uint256 totalPercentage = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            totalPercentage += percentages[i];
            royaltyShares[tokenId].push(
                RoyaltyShare(recipients[i], percentages[i])
            );
        }

        require(totalPercentage == 100, "Total percentage must be 100");
    }

    function distributeRoyalties(uint256 tokenId) public payable {
        uint256 totalAmount = msg.value;

        RoyaltyShare[] memory shares = royaltyShares[tokenId];
        require(shares.length > 0, "No royalty shares defined");

        for (uint256 i = 0; i < shares.length; i++) {
            RoyaltyShare memory share = shares[i];
            uint256 payment = (totalAmount * share.percentage) / 100;
            share.recipient.transfer(payment);
        }

        emit RoyaltiesDistributed(tokenId, totalAmount);
    }
}
