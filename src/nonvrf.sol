pragma solidity ^0.8.10;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SecretSanta is ERC721 {
    uint256 public nextGiftNum = 1;

    struct nft {
        address tokenAddress;
        address tokenFrom;
        uint256 tokenId;
    }

    mapping(uint256 => nft) public giftList;
    mapping(address => bool) public userEntered;
    mapping(address => bool) public hasClaimed;

    constructor() ERC721("WrappedGift", "SecretSanta") {}

    function random() public view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp + block.difficulty
                        + ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) + block.gaslimit
                        + ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) + block.number
                )
            )
        );

        return (seed - ((seed / 1000) * 1000));
    }

    function enter(address _tokenAddress, uint256 _tokenId) public {
        require(userEntered[msg.sender] == false, "User already participated");
        userEntered[msg.sender] = true;
        giftList[nextGiftNum] = nft(_tokenAddress, msg.sender, _tokenId);
        nextGiftNum++;
    }

    function fulfillClaim() public {
        require(hasClaimed[msg.sender] == false, "User already claimed");
        require(userEntered[msg.sender] == true);

        uint256 giftToTransfer = (random() % nextGiftNum) + 1;
        address addressToTransfer = giftList[giftToTransfer].tokenAddress;
        uint256 idToTransfer = giftList[giftToTransfer].tokenId;

        IERC721(addressToTransfer).transferFrom(address(this), msg.sender, idToTransfer);

        hasClaimed[msg.sender] = true;
    }

    function donate(address _contract, uint256 _tokenId) public {
        IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);
    }
}
