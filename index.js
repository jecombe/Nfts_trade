import Opensea from "./opensea/Opensea.js";

const opensea = new Opensea("0x00000000006c3852cbEf3e08E8dF289169EdE581");

const buyNft = async (tokenId, collecitonAddr) => {
    const tx = await opensea.buy(collecitonAddr, tokenId)
    console.log('Tx: ', tx);
}

// buyNft('363' ,"0xE29F8038d1A3445Ab22AD1373c65eC0a6E1161a4")