//
//  OrderLineConverterTests.swift
//  MobileOrderTests
//
//  Created by Michael Rutherford on 2/17/21.
//

import XCTest
@testable import MobileOrder
import MobileDownload
import MobileLegacyOrder
import MobileOrder

class OrderLineToLegacyOrderLineServiceTests: XCTestCase {
    
    func testTheBasics() throws {
        
        let line = OrderLine(itemNid: 1, itemName: "1", packName: "1", qtyOrdered: 100)
        line.unitPrice = 1.23
        line.isPreferredFreeGoodLine = true
        line.basePricesAndPromosOnQtyOrdered = true
        
        line.addCharge(.splitCaseCharge(amount: 0.19))
        
        let legacyLines = OrderLineToLegacyOrderLineService.getLegacyOrderLines(line)
        
        XCTAssertEqual(legacyLines.count, 1)
        
        if legacyLines.count >= 1 {
            let legacy = legacyLines[0]
            XCTAssertEqual(legacy.itemNid, line.itemNid)
            XCTAssertEqual(legacy.unitPrice, line.unitPrice)
            XCTAssertEqual(legacy.isPreferredFreeGoodLine, line.isPreferredFreeGoodLine)
            XCTAssertEqual(legacy.basePricesAndPromosOnQtyOrdered, line.basePricesAndPromosOnQtyOrdered)
        }
    }
    
    func testOneDiscount() throws {
        
        let line = OrderLine(itemNid: 1, itemName: "1", packName: "1", qtyOrdered: 100)
        line.unitPrice = 1.23
        line.addDiscount(promoPlan: .CCFOnInvoice, promoSectionNid: 11, unitDisc: 0.15, rebateAmount: .zero)
        line.addDiscount(promoPlan: .CMAOnInvoice, promoSectionNid: 12, unitDisc: 0.16, rebateAmount: .zero)
        line.addDiscount(promoPlan: .CTMOnInvoice, promoSectionNid: 13, unitDisc: 0.17, rebateAmount: .zero)
        
        let legacyLines = OrderLineToLegacyOrderLineService.getLegacyOrderLines(line)
        
        XCTAssertEqual(legacyLines.count, 1)
        
        if legacyLines.count >= 1 {
            let legacy = legacyLines[0]
            
            XCTAssertEqual(legacy.itemNid, line.itemNid)
            XCTAssertEqual(legacy.CCFOnNid, 11)
            XCTAssertEqual(legacy.CCFOnAmt, 0.15)
            XCTAssertEqual(legacy.CMAOnNid, 12)
            XCTAssertEqual(legacy.CMAOnAmt, 0.16)
            XCTAssertEqual(legacy.CTMOnNid, 13)
            XCTAssertEqual(legacy.CTMOnAmt, 0.17)
        }
    }
    
    func testMultipleDiscounts() throws {
        
        let line = OrderLine(itemNid: 1, itemName: "1", packName: "1", qtyOrdered: 100)
        line.unitPrice = 1.23
        line.addDiscount(promoPlan: .Default, promoSectionNid: 11, unitDisc: 0.15, rebateAmount: .zero)
        line.addDiscount(promoPlan: .Stackable, promoSectionNid: 12, unitDisc: 0.16, rebateAmount: .zero)
        line.addDiscount(promoPlan: .Stackable, promoSectionNid: 13, unitDisc: 0.17, rebateAmount: .zero)
        
        let legacyLines = OrderLineToLegacyOrderLineService.getLegacyOrderLines(line)
        
        // one line with a price and a discount, then two "discount-only" lines
        XCTAssertEqual(legacyLines.count, 3)
        
        if legacyLines.count >= 1 {
            let legacy = legacyLines[0]
            
            XCTAssertEqual(legacy.qtyOrdered, 100)
            XCTAssertEqual(legacy.qtyShipped, 100)
            XCTAssertEqual(legacy.itemNid, line.itemNid)
            XCTAssertEqual(legacy.promo1Nid, 11)
            XCTAssertEqual(legacy.unitDisc, 0.15)
        }
        
        if legacyLines.count >= 2 {
            let legacy = legacyLines[1]
            
            XCTAssertEqual(legacy.qtyOrdered, 100)
            XCTAssertEqual(legacy.qtyShipped, 100)
            XCTAssertEqual(legacy.unitPrice, .zero)
            XCTAssertEqual(legacy.promo1Nid, 12)
            XCTAssertEqual(legacy.unitDisc, 0.16)
        }
        
        if legacyLines.count >= 3 {
            let legacy = legacyLines[2]
            
            XCTAssertEqual(legacy.qtyOrdered, 100)
            XCTAssertEqual(legacy.qtyShipped, 100)
            XCTAssertEqual(legacy.unitPrice, .zero)
            XCTAssertEqual(legacy.promo1Nid, 13)
            XCTAssertEqual(legacy.unitDisc, 0.17)
        }
    }
    
