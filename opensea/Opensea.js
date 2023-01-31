import opensea from 'opensea-js';
import ethers from 'ethers';
import dotenv from 'dotenv';
import HDWalletProvider from '@truffle/hdwallet-provider';
import { createRequire } from "module";
const require = createRequire(import.meta.url);
dotenv.config();
const factoryAbi = require("./Seaport.json");

export default class {
    constructor(seaportAddress) {
        this.provider = new HDWalletProvider({
            mnemonic: {
                phrase: process.env.MEMO_PHRASES
            },
            providerOrUrl: process.env.PROVIDER
        });
        this.customHttpProvider = new ethers.providers.JsonRpcProvider(process.env.PROVIDER);
        this.wallet = new ethers.Wallet(process.env.SECRET_KEY, this.customHttpProvider);

        this.seaport = new opensea.OpenSeaPort(this.provider, {
            networkName: opensea.Network.Goerli
        });
        this.contractWithSigner = new ethers.Contract(seaportAddress, factoryAbi, this.wallet);
    }

    async getOrder(side, tokenId, assetContractAddress) {

        return this.seaport.api.getOrder({
            side,
            assetContractAddress,
            tokenId,
        })
    }

    createOrder(order) {
        const basicOrderParameters = {
            considerationToken: order.protocolData.parameters.consideration[0].token,
            considerationIdentifier: ethers.BigNumber.from('0'),
            considerationAmount: undefined,
            offerer: undefined,
            zone: order.protocolData.parameters.zone,
            offerToken: undefined,
            offerIdentifier: undefined,
            offerAmount: 1,
            basicOrderType: 0,
            startTime: undefined,
            endTime: undefined,
            zoneHash: order.protocolData.parameters.zoneHash,
            salt: undefined,
            offererConduitKey: order.protocolData.parameters.conduitKey,
            fulfillerConduitKey: order.protocolData.parameters.conduitKey,
            totalOriginalAdditionalRecipients: undefined,
            additionalRecipients: [],
            signature: undefined
        }
        basicOrderParameters.offerer = ethers.utils.getAddress(order.maker.address);
        basicOrderParameters.offerToken = order.protocolData.parameters.offer[0].token;
        basicOrderParameters.offerIdentifier = ethers.BigNumber.from(order.protocolData.parameters.offer[0].identifierOrCriteria);
        basicOrderParameters.startTime = order.listingTime;
        basicOrderParameters.endTime = order.expirationTime;
        basicOrderParameters.salt = order.protocolData.parameters.salt;
        basicOrderParameters.totalOriginalAdditionalRecipients = order.protocolData.parameters.totalOriginalConsiderationItems - 1
        basicOrderParameters.signature = order.protocolData.signature;
        for (let consider of order.protocolData.parameters.consideration) {
            if (consider.recipient === basicOrderParameters.offerer) {
                basicOrderParameters.considerationAmount = ethers.BigNumber.from(consider.startAmount);
                continue;
            }

            basicOrderParameters.additionalRecipients.push({
                amount: ethers.BigNumber.from(consider.startAmount),
                recipient: consider.recipient
            },
            );
        }

        return basicOrderParameters;
    }

    sendOrder(orderPayload, price) {
        return this.contractWithSigner.fulfillBasicOrder(orderPayload,
            {
                gasLimit: 300000,
                value: ethers.BigNumber.from(price)
            })
    }

    async buy(collectionAddr, tokenId) {
        try {
            const order = await this.getOrder('ask', tokenId, collectionAddr)
            const orderPayload = this.createOrder(order)
            const response = await this.sendOrder(orderPayload, order.currentPrice)
            console.log("transaction pending: ", response.hash);
            return response.wait();
        } catch (error) {
            console.log(error);
        }
    }
}