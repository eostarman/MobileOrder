//
//  File.swift
//  
//
//  Created by Michael Rutherford on 6/4/21.
//

import Foundation
import MoneyAndExchangeRates
import MobilePricing
import MobileDownload


struct OrderRecomputeService {
    let order: Order
    let transactionCurrency: Currency
    let numberOfDecimals: Int
    let promoDate: Date
    let deliveryDate: Date
    let shipFromWhseNid: Int
    let cusNid: Int
    
    let orderLines: [OrderLine]
    
    init(order: Order) {
        self.order = order
        transactionCurrency = order.transactionCurrency
        numberOfDecimals = order.numberOfDecimals
        promoDate = order.promoDate
        deliveryDate = order.deliveryDate
        shipFromWhseNid = order.shipFromWhseNid
        cusNid = order.cusNid
        orderLines = order.lines.filter({ $0.qtyOrdered >= 0 })
    }
    
    public func recompute() {
        
        let lines = orderLines.enumerated().map { (index, line) in
            MockOrderLine(id: line.id, seq: index, itemNid: line.itemNid, qtyOrdered: line.qtyOrdered, qtyShipped: line.qtyShippedOrExpectedToBeShipped, basePricesAndPromosOnQtyOrdered: line.basePricesAndPromosOnQtyOrdered, isPreferredFreeGoodLine: line.isPreferredFreeGoodLine)
        }
        
        let unusedFreebies: [UnusedFreebie]
        
        if lines.isEmpty {
            unusedFreebies = []
        } else {
            computePrices(lines: lines)
            unusedFreebies = computeDiscounts(lines: lines)
            computeSplitCaseCharges(lines: lines)
            computeDeposits(lines: lines)
            
            let changes = zip(orderLines, lines).filter({ hasChanges(to: $0, from: $1)})
            
            for change in changes {
                apply(to: change.0, from: change.1)
            }
            
            //print("DEBUG: \(order.lines.count) numberOfLines=\(orderLines.count) numberOfChanges=\(changes.count)")
        }
        
        order.objectWillChange.send()
        order.unusedFreebies = unusedFreebies
        order.totalAfterSavings = orderLines.reduce(MoneyWithoutCurrency.zero) { $0 + $1.totalAfterSavings }.withCurrency(transactionCurrency)
        order.totalSavings = orderLines.reduce(MoneyWithoutCurrency.zero, { $0 + $1.totalSavings }).withCurrency(transactionCurrency)
        order.qtyFree = orderLines.reduce(0) { $0 + $1.qtyFree }
    }
    
    private func hasChanges(to: OrderLine, from: MockOrderLine) -> Bool {

        if to.unitPrice != from.unitPrice {
            return true
        }
        
        if to.charges.count != from.charges.count || !zip(from.charges, to.charges).filter({ $0 != $1}).isEmpty {
            return true
        }
        
        if to.credits.count != from.credits.count || !zip(from.credits, to.credits).filter({ $0 != $1}).isEmpty {
            return true
        }
        
        if to.freeGoods.count != from.freeGoods.count || !zip(from.freeGoods, to.freeGoods).filter({ $0 != $1}).isEmpty {
            return true
        }
        
        if to.discounts.count != from.discounts.count || !zip(from.discounts, to.discounts).filter({ $0 != $1}).isEmpty {
            return true
        }
        
        if to.potentialDiscounts.count != from.potentialDiscounts.count || !zip(from.potentialDiscounts, to.potentialDiscounts).filter({ $0.unitDiscount != $1.unitDiscount}).isEmpty {
            return true
        }
        
        return false
    }
    
    private func apply(to: OrderLine, from: MockOrderLine) {
        to.objectWillChange.send()
        
        to.unitPrice = from.unitPrice
        to.charges = from.charges
        to.credits = from.credits
        to.freeGoods = from.freeGoods
        to.discounts = from.discounts
        to.potentialDiscounts = from.potentialDiscounts
    }
    
    private func computePrices(lines: [MockOrderLine]) {
        
        let shipFrom = mobileDownload.warehouses[shipFromWhseNid]
        let sellTo = mobileDownload.customers[cusNid]
        
        let priceService = FrontlinePriceService(shipFrom: shipFrom, sellTo: sellTo, pricingDate: promoDate, transactionCurrency: transactionCurrency, numberOfDecimals: numberOfDecimals)
        
        for line in lines {
            let item = mobileDownload.items[line.itemNid]
            line.unitPrice = priceService.getPrice(item)?.withoutCurrency()
        }
    }
    
    private func computeDiscounts(lines: [MockOrderLine]) -> [UnusedFreebie] {
        
        let promoSections = PromoService.getPromoSectionRecords(cusNid: cusNid, promoDate: promoDate, deliveryDate: deliveryDate)
        
        let calc = PromoService(transactionCurrency: transactionCurrency, promoSections: promoSections, promoDate: promoDate)
        
        let promoSolution = calc.computeDiscounts(dcOrderLines: lines)
        
        return promoSolution.unusedFreebies
    }
    
    private func computeSplitCaseCharges(lines: [MockOrderLine]) {
        SplitCaseChargeService.computeSplitCaseCharges(deliveryDate: deliveryDate, transactionCurrency: transactionCurrency, orderLines: lines)
    }
    
    private func computeDeposits(lines: [MockOrderLine]) {
        let shipFrom = mobileDownload.warehouses[shipFromWhseNid]
        let sellTo = mobileDownload.customers[cusNid]
        
        let depositService = DepositService(shipFrom: shipFrom, sellTo: sellTo, pricingDate: promoDate, transactionCurrency: transactionCurrency, numberOfDecimals: numberOfDecimals)
        
        depositService.applyDeposits(orderLines: lines)
    }
}
