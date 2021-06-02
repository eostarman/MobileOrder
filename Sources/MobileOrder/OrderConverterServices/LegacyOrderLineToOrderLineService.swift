//
//  File.swift
//  
//
//  Created by Michael Rutherford on 4/16/21.
//

import Foundation
import MobileLegacyOrder
import MobileDownload
import MoneyAndExchangeRates

struct LegacyOrderLineToOrderLineService {
    
    static func getOrderLines(orderNumber: Int, legacyOrderLines: [LegacyOrderLine]) -> [OrderLine] {
        var lines: [OrderLine] = []
        var badLines: [LegacyOrderLine] = []
        
        for lol in legacyOrderLines {
            if lol.isDiscountOnly {
                print("ERROR: Cannot convert from legacyOrder #\(orderNumber): found discount-only line")
                if let lastLine = lines.last {
                    badLines.append(lol)
                } else {
                    badLines.append(lol)
                }
            } else {
                if let line = getOrderLine(orderNumber: orderNumber, legacyOrderLine: lol) {
                    lines.append(line)
                } else {
                    badLines.append(lol)
                }
            }
        }
        
        return lines
    }
    
    static func getOrderLine(orderNumber: Int, legacyOrderLine lol: LegacyOrderLine) -> OrderLine? {
        
        guard let itemNid = lol.itemNid else {
            print("ERROR: Cannot convert from legacyOrder #\(orderNumber): found note line: '\(lol.itemNameOverride ?? "")'")
            return nil
        }
        
        let orderLine = OrderLine(itemNid: itemNid, qtyOrdered: 0)
        
        orderLine.convertFromLegacyOrderLine(orderNumber: orderNumber, legacyOrderLine: lol)
        
        return orderLine
    }
}

