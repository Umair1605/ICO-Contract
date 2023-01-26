//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract Token is ERC20PresetMinterPauser {
	constructor() ERC20PresetMinterPauser('Token_Coin', 'TKN'){}
    function mint(address minter) public {
        _mint(minter, 100000000 * (10 ** decimals()));
    }
}  