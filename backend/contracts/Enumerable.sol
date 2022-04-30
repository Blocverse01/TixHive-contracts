// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
library Enumerable {
    struct Enumerator {
        // Mapping from owner to list of owned token IDs
        mapping(address => mapping(uint256 => uint256)) _ownedTokens;
        // Mapping from token ID to index of the owner tokens list
        mapping(uint256 => uint256) _ownedTokensIndex;
    }


    /**
     * @dev internal function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(
        Enumerator storage enumerator,
        address to,
        uint256 tokenId,
        uint256 balance
    ) external {
        uint256 length = balance;
        enumerator._ownedTokens[to][length] = tokenId;
        enumerator._ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev internal function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(
        Enumerator storage enumerator,
        address from,
        uint256 tokenId,
        uint256 balance
    ) external {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balance - 1;
        uint256 tokenIndex = enumerator._ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = enumerator._ownedTokens[from][lastTokenIndex];

            enumerator._ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            enumerator._ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete enumerator._ownedTokensIndex[tokenId];
        delete enumerator._ownedTokens[from][lastTokenIndex];
    }
}
