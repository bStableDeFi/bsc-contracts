const StableSwapPool = artifacts.require("StableSwapPool");
const BStableProxy = artifacts.require("BStableProxy");

module.exports = async function (deployer) {
    if (deployer.network.indexOf('skipMigrations') > -1) { // skip migration
        return;
    }
    if (deployer.network.indexOf('kovan_oracle') > -1) { // skip migration
        return;
    }
    if (deployer.network_id == 4) { // Rinkeby
        // let compoundOracleAddress = "0x332b6e69f21acdba5fb3e8dac56ff81878527e06";
        // let stringComparatorLibrary = await deployer.deploy(stringComparator);
        // let oracleContract = await deployer.deploy(ploutozOracle, compoundOracleAddress);
        // let wethContract = await deployer.deploy(weth);
        // console.log('WETH contract address: ' + wethContract.address);
        // let exchangeContract = await deployer.deploy(exchange, uniswapFactoryAddress, uniswapRouter01Address, uniswapRouter02Address, address0);
        // deployer.link(stringComparator, factory);
        // let factoryContract = await deployer.deploy(factory, oracleContract.address, exchangeContract.address);
        // let exchangeContract=await deployer.
    } else if (deployer.network_id == 1) { // main net
    } else if (deployer.network_id == 5777) {
    } else if (deployer.network_id == 42) { // kovan
    } else if (deployer.network_id == 56) { // bsc main net
        let daiAddress = '0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3';
        let busdAddress = '0xe9e7cea3dedca5984780bafc599bd69add087d56';
        let usdtAddress = '0x55d398326f99059ff775485246999027b3197955';
        let stableCoins = [daiAddress, busdAddress, usdtAddress];
        let A = 100;
        let fee = 30000000;// 1e-10, 0.003, 0.3%
        // let adminFee = 0;
        let adminFee = 6666666666; // 1e-10, 0.666667, 66.67% 
        let stableSwapPoolContract = await deployer.deploy(StableSwapPool, stableCoins, A, fee, adminFee);
    } else if (deployer.network_id == 97) { //bsc test net
        // dai busd usdt
        let daiAddress = '0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867';
        let busdAddress = '0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee';
        let usdtAddress = '0x337610d27c682e347c9cd60bd4b3b107c9d34ddd';
        let stableCoins = [daiAddress, busdAddress, usdtAddress];
        let A = 100;
        let fee = 30000000;// 1e-10, 0.003, 0.3%
        // let adminFee = 0;
        let adminFee = 6666666666; // 1e-10, 0.666667, 66.67% 
        // await deployer.deploy(StableSwapPool, stableCoins, A, fee, adminFee);
        // let pool = await StableSwapPool.deployed();
        let proxy = await deployer.deploy(BStableProxy, "bStable Proxy (DAI/BUSD/USDT)", "BSProxy-01", stableCoins);
        // await pool.transferOwnership(BStableProxy01.address);
    } else {

    }

    // deployer.deploy(factory).then(() => {
    // });
    // deployer.deploy(exchange).then(() => {
    // });
};
