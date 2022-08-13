// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

import "./ERC721.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Context.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();
error ContractPaused();

contract NFT is ERC721, Ownable {

    using Strings for uint256;
    string public baseURI;
    string public uriPrefix = '';
    string public uriSuffix = '.json';
    string public hiddenMetadataUri;
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 20;
    uint256 public constant MINT_PRICE = 8 ether;
    bool public revealed = false;
    bool public paused = true;

    //events
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);
    event Pausedevnt(address account);

    modifier Paused(){
        if(paused)revert ContractPaused();
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        string memory _hiddenMetadataUri
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
        setHiddenMetadataUri(_hiddenMetadataUri);
    }

    function mintOmnes() public payable Paused returns (uint256) {
        if (msg.value != MINT_PRICE) {
            revert MintPriceNotPaid();
        }
        uint256 newTokenId = ++currentTokenId;
        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }
        _safeMint(msg.sender, newTokenId);
        return newTokenId;
    }

    function mintTo(address recipient) public payable Paused returns (uint256) {
        if (msg.value != MINT_PRICE) {
            revert MintPriceNotPaid();
        }
        uint256 newTokenId = ++currentTokenId;
        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }
        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    function mintAirdrp(address recipient) public payable onlyOwner returns (uint256) {
        uint256 newTokenId = ++currentTokenId;
        if (newTokenId > TOTAL_SUPPLY) {
            revert MaxSupply();
        }
        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Only owner of the token can burn it");
        _burn(tokenId);
    }

    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256) pure override internal {
        require(from == address(0) || to == address(0), "Not allowed to transfer token");
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) override internal {

        if (from == address(0)) {
            emit Attest(to, tokenId);
        } else if (to == address(0)) {
            emit Revoke(to, tokenId);
        }
    }


    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }if (revealed == false) {
      return hiddenMetadataUri;
    } else { //inseri o else para aparecer o código de revelação

    string memory currentBaseURI = baseURI;
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), uriSuffix))
        : '';
    }
    }

    function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

function setPaused(bool _paused) public onlyOwner{
    paused = _paused;
  emit Pausedevnt(msg.sender);
}
  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }



    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }
}
