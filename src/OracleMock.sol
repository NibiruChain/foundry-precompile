// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IOracle.sol";

contract OracleMock is IOracle {
    struct Data {
        uint256 price;
        uint64  timeMs;
        uint64  height;
    }
    mapping(string => Data) internal feed;

    function setPrice(string calldata pair, uint256 p) external {
        feed[pair] = Data({
            price:  p,
            timeMs: uint64(block.timestamp * 1000),
            height: uint64(block.number)
        });
    }

    // ---------- IOracle ----------
    function queryExchangeRate(
        string memory pair
    )
        external
        view
        returns (uint256 price, uint64 timeMs, uint64 height)
    {
        Data memory d = feed[pair];
        return (d.price, d.timeMs, d.height);
    }

    function chainLinkLatestRoundData(
        string memory pair
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        Data memory d = feed[pair];
        roundId         = uint80(d.height);
        answer          = int256(d.price);
        startedAt       = d.timeMs / 1000;
        updatedAt       = startedAt;
        answeredInRound = roundId;
    }
}

