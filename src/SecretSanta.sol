// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/tokens/ERC721/ERC721.sol";
import "@openzeppelin/contracts/tokens/ERC20/ERC20.sol";

    
contract secretSanta is VRFConsumerBase, ERC20, ERC721 {
  

  uint256 immutable MAX_INT = 2**256 - 1;

  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;
  uint256 public giftCount;
  uint256[] public giftArray;
  

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
  ///@notice requestId -> random number 
  mapping(bytes32 => uint256) public requestIdtoNum

    // 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
    // 0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
    constructor (address vrfCoordinator, address linkToken, string memory name, string memory symbol)
    ERC721(
        name,
        symbol
    )
    VRFConsumerBase(
        vrfCoordinator,
        linkToken
    ) {
        _setupRole("owner", msg.sender);
        _setupRole("steward", msg.sender);
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }

    modifier onlyOwner() {
        require(hasRole("owner", msg.sender), "RandomNFT.onlyOwner: caller is not the owner");
        _;
    }

    modifier onlySteward() {
        require(hasRole("steward", msg.sender), "RandomNFT.onlySteward: caller is not the steward");
        _;
    }

  ///@notice input and recieve a giftbox 
  ///@param _is721 allows function caller to input whether they would like to send an nft or not
  function enter(address _contract, uint256 _tokenId) public {
    require(hasEntered[msg.sender] == False, "User already participated")
    IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);
    emit Added721();
    giftList[giftNum.length] = 721(
      _contract,
      _tokenId,
      msg.sender
    );
    hasEntered[msg.sender] = true;
    hasClaimed[msg.sender] = true;
    giftNum.push(tokenId);
  }

  ///@notice donate a token without expecting anything in return 
  function donate(address _contract, uint256 _tokenId) public returns (string) {
    IERC721(_contract).safeTransferFrom(msg.sender, address(this), _tokenId);
    emit Donated();
    return "Thank you for donating a gift!"
  }

  function requestRandomness() public returns (bytes32 requestId) {
    require(hasClaimed[msg.sender] == false, "User already claimed");
    require(hasEntered[msg.sender] == true);
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
      requestIdtoNum[requestRandomness(keyHash,fee)] = msg.sender[];
    }
 
  function rollGift(uint256 userSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        uint256 seed = uint256(keccak256(abi.encode(userSeed, blockhash(block.number)))); // Hash user seed and blockhash
        bytes32 _requestId = requestRandomness(keyHash, fee, seed);
        emit RequestRandomness(_requestId, keyHash, seed);
        return _requestId;
    }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) external override {
        giftNum = randomness[requestId]
        selectGift(giftNum, randomness);
    }

    function selectGift(address receiver, uint256 randomness) internal {

        // reducing randomness to the same order as unclaimed
        // division will fail for divide by zero if the array is empty
        uint256 scale = MAX_INT / giftCount.length;
        uint256 index = randomness / scale;
        uint256 giftId = giftCount[index];
        giftCount[index] = 0;

        transferFrom(address(this), receiver, giftId);

  
  // fees for Chainlink VRF mioght change over time, so we need a method to update the fee
    function setFee(uint256 _fee) onlySteward() public {
        fee = _fee;
    }

    // method to recover unused LINK tokens
    function transferLink(address to, uint256 value) onlySteward() public {
        LINK.transfer(to, value);
    }
  }
    
}

 



    
  