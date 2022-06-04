//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevsNft.sol";

contract CryptoDevsToken is ERC20, Ownable {
    uint256 public constant tokenPrice = 0.001 ether;
    uint256 public constant tokensPerNFT = 10 * 10**18;
    uint256 public constant maxTokenSupply = 10000 * 10**18;

    ICryptoDevsNFT CryptoDevsNFT;

    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsNFT) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
    }

    /**
     * @dev Mints `amount` number of CryptoDevTokens
     * Requirements:
     * - `msg.value` should be equal or greater than the tokenPrice * amount
     */

    function mint(uint256 amountOfTokensToBeMinted) public payable {
        uint256 requiredAmount = amountOfTokensToBeMinted * tokenPrice;
        uint256 amountInDecimals = amountOfTokensToBeMinted * 10**18;
        require(msg.value >= requiredAmount, "ether is not enough");
        require(
            totalSupply() + amountInDecimals <= maxTokenSupply,
            "cannot exceed 10000 tokens"
        );
        _mint(msg.sender, amountInDecimals);
    }

    /**
     * @dev Mints tokens based on the number of NFT's held by the sender
     * Requirements:
     * balance of Crypto Dev NFT's owned by the sender should be greater than 0
     * Tokens should have not been claimed for all the NFTs owned by the sender
     */

    function claim() public {
        address sender = msg.sender;
        uint256 noNFTsOwned = CryptoDevsNFT.balanceOf(sender);
        require(noNFTsOwned > 0, "user does not own any NFTs");

        uint256 noClaimableNFTs;
        for (uint256 i = 0; i < noNFTsOwned; i++) {
            uint256 tokenIdOfNFTOwned = CryptoDevsNFT.tokenOfOwnerByIndex(
                sender,
                i
            );
            if (!tokenIdsClaimed[tokenIdOfNFTOwned]) {
                noClaimableNFTs += 1;
                tokenIdsClaimed[tokenIdOfNFTOwned] = true;
            }
        }

        require(noClaimableNFTs > 0, "no NFTs to claim tokens");
        _mint(sender, tokensPerNFT);
    }

    /**
     * @dev withdraws all ETH and tokens sent to the contract
     * Requirements:
     * wallet connected must be owner's address
     */

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        address _owner = owner();
        (bool sent, ) = _owner.call{value: balance}("");
        require(sent, "failed to withdraw");
    }

    receive() external payable {}

    fallback() external payable {}
}

//0xbFeBa75Bea0251975838294440B18BdD86c13303
