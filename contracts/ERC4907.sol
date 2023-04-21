// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./IERC4907.sol";

contract ERC4907 is ERC721URIStorage, IERC4907 {
    
    struct UserInfo {
        address user; // address of user role
        uint256 expires; // unix timestamp, user expires
    }

  //maps tokenID -> user
  mapping(uint256 => UserInfo) internal _users;

  constructor(
      string memory _name,
      string memory _symbol
  ) ERC721(_name, _symbol) {}

  /// @notice set the user and expires of a NFT
  /// @dev The zero address indicates there is no user
  /// Throws if `tokenId` is not valid NFT
  /// @param user  The new user of the NFT
  /// @param expires  UNIX timestamp, The new user could use the NFT before expires
  function setUser(uint256 tokenId, address user, uint64 expires) public virtual override {
      //check if msg.sender owns the NFT
      require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
      
      UserInfo storage info = _users[tokenId];
      info.user = user;
      info.expires = expires;//time is in seconds
      emit UpdateUser(tokenId, user, expires);
  }

  /// @notice Get the user address of an NFT
  /// @dev The zero address indicates that there is no user or the user is expired
  /// @param tokenId The NFT to get the user address for
  /// @return The user address for this NFT
  function userOf(uint256 tokenId) public view virtual override returns (address) {
    
    //check if 'expires' expiry date is greater than current time(block.timestamp)
    if (uint256(_users[tokenId].expires) >= block.timestamp) {
      return _users[tokenId].user;
    } 
    else return address(0);
  }

  /// @notice Get the user expires of an NFT
  /// @dev The zero value indicates that there is no user
  /// @param tokenId The NFT to get the user expires for
  /// @return The user expires for this NFT
  function userExpires(uint256 tokenId) public view virtual override returns(uint256){
    return _users[tokenId].expires;
  }

  /// @dev See {IERC165-supportsInterface}.
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);


    //delete the rentee user before selling the NFT
    if (from != to && _users[tokenId].user != address(0)) {
      delete _users[tokenId];
      emit UpdateUser(tokenId, address(0), 0);
    }
  }

}
