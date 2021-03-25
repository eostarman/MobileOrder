//  Created by Michael Rutherford on 2/17/21.

import Foundation
import MobileLegacyOrder
import MobileDownload
import MoneyAndExchangeRates

struct OrderLineConverter {
    static func getMobileOrderLines(_ line: PresellOrderLine) -> [MobileOrderLine] {
        line.getMobileOrderLines()
    }
}

fileprivate extension PresellOrderLine {
    /// return one or more MobileOrderLine's for a single PresellOrderLine (accounting for things like free-goods, fees, taxes and additional discount lines
    func getMobileOrderLines() -> [MobileOrderLine] {
        
        if itemNid == 0 {
            let noteLine = MobileOrderLine()
            noteLine.itemNameOverride = ""
            return [noteLine]
        }
        
        var mobileOrderLines: [MobileOrderLine] = []
        let unitPrice = self.unitPrice ?? .zero
        
        func getLine() -> MobileOrderLine {
            let line = MobileOrderLine()
            line.itemNid = itemNid
            line.basePricesAndPromosOnQtyOrdered = basePricesAndPromosOnQtyOrdered
            line.isPreferredFreeGoodLine = isPreferredFreeGoodLine
            return line
        }
        
        let qtyNonFree = qtyOrdered - self.qtyFree
        
        var unitCRV: MoneyWithoutCurrency = .zero
        var crvContainerTypeNid: Int? = nil
        var bottleOrCanDeposit: MoneyWithoutCurrency = .zero
        var carrierDeposit: MoneyWithoutCurrency = .zero
        var splitCaseCharge: MoneyWithoutCurrency = .zero
        var kegDeposit: MoneyWithoutCurrency = .zero
        var bagCredit: MoneyWithoutCurrency = .zero
        var statePickupCredit: MoneyWithoutCurrency = .zero
        
        
        var CMAOnNid: Int? = nil
        var CTMOnNid: Int? = nil
        var CCFOnNid: Int? = nil
        var CMAOffNid: Int? = nil
        var CTMOffNid: Int? = nil
        var CCFOffNid: Int? = nil
        var CMAOnAmt: MoneyWithoutCurrency = .zero
        var CTMOnAmt: MoneyWithoutCurrency = .zero
        var CCFOnAmt: MoneyWithoutCurrency = .zero
        var CMAOffAmt: MoneyWithoutCurrency = .zero
        var CTMOffAmt: MoneyWithoutCurrency = .zero
        var CCFOffAmt: MoneyWithoutCurrency = .zero
        
        struct DiscountPair {
            let promoSectionNid: Int
            let discount: MoneyWithoutCurrency
        }
        
        var discountPairs: [DiscountPair] = []
        
        for charge in charges {
            switch charge {
            
            case .CRV(let amount, let containerTypeNid):
                unitCRV += amount
                crvContainerTypeNid = containerTypeNid
            case .bottleOrCanDeposit(let amount):
                bottleOrCanDeposit += amount
            case .carrierDeposit(let amount):
                carrierDeposit += amount
            case .fee(let amount, let promoSectionNid):
                discountPairs.append(DiscountPair(promoSectionNid: promoSectionNid, discount: -amount)) // opposite of a discount
            case .kegDeposit(let amount):
                kegDeposit += amount
            case .splitCaseCharge(let amount):
                splitCaseCharge += amount
            case .tax(let amount, let promoSectionNid):
                discountPairs.append(DiscountPair(promoSectionNid: promoSectionNid, discount: -amount)) // opposite of a discount
            }
        }
        
        for credit in credits {
            switch credit {
            
            case .bagCredit(let amount):
                bagCredit = amount
            case .statePickupCredit(let amount):
                statePickupCredit = amount
            }
        }
        
        for discount in discounts {
            switch discount.promoPlan {
            
            case .CCFOffInvoice:
                CCFOffNid = discount.promoSectionNid
                CCFOffAmt = discount.unitDisc
            case .CCFOnInvoice:
                CCFOnNid = discount.promoSectionNid
                CCFOnAmt = discount.unitDisc
            case .CMAOffInvoice:
                CMAOffNid = discount.promoSectionNid
                CMAOffAmt = discount.unitDisc
            case .CMAOnInvoice:
                CMAOnNid = discount.promoSectionNid
                CMAOnAmt = discount.unitDisc
            case .CTMOffInvoice:
                CTMOffNid = discount.promoSectionNid
                CTMOffAmt = discount.unitDisc
            case .CTMOnInvoice:
                CTMOnNid = discount.promoSectionNid
                CTMOnAmt = discount.unitDisc
                
            case .Default, .Stackable, .AdditionalFee, .OffInvoiceAccrual:
                discountPairs.append(DiscountPair(promoSectionNid: discount.promoSectionNid, discount: discount.unitDisc))
            }
            
        }
        
        if discountPairs.isEmpty {
            discountPairs.append(DiscountPair(promoSectionNid: 0, discount: .zero))
        }
        
        // main order line
        if let firstDiscountPair = discountPairs.first {
            discountPairs.removeFirst()
            
            let line = getLine()
            line.qtyOrdered = qtyNonFree
            line.qtyShipped = qtyNonFree
            line.unitPrice = unitPrice
            
            if firstDiscountPair.discount.isNonZero {
                line.promo1Nid = firstDiscountPair.promoSectionNid
                line.unitDisc = firstDiscountPair.discount
            }
            
            line.unitCRV = unitCRV
            line.crvContainerTypeNid = crvContainerTypeNid
            line.unitDeposit = bottleOrCanDeposit + kegDeposit
            line.carrierDeposit = carrierDeposit
            line.unitSplitCaseCharge = splitCaseCharge
            line.bagCredit = bagCredit
            line.statePickupCredit = statePickupCredit
            
            line.CMAOnNid = CMAOnNid
            line.CTMOnNid = CTMOnNid
            line.CCFOnNid = CCFOnNid
            line.CMAOffNid = CMAOffNid
            line.CTMOffNid = CTMOffNid
            line.CCFOffNid = CCFOffNid
            line.CMAOnAmt = CMAOnAmt
            line.CTMOnAmt = CTMOnAmt
            line.CCFOnAmt = CCFOnAmt
            line.CMAOffAmt = CMAOffAmt
            line.CTMOffAmt = CTMOffAmt
            line.CCFOffAmt = CCFOffAmt
            
            mobileOrderLines.append(line)
        }
        
        // additional "discount only" lines
        for discountPair in discountPairs {
            let line = getLine()
            line.qtyOrdered = qtyNonFree
            line.qtyShipped = qtyNonFree
   
            line.unitPrice = .zero
            line.unitDisc = discountPair.discount
            if discountPair.promoSectionNid != 0 {
                line.promo1Nid = discountPair.promoSectionNid
            }
            
            mobileOrderLines.append(line)
        }
        
        // additional free-goods lines
        for freeGood in freeGoods {
            let line = getLine()
            line.promo1Nid = freeGood.promoSectionNid
            line.qtyOrdered = freeGood.qtyFree
            line.qtyShipped = freeGood.qtyFree
            line.unitPrice = unitPrice
            line.unitDisc = unitPrice
            line.unitSplitCaseCharge = .zero // don't add a split case charge if this is a sample
            
            mobileOrderLines.append(line)
        }
        
        return mobileOrderLines
    }
    
}
