pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
/*Contractname is carbon but can also be earthday for sake of test*/
contract SoulboundCarbonOffsetToken is ERC1155 {
    using Address for address;

    uint256 private _currentTokenId = 0;
    mapping(uint256 => CarbonOffsetProperties) private _carbonOffsetProperties;
    mapping(uint256 => bool) private _soulboundTokens;

    struct CarbonOffsetProperties {
        string name;
        uint256 timestamp;
        string location;
    }

    constructor(string memory uri) ERC1155(uri) {}

    function mintCarbonOffsetToken(address to, string memory name, uint256 timestamp, string memory location) external {
        uint256 tokenId = _currentTokenId;
        _mint(to, tokenId, 1, "");
        _carbonOffsetProperties[tokenId] = CarbonOffsetProperties(name, timestamp, location);
        _currentTokenId++;
    }

    function bindToken(uint256 tokenId) external {
        require(msg.sender == ERC1155.ownerOf(tokenId), "Only the token owner can bind it.");
        _soulboundTokens[tokenId] = true;
    }

    function isSoulbound(uint256 tokenId) external view returns (bool) {
        return _soulboundTokens[tokenId];
    }

    // Override ERC-721 transfer functions
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(!_soulboundTokens[tokenId], "Cannot transfer a soulbound token.");
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(!_soulboundTokens[tokenId], "Cannot transfer a soulbound token.");
        super.safeTransferFrom(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(!_soulboundTokens[tokenId], "Cannot transfer a soulbound token.");
        super.transferFrom(from, to, tokenId);
    }

    function getCarbonOffsetProperties(uint256 tokenId) external view returns (CarbonOffsetProperties memory) {
        return _carbonOffsetProperties[tokenId];
    }

    function searchTokensByName(string memory name) external view returns (uint256[] memory) {
        return _searchTokensByProperty("name", name, 0, "");
    }

    function searchTokensByTimestamp(uint256 timestamp) external view returns (uint256[] memory) {
        return _searchTokensByProperty("timestamp", "", timestamp, "");
    }

    function searchTokensByLocation(string memory location) external view returns (uint256[] memory) {
        return _searchTokensByProperty("location", "", 0, location);
    }

    function _searchTokensByProperty(string memory property, string memory name, uint256 timestamp, string memory location) private view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < _currentTokenId; i++) {
            if (_propertyMatches(property, i, name, timestamp, location)) {
                count++;
            }
        }

        uint256[] memory tokenIds = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < _currentTokenId; i++) {
            if (_propertyMatches(property, i, name, timestamp, location)) {
                tokenIds[index] = i;
                index++;
            }
    }

    return tokenIds;
}
}

function _propertyMatches(string memory property, uint256 tokenId, string memory name, uint256 timestamp, string memory location) private view returns (bool) {
    CarbonOffsetProperties memory properties = _carbonOffsetProperties[tokenId];

    if (keccak256(abi.encodePacked(property)) == keccak256(abi.encodePacked("name"))) {
        return keccak256(abi.encodePacked(properties.name)) == keccak256(abi.encodePacked(name));
    } else if (keccak256(abi.encodePacked(property)) == keccak256(abi.encodePacked("timestamp"))) {
        return properties.timestamp == timestamp;
    } else if (keccak256(abi.encodePacked(property)) == keccak256(abi.encodePacked("location"))) {
        return keccak256(abi.encodePacked(properties.location)) == keccak256(abi.encodePacked(location));
    } else {
        return false;
    }
}
