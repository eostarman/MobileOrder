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
        
        let orderLine = OrderLine(itemNid: itemNid, itemName: "", packName: "", qtyOrdered: 0)
        
        orderLine.convertFromLegacyOrderLine(orderNumber: orderNumber, legacyOrderLine: lol)
        
        return orderLine
    }
}

fileprivate extension OrderLine {
    func convertFromLegacyOrderLine(orderNumber: Int, legacyOrderLine lol: LegacyOrderLine) {
        
        func error(_ message: String) {
            print("ERROR: Cannot convert from legacyOrder #\(orderNumber): itemNid \(itemNid): \(message)")
        }
        
        if lol.itemWriteoffNid != nil { error("itemWriteoffNid = '\(lol.itemWriteoffNid!)'") }
        if lol.qtyShippedWhenVoided != nil { error("qtyShippedWhenVoided = '\(lol.qtyShippedWhenVoided!)'") }
        if lol.qtyDiscounted != 0 { error("qtyDiscounted = '\(lol.qtyDiscounted)'") }
        if lol.qtyLayerRoundingAdjustment != nil { error("qtyLayerRoundingAdjustment = '\(lol.qtyLayerRoundingAdjustment!)'") }
        if lol.qtyDeliveryDriverAdjustment != nil { error("qtyDeliveryDriverAdjustment = '\(lol.qtyDeliveryDriverAdjustment!)'") }
        if lol.itemNameOverride != nil { error("itemNameOverride = '\(lol.itemNameOverride!)'") }
        if lol.isManualPrice != false { error("isManualPrice = '\(lol.isManualPrice)'") }
        if lol.isManualDiscount != false { error("isManualDiscount = '\(lol.isManualDiscount)'") }
        if lol.unitFreight != .zero { error("unitFreight = '\(lol.unitFreight)'") }
        if lol.unitDeliveryCharge != .zero { error("unitDeliveryCharge = '\(lol.unitDeliveryCharge)'") }
        if lol.qtyBackordered != nil { error("qtyBackordered = '\(lol.qtyBackordered!)'") }
        if lol.isCloseDatedInMarket != false { error("isCloseDatedInMarket = '\(lol.isCloseDatedInMarket)'") }
        if lol.isManualDeposit != false { error("isManualDeposit = '\(lol.isManualDeposit)'") }
        if lol.wasAutoCut != false { error("wasAutoCut = '\(lol.wasAutoCut)'") }
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


        
        

        let _ = lol.itemWriteoffNid
        let _ = lol.qtyShippedWhenVoided
        qtyShipped = lol.qtyShipped
        qtyOrdered = lol.qtyOrdered
        let _ = lol.qtyDiscounted
        addDiscount(promoPlan: .Default, promoSectionNid: lol.promo1Nid, unitDisc: lol.unitDisc, rebateAmount: .zero)
        let _ = lol.qtyLayerRoundingAdjustment
        addCharge(.CRV(amount: lol.unitCRV, crvContainerTypeNid: lol.crvContainerTypeNid))
        let _ = lol.qtyDeliveryDriverAdjustment
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
        let _ = lol.qtyBackordered
        let _ = lol.isCloseDatedInMarket
        let _ = lol.isManualDeposit
        basePricesAndPromosOnQtyOrdered = lol.basePricesAndPromosOnQtyOrdered
        let _ = lol.wasAutoCut
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
        
        let _ = lol.commOverrideSlsEmpNid
        let _ = lol.commOverrideDrvEmpNid
        let _ = lol.qtyCloseDateRequested
        let _ = lol.qtyCloseDateShipped
        let _ = lol.preservePricing
        let _ = lol.noteLink
        let _ = lol.seq

    }
}
