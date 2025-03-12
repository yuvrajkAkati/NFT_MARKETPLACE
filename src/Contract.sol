// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Contract is ERC721URIStorage,ReentrancyGuard { 
    struct NFT{
        address seller; 
        address nftContract;
        uint _tokenId;
        uint price;
        bool isActive;
    }

    mapping(address => mapping(uint => NFT)) public usersNFT;
    uint public fee = 250;
    uint public mintFee = 0.01 ether;
    address public owner;
    uint private _tokenId;

    NFT[] public allNFTs;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not marketplace owner");
        _;
    }

    function listNFT(address NFTContractAddress , uint tokenId , uint price ) public {
        require(price > 0 , "price should be greater than zero");
        IERC71 nft = IERC71(NFTAddress);
        require(nft.ownerOf(tokenId) == msg.sender);
        require(nft.getApproved(tokenId) == address(this) , "marketplace is not approved to list this");
        usersNFT[NFTContractAddress][tokenId] = NFT(msg.sender,NFTContractAddress,tokenId,price,true);
    }

    function buyNFT(address NFTContract , uint tokenId ) external payable nonReentrant {
        NFT storage userNFT = usersNFT[NFTContract][tokenId];
        require(userNFT.isActive == true , "NFT not for sale");
        require(msg.value >= userNFT.price , "insufficient balance");
        uint feeAmount = (fee * userNFT.price) /10000;
        uint sellerAmount = userNFT.price - feeAmount;

        payable(userNFT.seller).transfer(sellerAmount);
        payable(address(owner)).transfer(feeAmount);

        IERC71(NFTContract).safeTransferFrom(userNFT.seller , msg.sender , tokenId);
        userNFT.isActive = false;

        if(msg.value > userNFT.price){
            uint refundableAmount = msg.value - userNFT.price;
            payable(msg.sender).transfer(refundableAmount);
        }
    }

    function unlist(address nftContract , uint tokenId) external  {
        NFT storage userNFT = NFT[nftContractAddress][tokenId];
        require(msg.sender == userNFT.seller , "you dont have access");
        require(userNFT.isActive == true , "NFT is not listed");

        userNFT.isActive = false;
    }
    //creation of nft
    function mintNFT (string memory tokenUri , uint price, bool listAfterMinting ) external payable {
        require(msg.value >= mintFee , "insufficient balance");
        require(price > 0 , "price can't be 0");
        _tokenId++;
        _mint(msg.sender,_tokenId);
        _setTokenURI(_tokenId, tokenUri);

        usersNFT[address(this)][_tokenId] = NFT(msg.sender, address(this),_tokenId,price,listAfterMinting);

        payable(owner).transfer(mintFee);
        if(msg.value > mintFee){
            payable(address(msg.sender)).transfer(msg.value - mintFee);
        }

    }
    //fetch nft bought by me
    function nftOwnedByAddress( address seller ) {
        NFT storage ownedNFT = usersNFT[][] //filtering the users
    }
    //fetch unsold nft
    function unsoldNFT(){
    }

    function setMarketFee(uint newFee) external onlyOwner {
        require(newFee <= 1000 , "fee too high");
        fee = newFee;
    }

}