fileprivate extension OrderLine {
    func convertFromLegacyOrderLine(orderNumber: Int, legacyOrderLine lol: LegacyOrderLine) {
        
        func error(_ message: String) {
            print("ERROR: Cannot convert from legacyOrder #\(orderNumber): itemNid \(itemNid): \(message)")
        }
        
        if lol.qtyDiscounted != 0 { error("qtyDiscounted = '\(lol.qtyDiscounted)'") }
        if lol.itemNameOverride != nil { error("itemNameOverride = '\(lol.itemNameOverride!)'") }
        if lol.isManualPrice != false { error("isManualPrice = '\(lol.isManualPrice)'") }
        if lol.isManualDiscount != false { error("isManualDiscount = '\(lol.isManualDiscount)'") }
        if lol.unitFreight != .zero { error("unitFreight = '\(lol.unitFreight)'") }
        if lol.unitDeliveryCharge != .zero { error("unitDeliveryCharge = '\(lol.unitDeliveryCharge)'") }
        if lol.isCloseDatedInMarket != false { error("isCloseDatedInMarket = '\(lol.isCloseDatedInMarket)'") }
        if lol.isManualDeposit != false { error("isManualDeposit = '\(lol.isManualDeposit)'") }
        if lol.mergeSequenceTag != nil && lol.mergeSequenceTag != -1 { error("mergeSequenceTag = '\(lol.mergeSequenceTag!)'") }
        if lol.autoFreeGoodsLine != false { error("autoFreeGoodsLine = '\(lol.autoFreeGoodsLine)'") }
        if lol.uniqueifier != nil { error("uniqueifier = '\(lol.uniqueifier!)'") }
        if lol.wasDownloaded != false { error("wasDownloaded = '\(lol.wasDownloaded)'") }
        if lol.pickAndShipDateCodes != nil { error("pickAndShipDateCodes = '\(lol.pickAndShipDateCodes!)'") }
        if lol.dateCode != nil { error("dateCode = '\(lol.dateCode!)'") }
        if lol.commOverrideSlsEmpNid != nil { error("commOverrideSlsEmpNid = '\(lol.commOverrideSlsEmpNid!)'") }
        if lol.commOverrideDrvEmpNid != nil { error("commOverrideDrvEmpNid = '\(lol.commOverrideDrvEmpNid!)'") }
        if lol.qtyCloseDateRequested != nil { error("qtyCloseDateRequested = '\(lol.qtyCloseDateRequested!)'") }
        if lol.qtyCloseDateShipped != nil { error("qtyCloseDateShipped = '\(lol.qtyCloseDateShipped!)'") }
        if lol.preservePricing != false { error("preservePricing = '\(lol.preservePricing)'") }
        if lol.noteLink != nil { error("noteLink = '\(lol.noteLink!)'") }
        //if lol.seq != 0 { error("seq = '\(lol.seq)'") }
        
        
        
        
        qtyOrdered = lol.qtyOrdered
        let _ = lol.qtyDiscounted
        addDiscount(promoPlan: .Default, promoSectionNid: lol.promo1Nid, unitDisc: lol.unitDisc, rebateAmount: .zero)
        
        addCharge(.CRV(amount: lol.unitCRV, crvContainerTypeNid: lol.crvContainerTypeNid))
        let _ = lol.itemNameOverride
        unitPrice = lol.unitPrice
        let _ = lol.isManualPrice
        addCharge(.splitCaseCharge(amount: lol.unitSplitCaseCharge))
        let _ = lol.isManualDiscount
        addCharge(.bottleOrCanDeposit(amount: lol.unitDeposit))
        addCharge(.carrierDeposit(amount: lol.carrierDeposit))
        addCredit(.bagCredit(amount: lol.bagCredit))
        addCredit(.statePickupCredit(amount: lol.statePickupCredit))
        let _ = lol.unitFreight
        let _ = lol.unitDeliveryCharge
        let _ = lol.isCloseDatedInMarket
        let _ = lol.isManualDeposit
        basePricesAndPromosOnQtyOrdered = lol.basePricesAndPromosOnQtyOrdered
        let _ = lol.mergeSequenceTag
        let _ = lol.autoFreeGoodsLine
        isPreferredFreeGoodLine = lol.isPreferredFreeGoodLine
        let _ = lol.uniqueifier
        let _ = lol.wasDownloaded
        let _ = lol.pickAndShipDateCodes
        let _ = lol.dateCode
        
        addDiscount(promoPlan: .CMAOnInvoice, promoSectionNid: lol.CMAOnNid, unitDisc: lol.CMAOnAmt, rebateAmount: .zero)
        addDiscount(promoPlan: .CTMOnInvoice, promoSectionNid: lol.CTMOnNid, unitDisc: lol.CTMOnAmt, rebateAmount: .zero)
        addDiscount(promoPlan: .CCFOnInvoice, promoSectionNid: lol.CCFOnNid, unitDisc: lol.CCFOnAmt, rebateAmount: .zero)
        
        addDiscount(promoPlan: .CMAOffInvoice, promoSectionNid: lol.CMAOffNid, unitDisc: lol.CMAOffAmt, rebateAmount: .zero)
        addDiscount(promoPlan: .CTMOffInvoice, promoSectionNid: lol.CTMOffNid, unitDisc: lol.CTMOffAmt, rebateAmount: .zero)
        addDiscount(promoPlan: .CCFOffInvoice, promoSectionNid: lol.CCFOffNid, unitDisc: lol.CCFOffAmt, rebateAmount: .zero)
        
        convertAdjustmentsAndQtyShipped(legacyOrderLine: lol)
        
        let _ = lol.commOverrideSlsEmpNid
        let _ = lol.commOverrideDrvEmpNid
        let _ = lol.qtyCloseDateRequested
        let _ = lol.qtyCloseDateShipped
        let _ = lol.preservePricing
        let _ = lol.noteLink
        let _ = lol.seq
        
    }
    
    func convertAdjustmentsAndQtyShipped(legacyOrderLine lol: LegacyOrderLine) {
        
        var calculatedQtyShipped = lol.qtyOrdered
        var itemWriteoffNid = lol.itemWriteoffNid // we want to "consume" the itemWriteoffNid once only
        
        if let layerRoundingAdjustment = lol.qtyLayerRoundingAdjustment, layerRoundingAdjustment != 0 {
            adjustments.append(LineItemAdjustment(.qtyLayerRoundingAdjustment, qtyToAddOrCut: layerRoundingAdjustment, reasonNid: nil))
            calculatedQtyShipped += layerRoundingAdjustment
        }
        
        if let qtyBackordered = lol.qtyBackordered, qtyBackordered != 0 {
            // if you order 100, then put 30 on back-order, that means that you're delivering (shipping) 70. So, the back-order quantity is effectively a "cut"
            adjustments.append(LineItemAdjustment(.qtyBackordered, qtyToAddOrCut: -qtyBackordered, reasonNid: nil))
            calculatedQtyShipped -= qtyBackordered
        }
        
        if let driverAdjustment = lol.qtyDeliveryDriverAdjustment, driverAdjustment != 0 {
            adjustments.append(LineItemAdjustment(.qtyDeliveryDriverAdjustment, qtyToAddOrCut: driverAdjustment, reasonNid: itemWriteoffNid))
            itemWriteoffNid = nil
            calculatedQtyShipped += driverAdjustment
        }
        
        if let qtyShippedWhenVoided = lol.qtyShippedWhenVoided, qtyShippedWhenVoided != 0 {
            adjustments.append(LineItemAdjustment(.qtyShippedWhenVoided, qtyToAddOrCut: -qtyShippedWhenVoided, reasonNid: nil))
            calculatedQtyShipped -= qtyShippedWhenVoided
        }
        
        if lol.qtyShipped != calculatedQtyShipped {
            let qtyToAddOrCut = lol.qtyShipped - calculatedQtyShipped // (+) is an add, (-) is a cut causing the shipment of less than what was ordered
            adjustments.append(LineItemAdjustment(.adjustmentToMatchLegacyQtyShipped, qtyToAddOrCut: qtyToAddOrCut, reasonNid: itemWriteoffNid))
            itemWriteoffNid = nil
            calculatedQtyShipped += qtyToAddOrCut
        }
        
        qtyShipped = calculatedQtyShipped
    }
}
