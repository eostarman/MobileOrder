//
//  File.swift
//
//
//  Created by Michael Rutherford on 6/1/21.
//

import Foundation

/// captures an addition to the quantity ordered (e.g. for layer rounding) or a cut such as when orders-to-loads cuts unavailable items
public struct LineItemAdjustment {
    
    public enum LineItemAdjustmentType {
        case qtyLayerRoundingAdjustment
        case qtyBackordered
        case qtyDeliveryDriverAdjustment
        case qtyShippedWhenVoided
        case adjustmentToMatchLegacyQtyShipped
    }
    
    public init(_ adjustmentType: LineItemAdjustmentType, qtyToAddOrCut: Int, reasonNid: Int?) {
        self.adjustmentType = adjustmentType
        self.qtyToAddOrCut = qtyToAddOrCut
        self.reasonNid = reasonNid
    }
    
    public let adjustmentType: LineItemAdjustmentType
    /// (+) is an add (e.g. for layer rounding) and (-) is a cut (e.g. when orders-to-loads cuts an order)
    public let qtyToAddOrCut: Int
    /// itemWriteoffNid
    public let reasonNid: Int?
}
