//
//  PresellOrder.swift
//  MobileBench
//
//  Created by Michael Rutherford on 7/26/20.
//

import Combine
import Foundation
import SwiftUI
import MobileDownload
import MoneyAndExchangeRates
import MobilePricing

public class PresellOrder: Identifiable, ObservableObject {
    public let id = UUID()

    public let shipFromWhseNid: Int
    public let cusNid: Int
    @Published public var transactionCurrency: Currency
    public let numberOfDecimals: Int
    
    var promoDate: Date {
        mobileDownload.databaseSource == .live ? deliveryDate : mobileDownload.handheld.syncDate
    }

    public var entrySequenceForCustomer: Int = 1

    @Published public var lines: [PresellOrderLine] = []

    @Published public var totalAfterSavings: Money = Currency.USD.zero
    @Published public var totalSavings: Money = Currency.USD.zero
    @Published public var qtyFree: Int = 0

    @Published public var deliveryNote: String = ""

    @Published public var deliveryDate = Date()
    
    public var unusedFreebies: [UnusedFreebie] = []

    public init(shipFromWhseNid: Int, cusNid: Int, deliveryDate: Date, lines: [PresellOrderLine]) {
        self.shipFromWhseNid = shipFromWhseNid
        self.cusNid = cusNid
        self.deliveryDate = deliveryDate
        self.lines = lines
        
        transactionCurrency = mobileDownload.customers[cusNid].transactionCurrency
        numberOfDecimals = mobileDownload.handheld.nbrPriceDecimals

        recompute()
    }

    // for previews
    public init(lines: [PresellOrderLine]) {
        shipFromWhseNid = 0
        cusNid = 0
        deliveryDate = Date()
        self.lines = lines
        
        transactionCurrency = .USD
        numberOfDecimals = 2
        
        recompute()
    }
}

// calculations on the order
extension PresellOrder {

    public func recompute() {
        
        objectWillChange.send()
        
        let filteredLines = lines.filter { $0.qtyOrdered >= 0 }
            
        if filteredLines.isEmpty {
            unusedFreebies = []
        } else {
            computePrices(filteredLines: filteredLines)
            unusedFreebies = computeDiscounts(filteredLines: filteredLines)
            computeSplitCaseCharges(filteredLines: filteredLines)
        }
        
        totalAfterSavings = lines.reduce(MoneyWithoutCurrency.zero) { $0 + $1.totalAfterSavings }.withCurrency(transactionCurrency)
        totalSavings = lines.reduce(MoneyWithoutCurrency.zero, { $0 + $1.totalSavings }).withCurrency(transactionCurrency)
        qtyFree = lines.reduce(0) { $0 + $1.qtyFree }
    }
    
    private func getTotalAfterSavings() -> Money {
        let total = lines.reduce(MoneyWithoutCurrency.zero) { $0 + $1.totalAfterSavings }
        return total.withCurrency(transactionCurrency)
    }
    
    private func getTotalSavings() -> Money {
        let total = lines.reduce(MoneyWithoutCurrency.zero) { $0 + $1.totalSavings }
        return total.withCurrency(transactionCurrency)
    }

    private func computePrices(filteredLines: [PresellOrderLine]) {
        
        let shipFrom = mobileDownload.warehouses[shipFromWhseNid]
        let sellTo = mobileDownload.customers[cusNid]

        let priceService = FrontlinePriceService(shipFrom: shipFrom, sellTo: sellTo, pricingDate: promoDate, transactionCurrency: transactionCurrency, numberOfDecimals: numberOfDecimals)

        for saleLine in filteredLines {
            let item = mobileDownload.items[saleLine.itemNid]
            saleLine.unitPrice = priceService.getPrice(item)?.withoutCurrency()
        }
    }
    
    private func computeDiscounts(filteredLines: [PresellOrderLine]) -> [UnusedFreebie] {
        
        let promoSections = PromoService.getPromoSectionRecords(cusNid: cusNid, promoDate: promoDate, deliveryDate: deliveryDate)
        
        let calc = PromoService(transactionCurrency: transactionCurrency, promoSections: promoSections, promoDate: promoDate)
        
        let promoSolution = calc.computeDiscounts(dcOrderLines: filteredLines)
        
        return promoSolution.unusedFreebies
    }
    
    private func computeSplitCaseCharges(filteredLines: [PresellOrderLine]) {
        SplitCaseChargeService.computeSplitCaseCharges(deliveryDate: deliveryDate, transactionCurrency: transactionCurrency, orderLines: filteredLines)
    }
}

// populate order lines based on history
extension PresellOrder {
    
    public enum CreationFilter {
        case allHistory
        case allItems
    }
    
    public enum OrderLineFilter {
        case allLines
        case discounts
        case potentialDiscounts
    }
    
    public func getFilteredOrderLines(filter: OrderLineFilter) -> [PresellOrderLine] {
        switch filter {
        case .discounts:
            return lines.filter { !$0.discounts.isEmpty }
        case .potentialDiscounts:
            return lines.filter { !$0.potentialDiscounts.isEmpty }
        case .allLines:
            return lines
        }
    }
    
    public static func createNewOrder(customer: CustomerRecord) -> PresellOrder {
        let shipFromWhseNid = customer.whseNid
        let deliveryDate = PresellOrderService.getSoonestDeliveryDate()
        
        let orderLines = getOrderLines(whseNid: shipFromWhseNid, cusNid: customer.recNid, deliveryDate: deliveryDate, creationFilter: .allHistory)
      
        let newOrder = PresellOrder(shipFromWhseNid: shipFromWhseNid, cusNid: customer.recNid, deliveryDate: deliveryDate, lines: orderLines)

        return newOrder
    }
    
    public func resetOrderLines(creationFilter: CreationFilter) {
        objectWillChange.send()
        
        let newOrderLines = Self.getOrderLines(whseNid: shipFromWhseNid, cusNid: cusNid, deliveryDate: deliveryDate, creationFilter: creationFilter)
        
        lines = newOrderLines
        
        recompute()
    }
    
    public static func getOrderLines(whseNid: Int, cusNid: Int, deliveryDate: Date, creationFilter: CreationFilter) -> [PresellOrderLine] {
        let items: [ItemRecord]
        
        switch creationFilter {
        case .allHistory:
            items = getItemsFromAllHistory(cusNid: cusNid).sorted(by: { $0.recName < $1.recName })
        case .allItems:
            items = mobileDownload.items.getAll().filter({ $0.activeFlag && $0.canSell }).sorted(by: { $0.recName < $1.recName })
        }
        
        let authorizedItemsService = AuthorizedItemsService(fromWhseNid: whseNid, cusNid: cusNid, shipDate: deliveryDate)
        
        let authorizedItems = items.filter { authorizedItemsService.isAuthorized(itemNid: $0.recNid) }
   
        return authorizedItems.map { item in  PresellOrderLine(itemNid: item.recNid, itemName: item.recName, packName: item.packName, qtyOrdered: 0) }
    }
    
    private static func getItemsFromAllHistory(cusNid: Int) -> [ItemRecord] {
      
        let customer = mobileDownload.customers[cusNid]
        let sales = mobileDownload.customers.getCustomerSales(customer)

        let itemNids = sales.map { $0.itemNid }.unique()

        let items = itemNids.map { mobileDownload.items[$0] }

        return items
    }
}
