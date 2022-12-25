// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//////////////////
//Error Dialoge//
//////////////////

error Estate_NotOwner();
error Estate_Owner();
error Estate_PriceLessThanZero();
error Estate_AlreadyListed();
error Estate_NotListed(uint256 tokenId);
error Estate_NotInspected(uint256 tokenId);
error Estate_PriceNotMet();

contract Estate is ERC721URIStorage, Ownable {
    struct Listing {
        uint256 price;
        address seller;
        bool inspect;
    }

    //////////
    //Events//
    /////////
    event EstateTransfer(
        uint256 tokenId,
        address from,
        address to,
        string tokenURI,
        uint256 price
    );

    event Withdraw(address indexed contractOwner, uint256 indexed balance);

    ////////////
    //Modifier//
    ////////////

    modifier isOwner(uint256 tokenId, address spender) {
        address owner = ownerOf(tokenId);

        if (spender != owner) {
            revert Estate_NotOwner();
        }

        _;
    }

    modifier notOwner(uint256 tokenId, address inspecotor) {
        address owner = _list[tokenId].seller;

        if (owner == inspecotor) {
            revert Estate_Owner();
        }
        _;
    }
    modifier isSeller(uint256 tokenId, address canceller) {
        address owner = _list[tokenId].seller;

        if (owner != canceller) {
            revert Estate_NotOwner();
        }
        _;
    }

    modifier notListed(uint256 tokenId) {
        if (_list[tokenId].price != 0) {
            revert Estate_AlreadyListed();
        }
        _;
    }

    modifier inspected(uint256 tokenId) {
        if (_list[tokenId].inspect == false) {
            revert Estate_NotInspected(tokenId);
        }
        _;
    }

    modifier listed(uint256 tokenId) {
        if (_list[tokenId].price == 0) {
            revert Estate_NotListed(tokenId);
        }
        _;
    }

    //////////////////
    //DataStructures//
    //////////////////

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;
    mapping(uint256 => Listing) private _list;

    constructor() ERC721("ESTATE", "EST") {}

    /////////////////////////
    //Estate Asset creation//
    ////////////////////////

    function realEstate(string calldata tokenURI) public {
        _tokenId.increment();

        uint256 currentId = _tokenId.current();
        _safeMint(msg.sender, currentId);
        _setTokenURI(currentId, tokenURI);

        emit EstateTransfer(currentId, address(0), msg.sender, tokenURI, 0);
    }

    //////////////////
    //Advertisement//
    //////////////////

    function listEstate(
        uint256 tokenId,
        uint256 price
    ) external isOwner(tokenId, msg.sender) notListed(tokenId) {
        if (price <= 0) {
            revert Estate_PriceLessThanZero();
        }
        approve(address(this), tokenId);
        transferFrom(msg.sender, address(this), tokenId);
        _list[tokenId] = Listing(price, msg.sender, false);

        emit EstateTransfer(tokenId, msg.sender, address(this), "", price);
    }

    //////////////////
    //Inspection//
    //////////////////

    function inspect(
        uint256 tokenId
    ) external notOwner(tokenId, msg.sender) listed(tokenId) {
        _list[tokenId].inspect = true;

        emit EstateTransfer(tokenId, address(this), address(this), "", 0);
    }

    /////////////
    //Asset Buy//
    ////////////

    function buyEstate(
        uint256 tokenId
    ) public payable listed(tokenId) inspected(tokenId) {
        if (msg.value != _list[tokenId].price) {
            revert Estate_PriceNotMet();
        }
        ERC721(address(this)).transferFrom(address(this), msg.sender, tokenId);
        (bool success, ) = payable(_list[tokenId].seller).call{
            value: _list[tokenId].price.mul(97).div(100)
        }("");
        require(success, "Transfer failed");

        emit EstateTransfer(
            tokenId,
            address(this),
            msg.sender,
            "",
            _list[tokenId].price
        );

        _list[tokenId].price = 0;
        _list[tokenId].seller = address(0);
        _list[tokenId].inspect = false;
    }

    ////////////////
    //Canceling Ad//
    ///////////////

    function cancelListing(
        uint256 tokenId
    ) public listed(tokenId) isSeller(tokenId, msg.sender) {
        ERC721(address(this)).transferFrom(address(this), msg.sender, tokenId);

        _list[tokenId].price = 0;
        _list[tokenId].seller = address(0);
        _list[tokenId].inspect = false;

        emit EstateTransfer(tokenId, address(this), msg.sender, "", 0);
    }

    ///////////////////////////////
    //Withdraw for contract owner//
    ///////////////////////////////

    function withdrawFund() public onlyOwner {
        uint256 balance = address(this).balance;

        require(balance > 0, "Balance is zero");

        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");

        emit Withdraw(msg.sender, balance);
    }
}
