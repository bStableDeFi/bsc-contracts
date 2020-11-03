const SmartSwapPool03 = artifacts.require("SmartSwapPool03");

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
        let qusdAddress = '0xb8c540d00dd0bf76ea12e4b4b95efc90804f924e';
        let daiAddress = '0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3';
        let vaiAddress = '0xa8F1c29D4162EA545bcF3A85010F6E1BABF8B9b2';
        let stableCoins = [qusdAddress, daiAddress, vaiAddress];
        let A = 100;
        let fee = 30000000;// 1e-10, 0.003, 0.3%
        // let adminFee = 0;
        let adminFee = 6666666666; // 1e-10, 0.666667, 66.67% 
        let smartSwapPool03Contract = await deployer.deploy(SmartSwapPool03, stableCoins, A, fee, adminFee);
    } else if (deployer.network_id == 97) { //bsc test net
        // dai busd usdt
        let qusdAddress = '0x43B8ad974F49553dd4f5f3cB534A368fbC4761DB';
        let daiAddress = '0xec5dcb5dbf4b114c9d0f65bccab49ec54f6a0867';
        let vaiAddress = '0x0a87c5bdec19d74bee9938f928bfa153bc8532b2';
        let stableCoins = [qusdAddress, daiAddress, vaiAddress];
        let A = 100;
        let fee = 30000000;// 1e-10, 0.003, 0.3%
        // let adminFee = 0;
        let adminFee = 6666666666; // 1e-10, 0.666667, 66.67% 
        let smartSwapPool03Contract = await deployer.deploy(SmartSwapPool03, stableCoins, A, fee, adminFee);
        // console.log(stableSwapPoolContract.address);
    } else {

    }

    // deployer.deploy(factory).then(() => {
    // });
    // deployer.deploy(exchange).then(() => {
    // });
};
