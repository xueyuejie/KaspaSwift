//
//  Constants.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/12/30.
//

import Foundation

public let kOpEqual: UInt8 = 135
public let kOpBlake2b: UInt8 = 170
public let kOpCheckSigECDSA: UInt8 = 171
public let kOpCheckSig: UInt8 = 172

public let kTransactionHashDomain = "TransactionHash"
public let kTransactionIdDomain = "TransactionID"
public let blake2bDigestKey = "TransactionSigningHash".data(using: .utf8)?.bytes ?? []

public let feePerInputRaw = 10000
public let kMinChangeTarget = 20000000

public let KRC20_UTXO_MIN_BALANCE = 30000000
public let kSubnetworkIdNativeHex  = "0000000000000000000000000000000000000000"
public let kSubnetworkIdCoinbaseHex = "0100000000000000000000000000000000000000"
