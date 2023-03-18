// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyCollectible is ERC20 {
    constructor(uint256 initialSupply) ERC20("Swplit", "SP") {
        _mint(0x607Ec1a7F093801b40DaE21131dDAdB8ce991106, initialSupply*10**18);
    }
}
