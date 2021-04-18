//  Created by Michael Rutherford on 2/19/21.

import Foundation

import Foundation
import MobileLegacyOrder
import MobileDownload
import MoneyAndExchangeRates

public struct OrderCreator {
    public static func PrepareNewPresellOrder(cusNid: Int, productSetNid: Int, empNid: Int) -> Order {
        let customer = mobileDownload.customers[cusNid]
        
        let entryTime = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: entryTime)

        let deliveryDate = Calendar.current.date(from: components)!
        
        let lines: [OrderLine] = []
        
        //let orderNumber = 1001 // mobileCache.getNextAvailableOrderNumber(temporaryOrderNumbersAreAcceptable: true)
        let order =  Order(orderNumber: nil, shipFromWhseNid: customer.whseNid, cusNid: customer.recNid, deliveryDate: deliveryDate, lines: lines)
        
        //order.companyNid = 1
        //order.cusNid = customer.recNid
        //order.slsEmpNid = empNid
        //order.enteredDate = Date()
        //
        //order.orderedDate = entryTime
        //order.shippedDate = deliveryDate
        //
        //order.hostWhseNid = customer.whseNid
        //
        //order.isTaxable = customer.isTaxable
        //
        //var stateDeliveryChargeAmount: MoneyWithoutCurrency = .zero
        //if let stateRecord = mobileDownload.states[customer.shipState] {
        //    stateDeliveryChargeAmount = stateRecord.deliveryChargeAmount
        //}
        //
        //if customer.deliveryChargeNid != 0 || stateDeliveryChargeAmount > 0 {
        //    order.isAutoDeliveryCharge = true
        //    order.deliveryChargeNid = customer.deliveryChargeNid
        //} else {
        //    order.isAutoDeliveryCharge = false
        //
        //    if customer.totalFreight != 0 {
        //        order.totalFreight = customer.totalFreight
        //    }
        //}
        //
        //order.offInvoiceDiscPct = customer.offInvoiceDiscPct
        //order.isBulkOrder = customer.isBulkOrderFlag
        //
        //var retailDateCodes = RetailDateCodes(mobileCache, customer)
        //AddLinesToNewOrder(mobileCache, order, customer, retailDateCodes, productSetNid)
        //
        //order.lookupPaymentTerms() // mpr: Thu Oct 16 16:03:22 EDT 2008
        //
        //order.doNotChargeUnitDeliveryCharge = customer.doNotChargeUnitDeliveryCharge
        //order.doNotChargeUnitFreight = customer.doNotChargeUnitFreight
        //
        //order.poNumber = customer.getStandingPONum(order.companyNid)
        
        return order
    }
    
    //mobileCache.mobileUpload.addSessionLogStartEvent(customer.recNid, empNid, "Pre-sell order")
    //mobileCache.mobileUpload.addSessionLogEntry(customer.recNid, order.orderNumber, "Started pre-sell order", null, null, null)
    //mobileCache.mobileUpload.addSessionLogEntry(customer.recNid, order.orderNumber, order.orderLines.count.toString() + " items pre-populated", null, null, null)
    
    
}
