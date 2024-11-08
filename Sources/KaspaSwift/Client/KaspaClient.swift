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


// 创建一个符合 RPCClientProtocol 的客户端类
class MyRPCClient: Protowire_RPCClientProtocol {
    internal let channel: GRPCChannel
    internal var defaultCallOptions: CallOptions
    internal var interceptors: Protowire_RPCClientInterceptorFactoryProtocol?

    init(channel: GRPCChannel, defaultCallOptions: CallOptions = CallOptions(), interceptors: Protowire_RPCClientInterceptorFactoryProtocol? = nil) {
        self.channel = channel
        self.defaultCallOptions = defaultCallOptions
        self.interceptors = interceptors
    }
}

public struct KaspaClient : ~Copyable{
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
    
    public func getBalancesByAddresses(addresses: [String], handle: @escaping ([Protowire_RpcBalancesByAddressesEntry]) -> Void
    ) async throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = ClientConnection.insecure(group: group).connect(host: self.host, port: self.port)
        let client = MyRPCClient(channel: channel)
        let call = client.messageStream{ response in
            // 处理每个响应
            print("Received response: \(response)")
        }
        var request = Protowire_KaspadRequest()
        var balanceRequest = Protowire_GetBalancesByAddressesRequestMessage()
        balanceRequest.addresses = addresses
        request.getBalancesByAddressesRequest = balanceRequest
        call.sendMessage(request).whenComplete { result in
            switch result {
            case .success(let success):
                print("Request sent successfully")
            case .failure(let error):
                print("Failed to send request: \(error)")
            }
        }
        // 结束请求流
        call.sendEnd().whenComplete { result in
            switch result {
            case .success:
                print("Stream ended successfully")
            case .failure(let error):
                print("Failed to end stream: \(error)")
            }
        }
    }
}
