// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/utils/Base64.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract Visitor is IERC721 {
    using Strings for uint256;

    error InvalidOwner();
    error InvalidAddress();
    error InvalidToken();
    error CannotTransfer();
    error CannotApprove();
    error AlreadyMinted();

    mapping(address => bool) public minted;

    mapping(uint256 => address) private owners;
    mapping(address => uint256) private tokens;
    mapping(uint256 => string) private tokenURIs;
    string private _name;
    string private _symbol;
    uint256 private _tokenId;

    string[2][10] private colors = [
        ["654ea3", "eaafc8"],
        ["c6ffdd", "f7797d"],
        ["ff9966", "ff5e62"],
        ["c0c0aa", "1cefff"],
        ["fc00ff", "00dbde"],
        ["fbd3e9", "bb377d"],
        ["232526", "7a7a7a"],
        ["1a2980", "26d0ce"],
        ["ffe259", "ffa751"],
        ["007991", "78ffd6"]
    ];

    constructor() {
        _name = "alt.ug Visitor NFTs";
        _symbol = "alt.ug";
        _tokenId = 1;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert InvalidOwner();
        return tokens[msg.sender] > 0 ? 1 : 0;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = owners[tokenId];
        if (owner == address(0)) revert InvalidOwner();
        return owner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external {
        revert CannotTransfer();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        revert CannotTransfer();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        revert CannotTransfer();
    }

    function approve(address to, uint256 tokenId) external {
        revert CannotApprove();
    }

    function setApprovalForAll(address operator, bool _approved) external {
        revert CannotApprove();
    }

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator)
    {
        return address(0);
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool)
    {
        return false;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURIs[tokenId];
    }

    function mint() public {
        if (minted[msg.sender]) revert AlreadyMinted();
        minted[msg.sender] = true;

        uint256 tokenId = _tokenId;
        tokens[msg.sender] = tokenId;
        owners[tokenId] = msg.sender;
        tokenURIs[tokenId] = buildURI(tokenId);

        emit Transfer(address(0), msg.sender, tokenId);

        _tokenId++;
    }

    function burn() public {
        uint256 tokenId = tokens[msg.sender];
        if (tokenId == 0) revert InvalidToken();

        delete tokens[msg.sender];
        delete owners[tokenId];
        delete tokenURIs[tokenId];

        emit Transfer(msg.sender, address(0), tokenId);
    }

    function currentTokenId() external view returns (uint256) {
        return _tokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return interfaceId == type(IERC721).interfaceId;
    }

    function buildURI(uint256 tokenId) private view returns (string memory) {
        return
            string.concat(
                '{"name": "Visitor #',
                tokenId.toString(),
                '", "description": "An NFT for visiting alt.ug", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(buildSVG(tokenId))),
                '"}'
            );
    }

    function buildSVG(uint256 tokenId) private view returns (string memory) {
        uint256 random = uint256(
            keccak256(
                abi.encode(
                    block.number,
                    block.timestamp,
                    block.coinbase,
                    msg.sender
                )
            )
        ) % 10;
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#',
                colors[random][0],
                '"/><stop offset="1" stop-color="#',
                colors[random][1],
                '" stop-opacity=".99"/></linearGradient></defs><text x="20" y="30" font-size="12" fill="#fff" filter="url(#A)" font-family="Courier New" font-weight="bold">>A</text><text x="220" y="240" font-size="12" fill="#fff" filter="url(#A)" font-family="Helvetica" font-weight="bold" text-anchor="end">#',
                tokenId.toString(),
                '</text><text x="42" y="142" font-size="27" fill="#fff" filter="url(#A)" font-family="Helvetica" font-weight="bold">I visited alt.ug</text></svg>'
            );
    }
}
