# Nibiru Oracle Mocking Demo (Foundry)

## 🧩 What problem does this repo solve?

`NibiruOracleChainlinkLike.latestAnswer()` calls a **Nibiru oracle precompile** hard‑coded at `0x000…0801`.
On a local Foundry test‑VM this address has **no code and no storage**, so every call reverts with a custom error such as `FeedNotFound("unibi:uusd")`.

## 🛠️ How we fixed it

1. **OracleMock.sol** – a minimal contract that implements the same ABI as the precompile (`IOracle`). It lets tests push arbitrary prices via `setPrice(pair, price)`.
2. **trick** – Foundry cheat code used to copy the mock’s *runtime bytecode* into the real precompile slot.
3. **Write storage after etch** – because `vm.etch` transfers *code only*, the test calls `OracleMock(PRECOMPILE).setPrice(...)` *after* etching so the storage lives at the precompile address.

Result: your adapter contract reads prices just like on‑chain, and tests pass 🎉.

## 📁 Project structure

```
.
├── foundry.toml             # Foundry config
├── src/
│   ├── IOracle.sol          # Interface + global constants
│   ├── OracleMock.sol       # Mock that we etch
│   ├── NibiruOracleChainlinkLike.sol  # The adapter under test
│   └── ChainLinkAggregatorV3Interface.sol  # External interface
└── test/
    └── OraclePrecompile.t.sol  # Proof‑of‑concept test
```

## 🚀 Quick start

```bash
# 1) install Foundry once
curl -L https://foundry.paradigm.xyz | bash && foundryup

# 2) clone and test
forge install                               # pulls forge‑std
forge test -vvvv                           # should pass ✅
```

### What you should see

```
[PASS] testLatestAnswer() (gas: …)
```

No `EvmError: Revert`, price equals `100e18`.

## 🔍 Key lines to understand

```solidity
// test/OraclePrecompile.t.sol
mock = new OracleMock();            // deploy standalone mock
vm.etch(PRECOMPILE, address(mock).code);  // move its *code* into 0x…0801
OracleMock(PRECOMPILE).setPrice("unibi:uusd", 100e18); // now write storage

feed = new NibiruOracleChainlinkLike("unibi:uusd", 18);
```

* Always set storage **after** the etch.

## 🧑‍💻 Extending

* Add more pairs: `OracleMock(PRECOMPILE).setPrice("ubtc:uusd", 65000e18)` \* Need dynamic prices? Call `setPrice` inside each test or in `beforeEach`.
* Re‑use the base setup by inheriting from `OraclePrecompileTest`.

## ⚠️ Troubleshooting

| Symptom                              | Likely cause                      |
| ------------------------------------ | --------------------------------- |
| Revert with `FeedNotFound`           | Price not set **after** etch      |
| Zero price returned                  | Same as above, or wrong decimals  |
| `Identifier not found` compile error | Missing `import "./IOracle.sol";` |

---

Made with ❤️ & `vm.etch()` so you can iterate fast.
