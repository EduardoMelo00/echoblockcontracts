// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract EchoBlockMusic is ERC1155, AccessControl, IERC1155Receiver {
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    uint256 private _tokenIdTracker;

    struct Song {
        address artist;
        string cover;
        uint256 totalTokens;
        uint256 tokensForSale;
    }

    mapping(uint256 => Song) public songs;
    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createSong(
        string memory metadataUri,
        uint256 totalTokens,
        uint256 percentageForSale
    ) public onlyRole(ARTIST_ROLE) {
        uint256 newTokenId = _tokenIdTracker;
        uint256 tokensForSale = (totalTokens * percentageForSale) / 100;
        uint256 tokensForArtist = totalTokens - tokensForSale;

        songs[newTokenId] = Song({
            artist: msg.sender,
            cover: metadataUri,
            totalTokens: totalTokens,
            tokensForSale: tokensForSale
        });

        _mint(msg.sender, newTokenId, tokensForArtist, "");
        _mint(address(this), newTokenId, tokensForSale, "");
        _tokenURIs[newTokenId] = metadataUri;
        _tokenIdTracker += 1;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155, AccessControl, IERC165)
        returns (bool)
    {
        return
            ERC1155.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId) ||
            interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function grantArtistRole(
        address artistAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ARTIST_ROLE, artistAddress);
    }

    function revokeArtistRole(
        address artistAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ARTIST_ROLE, artistAddress);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
