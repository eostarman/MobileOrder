//
//  OrderConverterTests.swift
//  MobileOrderTests
//
//  Created by Michael Rutherford on 2/17/21.
//

import XCTest
@testable import MobileOrder
import MobileDownload
import MobileLegacyOrder
import MobileOrder
import MoneyAndExchangeRates

class OrderConverterTests: XCTestCase {

    // note that the Legacy MobileOrderLine eschews nil values (unlike the PresellOrderLine)
    func testTheBasics() throws {
        
        let line = PresellOrderLine(itemNid: 101, itemName: "", packName: "", qtyOrdered: 100)
        line.unitPrice = 1.23
        
        let order = PresellOrder(shipFromWhseNid: 1, cusNid: 2, deliveryDate: "2020-12-26", lines: [line])
        
        order.transactionCurrency = Currency.USD
        //order.promoDate = "2020-12-25"
        order.deliveryNote = "Check with Mike"
        
        let legacyOrder = OrderConverter.getMobileOrder(order)
        
        XCTAssertEqual(legacyOrder.transactionCurrencyNid, order.transactionCurrency.currencyNid)
        XCTAssertEqual(legacyOrder.whseNid, order.shipFromWhseNid)
        XCTAssertEqual(legacyOrder.toCusNid, order.cusNid)
        XCTAssertEqual(legacyOrder.promoDate, order.promoDate)
        XCTAssertEqual(legacyOrder.shippedDate, order.deliveryDate)
        XCTAssertEqual(legacyOrder.invoiceNote, order.deliveryNote)
        
        XCTAssertEqual(legacyOrder.lines.count, order.lines.count)
        
        if legacyOrder.lines.count >= 1 {
            let line = order.lines[0]
            let legacy = legacyOrder.lines[0]
            
            XCTAssertEqual(legacy.itemNid, line.itemNid)
            XCTAssertEqual(legacy.unitPrice, line.unitPrice ?? .zero)
        }
    }
}
