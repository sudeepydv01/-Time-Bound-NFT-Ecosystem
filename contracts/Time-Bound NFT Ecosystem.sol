// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChronoNFT is ERC721URIStorage, Ownable {
    uint256 public tokenIdCounter;

    enum Phase { Genesis, Growth, Prime, Decay }

    struct NFTData {
        uint256 birthTime;
        Phase currentPhase;
    }

    mapping(uint256 => NFTData) public nftData;

    constructor(address initialOwner) ERC721("ChronoNFT", "CHNFT") Ownable(initialOwner) {}

    // Mint a new NFT with initial "Genesis" phase
    function mintNFT(address to, string memory tokenURI) public onlyOwner {
        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        nftData[tokenId] = NFTData({
            birthTime: block.timestamp,
            currentPhase: Phase.Genesis
        });

        tokenIdCounter++;
    }

    // Custom token existence check
    function tokenExists(uint256 tokenId) public view returns (bool) {
        return nftData[tokenId].birthTime != 0 || tokenId == 0;
    }

    // Update the NFT's lifecycle phase based on age
    function updatePhase(uint256 tokenId) public {
        require(tokenExists(tokenId), "Token does not exist");

        uint256 age = block.timestamp - nftData[tokenId].birthTime;

        if (age < 7 days) {
            nftData[tokenId].currentPhase = Phase.Genesis;
        } else if (age < 30 days) {
            nftData[tokenId].currentPhase = Phase.Growth;
        } else if (age < 90 days) {
            nftData[tokenId].currentPhase = Phase.Prime;
        } else {
            nftData[tokenId].currentPhase = Phase.Decay;
        }
    }

    // Burn NFT only if it's in "Decay" phase and owned by caller
    function burnIfDecayed(uint256 tokenId) public {
        require(tokenExists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        require(nftData[tokenId].currentPhase == Phase.Decay, "NFT not in Decay phase");

        _burn(tokenId);
        delete nftData[tokenId];
    }

    // View the current lifecycle phase of the NFT
    function viewPhase(uint256 tokenId) public view returns (string memory) {
        require(tokenExists(tokenId), "Token does not exist");

        Phase p = nftData[tokenId].currentPhase;
        if (p == Phase.Genesis) return "Genesis";
        if (p == Phase.Growth) return "Growth";
        if (p == Phase.Prime) return "Prime";
        return "Decay";
    }
}

