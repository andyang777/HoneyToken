// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title HoneyToken
 * @dev ERC20 token representing governance for HoneyDAO with a fixed supply of 100 million tokens.
 *      Includes blacklist functionality to prevent certain addresses from transferring tokens,
 *      as well as pause/unpause functionality to halt transfers in case of emergency.
 *      Adds burn functionality with blacklist checks.
 * @custom:copyright PeerHive 2024
 */
contract HoneyToken is ERC20, ERC20Burnable, Ownable, Pausable {
    uint256 public constant TOTAL_SUPPLY = 100_000_000 * 10**18;
    mapping(address => bool) public blacklist;

    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);

    /**
     * @dev Constructor that mints the total supply to the owner.
     */
    constructor() ERC20("HoneyToken", "HONEY") Ownable(msg.sender) {
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    /**
     * @dev Override the transfer functions to include blacklist checks and pause functionality.
     */
    function transfer(address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        _checkBlacklist(msg.sender, to);
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override whenNotPaused returns (bool) {
        _checkBlacklist(from, to);
        return super.transferFrom(from, to, amount);
    }

    /**
     * @dev Custom burn function that includes blacklist checks.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) public override whenNotPaused {
        _checkBlacklist(msg.sender, address(0)); // Ensure sender is not blacklisted
        super.burn(amount);
    }

    /**
     * @dev Custom burnFrom function that includes blacklist checks.
     * @param account The address from which tokens will be burned.
     * @param amount The amount of tokens to burn.
     */
    function burnFrom(address account, uint256 amount) public override whenNotPaused {
        _checkBlacklist(account, address(0)); // Ensure the account is not blacklisted
        super.burnFrom(account, amount);
    }

    /**
     * @dev Internal function to check if addresses are blacklisted.
     */
    function _checkBlacklist(address from, address to) internal view {
        require(!blacklist[from], "HoneyToken: sender is blacklisted");
        require(!blacklist[to], "HoneyToken: recipient is blacklisted");
    }

    /**
     * @notice Pauses all token transfers.
     * @dev Only the owner can pause the contract.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers.
     * @dev Only the owner can unpause the contract.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Blacklists an address, preventing it from transferring or burning tokens.
     * @dev Only the owner can blacklist addresses.
     * @param _account The address to blacklist.
     */
    function blacklistAddress(address _account) external onlyOwner {
        blacklist[_account] = true;
        emit Blacklisted(_account);
    }

    /**
     * @notice Removes an address from the blacklist, allowing it to transfer or burn tokens again.
     * @dev Only the owner can remove addresses from the blacklist.
     * @param _account The address to remove from the blacklist.
     */
    function whitelistAddress(address _account) external onlyOwner {
        blacklist[_account] = false;
        emit Whitelisted(_account);
    }

    /*snapshot*/
}