    func testFreeGoodsMultipleDiscounts() throws {
        
        let line = OrderLine(itemNid: 1, itemName: "1", packName: "1", qtyOrdered: 120)
        line.unitPrice = 1.23
        line.addDiscount(promoPlan: .Default, promoSectionNid: 11, unitDisc: 0.15, rebateAmount: .zero)
        line.addDiscount(promoPlan: .Stackable, promoSectionNid: 12, unitDisc: 0.16, rebateAmount: .zero)
        line.addDiscount(promoPlan: .Stackable, promoSectionNid: 13, unitDisc: 0.17, rebateAmount: .zero)
        
        // the Coke CCF promo amount is for the non-free goods
        line.addDiscount(promoPlan: .CCFOnInvoice, promoSectionNid: 33, unitDisc: 0.23, rebateAmount: .zero)
        
        line.addFreeGoods(promoSectionNid: 77, qtyFree: 20, rebateAmount: .zero)
        
        let legacyLines = OrderLineToLegacyOrderLineService.getLegacyOrderLines(line)
        
        // one line with a price and a discount, then two "discount-only" lines, then the free-goods line for the 20 free
        XCTAssertEqual(legacyLines.count, 4)
        
        if legacyLines.count >= 1 {
            let legacy = legacyLines[0]
            
            XCTAssertEqual(legacy.qtyOrdered, 100)
            XCTAssertEqual(legacy.qtyShipped, 100)
            XCTAssertEqual(legacy.unitPrice, 1.23)
            XCTAssertEqual(legacy.itemNid, line.itemNid)
            XCTAssertEqual(legacy.promo1Nid, 11)
            XCTAssertEqual(legacy.unitDisc, 0.15)
            XCTAssertEqual(legacy.CCFOnNid, 33)
            XCTAssertEqual(legacy.CCFOnAmt, 0.23)
        }
        
        if legacyLines.count >= 2 {
            let legacy = legacyLines[1]
            
            XCTAssertEqual(legacy.qtyOrdered, 100)
            XCTAssertEqual(legacy.qtyShipped, 100)
            XCTAssertEqual(legacy.unitPrice, .zero)
            XCTAssertEqual(legacy.promo1Nid, 12)
            XCTAssertEqual(legacy.unitDisc, 0.16)
            XCTAssertNil(legacy.CCFOnNid)
            XCTAssertEqual(legacy.CCFOnAmt, .zero)
        }
        
        if legacyLines.count >= 3 {
            let legacy = legacyLines[2]
            
            XCTAssertEqual(legacy.qtyOrdered, 100)
            XCTAssertEqual(legacy.qtyShipped, 100)
            XCTAssertEqual(legacy.unitPrice, .zero)
            XCTAssertEqual(legacy.promo1Nid, 13)
            XCTAssertEqual(legacy.unitDisc, 0.17)
            XCTAssertNil(legacy.CCFOnNid)
            XCTAssertEqual(legacy.CCFOnAmt, .zero)
        }
        
        // this is the 20 free ones
        if legacyLines.count >= 4 {
            let legacy = legacyLines[3]
            
            XCTAssertEqual(legacy.qtyOrdered, 20)
            XCTAssertEqual(legacy.qtyShipped, 20)
            XCTAssertEqual(legacy.unitPrice, 1.23)
            XCTAssertEqual(legacy.promo1Nid, 77)
            XCTAssertEqual(legacy.unitDisc, 1.23)
            XCTAssertNil(legacy.CCFOnNid)
            XCTAssertEqual(legacy.CCFOnAmt, .zero)
        }
    }
}
