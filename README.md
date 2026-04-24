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

---

# KaspaSwift 中文文档

一个用于 Kaspa 区块链交互的 Swift 库，提供钱包管理、交易构建和地址操作的全面支持。

## 功能特性

- **地址管理**：支持 P2PK（Schnorr/ECDSA）和 P2SH 地址类型
- **交易构建**：创建和签名 Kaspa 交易
- **HD 钱包支持**：BIP32/BIP39 助记词种子派生
- **UTXO 管理**：UTXO 选择和交易手续费计算
- **gRPC 客户端**：集成 Kaspa gRPC 协议

## 系统要求

- Swift 5.6+
- iOS 13.0+ / macOS 10.15+

## 安装方式

### Swift Package Manager

在 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/xueyuejie/KaspaSwift.git", from: "1.0.0")
]
```

## 使用示例

### 密钥生成

```swift
import KaspaSwift

// 从助记词生成密钥
let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
let key = try KaspaKey.fromMnemonics(mnemonic)

// 派生特定路径
let derivedKey = try key.derive(path: "m/44'/111111'/0'/0/0")

// 公钥
print(derivedKey.publicKey.hex)

// 私钥
print(derivedKey.privateKey?.hex)
```

### 地址操作

```swift
import KaspaSwift

// 创建 P2PK Schnorr 地址
let schnorrAddress = try KaspaAddress.publicKey(
    prefix: .kaspa,
    publicKey: schnorrPublicKey
)

// 创建 P2PK ECDSA 地址
let ecdsaAddress = try KaspaAddress.pubKeyECDSA(
    prefix: .kaspa,
    publicKey: ecdsaPublicKey
)

// 创建 P2SH 地址
let p2shAddress = KaspaAddress.scriptHash(
    prefix: .kaspa,
    hash: scriptHash
)

// 编码地址为字符串
let addressString = schnorrAddress.encodeAddress()

// 从字符串解码地址
let decodedAddress = try KaspaAddress.decodeAddress(
    address: "kaspa:qzp...truncated",
    expectedPrefix: .kaspa
)

// 验证地址
let isValid = KaspaAddress.isValid(
    "kaspa:qzp...truncated",
    expectedPrefix: .kaspa
)
```

### 交易构建

```swift
import KaspaSwift
import BigInt

// 构建交易
let transaction = try TransactionBuilder.createTransaction(
    toAddress: toAddress,
    amount: BigUInt(100000000), // 1 KAS
    changeAddress: changeAddress,
    utxos: availableUtxos,
    priorityFee: BigUInt(1000)
)

// 签名交易
for (index, input) in transaction.inputs.enumerated() {
    try SignHelper.signInput(
        transaction: transaction,
        input: input,
        inputIndex: index,
        key: derivedKey
    )
}

// 序列化交易
let serializedTx = try transaction.serialize()
```

### 地址前缀

```swift
// 支持的网络前缀
public enum KaspaAddressPrefix: String {
    case unknown
    case kaspa       // 主网
    case kaspaTest   // 测试网
    case kaspaDev    // 开发网
    case kaspaSim    // 模拟网
}
```

### UTXO 模型

```swift
// Kaspa UTXO 结构
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

## 依赖库

- **Secp256k1Swift**: 椭圆曲线加密
- **BIP39swift**: 助记词生成
- **SwiftProtobuf**: Protocol Buffer 支持
- **GRPC**: Kaspa 节点 gRPC 通信客户端
- **Blake2**: 哈希函数

## 交易手续费计算

```swift
// 手续费计算常量
let feePerInput = BigUInt(1000) // 每个输入的基础手续费
let fee = TransactionBuilder.getFee(
    selectedUtxos: selectedUtxos,
    priorityFee: priorityFee
)
```

## 许可证

MIT License
