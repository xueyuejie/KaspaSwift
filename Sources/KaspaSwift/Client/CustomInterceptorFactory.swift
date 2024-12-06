//
//  CustomInterceptorFactory.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/12/5.
//

import GRPC
import NIO

// 定义拦截器工厂
final class CustomInterceptorFactory: Protowire_RPCClientInterceptorFactoryProtocol {
    func makeMessageStreamInterceptors() -> [ClientInterceptor<Protowire_KaspadRequest, Protowire_KaspadResponse>] {
        return [LoggingInterceptor()]
    }
}

class LoggingInterceptor: ClientInterceptor<Protowire_KaspadRequest, Protowire_KaspadResponse>, @unchecked Sendable {
    override func send(
        _ part: GRPCClientRequestPart<Protowire_KaspadRequest>,
        promise: EventLoopPromise<Void>?,
        context: ClientInterceptorContext<Protowire_KaspadRequest, Protowire_KaspadResponse>
    ) {
        // 记录日志或进行其他操作
//        switch part {
//        case .metadata(let hPACKHeaders):
//            debugPrint("Sending request: \(hPACKHeaders)")
//        case .message(let request, let messageMetadata):
//            debugPrint("Sending message: \(request),\(messageMetadata)")
//        case .end:
//            debugPrint("Sending request: end")
//        }
        // 传递请求到下一个拦截器或实际的 gRPC 服务
        context.send(part, promise: promise)
    }

    override func receive(
        _ part: GRPCClientResponsePart<Protowire_KaspadResponse>,
        context: ClientInterceptorContext<Protowire_KaspadRequest, Protowire_KaspadResponse>
    ) {
//        debugPrint("Receiving response: \(part)")
        context.receive(part) // 将响应传递到调用者
    }
}

