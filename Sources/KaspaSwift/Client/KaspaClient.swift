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
    
    public func sendRequest(request: Kaspa_KaspadRequest, handle: @escaping  @Sendable(Kaspa_KaspadResponse) -> Void, failture: @escaping  @Sendable (KaspaError) -> Void) async throws {
        // 创建事件循环组
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        // 建立通道连接
        let channel = try GRPCChannelPool.with(
            target: .host(self.host, port: self.port),  // 服务器地址和端口
            transportSecurity: .plaintext,            // 使用不加密连接
            eventLoopGroup: group           // 使用的 EventLoopGroup
        )
        let client = Kaspa_RPCNIOClient(channel: channel)
        // 创建请求流
        let call = client.messageStream { response in
            handle(response)
        }
        call.sendMessage(request).whenComplete { result in
            switch result {
            case .success:
                print("Successfully sent message ")
            case .failure(let error):
                failture(KaspaError.message(error.localizedDescription))
            }
        }
        call.sendEnd().whenComplete { result in
            switch result {
            case .success:
                print("Successfully closed the stream")
            case .failure(let error):
                failture(KaspaError.message(error.localizedDescription))
            }
        }
    }
}

extension KaspaClient{
    public func getBalancesByAddress(address: String, handle: @escaping  @Sendable(_ balance: UInt64) -> Void, failture: @escaping  @Sendable (KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetBalanceByAddressRequestMessage()
        message.address = address
        request.getBalanceByAddressRequest = message
        request.id = 1077
        try await self.sendRequest(request: request) { response in
            let result = response.getBalanceByAddressResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.balance)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getBalancesByAddresses(addresses: [String], handle: @escaping  @Sendable(_ entris: [Kaspa_RpcBalancesByAddressesEntry]) -> Void, failture: @escaping  @Sendable (KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetBalancesByAddressesRequestMessage()
        message.addresses = addresses
        request.getBalancesByAddressesRequest = message
        request.id = 1079
        try await self.sendRequest(request: request) { response in
            let result = response.getBalancesByAddressesResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.entries)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getUtxosByAddresses(addresses: [String], handle: @escaping  @Sendable(_ entris: [Kaspa_RpcUtxosByAddressesEntry]) -> Void, failture: @escaping  @Sendable (KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetUtxosByAddressesRequestMessage()
        message.addresses = addresses
        request.getUtxosByAddressesRequest = message
        request.id = 1052
        try await self.sendRequest(request: request) { response in
            let result = response.getUtxosByAddressesResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.entries)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func notifyUtxosChanged(addresses: [String], handle: @escaping  @Sendable(_ added: [Kaspa_RpcUtxosByAddressesEntry], _ removed: [Kaspa_RpcUtxosByAddressesEntry]) -> Void, failture: @escaping  @Sendable (KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_NotifyUtxosChangedRequestMessage()
        message.addresses = addresses
        request.notifyUtxosChangedRequest = message
        request.id = 1049
        try await self.sendRequest(request: request) { response in
            let result = response.notifyUtxosChangedResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(response.utxosChangedNotification.added, response.utxosChangedNotification.removed)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func stopNotifyingUtxosChanged(addresses: [String], handle: @escaping  @Sendable(_ isSuccess: Bool) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_StopNotifyingUtxosChangedRequestMessage()
        message.addresses = addresses
        request.stopNotifyingUtxosChangedRequest = message
        request.id = 1065
        try await self.sendRequest(request: request) { response in
            let result = response.stopNotifyingUtxosChangedResponse
            if result.hasError {
                handle(false)
//                failture(KaspaError.message(result.error.message))
            } else {
                handle(true)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func notifyBlockAdded(handle: @escaping  @Sendable(_ isSuccess: Bool) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_NotifyBlockAddedRequestMessage()
        request.notifyBlockAddedRequest = message
        request.id = 1007
        try await self.sendRequest(request: request) { response in
            let result = response.notifyBlockAddedResponse
            if result.hasError {
                handle(false)
//                failture(KaspaError.message(result.error.message))
            } else {
                handle(true)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func submitTransaction(transaction: Kaspa_RpcTransaction, handle: @escaping  @Sendable(_ transactionId: String) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_SubmitTransactionRequestMessage()
        message.transaction = transaction
        request.submitTransactionRequest = message
        request.id = 1020
        try await self.sendRequest(request: request) { response in
            let result = response.submitTransactionResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.transactionID)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func submitTransaction(transaction: Kaspa_RpcTransaction, handle: @escaping  @Sendable(_ transactionId: String, _ replacedTransaction: Kaspa_RpcTransaction) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_SubmitTransactionReplacementRequestMessage()
        message.transaction = transaction
        request.submitTransactionReplacementRequest = message
        request.id = 1100
        try await self.sendRequest(request: request) { response in
            let result = response.submitTransactionReplacementResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.transactionID, result.replacedTransaction)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getFeeEstimate(handle: @escaping  @Sendable(_ estimate: Kaspa_RpcFeeEstimate) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetFeeEstimateRequestMessage()
        request.getFeeEstimateRequest = message
        request.id = 1106
        try await self.sendRequest(request: request) { response in
            let result = response.getFeeEstimateResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.estimate)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getMempoolEntry(txID: String, includeOrphanPool: Bool = true, filterTransactionPool: Bool = true, handle: @escaping  @Sendable(_ entry: Kaspa_RpcMempoolEntry) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetMempoolEntryRequestMessage()
        message.txID = txID
        message.includeOrphanPool = includeOrphanPool
        message.filterTransactionPool = filterTransactionPool
        request.getMempoolEntryRequest = message
        request.id = 1014
        try await self.sendRequest(request: request) { response in
            let result = response.getMempoolEntryResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.entry)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getMempoolEntries(includeOrphanPool: Bool = true, filterTransactionPool: Bool = true, handle: @escaping  @Sendable(_ entries: [Kaspa_RpcMempoolEntry]) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetMempoolEntriesRequestMessage()
        message.includeOrphanPool = includeOrphanPool
        message.filterTransactionPool = filterTransactionPool
        request.getMempoolEntriesRequest = message
        request.id = 1043
        try await self.sendRequest(request: request) { response in
            let result = response.getMempoolEntriesResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.entries)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getMempoolEntriesByAddresses(addresses: [String], includeOrphanPool: Bool = true, filterTransactionPool: Bool = true, handle: @escaping  @Sendable(_ entries: [Kaspa_RpcMempoolEntryByAddress]) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetMempoolEntriesByAddressesRequestMessage()
        message.includeOrphanPool = includeOrphanPool
        message.filterTransactionPool = filterTransactionPool
        request.getMempoolEntriesByAddressesRequest = message
        request.id = 1084
        try await self.sendRequest(request: request) { response in
            let result = response.getMempoolEntriesByAddressesResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.entries)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getCurrentNetwork(handle: @escaping  @Sendable(_ currentNetwork: String) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetCurrentNetworkRequestMessage()
        request.getCurrentNetworkRequest = message
        request.id = 1001
        try await self.sendRequest(request: request) { response in
            let result = response.getCurrentNetworkResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.currentNetwork)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getInfo(handle: @escaping  @Sendable(_ info: Kaspa_GetInfoResponseMessage) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetInfoRequestMessage()
        request.getInfoRequest = message
        request.id = 1063
        try await self.sendRequest(request: request) { response in
            let result = response.getInfoResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func notifyVirtualSelectedParentChainChanged(includeAcceptedTransactionIds: Bool, handle: @escaping  @Sendable(Kaspa_VirtualChainChangedNotificationMessage) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_NotifyVirtualChainChangedRequestMessage()
        message.includeAcceptedTransactionIds = includeAcceptedTransactionIds
        request.notifyVirtualChainChangedRequest = message
        request.id = 1022
        try await self.sendRequest(request: request) { response in
            if response.notifyVirtualChainChangedResponse.hasError {
                failture(KaspaError.message(response.notifyVirtualChainChangedResponse.error.message))
            } else {
                handle(response.virtualChainChangedNotification)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getVirtualSelectedParentBlueScore(handle: @escaping  @Sendable(_ blueScore: UInt64) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_GetSinkBlueScoreRequestMessage()
        request.getSinkBlueScoreRequest = message
        request.id = 1054
        try await self.sendRequest(request: request) { response in
            let result = response.getSinkBlueScoreResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.blueScore)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func notifyVirtualSelectedParentBlueScoreChanged(handle: @escaping  @Sendable(_ sinkBlueScore: UInt64) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_NotifySinkBlueScoreChangedRequestMessage()
        request.notifySinkBlueScoreChangedRequest = message
        request.id = 1056
        try await self.sendRequest(request: request) { response in
            if response.notifySinkBlueScoreChangedResponse.hasError {
                failture(KaspaError.message(response.notifySinkBlueScoreChangedResponse.error.message))
            } else {
                handle(response.sinkBlueScoreChangedNotification.sinkBlueScore)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func notifyVirtualDaaScoreChanged(handle: @escaping  @Sendable(_ virtualDaaScore: UInt64) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        let message = Kaspa_NotifyVirtualDaaScoreChangedRequestMessage()
        request.notifyVirtualDaaScoreChangedRequest = message
        request.id = 1074
        try await self.sendRequest(request: request) { response in
            if response.notifyVirtualDaaScoreChangedResponse.hasError {
                failture(KaspaError.message(response.notifyVirtualDaaScoreChangedResponse.error.message))
            } else {
                handle(response.virtualDaaScoreChangedNotification.virtualDaaScore)
            }
        } failture: { error in
            failture(error)
        }
    }
    
    public func getBlockByHash(hash: String, includeTransactions: Bool = true, handle: @escaping  @Sendable(_ block: Kaspa_RpcBlock) -> Void, failture: @escaping  @Sendable(_ error: KaspaError) -> Void) async throws {
        var request = Kaspa_KaspadRequest()
        var message = Kaspa_GetBlockRequestMessage()
        message.hash = hash
        message.includeTransactions = includeTransactions
        request.getBlockRequest = message
        request.id = 1025
        try await self.sendRequest(request: request) { response in
            let result = response.getBlockResponse
            if result.hasError {
                failture(KaspaError.message(result.error.message))
            } else {
                handle(result.block)
            }
        } failture: { error in
            failture(error)
        }
    }
}
