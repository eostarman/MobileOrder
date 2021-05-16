//
//  File.swift
//  
//
//  Created by Michael Rutherford on 5/16/21.
//

import Foundation

public struct OrderDeliveryInfo {
    internal init(shipAdr1: String? = nil, shipAdr2: String? = nil, shipCity: String? = nil, shipState: String? = nil, shipZip: String? = nil) {
        self.shipAdr1 = shipAdr1
        self.shipAdr2 = shipAdr2
        self.shipCity = shipCity
        self.shipState = shipState
        self.shipZip = shipZip
    }
    
    public var shipAdr1: String?
    public var shipAdr2: String?
    public var shipCity: String?
    public var shipState: String?
    public var shipZip: String?
    
    public init() {
        
    }
}
