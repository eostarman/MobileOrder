//
//  OfficeListService.swift
//  MobileBench (iOS)
//
//  Created by Michael Rutherford on 4/11/21.
//
//  replicating (mostly) the logic in eoTouch/eoTouchCore/OfficeList.cs


import Foundation
import MobileDownload

/// When a preseller takes an order, the "office list" is just a list of items we feel they should be entering from based on downloaded data (i.e. a list of items determined by data at the "office")
class OfficeListService {
    private let customer: CustomerRecord
    var itemNids: [Int] = []
    
    private var altPackFamilyNids: Set<Int> = []
    
    init(cusNid: Int) {
        self.customer = mobileDownload.customers[cusNid]
        
        addManualOfficeListItems()

        addAllocatedItems()

        addTargetedItems()

        addItemsFromListsAndLocations()

        addItemsFromSalesHistory()

        addItemsFromStandingOrders()
    }
    
    /// add an item to the end of the list if it's primary pack hasn't already been seen
    private func add(itemNid: Int) {
        let item = mobileDownload.items[itemNid]
        
        if altPackFamilyNids.contains(item.altPackFamilyNid) {
            return
        }
        
        altPackFamilyNids.insert(item.altPackFamilyNid)
        itemNids.append(itemNid)
    }
    
    private func addManualOfficeListItems() {
        // mpr: I'm not sure about the reasoning for the c# implementation.
        // eoTouch keeps a list of itemNids in its configuration file but this has two main problems: it isn't shared
        // between devices (or persisted in SQL), and it could be confused (I think) if we use one device to connect to two different databases
    }

    private func addAllocatedItems() {
        let allocations = mobileDownload.cusAllocations.filter { $0.cusNid == customer.recNid }
        for allocation in allocations {
            add(itemNid: allocation.itemNid)
        }
    }

    private func addTargetedItems() {
        let orderEntryDate = Date().withoutTimeStamp()
        
        for target in mobileDownload.customerProductTargetingRules.getAll() {
            if !target.targetCustomers.contains(customer.recNid) {
                continue
            }
            
            if let fromDate = target.fromDate, orderEntryDate < fromDate {
                continue
            }
            
            if let thruDate = target.thruDate, orderEntryDate > thruDate {
                continue
            }
            
            for altPackFamilyNid in target.targetProducts {
                add(itemNid: altPackFamilyNid)
            }
            
        }
    }

    private func addItemsFromListsAndLocations() {
        func addListOrLocation(_ listOrLocation: RetailerList) {
            for entry in listOrLocation.getAllItems() {
                add(itemNid: entry.itemNid)
            }
        }
        
        // add items in the countable office list (this is a so-called "office list" but we have a data structure (in the retailerInfo) that can record shelf counts
        for location in customer.retailerInfo.retailLocations.filter({ $0.IsCountableOfficeList }) {
            addListOrLocation(location)
        }
        
        // add items in the retail locations next. Items are added in the order scanned, so they will be listed in the sequence on the shelf (most likely)
        for location in customer.retailerInfo.retailLocations.filter({ !$0.IsCountableOfficeList }) {
            addListOrLocation(location)
        }
        
        // any product lists recorded for this customer are scanned to pick up items not listed at a retail location
        for productList in customer.retailerInfo.productLists {
            addListOrLocation(productList)
        }
        
        // an item listed as one tracked in the back-stock location will be added to the list (if it's not already in the list)
        for backstockLocation in customer.retailerInfo.backstockLocations {
            addListOrLocation(backstockLocation)
        }
    }

    private func addItemsFromSalesHistory() {
        
        /// when creating the office list, we don't want to add an item from last year just because we've downloaded history from last year (which is needed for the business review logic and handling of seasonal
        func getNumberOfSalesHistoryDaysToUse() -> Int {
            if customer.numberOfSalesHistoryDays > 0 {
                return customer.numberOfSalesHistoryDays
            }
            
            if mobileDownload.handheld.numberOfSalesHistoryDays > 0 {
                return mobileDownload.handheld.numberOfSalesHistoryDays
            }
            
            return 180
        }
        
        let numberOfSalesHistoryDays = getNumberOfSalesHistoryDaysToUse()
        let syncDate = mobileDownload.handheld.syncDate
        let earliestDate = Calendar.current.date(byAdding: .day, value: -numberOfSalesHistoryDays, to: syncDate)!
        
        for sale in mobileDownload.customers.getCustomerSales(customer) {
            if let deliveryDate = sale.deliveryDate {
                if deliveryDate >= earliestDate {
                    add(itemNid: sale.itemNid)
                }
            } else { // if it isn't delivered yet (it's an upcoming delivery) then add it to the office list
                add(itemNid: sale.itemNid)
            }
        }
    }

    private func addItemsFromStandingOrders() {
    }
}
