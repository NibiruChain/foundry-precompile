// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/OracleMock.sol";
import "../src/NibiruOracleChainLinkLike.sol";

contract OraclePrecompileTest is Test {
    address constant PRECOMPILE = 0x0000000000000000000000000000000000000801;

    OracleMock mock;
    NibiruOracleChainLinkLike feed;

    function setUp() public {
        mock = new OracleMock();
        mock.setPrice("unibi:uusd", 100e18); // 100.00 USD in 18 dec

        // move the runtime code of the mock into the reserved precompile slot
        vm.etch(PRECOMPILE, address(mock).code);

        OracleMock(PRECOMPILE).setPrice("unibi:uusd", 100e18);

        feed = new NibiruOracleChainLinkLike("unibi:uusd", 18);
    }

    function testLatestAnswer() public {
        int256 price = feed.latestAnswer();
        assertEq(price, 100e18);
    }
}
