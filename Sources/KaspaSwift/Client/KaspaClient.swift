//
//  KaspaClient.swift
//  KaspaSwift
//
//  Created by 薛跃杰 on 2024/11/5.
//

import Foundation
import GRPC
import SwiftProtobuf
import NIO

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct KaspaClient {
    public let host: String
    public let port: Int
    
    public init(host: String = "localhost", port: Int = 50051) {
        self.host = host
        self.port = port
    }
    
    public init(url: String) throws{
        guard url.isGRPC() else {
            throw KaspaClientError.invalidUrl
        }
        let host = String(url.split(separator: ":")[0])
        let port = String(url.split(separator: ":")[1])
        self.init(host: host, port: Int(port) ?? 0)
    }
    
    public func sendRequest(request: Kaspa_KaspadRequest) async throws -> Kaspa_KaspadResponse {
        // 创建事件循环组
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            Task {
                try? await group.shutdownGracefully()
            }
        }
        // 建立通道连接
        let channel = try GRPCChannelPool.with(
            target: .host(self.host, port: self.port),  // 服务器地址和端口
            transportSecurity: .plaintext,            // 使用不加密连接
            eventLoopGroup: group           // 使用的 EventLoopGroup
        )
        let client = Kaspa_RPCAsyncClient(channel: channel)
        // 调用 gRPC 服务
        do {
            let call = client.makeMessageStreamCall()
            try await call.requestStream.send(request)
            call.requestStream.finish()
            var response: Kaspa_KaspadResponse?
            // 接收响应
            for try await _response in call.responseStream {
                response = _response
            }
            guard let _response = response else {
                throw KaspaError.unknow
            }
            return _response
        } catch {
            throw KaspaError.message(error.localizedDescription)
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension KaspaClient{
    public func getBalanceByAddress(address: String) async throws -> UInt64 {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetBalanceByAddressRequestMessage()
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
    
    public func getBalancesByAddresses(addresses: [String]) async throws -> [Kaspa_RpcBalancesByAddressesEntry] {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetBalancesByAddressesRequestMessage()
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
    
    public func getUtxosByAddresses(addresses: [String]) async throws -> [Kaspa_RpcUtxosByAddressesEntry] {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetUtxosByAddressesRequestMessage()
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
    
    public func notifyUtxosChanged(addresses: [String]) async throws -> (added: [Kaspa_RpcUtxosByAddressesEntry], removed: [Kaspa_RpcUtxosByAddressesEntry]) {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_NotifyUtxosChangedRequestMessage()
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
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_StopNotifyingUtxosChangedRequestMessage()
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
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_NotifyBlockAddedRequestMessage()
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
    
    public func submitTransaction(transaction: Kaspa_RpcTransaction) async throws -> String {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_SubmitTransactionRequestMessage()
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
    
    public func submitTransactionReplacement(transaction: Kaspa_RpcTransaction) async throws -> (transactionId: String, replacedTransaction: Kaspa_RpcTransaction) {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_SubmitTransactionReplacementRequestMessage()
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
    
    public func getFeeEstimate() async throws -> Kaspa_RpcFeeEstimate {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetFeeEstimateRequestMessage()
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
    
    public func getMempoolEntry(txID: String, includeOrphanPool: Bool = true, filterTransactionPool: Bool = true) async throws -> Kaspa_RpcMempoolEntry {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetMempoolEntryRequestMessage()
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
    
    public func getMempoolEntries(includeOrphanPool: Bool = true, filterTransactionPool: Bool = true) async throws -> [Kaspa_RpcMempoolEntry] {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetMempoolEntriesRequestMessage()
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
    
    public func getMempoolEntriesByAddresses(addresses: [String], includeOrphanPool: Bool = true, filterTransactionPool: Bool = true) async throws -> [Kaspa_RpcMempoolEntryByAddress] {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetMempoolEntriesByAddressesRequestMessage()
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
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetCurrentNetworkRequestMessage()
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
    
    public func getInfo() async throws -> Kaspa_GetInfoResponseMessage {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetInfoRequestMessage()
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
    
    public func notifyVirtualSelectedParentChainChanged(includeAcceptedTransactionIds: Bool) async throws -> Kaspa_VirtualChainChangedNotificationMessage {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_NotifyVirtualChainChangedRequestMessage()
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
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetSinkBlueScoreRequestMessage()
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
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_NotifySinkBlueScoreChangedRequestMessage()
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
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_NotifyVirtualDaaScoreChangedRequestMessage()
        request.notifyVirtualDaaScoreChangedRequest = message
        request.id = 1074
        let response = try await self.sendRequest(request: request)
        if response.notifyVirtualDaaScoreChangedResponse.hasError {
            throw KaspaError.message(response.notifyVirtualDaaScoreChangedResponse.error.message)
        } else {
            return response.virtualDaaScoreChangedNotification.virtualDaaScore
        }
    }
    
    public func getBlockByHash(hash: String, includeTransactions: Bool = true) async throws -> Kaspa_RpcBlock {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetBlockRequestMessage()
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
