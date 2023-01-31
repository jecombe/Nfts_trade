// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.10;
pragma abicoder v2;

import {FlashLoanReceiverBase} from "FlashLoanReceiverBase.sol";
import {ILendingPool, ILendingPoolAddressesProvider} from "Interfaces.sol";
import {SafeMath} from "Libraries.sol";
import "./Ownable.sol";

import "./IUniswapV2Router02.sol";

import "https://github.com/Uniswap/v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";

import "https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/TransferHelper.sol";

// ===================== FOR REMIX ============================ 
contract OpenSea is  Ownable {


    constructor()
    {


    }

    function buyNft() public {

    }

    function getERC20Balance(address _erc20Address)
        public
        view
        returns (uint256)
    {
        return IERC20(_erc20Address).balanceOf(address(this));
    }

    /*
     * Rugpull all ERC20 tokens from the contract
     */
    function rugPull(address tokenAddr) public payable onlyOwner {
        // withdraw all ETH
        msg.sender.call{value: address(this).balance}("");

        // withdraw all x ERC20 tokens
        IERC20(tokenAddr).transfer(
            msg.sender,
            IERC20(tokenAddr).balanceOf(address(this))
        );
    }
}
