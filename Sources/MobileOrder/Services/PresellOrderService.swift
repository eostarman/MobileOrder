//
//  PresellOrderService.swift
//  MobileBench (iOS)
//
//  Created by Michael Rutherford on 10/3/20.
//

import Foundation
import MobileDownload

public struct PresellOrderService {
    public static func getSoonestDeliveryDate() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1), to: Date()) ?? Date()
    }
    
    public static func itemsInCustomerOfficeList(cusNid: Int) -> [ItemRecord] {
        OfficeListService(cusNid: cusNid).itemNids.map { mobileDownload.items[$0] }
    }
    
    public static func itemsInCustomerHistory(cusNid: Int) -> [ItemRecord] {
        let customer = mobileDownload.customers[cusNid]
        let sales = mobileDownload.customers.getCustomerSales(customer)

        let itemNids = sales.map { $0.itemNid }.unique()

        return itemNids.map { mobileDownload.items[$0] }
    }
    
    public static func itemsListedAsCanSellInMobileDownload() -> [ItemRecord] {
        mobileDownload.items.getAll().filter({ $0.activeFlag && $0.canSell })
    }
    
}
