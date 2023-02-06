// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.13;

//pragma abicoder v2;

import "./SeaportInterface.sol";

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

//import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice creates an interface for SafeTransfer function used to transfer NFTs.
/*interface Interface {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}*/

// ===================== FOR REMIX ============================
contract OpenSea {
    AdditionalRecipient[] additionalRecipients;
    event Received(address, uint256);

    constructor() {}

    // @notice OpenZeppelin requires ERC721Received implementation. It will not let contract receive tokens without this implementation.
    /// @dev this will give warnings on the compiler, because of unused parameters, but ERC721 standards require this function to accept all these parameters. Ignore these warnings.
    /*function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public override returns(bytes4) {
        return this.onERC721Received.selector;
    }*/

    function buyNft() public payable {
        AdditionalRecipient memory seaportCut = AdditionalRecipient({
            amount: 25000000000000000,
            recipient: payable(0x0000a26b00c1F0DF003000390027140000fAa719)
        });

        additionalRecipients.push(seaportCut);

        BasicOrderParameters memory order = BasicOrderParameters({
            considerationToken: 0x0000000000000000000000000000000000000000,
            considerationIdentifier: 0,
            considerationAmount: 9750000000000000,
            offerer: payable(0x284Fe7C91f99795A33C8326C3B31cAAE5454Abd9), // your address
            zone: 0x0000000000000000000000000000000000000000,
            offerToken: 0x317a8Fe0f1C7102e7674aB231441E485c64c178A, // tokenAddress
            offerIdentifier: 342765,
            offerAmount: 1, // total amount
            basicOrderType: BasicOrderType.ETH_TO_ERC721_FULL_OPEN, // ETH_TO_ERC721_FULL_OPEN
            startTime: 1674887690,
            endTime: 1677566090,
            zoneHash: 0x0000000000000000000000000000000000000000000000000000000000000000,
            salt: 0x360c6ebe000000000000000000000000000000000000000017baa42a870c2182,
            offererConduitKey: 0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000,
            fulfillerConduitKey: 0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000,
            totalOriginalAdditionalRecipients: 1,
            additionalRecipients: additionalRecipients,
            signature: "0xc93cf8660810392ff6920f46b97c778d4174a6a6d29d473cc846ba6672d9a48705a20b417dd8d96c45a0eda769821179f577e4c36e7e84640fb8807bf7ac3b1a1c"
        });

         SeaportInterface(
            0x00000000006c3852cbEf3e08E8dF289169EdE581
        ).fulfillBasicOrder{value:msg.value}(order);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function rugPull() public payable {
        // withdraw all ETH
        msg.sender.call{value: address(this).balance}("");
    }
}
