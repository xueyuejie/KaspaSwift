//
//  SighashReusedValues.swift
//  KaspaSwift
//
//  Created by xgblin on 2024/11/14.
//

import Foundation

public struct SighashReusedValues {
    public var previousOutputsHash: Data?
    public var sequencesHash: Data?
    public var sigOpCountsHash: Data?
    public var outputsHash: Data?
    public var payloadHash: Data?

    public init(
        previousOutputsHash: Data? = nil,
        sequencesHash: Data? = nil,
        sigOpCountsHash: Data? = nil,
        outputsHash: Data? = nil,
        payloadHash: Data? = nil
    ) {
        self.previousOutputsHash = previousOutputsHash
        self.sequencesHash = sequencesHash
        self.sigOpCountsHash = sigOpCountsHash
        self.outputsHash = outputsHash
        self.payloadHash = payloadHash
    }
}
