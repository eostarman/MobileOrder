//
//  File.swift
//  
//
//  Created by Michael Rutherford on 5/16/21.
//

import Foundation

/// information captured when an order is voided
public struct OrderVoidingEntry: Codable {

    /// an order can be voided by just setting this flag and nothing else - pretty unusual though
    public var isVoided: Bool = true
    
    public var voidedDate: Date?
    public var voidedByNid: Int?
    
    public var voidReason: String?
    public var voidReasonNid: Int?
    
    public init() {
    }
    
    public init(isVoided: Bool, voidedDate: Date?, voidedByNid: Int?, voidReason: String?, voidReasonNid: Int?) {
        self.isVoided = isVoided
        self.voidedDate = voidedDate
        self.voidedByNid = voidedByNid
        self.voidReason = voidReason
        self.voidReasonNid = voidReasonNid
    }
}
