//
//  Order.swift
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
import MobileLegacyOrder

public class Order: Identifiable, ObservableObject {
    public let id = UUID()
    
    public var orderedDate: Date = Date()

    public var orderNumber: Int?
    public var shipFromWhseNid: Int
    public var cusNid: Int
    public var companyNid: Int = 1
    public var trkNid: Int?
    public var drvEmpNid: Int?
    public var slsEmpNid: Int?
    public var orderTypeNid: Int?
    public var orderType: eOrderType = .FreshPresellOrder
    
    @Published public var transactionCurrency: Currency
    public let numberOfDecimals: Int
    
    var promoDate: Date {
        mobileDownload.databaseSource == .live ? promoOverrideDate ?? deliveryDate : mobileDownload.handheld.syncDate
    }
    
    public var entrySequenceForCustomer: Int = 1

    public var conversionErrors: [String] = []

    @Published public var lines: [OrderLine] = []

    @Published public var totalAfterSavings: Money = Currency.USD.zero
    @Published public var totalSavings: Money = Currency.USD.zero
    @Published public var qtyFree: Int = 0

    @Published public var deliveryNote: String = ""

    @Published public var deliveryDate = Date()
    
    public var promoOverrideDate: Date?
    
    public var unusedFreebies: [UnusedFreebie] = []
    
    public var logEntries: [OrderLogEntry] = []
    public var voidingEntry: OrderVoidingEntry?
    public var deliveryInfo: OrderDeliveryInfo = .init()
    public var deliveryRouteInfo: OrderDeliveryRouteInfo = .init()
    public var paymentTermsInfo: OrderPaymentTermsInfo = .init()

    public init(orderNumber: Int?, shipFromWhseNid: Int, cusNid: Int, deliveryDate: Date, lines: [OrderLine]) {
        self.orderNumber = orderNumber
        self.shipFromWhseNid = shipFromWhseNid
        self.cusNid = cusNid
        self.deliveryDate = deliveryDate
        self.lines = lines
        
        transactionCurrency = mobileDownload.customers[cusNid].transactionCurrency
        numberOfDecimals = mobileDownload.handheld.nbrPriceDecimals

        recompute()
    }

