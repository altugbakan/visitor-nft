// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/utils/Base64.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

/// @title alt.ug Visitor NFTs
/// @author Altuğ Bakan
/// @notice Soulbound, on-chain NFT for visiting alt.ug.
contract Visitor is IERC721 {
    using Strings for uint256;

    /// @notice Thrown when the token has no owner.
    error InvalidOwner();

    /// @notice Thrown when the owner does not own a token.
    error InvalidToken();

    /// @notice Thrown when trying to transfer an NFT.
    error CannotTransfer();

    /// @notice Thrown when trying to approve an NFT for spending.
    error CannotApprove();

    /// @notice Thrown when trying to mint twice.
    error AlreadyMinted();

    /// @notice Keeps track of wallets minted.
    /// @dev This is required as balanceOf can
    /// be 0 after burning a token.
    mapping(address => bool) public minted;

    /// @notice Keeps track of owners of tokens.
    mapping(uint256 => address) private owners;

    /// @notice Keeps track of tokens of owners.
    mapping(address => uint256) private tokens;

    /// @notice Keeps the URI data of tokens.
    mapping(uint256 => string) private tokenURIs;

    /// @notice Name of the token.
    string private _name;

    /// @notice Symbol of the token.
    string private _symbol;

    /// @notice Current token ID.
    uint256 private _tokenId;

    /// @notice Possible background colors of the SVG gradient.
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

    /// @notice Initializes the name and symbol
    // of the token and sets the token ID.
    /// @dev Token ID starts from 1 as token ID
    /// of 0 is used to detect ownerless tokens.
    constructor() {
        _name = "alt.ug Visitor NFTs";
        _symbol = "alt.ug";
        _tokenId = 1;
    }

    /// @notice Returns the number of tokens in owner's account.
    /// @dev Since a wallet can only mint once, this function returns 0 or 1.
    /// @param owner The wallet which its balance is queried.
    /// @return The balance of the supplied owner.
    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert InvalidOwner();
        return tokens[msg.sender] > 0 ? 1 : 0;
    }

    /// @notice Returns the owner of the tokenId token.
    /// @param tokenId The token which its owner is queried.
    /// @return The owner of the supplied token ID.
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = owners[tokenId];
        if (owner == address(0)) revert InvalidOwner();
        return owner;
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be transferred.
    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure {
        revert CannotTransfer();
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be transferred.
    function safeTransferFrom(
        address,
        address,
        uint256
    ) external pure {
        revert CannotTransfer();
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be transferred.
    function transferFrom(
        address,
        address,
        uint256
    ) external pure {
        revert CannotTransfer();
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be approved.
    function approve(address, uint256) external pure {
        revert CannotApprove();
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be approved.
    function setApprovalForAll(address, bool) external pure {
        revert CannotApprove();
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be approved.
    /// @return address 0.
    function getApproved(uint256) external pure returns (address) {
        return address(0);
    }

    /// @notice This function is supplied to fit the ERC721 standard.
    /// Tokens cannot actually be approved.
    /// @return false.
    function isApprovedForAll(address, address) external pure returns (bool) {
        return false;
    }

    /// @notice Returns the name of the token.
    /// @return The name of the token.
    function name() public view returns (string memory) {
        return _name;
    }

    /// @notice Returns the symbol of the token.
    /// @return The symbol of the token.
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /// @notice Returns the token URI of the token.
    /// @return The token URI of the token.
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenURIs[tokenId];
    }

    /// @notice The function to mint a (not really) randomized token.
    /// @dev Since randomness is not really critical in this case,
    /// a Verifiable Randomness Function is not used. Do not use this
    /// logic in a situation where true randomness is required.
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

    /// @notice The function to burn the owned token. Note that
    /// burning a token does not give the ability to mint again.
    function burn() public {
        uint256 tokenId = tokens[msg.sender];
        if (tokenId == 0) revert InvalidToken();

        delete tokens[msg.sender];
        delete owners[tokenId];
        delete tokenURIs[tokenId];

        emit Transfer(msg.sender, address(0), tokenId);
    }

    /// @notice Returns the current token ID.
    /// @return The current token ID.
    function currentTokenId() external view returns (uint256) {
        return _tokenId;
    }

    /// @notice Returns the token of an owner.
    /// @dev Since a wallet can only mint one token, this function
    /// can be used to find the token of an owner easily.
    /// @param owner The wallet which its balance is queried.
    /// @return The token of an owner.
    function tokenOf(address owner) external view returns (uint256) {
        uint256 token = tokens[owner];
        if (token == 0) revert InvalidToken();
        return token;
    }

    /// @notice Retuns the knowledge that this function supports
    /// The ERC721 standard.
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId;
    }

    /// @notice Builds the token URI for the supplied token ID.
    /// @dev The URI is built as a Base64 encoded JSON, where the
    /// image is a Base64 encoded SVG.
    /// @param tokenId The token ID for which the URI is created.
    /// @return The URI for the supplied token ID.
    function buildURI(uint256 tokenId) private view returns (string memory) {
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string.concat(
                            '{"name": "Visitor #',
                            tokenId.toString(),
                            '", "description": "An NFT for visiting alt.ug", "image": "data:image/svg+xml;base64,',
                            Base64.encode(bytes(buildSVG(tokenId))),
                            '"}'
                        )
                    )
                )
            );
    }

    /// @notice Builds the image of the supplied token ID.
    /// @dev The randomness can easily be gamed by checking the block number,
    /// timestamp, coinbase, and the token ID in another contract. Do not use
    /// this logic where randomness is critical.
    /// @param tokenId The token ID for which the SVG is created.
    /// @return The SVG for the supplied token ID.
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
