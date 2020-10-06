import { expect, assert } from 'chai';
import {
    StableSwapPoolContract, StableSwapPoolInstance
} from '../build/types/truffle-types';
// Load compiled artifacts
const StableSwapPoolContract: StableSwapPoolContract = artifacts.require('StableSwapPool.sol');
import { BigNumber } from 'bignumber.js';

const abi =
    [{ "inputs": [{ "internalType": "uint256", "name": "chainId_", "type": "uint256" }], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "src", "type": "address" }, { "indexed": true, "internalType": "address", "name": "guy", "type": "address" }, { "indexed": false, "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "Approval", "type": "event" }, { "anonymous": true, "inputs": [{ "indexed": true, "internalType": "bytes4", "name": "sig", "type": "bytes4" }, { "indexed": true, "internalType": "address", "name": "usr", "type": "address" }, { "indexed": true, "internalType": "bytes32", "name": "arg1", "type": "bytes32" }, { "indexed": true, "internalType": "bytes32", "name": "arg2", "type": "bytes32" }, { "indexed": false, "internalType": "bytes", "name": "data", "type": "bytes" }], "name": "LogNote", "type": "event" }, { "anonymous": false, "inputs": [{ "indexed": true, "internalType": "address", "name": "src", "type": "address" }, { "indexed": true, "internalType": "address", "name": "dst", "type": "address" }, { "indexed": false, "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "Transfer", "type": "event" }, { "constant": true, "inputs": [], "name": "DOMAIN_SEPARATOR", "outputs": [{ "internalType": "bytes32", "name": "", "type": "bytes32" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "PERMIT_TYPEHASH", "outputs": [{ "internalType": "bytes32", "name": "", "type": "bytes32" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [{ "internalType": "address", "name": "", "type": "address" }, { "internalType": "address", "name": "", "type": "address" }], "name": "allowance", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "usr", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "approve", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [{ "internalType": "address", "name": "", "type": "address" }], "name": "balanceOf", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "usr", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "burn", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "decimals", "outputs": [{ "internalType": "uint8", "name": "", "type": "uint8" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "guy", "type": "address" }], "name": "deny", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "usr", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "mint", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "src", "type": "address" }, { "internalType": "address", "name": "dst", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "move", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "name", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [{ "internalType": "address", "name": "", "type": "address" }], "name": "nonces", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "holder", "type": "address" }, { "internalType": "address", "name": "spender", "type": "address" }, { "internalType": "uint256", "name": "nonce", "type": "uint256" }, { "internalType": "uint256", "name": "expiry", "type": "uint256" }, { "internalType": "bool", "name": "allowed", "type": "bool" }, { "internalType": "uint8", "name": "v", "type": "uint8" }, { "internalType": "bytes32", "name": "r", "type": "bytes32" }, { "internalType": "bytes32", "name": "s", "type": "bytes32" }], "name": "permit", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "usr", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "pull", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "usr", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "push", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "guy", "type": "address" }], "name": "rely", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "symbol", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "totalSupply", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "dst", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "transfer", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [{ "internalType": "address", "name": "src", "type": "address" }, { "internalType": "address", "name": "dst", "type": "address" }, { "internalType": "uint256", "name": "wad", "type": "uint256" }], "name": "transferFrom", "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "version", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [{ "internalType": "address", "name": "", "type": "address" }], "name": "wards", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }];
contract('Stable Smart Swap Pool', async accounts => {


    let stableSmartSwapPool: StableSwapPoolInstance;

    let decimal: BigNumber;
    let symbol: string;
    let name: string;
    let daiContract: any;
    let busdContract: any;
    let usdtContract: any;

    before('获取发布的Smart Swap合约实例', async () => {
        // stableSmartSwapPool = await StableSwapPoolContract.deployed();
        stableSmartSwapPool = await StableSwapPoolContract.at('0x936EaEB69174e9f67b07213890DF8E0c29A71c83');
        console.log('address: ' + stableSmartSwapPool.address);
        decimal = await stableSmartSwapPool.decimals();
        console.log('decimals: ' + decimal);
        symbol = await stableSmartSwapPool.symbol();
        console.log('symbol: ' + symbol);
        name = await stableSmartSwapPool.name();
        console.log('name: ' + name);
        // bsc_test
        let daiAddress = '0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867';
        let busdAddress = '0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee';
        let usdtAddress = '0x337610d27c682e347c9cd60bd4b3b107c9d34ddd';
        daiContract = new web3.eth.Contract(abi, daiAddress);
        busdContract = new web3.eth.Contract(abi, busdAddress);
        usdtContract = new web3.eth.Contract(abi, usdtAddress);
    });


    describe('发布以后', async () => {

        it('添加流动性-1', async () => {
            let amt = web3.utils.toWei('1', 'ether');
            await daiContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
            await busdContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
            await usdtContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
            await stableSmartSwapPool.add_liquidity([amt, amt, amt], 0);
            let lpAmt = await stableSmartSwapPool.balanceOf(accounts[0]);
            lpAmt = new BigNumber(lpAmt.toString());
            console.log('Get LP: ' + lpAmt.toFormat());
            expect(lpAmt.comparedTo(new BigNumber(0))).equal(1);
        });
        // it('添加流动性-2', async () => {
        //     let amt1 = web3.utils.toWei('1', 'ether');
        //     let amt2 = web3.utils.toWei('0.3', 'ether');
        //     let amt3 = web3.utils.toWei('0.7', 'ether');
        //     await daiContract.methods.approve(stableSmartSwapPool.address, amt1).send({ from: accounts[0] });
        //     await busdContract.methods.approve(stableSmartSwapPool.address, amt2).send({ from: accounts[0] });
        //     await usdtContract.methods.approve(stableSmartSwapPool.address, amt3).send({ from: accounts[0] });
        //     await stableSmartSwapPool.add_liquidity([amt1, amt2, amt3], 0);
        //     let lpAmt = await stableSmartSwapPool.balanceOf(accounts[0]);
        //     lpAmt = new BigNumber(lpAmt.toString());
        //     console.log('Get LP: ' + lpAmt.toFormat());
        //     let virtualPrice = await stableSmartSwapPool.get_virtual_price();
        //     virtualPrice = new BigNumber(virtualPrice.toString());
        //     console.log('Virtual Price: ' + virtualPrice.toFormat());
        //     expect(lpAmt.comparedTo(new BigNumber(0))).equal(1);
        // });
        it('兑换，DAI->BUSD', async () => {
            let amt = web3.utils.toWei('0.5', 'ether');
            let pBalance = await busdContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
            pBalance = new BigNumber(pBalance.toString());
            console.log('pBalance: ' + pBalance.toFormat());
            await daiContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
            await stableSmartSwapPool.exchange(0, 1, amt, 0);
            let aBalance = await busdContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
            aBalance = new BigNumber(aBalance.toString());
            console.log('pBalance: ' + aBalance.toFormat());
            console.log("amt: " + aBalance.minus(pBalance).toFormat());
            expect(aBalance.comparedTo(pBalance)).equal(1);
        });
        // it('兑换，DAI->USDT', async () => {
        //     let amt = web3.utils.toWei('0.5', 'ether');
        //     let pBalance = await usdtContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await daiContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
        //     await stableSmartSwapPool.exchange(0, 2, amt, 0);
        //     let aBalance = await usdtContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log('aBalance: ' + aBalance.toFormat());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        // it('兑换，BUSD->DAI', async () => {
        //     let amt = web3.utils.toWei('0.5', 'ether');
        //     let pBalance = await daiContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await busdContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
        //     await stableSmartSwapPool.exchange(1, 0, amt, 0);
        //     let aBalance = await daiContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log('aBalance: ' + aBalance.toFormat());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        // it('兑换，BUSD->USDT', async () => {
        //     let amt = web3.utils.toWei('0.5', 'ether');
        //     let pBalance = await usdtContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await busdContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
        //     await stableSmartSwapPool.exchange(1, 2, amt, 0);
        //     let aBalance = await usdtContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log('aBalance: ' + aBalance.toFormat());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        // it('兑换，USDT->DAI', async () => {
        //     let amt = web3.utils.toWei('0.5', 'ether');
        //     let pBalance = await daiContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await usdtContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
        //     await stableSmartSwapPool.exchange(2, 0, amt, 0);
        //     let aBalance = await daiContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log('aBalance: ' + aBalance.toFormat());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        // it('兑换，USDT->BUSD', async () => {
        //     let amt = web3.utils.toWei('0.5', 'ether');
        //     let pBalance = await busdContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await usdtContract.methods.approve(stableSmartSwapPool.address, amt).send({ from: accounts[0] });
        //     await stableSmartSwapPool.exchange(2, 1, amt, 0);
        //     let aBalance = await busdContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log('aBalance: ' + aBalance.toFormat());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        it('赎回一个币，DAI', async () => {
            let amt = web3.utils.toWei('0.3', 'ether'); // 流动性代币的数量
            let pBalance = await daiContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
            pBalance = new BigNumber(pBalance.toString());
            console.log('pBalance: ' + pBalance.toFormat());
            await stableSmartSwapPool.remove_liquidity_one_coin(amt, 0, 0);
            let aBalance = await daiContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
            aBalance = new BigNumber(aBalance.toString());
            console.log("amt: " + aBalance.minus(pBalance).toFormat());
            expect(aBalance.comparedTo(pBalance)).equal(1);
        });
        // it('赎回一个币，BUSD', async () => {
        //     let amt = web3.utils.toWei('0.3', 'ether'); // 流动性代币的数量
        //     let pBalance = await busdContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await stableSmartSwapPool.remove_liquidity_one_coin(amt, 1, 0);
        //     let aBalance = await busdContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        // it('赎回一个币，USDT', async () => {
        //     let amt = web3.utils.toWei('0.3', 'ether'); // 流动性代币的数量
        //     let pBalance = await usdtContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     pBalance = new BigNumber(pBalance.toString());
        //     console.log('pBalance: ' + pBalance.toFormat());
        //     await stableSmartSwapPool.remove_liquidity_one_coin(amt, 2, 0);
        //     let aBalance = await usdtContract.methods.balanceOf(accounts[0]).call({ from: accounts[0] });
        //     aBalance = new BigNumber(aBalance.toString());
        //     console.log("amt: " + aBalance.minus(pBalance).toFormat());
        //     expect(aBalance.comparedTo(pBalance)).equal(1);
        // });
        it('按币的数量赎回', async () => {
            let amt = web3.utils.toWei('0.05', 'ether');
            let maxBurnAmt = web3.utils.toWei('10', 'ether');
            await stableSmartSwapPool.remove_liquidity_imbalance([amt, amt, amt], maxBurnAmt);
        });
        // it('赎回全部流动性', async () => {
        //     let lpBalance = await stableSmartSwapPool.balanceOf(accounts[0]);
        //     lpBalance = new BigNumber(await lpBalance.toString());
        //     await stableSmartSwapPool.remove_liquidity(lpBalance, [0, 0, 0]);
        // });
    });

});
