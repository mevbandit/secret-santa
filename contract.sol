// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/tokens/ERC721/ERC721.sol";
import "@openzeppelin/contracts/tokens/ERC20/ERC20.sol";

    
contract secretSanta is VRFConsumerBase, ERC20, ERC721 {
  
  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;
  uint256 public nextGiftNum = 1;

  struct 721 {
    address contract;
    uint tokenId;
    address from   
  }
  ///@notice event for when a token is added / received
  event Added721();
  event Recieved();
  event Donated();

  ///@notice list of nfts
  mapping(uint256 => 721) public giftList;
  ///@notice user has entered
  mapping(address => bool) public hasEntered;
  ///@notice user has claimed
  mapping(address => bool) public hasClaimed;
  constructor() 
    public
    VRFConsumerBase(
        0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
        0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
     )
    ERC721 ("WrappedGift", "SecretSanta")
   {
    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
  }

  ///@notice input and recieve a giftbox 
  ///@param _is721 allows function caller to input whether they would like to send an nft or not
  function enter(address _contract, uint256 _tokenId) public {
    require(hasEntered[msg.sender] == False, "User already participated")
    IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);
    emit Added721();
    giftList[nextGiftNum] = 721(
      _contract,
      _tokenId,
      msg.sender
    )
    hasEntered[msg.sender] = true;
    hasClaimed[msg.sender] = true;
    nextGiftNum ++;
  }

  ///@notice donate a token without expecting anything in return 
  function donate(address _contract, uint256 _tokenId) public returns (string) {
    IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);
    emit Donated();
    return "Thank you for donating a gift!"
  }

  ///@notice claim either an nft or erc20 based on VRF output - uint32 to save gas
  function requestRandomNumber() public returns (bytes32 requestId) {
    require(hasClaimed[msg.sender] == false, "User already claimed");
    require(hasEntered[msg.sender] == true);
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash,fee);}
 
  function fulfillClaim(bytes32 requestId, uint256 randomness) public {
    require(hasClaimed[msg.sender] == false, "User already claimed");
    require(hasEntered[msg.sender] == true);
    uint256 randomResult = randomness;

    uint256 giftToTransfer = (randomResult % nextGiftNum) + 1;
    address contractToTransfer = giftList[giftToTransfer].contract;
    uint256 idToTransfer = giftList[giftToTransfer].tokenId;

    IERC721(contractToTransfer).safeTransfer(address(this), msg.sender, idToTransfer);
  }
  
   // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
  function withdrawLink(address _tokenContract, uint256 _amount) external {
    IERC20 tokenContract = IERC20(_tokenContract);
    // transfer the token from address of this contract
    // to address of the user (executing the withdrawToken() function)
    tokenContract.transfer(msg.sender, _amount);
  }

    
  }

 
}


    
  }