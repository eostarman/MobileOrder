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
    
    /// Number of items (excluding billing codes, but including dunnage)
    public var numberOfItems: Int {
        let nonZeroLines = lines.filter({ $0.qtyShippedOrExpectedToBeShipped > 0 })
        let nonBillingCodes = nonZeroLines.filter { !mobileDownload.items[$0.itemNid].isBillingCode }
        let totalQty = nonBillingCodes.reduce(0, {$0 + $1.qtyShippedOrExpectedToBeShipped})
        return totalQty
    }

    public init(orderNumber: Int?, shipFromWhseNid: Int, cusNid: Int, deliveryDate: Date, lines: [OrderLine]) {
        self.orderNumber = orderNumber
        self.shipFromWhseNid = shipFromWhseNid
        self.cusNid = cusNid
        self.deliveryDate = deliveryDate
        self.lines = lines
        
        self.slsEmpNid = mobileDownload.loggedInEmpNid
        
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
    
    public func recompute() {
        let recomputeService = OrderRecomputeService(order: self)
        recomputeService.recompute()
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
    
    public func getFilteredOrderLines(lines: [OrderLine], searchText: String) -> [OrderLine] {
        searchText.isEmpty ? lines : lines.filter { mobileDownload.items[$0.itemNid].recName.localizedCaseInsensitiveContains(searchText) }
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
            items = PresellOrderService.itemsInCustomerOfficeList(cusNid: cusNid)
        case .allHistory:
            items = PresellOrderService.itemsInCustomerHistory(cusNid: cusNid)
        case .allItems:
            items = PresellOrderService.itemsListedAsCanSellInMobileDownload()
        }
        
        items = items.sorted(by: { $0.recName < $1.recName })
        
        let authorizedItemsService = AuthorizedItemsService(fromWhseNid: whseNid, cusNid: cusNid, shipDate: deliveryDate)
        
        let authorizedItems = items.filter { authorizedItemsService.isAuthorized(itemNid: $0.recNid) }
        
        let employeeCanSellService = EmployeeCanSellService(customer: mobileDownload.customers[cusNid])
        
        let sellableItems = authorizedItems.filter(employeeCanSellService.employeeCanAndShouldSellItemToCustomer)
   
        let lines = sellableItems.map { item in  OrderLine(itemNid: item.recNid, qtyOrdered: 0) }
        
        return lines
    }
}

