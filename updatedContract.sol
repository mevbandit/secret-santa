pragma solidity ^0.8.10;
//SPDX-License-Identifier: MIT

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SecretSanta is VRFConsumerBase, ERC721 {
    uint256 public nextGiftNum = 1;
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256 public randomResult;

    struct nft {
        address tokenAddress;
        address tokenFrom;
        uint256 tokenId;
    }

    mapping(uint256 => nft) public giftList;
    mapping(address => bool) public userEntered;
    mapping(address => bool) public hasClaimed;

    constructor()
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        )
        ERC721 ("WrappedGift", "SecretSanta")
   {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
  }

    function enter(address _tokenAddress, uint256 _tokenId) public {
        require(userEntered[msg.sender] == false, "User already participated");
        userEntered[msg.sender] = true;
        giftList[nextGiftNum] = nft(
            _tokenAddress,
            msg.sender,
            _tokenId
        );
        nextGiftNum++;
    }

    function requestRandomNumber() public returns (bytes32 requestId) {
        require(userEntered[msg.sender] == false, "User already participated");
        require(hasClaimed[msg.sender] == false, "User already participated");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");

        return requestRandomness(keyHash, fee);
    } 
 
    function fulfillClaim(bytes32 requestId, uint256 randomness) public {
        require(hasClaimed[msg.sender] == false, "User already claimed");
        require(userEntered[msg.sender] == true);

        randomResult = randomness;

        uint256 giftToTransfer = (randomResult % nextGiftNum) + 1;
        address addressToTransfer = giftList[giftToTransfer].tokenAddress;
        uint256 idToTransfer = giftList[giftToTransfer].tokenId;

        IERC721(addressToTransfer).transferFrom(address(this), msg.sender, idToTransfer);

        hasClaimed[msg.sender] = true;
    }

    function donate(address _contract, uint256 _tokenId) public {
        IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);
    }

}