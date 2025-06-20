// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IOracle {
    function queryExchangeRate(
        string memory pair
    ) external view returns (uint256, uint64, uint64);

    function chainLinkLatestRoundData(
        string memory pair
    )
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}

address  constant ORACLE_PRECOMPILE_ADDRESS = 0x0000000000000000000000000000000000000801;
IOracle constant NIBIRU_ORACLE           = IOracle(ORACLE_PRECOMPILE_ADDRESS);
