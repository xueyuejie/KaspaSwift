//
//  KaspaClient.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/5.
//

import Foundation
import GRPC
import SwiftProtobuf
import NIO
import Logging

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct KaspaClient {
    private let host: String
    private let port: Int
    private let group: MultiThreadedEventLoopGroup
//    private let channel: ClientConnection
    private let asyncClient: Protowire_RPCAsyncClient
    
    public init(host: String = "kaspa.maiziqianbao.net", port: Int = 80) {
        self.host = host
        self.port = port
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = ClientConnection.insecure(group: group).connect(host: host, port: port)
        // 创建拦截器工厂
        let interceptorFactory = CustomInterceptorFactory()
        self.asyncClient = Protowire_RPCAsyncClient(channel: channel, interceptors: interceptorFactory)
    }
    
    public init(url: String) throws{
        guard url.isGRPC() else {
            throw KaspaClientError.invalidUrl
        }
        let host = String(url.split(separator: ":")[0])
        let port = String(url.split(separator: ":")[1])
        self.init(host: host, port: Int(port) ?? 0)
    }
    
    public func sendRequest(request: Protowire_KaspadRequest) async throws -> Protowire_KaspadResponse {
        // 调用 gRPC 服务
        do {
            let call = asyncClient.makeMessageStreamCall()
            try await call.requestStream.send(request)
            call.requestStream.finish()
            var response: Protowire_KaspadResponse?
            // 接收响应
            for try await _response in call.responseStream {
                response = _response
               
            }
            guard let _response = response else {
                throw KaspaError.unknow
            }
            return _response
        }
    }

    public func shutdown() async throws {
        try await group.shutdownGracefully()
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension KaspaClient{
    public func getBalanceByAddress(address: String) async throws -> UInt64 {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetBalanceByAddressRequestMessage()
        message.address = address
        request.getBalanceByAddressRequest = message
        request.id = 1077
        let response = try await self.sendRequest(request: request)
        let result = response.getBalanceByAddressResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.balance
        }
    }
    
    public func getBalancesByAddresses(addresses: [String]) async throws -> [Protowire_RpcBalancesByAddressesEntry] {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetBalancesByAddressesRequestMessage()
        message.addresses = addresses
        request.getBalancesByAddressesRequest = message
        request.id = 1079
        let response = try await self.sendRequest(request: request)
        let result = response.getBalancesByAddressesResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.entries
        }
    }
    
    public func getUtxosByAddresses(addresses: [String]) async throws -> [Protowire_RpcUtxosByAddressesEntry] {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetUtxosByAddressesRequestMessage()
        message.addresses = addresses
        request.getUtxosByAddressesRequest = message
        request.id = 1052
        let response = try await self.sendRequest(request: request)
        let result = response.getUtxosByAddressesResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.entries
        }
    }
    
    public func notifyUtxosChanged(addresses: [String]) async throws -> (added: [Protowire_RpcUtxosByAddressesEntry], removed: [Protowire_RpcUtxosByAddressesEntry]) {
        var request = Protowire_KaspadRequest()
        var message = Protowire_NotifyUtxosChangedRequestMessage()
        message.addresses = addresses
        request.notifyUtxosChangedRequest = message
        request.id = 1049
        let response = try await self.sendRequest(request: request)
        let result = response.notifyUtxosChangedResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return (added: response.utxosChangedNotification.added, removed:response.utxosChangedNotification.removed)
        }
    }
    
    public func stopNotifyingUtxosChanged(addresses: [String]) async throws -> Bool {
        var request = Protowire_KaspadRequest()
        var message = Protowire_StopNotifyingUtxosChangedRequestMessage()
        message.addresses = addresses
        request.stopNotifyingUtxosChangedRequest = message
        request.id = 1065
        let response = try await self.sendRequest(request: request)
        let result = response.stopNotifyingUtxosChangedResponse
        if result.hasError {
            return false
            //                throw KaspaError.message(result.error.message)
        } else {
            return true
        }
    }
    
    public func notifyBlockAdded() async throws -> Bool {
        var request = Protowire_KaspadRequest()
        let message = Protowire_NotifyBlockAddedRequestMessage()
        request.notifyBlockAddedRequest = message
        request.id = 1007
        let response = try await self.sendRequest(request: request)
        let result = response.notifyBlockAddedResponse
        if result.hasError {
            return false
            //                throw KaspaError.message(result.error.message)
        } else {
            return true
        }
    }
    
    public func submitTransaction(transaction: Protowire_RpcTransaction) async throws -> String {
        var request = Protowire_KaspadRequest()
        var message = Protowire_SubmitTransactionRequestMessage()
        message.transaction = transaction
        request.submitTransactionRequest = message
        request.id = 1020
        let response = try await self.sendRequest(request: request)
        let result = response.submitTransactionResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.transactionID
        }
    }
    
    public func submitTransactionReplacement(transaction: Protowire_RpcTransaction) async throws -> (transactionId: String, replacedTransaction: Protowire_RpcTransaction) {
        var request = Protowire_KaspadRequest()
        var message = Protowire_SubmitTransactionReplacementRequestMessage()
        message.transaction = transaction
        request.submitTransactionReplacementRequest = message
        request.id = 1100
        let response = try await self.sendRequest(request: request)
        let result = response.submitTransactionReplacementResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return (transactionId: result.transactionID, replacedTransaction: result.replacedTransaction)
        }
    }
    
    public func getFeeEstimate() async throws -> Protowire_RpcFeeEstimate {
        var request = Protowire_KaspadRequest()
        let message = Protowire_GetFeeEstimateRequestMessage()
        request.getFeeEstimateRequest = message
        request.id = 1106
        let response = try await self.sendRequest(request: request)
        let result = response.getFeeEstimateResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.estimate
        }
    }
    
    public func getMempoolEntry(txID: String, includeOrphanPool: Bool = true, filterTransactionPool: Bool = true) async throws -> Protowire_RpcMempoolEntry {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetMempoolEntryRequestMessage()
        message.txID = txID
        message.includeOrphanPool = includeOrphanPool
        message.filterTransactionPool = filterTransactionPool
        request.getMempoolEntryRequest = message
        request.id = 1014
        let response = try await self.sendRequest(request: request)
        let result = response.getMempoolEntryResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.entry
        }
    }
    
    public func getMempoolEntries(includeOrphanPool: Bool = true, filterTransactionPool: Bool = true) async throws -> [Protowire_RpcMempoolEntry] {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetMempoolEntriesRequestMessage()
        message.includeOrphanPool = includeOrphanPool
        message.filterTransactionPool = filterTransactionPool
        request.getMempoolEntriesRequest = message
        request.id = 1043
        let response = try await self.sendRequest(request: request)
        let result = response.getMempoolEntriesResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.entries
        }
    }
    
    public func getMempoolEntriesByAddresses(addresses: [String], includeOrphanPool: Bool = true, filterTransactionPool: Bool = true) async throws -> [Protowire_RpcMempoolEntryByAddress] {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetMempoolEntriesByAddressesRequestMessage()
        message.includeOrphanPool = includeOrphanPool
        message.filterTransactionPool = filterTransactionPool
        request.getMempoolEntriesByAddressesRequest = message
        request.id = 1084
        let response = try await self.sendRequest(request: request)
        let result = response.getMempoolEntriesByAddressesResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.entries
        }
    }
    
    public func getCurrentNetwork() async throws -> String {
        var request = Protowire_KaspadRequest()
        let message = Protowire_GetCurrentNetworkRequestMessage()
        request.getCurrentNetworkRequest = message
        request.id = 1001
        let response = try await self.sendRequest(request: request)
        let result = response.getCurrentNetworkResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.currentNetwork
        }
    }
    
    public func getBlockCount() async throws -> Protowire_GetBlockCountResponseMessage {
        var request = Protowire_KaspadRequest()
        let message = Protowire_GetBlockCountRequestMessage()
        request.getBlockCountRequest = message
        request.id = 1034
        let response = try await self.sendRequest(request: request)
        let result = response.getBlockCountResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result
        }
    }
    
    public func getBlockDagInfo() async throws -> Protowire_GetBlockDagInfoResponseMessage {
        var request = Protowire_KaspadRequest()
        let message = Protowire_GetBlockDagInfoRequestMessage()
        request.getBlockDagInfoRequest = message
        request.id = 1036
        let response = try await self.sendRequest(request: request)
        let result = response.getBlockDagInfoResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result
        }
    }
    
    public func getInfo() async throws -> Protowire_GetInfoResponseMessage {
        var request = Protowire_KaspadRequest()
        let message = Protowire_GetInfoRequestMessage()
        request.getInfoRequest = message
        request.id = 1063
        let response = try await self.sendRequest(request: request)
        let result = response.getInfoResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result
        }
    }
    
    public func notifyVirtualSelectedParentChainChanged(includeAcceptedTransactionIds: Bool) async throws -> Protowire_VirtualChainChangedNotificationMessage {
        var request = Protowire_KaspadRequest()
        var message = Protowire_NotifyVirtualChainChangedRequestMessage()
        message.includeAcceptedTransactionIds = includeAcceptedTransactionIds
        request.notifyVirtualChainChangedRequest = message
        request.id = 1022
        let response = try await self.sendRequest(request: request)
        if response.notifyVirtualChainChangedResponse.hasError {
            throw KaspaError.message(response.notifyVirtualChainChangedResponse.error.message)
        } else {
            return response.virtualChainChangedNotification
        }
    }
    
    public func getVirtualSelectedParentBlueScore() async throws -> UInt64 {
        var request = Protowire_KaspadRequest()
        let message = Protowire_GetSinkBlueScoreRequestMessage()
        request.getSinkBlueScoreRequest = message
        request.id = 1054
        let response = try await self.sendRequest(request: request)
        let result = response.getSinkBlueScoreResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.blueScore
        }
    }
    
    public func notifyVirtualSelectedParentBlueScoreChanged() async throws -> UInt64 {
        var request = Protowire_KaspadRequest()
        let message = Protowire_NotifySinkBlueScoreChangedRequestMessage()
        request.notifySinkBlueScoreChangedRequest = message
        request.id = 1056
        let response = try await self.sendRequest(request: request)
        if response.notifySinkBlueScoreChangedResponse.hasError {
            throw KaspaError.message(response.notifySinkBlueScoreChangedResponse.error.message)
        } else {
            return response.sinkBlueScoreChangedNotification.sinkBlueScore
        }
    }
    
    public func notifyVirtualDaaScoreChanged() async throws -> UInt64 {
        var request = Protowire_KaspadRequest()
        let message = Protowire_NotifyVirtualDaaScoreChangedRequestMessage()
        request.notifyVirtualDaaScoreChangedRequest = message
        request.id = 1074
        let response = try await self.sendRequest(request: request)
        if response.notifyVirtualDaaScoreChangedResponse.hasError {
            throw KaspaError.message(response.notifyVirtualDaaScoreChangedResponse.error.message)
        } else {
            return response.virtualDaaScoreChangedNotification.virtualDaaScore
        }
    }
    
    public func getBlockByHash(hash: String, includeTransactions: Bool = true) async throws -> Protowire_RpcBlock {
        var request = Protowire_KaspadRequest()
        var message = Protowire_GetBlockRequestMessage()
        message.hash = hash
        message.includeTransactions = includeTransactions
        request.getBlockRequest = message
        request.id = 1025
        let response = try await self.sendRequest(request: request)
        let result = response.getBlockResponse
        if result.hasError {
            throw KaspaError.message(result.error.message)
        } else {
            return result.block
        }
    }
}
