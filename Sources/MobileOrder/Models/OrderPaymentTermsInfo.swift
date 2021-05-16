//
//  File.swift
//  
//
//  Created by Michael Rutherford on 5/16/21.
//

import Foundation

public struct OrderPaymentTermsInfo {
    internal init(paymentTermsNid: Int?, isCharge: Bool, isEFT: Bool, termDiscountDays: Int?, termDiscountPct: Int?) {
        self.paymentTermsNid = paymentTermsNid
        self.isCharge = isCharge
        self.isEFT = isEFT
        self.termDiscountDays = termDiscountDays
        self.termDiscountPct = termDiscountPct
    }
    
    public init() {        
    }
    
    public var paymentTermsNid: Int?
    public var isCharge: Bool = false
    public var isEFT: Bool = false
    public var termDiscountDays: Int?
    public var termDiscountPct: Int?
}