    // for previews
    public init(lines: [OrderLine]) {
        orderNumber = nil
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
extension Order {

    public func recompute() {
        
        objectWillChange.send()
        
        let filteredLines = lines.filter { $0.qtyOrdered >= 0 }
            
        if filteredLines.isEmpty {
            unusedFreebies = []
        } else {
            computePrices(filteredLines: filteredLines)
            unusedFreebies = computeDiscounts(filteredLines: filteredLines)
            computeSplitCaseCharges(filteredLines: filteredLines)
            computeDeposits(filteredLines: filteredLines)
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

    private func computePrices(filteredLines: [OrderLine]) {
        
        let shipFrom = mobileDownload.warehouses[shipFromWhseNid]
        let sellTo = mobileDownload.customers[cusNid]

        let priceService = FrontlinePriceService(shipFrom: shipFrom, sellTo: sellTo, pricingDate: promoDate, transactionCurrency: transactionCurrency, numberOfDecimals: numberOfDecimals)

        for saleLine in filteredLines {
            let item = mobileDownload.items[saleLine.itemNid]
            saleLine.unitPrice = priceService.getPrice(item)?.withoutCurrency()
        }
    }
    
    private func computeDiscounts(filteredLines: [OrderLine]) -> [UnusedFreebie] {
        
        let promoSections = PromoService.getPromoSectionRecords(cusNid: cusNid, promoDate: promoDate, deliveryDate: deliveryDate)
        
        let calc = PromoService(transactionCurrency: transactionCurrency, promoSections: promoSections, promoDate: promoDate)
        
        let promoSolution = calc.computeDiscounts(dcOrderLines: filteredLines)
        
        return promoSolution.unusedFreebies
    }
    
    private func computeSplitCaseCharges(filteredLines: [OrderLine]) {
        SplitCaseChargeService.computeSplitCaseCharges(deliveryDate: deliveryDate, transactionCurrency: transactionCurrency, orderLines: filteredLines)
    }
    
    private func computeDeposits(filteredLines: [OrderLine]) {
        let shipFrom = mobileDownload.warehouses[shipFromWhseNid]
        let sellTo = mobileDownload.customers[cusNid]
        
        let depositService = DepositService(shipFrom: shipFrom, sellTo: sellTo, pricingDate: promoDate, transactionCurrency: transactionCurrency, numberOfDecimals: numberOfDecimals)
        
        depositService.applyDeposits(orderLines: filteredLines)
    }
}

// populate order lines based on history
extension Order {
    
    public enum CreationFilter {
        case officeList
        case allHistory
        case allItems
    }
    
    public enum OrderLineFilter {
        case allLines
        case discounts
        case potentialDiscounts
    }
    
    public func getFilteredOrderLines(filter: OrderLineFilter) -> [OrderLine] {
        switch filter {
        case .discounts:
            return lines.filter { !$0.discounts.isEmpty }
        case .potentialDiscounts:
            return lines.filter { !$0.potentialDiscounts.isEmpty }
        case .allLines:
            return lines
        }
    }
    
    public static func createNewOrder(customer: CustomerRecord) -> Order {
        let shipFromWhseNid = customer.whseNid
        let deliveryDate = PresellOrderService.getSoonestDeliveryDate()
        
        let orderLines = getOrderLines(whseNid: shipFromWhseNid, cusNid: customer.recNid, deliveryDate: deliveryDate, creationFilter: .officeList)
      
        let newOrder = Order(orderNumber: nil, shipFromWhseNid: shipFromWhseNid, cusNid: customer.recNid, deliveryDate: deliveryDate, lines: orderLines)

        return newOrder
    }
    
    public func resetOrderLines(creationFilter: CreationFilter) {
        objectWillChange.send()
        
        let newOrderLines = Self.getOrderLines(whseNid: shipFromWhseNid, cusNid: cusNid, deliveryDate: deliveryDate, creationFilter: creationFilter)
        
        lines = newOrderLines
        
        recompute()
    }
    
    public static func getOrderLines(whseNid: Int, cusNid: Int, deliveryDate: Date, creationFilter: CreationFilter) -> [OrderLine] {
        var items: [ItemRecord]
        
        switch creationFilter {
        case .officeList:
            let officeListService = OfficeListService(cusNid: cusNid)
            items = officeListService.itemNids.map { mobileDownload.items[$0] }            
        case .allHistory:
            items = getItemsFromAllHistory(cusNid: cusNid)
        case .allItems:
            items = mobileDownload.items.getAll().filter({ $0.activeFlag && $0.canSell })
        }
        
        items = items.sorted(by: { $0.recName < $1.recName })
        
        let authorizedItemsService = AuthorizedItemsService(fromWhseNid: whseNid, cusNid: cusNid, shipDate: deliveryDate)
        
        let authorizedItems = items.filter { authorizedItemsService.isAuthorized(itemNid: $0.recNid) }
        
        let employeeCanSellService = EmployeeCanSellService(customer: mobileDownload.customers[cusNid])
        
        let sellableItems = authorizedItems.filter(employeeCanSellService.employeeCanAndShouldSellItemToCustomer)
   
        let lines = sellableItems.map { item in  OrderLine(itemNid: item.recNid, itemName: item.recName, packName: item.packName, qtyOrdered: 0) }
        
        return lines
    }
    
    private static func getItemsFromAllHistory(cusNid: Int) -> [ItemRecord] {
      
        let customer = mobileDownload.customers[cusNid]
        let sales = mobileDownload.customers.getCustomerSales(customer)

        let itemNids = sales.map { $0.itemNid }.unique()

        let items = itemNids.map { mobileDownload.items[$0] }

        return items
    }
}

