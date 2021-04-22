//
//  OrderLine.swift
//  MobileBench
//
//  Created by Michael Rutherford on 7/26/20.
//

import Foundation
import MoneyAndExchangeRates
import MobilePricing
import MobileDownload

public class OrderLine: Identifiable, ObservableObject {
    // note that I'm not publishing individual properties - so, a view should observe the orderLine itself. The objectWillChange is fired when the order is recomputed (this recomputes all of its order lines). So, changing a quantity in one order line could change the price or discounts in some different order lines
    public let id = UUID()
    
    public var seq: Int = 0
    
    public let itemNid: Int
    public let itemName: String
    public let packName: String
    
    public var isPreferredFreeGoodLine: Bool = false
    
    public var basePricesAndPromosOnQtyOrdered: Bool = false
    
    public private(set) var unitSplitCaseCharge: MoneyWithoutCurrency = .zero
    
    public var freeGoods: [LineFreeGoods] = []
    public var discounts: [LineDiscount] = []
    public var charges: [LineItemCharge] = []
    public var credits: [LineItemCredit] = []
    public var potentialDiscounts: [PotentialDiscount] = []
    
    public var qtyOrdered: Int
    public var qtyShipped: Int?
    public var qtyShippedOrExpectedToBeShipped: Int {
        qtyShipped ?? qtyOrdered
    }
    public var unitPrice: MoneyWithoutCurrency?
    
    public var unitDiscount: MoneyWithoutCurrency {
         discounts.reduce(.zero, { $0 + $1.unitDisc })
    }
    
    public var unitCharge: MoneyWithoutCurrency {
        charges.reduce(.zero, { $0 + $1.amount })
    }
    
    public var unitCredit: MoneyWithoutCurrency {
        credits.reduce(.zero, { $0 + $1.amount })
    }
    
    public var netUnitPrice: MoneyWithoutCurrency? {
        guard let unitPrice = unitPrice else {
            return nil
        }
        
        let net = unitPrice - unitDiscount + unitCharge - unitCredit
        return net
    }
    
    public var totalNet: MoneyWithoutCurrency {
        qtyOrdered * unitNetAfterDiscount
    }
    
    public init(itemNid: Int, itemName: String, packName: String, qtyOrdered: Int) {
        self.itemNid = itemNid
        self.itemName = itemName
        self.packName = packName
        self.qtyOrdered = qtyOrdered
    }
}

extension OrderLine: DCOrderLine {
    public var qtyDiscounted: Int {
        discounts.isEmpty ? 0 : qtyShippedOrExpectedToBeShipped - qtyFree
    }

    public var hasDeeperDiscount: Bool {
        potentialDiscounts.contains { $0.unitDiscount > unitDiscount }
    }
    
    public var totalAfterSavings: MoneyWithoutCurrency {
        
        guard let unitPrice = unitPrice else {
            return .zero
        }
        
        let totalCharges = qtyShippedOrExpectedToBeShipped * unitCharge
        let totalCredits = qtyShippedOrExpectedToBeShipped * unitCredit
        
        let frontline = qtyShippedOrExpectedToBeShipped * unitPrice
        let splitCaseCharge = (qtyShippedOrExpectedToBeShipped - qtyFree) * unitSplitCaseCharge // the split-case charge is for the non-free items
        
        let totalSavings = self.totalSavings
        
        let totalAfterSavings = frontline + splitCaseCharge + totalCharges - totalCredits - totalSavings
        
        return totalAfterSavings
    }
    
    /// value of the free goods plus any discounts on the non-free goods
    public var totalSavings: MoneyWithoutCurrency {
        guard let unitPrice = unitPrice else {
            return .zero
        }
        
        let valueOfFreeGoods = qtyFree * unitPrice
        
        let totalDiscountedOnNonFreeGoods = (qtyShippedOrExpectedToBeShipped - qtyFree) * unitDiscount
        
        let savings = valueOfFreeGoods + totalDiscountedOnNonFreeGoods
        
        return savings
    }
    
    /// The number of free goods. If the unitPrice (the frontlinePrice) is fully discounted (i.e. matches unitDiscount) then each one of the qtyShipped is free
    public var qtyFree: Int {
        if unitPrice == unitDiscount {
            return qtyShippedOrExpectedToBeShipped
        } else {
            return freeGoods.map({ $0.qtyFree}).reduce(0, +)
        }
    }

    public var unitNetAfterDiscount: MoneyWithoutCurrency {
        if let unitPrice = unitPrice {
            return unitPrice - unitDiscount
        }
        return .zero
    }
    
    public func getCokePromoTotal() -> MoneyWithoutCurrency {
        discounts.filter({ $0.promoPlan.isCokePromo }).map({ $0.unitDisc }).reduce(.zero, +)
    }
    
    public func clearAllPromoData() {
        
        objectWillChange.send() // so SwiftUI will re-render any views observing this orderLine
        
        freeGoods = []
        discounts = []
        charges = []
        credits = []
        potentialDiscounts = []
        
        unitSplitCaseCharge = .zero
    }
    
    public func addFreeGoods(promoSectionNid: Int?, qtyFree: Int, rebateAmount: MoneyWithoutCurrency) {
        freeGoods.append(LineFreeGoods(promoSectionNid: promoSectionNid, qtyFree: qtyFree, rebateAmount: rebateAmount))
    }
    
    public func addDiscount(promoPlan: ePromoPlan, promoSectionNid: Int?, unitDisc: MoneyWithoutCurrency, rebateAmount: MoneyWithoutCurrency) {
        discounts.append(LineDiscount(promoPlan: promoPlan, promoSectionNid: promoSectionNid, unitDisc: unitDisc, rebateAmount: rebateAmount))
    }
    
    public func addCharge(_ charge: LineItemCharge) {
        charges.append(charge)
        
        switch charge {
        case .splitCaseCharge(let amount):
            unitSplitCaseCharge += amount
        default:
            break
        }
    }
    
    public func addCredit(_ credit: LineItemCredit) {
        credits.append(credit)
    }
    
    public func addPotentialDiscount(potentialDiscount: PotentialDiscount) {
        potentialDiscounts.append(potentialDiscount)
    }
}

extension OrderLine {
    
    public struct LineFreeGoods {
        public let promoSectionNid: Int?
        public let qtyFree: Int
        public let rebateAmount: MoneyWithoutCurrency
    }
    
    public struct LineDiscount {
        public let promoPlan: ePromoPlan
        public let promoSectionNid: Int?
        public let unitDisc: MoneyWithoutCurrency
        let rebateAmount: MoneyWithoutCurrency
    }
}


