# KaspaSwift

A Swift library for Kaspa blockchain interactions, providing comprehensive support for wallet management, transaction building, and address operations.

## Features

- **Address Management**: Support for P2PK (Schnorr/ECDSA) and P2SH address types
- **Transaction Building**: Create and sign Kaspa transactions
- **HD Wallet Support**: BIP32/BIP39 mnemonic seed derivation
- **UTXO Management**: UTXO selection and transaction fee calculation
- **gRPC Client**: Integration with Kaspa gRPC protocol

## Requirements

- Swift 5.6+
- iOS 13.0+ / macOS 10.15+

## Installation

### Swift Package Manager

Add KaspaSwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/xueyuejie/KaspaSwift.git", from: "1.0.0")
]
```

## Usage

### Key Generation

```swift
import KaspaSwift

// Generate key from mnemonic
let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
let key = try KaspaKey.fromMnemonics(mnemonic)

// Derive specific path
let derivedKey = try key.derive(path: "m/44'/111111'/0'/0/0")

// Public key
print(derivedKey.publicKey.hex)

// Private key
print(derivedKey.privateKey?.hex)
```

### Address Operations

```swift
import KaspaSwift

// Create P2PK Schnorr address
let schnorrAddress = try KaspaAddress.publicKey(
    prefix: .kaspa,
    publicKey: schnorrPublicKey
)

// Create P2PK ECDSA address
let ecdsaAddress = try KaspaAddress.pubKeyECDSA(
    prefix: .kaspa,
    publicKey: ecdsaPublicKey
)

// Create P2SH address
let p2shAddress = KaspaAddress.scriptHash(
    prefix: .kaspa,
    hash: scriptHash
)

// Encode address to string
let addressString = schnorrAddress.encodeAddress()

// Decode address from string
let decodedAddress = try KaspaAddress.decodeAddress(
    address: "kaspa:qzp...truncated",
    expectedPrefix: .kaspa
)

// Validate address
let isValid = KaspaAddress.isValid(
    "kaspa:qzp...truncated",
    expectedPrefix: .kaspa
)
```

### Transaction Building

```swift
import KaspaSwift
import BigInt

// Build transaction
let transaction = try TransactionBuilder.createTransaction(
    toAddress: toAddress,
    amount: BigUInt(100000000), // 1 KAS
    changeAddress: changeAddress,
    utxos: availableUtxos,
    priorityFee: BigUInt(1000)
)

// Sign transaction
for (index, input) in transaction.inputs.enumerated() {
    try SignHelper.signInput(
        transaction: transaction,
        input: input,
        inputIndex: index,
        key: derivedKey
    )
}

// Serialize transaction
let serializedTx = try transaction.serialize()
```

### Address Prefixes

```swift
// Supported network prefixes
public enum KaspaAddressPrefix: String {
    case unknown
    case kaspa       // Mainnet
    case kaspaTest   // Testnet
    case kaspaDev    // Devnet
    case kaspaSim    // Simulation
}
```

### UTXO Model

```swift
// Kaspa UTXO structure
let utxo = KaspaUtxo(
    outpoint: KaspaOutpoint(transactionId: txId, index: 0),
    address: "kaspa:qzp...",
    utxoEntry: KaspaUtxoEntry(
        amount: UInt64(1000000000),
        scriptPublicKey: scriptPubKey,
        blockDaaScore: BigInt(1000)
    )
)
```

## Dependencies

- **Secp256k1Swift**: Elliptic curve cryptography
- **BIP39swift**: Mnemonic code generation
- **SwiftProtobuf**: Protocol buffer support
- **GRPC**: gRPC client for Kaspa node communication
- **Blake2**: Hash functions

## Transaction Fee Calculation

```swift
// Fee calculation constants
let feePerInput = BigUInt(1000) // Base fee per input
let fee = TransactionBuilder.getFee(
    selectedUtxos: selectedUtxos,
    priorityFee: priorityFee
)
```

## License

MIT License
