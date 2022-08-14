// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.15;

//ERC721AX implementation: https://github.com/0xPhaze/ERC721A-Improved
import "./ERC721A/ERC721AX.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Context.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();
error ContractPaused();

contract NFT is ERC721AX, Ownable {

    using Strings for uint256;
    string public baseURI;
    uint256 public constant MINT_PRICE = 0.08 ether;
    bool public paused = true;

    //events
    event Pausedevnt(address account);

    modifier Paused(){
        if(paused)revert ContractPaused();
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        uint256 _startingIndex,
        uint256 _collectionSize,
        uint256 _maxPerWallet
    ) ERC721AX(_name, _symbol, 
    _startingIndex, _collectionSize, _maxPerWallet) {
        baseURI = _baseURI;
    }

    function mintTo(address recipient) public payable {
        if (msg.value != MINT_PRICE) {
            revert MintPriceNotPaid();
        }
        _mint(recipient, 1);
    }

     function mint(address user, uint256 quantity) external {
        // if (quantity > maxPerTx) revert MintExceedsMaxPerTx();
        _mint(user, quantity);
    }

    function mintOne(address user) external { //public payable
        //  if (msg.value != MINT_PRICE) {
        //     revert MintPriceNotPaid();
        // }
        _mint(user, 1);
    }

    function mintFive(address user) external {
        _mint(user, 5);
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
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function setPaused(bool _paused) public onlyOwner{
    paused = _paused;
  emit Pausedevnt(msg.sender);
}

    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }
}