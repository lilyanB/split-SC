// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyCollectible is ERC20 {
    constructor(uint256 initialSupply) ERC20("Swplit", "SP") {
        _mint(msg.sender, initialSupply*10**18);
    }
}
