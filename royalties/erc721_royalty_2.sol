// SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


//0x1fbb4c25c4616ea8f77aae6eb1c3557931ef8db95ac13d324630811789168bdc

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract wassimRoyalty is Context, ERC165, IERC721  {


    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    uint internal salePrice = 1 ether ;

    
    string private _name;

    string private _symbol;

    address internal Owner ;

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    mapping(uint256  => address) private _owners;

    mapping(address  => uint256) private _balances;

    mapping(uint256  => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    mapping(uint256 => string) private URI;


    constructor(string memory name_, string memory symbol_) {
        Owner = msg.sender ;
        _name = name_;
        _symbol = symbol_;
    }


    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 royaltyPercent) internal {
        require(receiver != address(0), "ERC2981: Invalid parameters");
        require(royaltyPercent < 100, "royaltyPercent can not be < 100");

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, royaltyPercent);
    }


    function mint(address to, address receiver, uint96 royaltyPercent) public {
        require(royaltyPercent < 100, "Royalty percent cannot exceed 100");

        _tokenIds.increment();
        uint tokenId = _tokenIds.current();

        //_royaltyRecipients[tokenId] = royaltyRecipient;
        //_royaltyPercents[tokenId] = royaltyPercent;

        _mint(to,tokenId);
        _setTokenRoyalty(tokenId, receiver, royaltyPercent);
    }

    function royaltyInfo(uint256 tokenId) public view returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / 100 ;

        return (royalty.receiver, royaltyAmount);
    }


    function transferWithRoyalty(address from, address to, uint256 tokenId ) payable public  {
        require(msg.value >= salePrice,"value of ETH < salePrice.");
        (address receiver, uint256 amount) = royaltyInfo(tokenId);
    
        transferFrom(from, to, tokenId);
    
        payable(receiver).transfer(amount);
    
        payable(from).transfer(salePrice - amount);
    }

    /**only owner can be from address
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0),"invalid Owner.");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0),"invalid Owner.");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */


    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(_owners[tokenId] != address(0),"token Id not exist.");

        string memory baseURI = _baseURI(tokenId);
        return bytes(baseURI).length > 0 ? baseURI : "";
    }
    function setTokenURI(uint256 tokenId, string memory uri) public {
        URI[tokenId] = uri ;
    }


    function _baseURI(uint256 tokenId) internal view virtual returns (string memory) {
        return  URI[tokenId] ;
    }


    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */


    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, msg.sender);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireMinted(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }



    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual  {
            require(to != address(0),"reciver address 0.");
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(to, tokenId, _msgSender());
        if (previousOwner != from) {
            revert("only owner can be from address") ;
        }

    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**"Not the owner
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not
     * verify this assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` has not approval for all assets of the provided `owner` nor the actual owner approved the `spender` for the specific `tokenId`.
     *
     * WARNING: This function relies on {_isAuthorized}, so it doesn't check whether `owner` is the
     * actual owner of `tokenId`.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert("owner == address(0)");
            } 
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *address(form) not the token owner address
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }



        // Execute the update
        if (from != address(0)) {
            delete _tokenApprovals[tokenId];
            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
        
        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert("address to can not be address(0)");
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert("token minted befor.") ;
        }
    }


    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert("token owner can not be address(0)");
        }
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert("address(to) can not be address(0)");
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner == address(0)) {
            revert("address(from) can not be address(0)") ;
        } else if (_ownerOf(tokenId) == from) {
            revert ("address(form) not the token owner address");
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *Not the owner
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     Not the owner
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        require(_owners[tokenId] == auth,"only owner can approve");

        address owner = ownerOf(tokenId);
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);

        return owner;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        if (operator == address(0)) {
            revert("operator == address(0)") ;
        }
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        if (_ownerOf(tokenId) == address(0)) {
            revert("Token does not exist");
        }
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert("retval != IERC721Receiver.onERC721Received.selector") ;
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ("eason.length == 0");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
