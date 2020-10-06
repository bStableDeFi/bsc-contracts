import { expect, assert } from 'chai';
import {
    SmartSwapContract, SmartSwapInstance
} from '../build/types/truffle-types';
// Load compiled artifacts
const SmartSwap: SmartSwapContract = artifacts.require('SmartSwap.sol');
import { BigNumber } from 'bignumber.js';

contract('Smart Swap(SSWAP Token) Contract', async accounts => {


    let smartSwap: SmartSwapInstance;

    let decimal: BigNumber;
    let symbol: string;
    let name: string;

    before('获取发布的Smart Swap合约实例', async () => {
        smartSwap = await SmartSwap.deployed();
        console.log('address: ' + smartSwap.address);
        decimal = await smartSwap.decimals();
        console.log('decimals: ' + decimal);
        symbol = await smartSwap.symbol();
        console.log('symbol: ' + symbol);
        name = await smartSwap.name();
        console.log('name: ' + name);
    });


    describe('发布以后，检查余额', async () => {

        it('发布以后，全部币应该都在accounts[0]手中', async () => {
            let totalSuppy = new BigNumber(await web3.utils.toWei('100000000', 'ether'));
            let ac1Balance = new BigNumber((await smartSwap.balanceOf(accounts[0])).toString());
            console.log('TotalSypply should be: ' + totalSuppy.toFormat());
            console.log('Account[0] balance should be: ' + ac1Balance.toFormat());
            expect(totalSuppy.toFormat()).equal(ac1Balance.toFormat());
        });
    });

});
