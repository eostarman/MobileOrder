//
//  LegacyOrderLineToOrderLineServiceTests.swift
//  MobileOrderTests
//
//  Created by Michael Rutherford on 4/16/21.
//

import XCTest
@testable import MobileOrder
import MobileLegacyOrder
import MoneyAndExchangeRates

class LegacyOrderLineToOrderLineServiceTests: XCTestCase {

    func testIncompleteConversionFromLegacyOrderLine() throws {
        let lol = LegacyOrderLine()
        
        let seedValues = SeedValues(bool: true, int: 123, nullableInt: 22, money: 1.0, nullableString: "x", nullableDate: Date(), nullableMoney: 5.67, date: Date())
        
        lol.seed(seedValues)
        
        guard let line = LegacyOrderLineToOrderLineService.getOrderLine(orderNumber: 666, legacyOrderLine: lol) else {
            XCTFail("Conversion failed")
            return
        }
        
        let lol2Lines = OrderLineToLegacyOrderLineService.getLegacyOrderLines(line)
        
        guard lol2Lines.count == 1, let lol2 = lol2Lines.first else {
            XCTFail("Expected a single line")
            return
        }
        
        XCTAssertEqual(lol.itemNid, lol2.itemNid)
        XCTAssertEqual(lol.itemWriteoffNid, lol2.itemWriteoffNid)
        XCTAssertEqual(lol.qtyShippedWhenVoided, lol2.qtyShippedWhenVoided)
        XCTAssertEqual(lol.qtyShipped, lol2.qtyShipped)
        XCTAssertEqual(lol.qtyOrdered, lol2.qtyOrdered)
        XCTAssertEqual(lol.qtyDiscounted, lol2.qtyDiscounted)
        XCTAssertEqual(lol.promo1Nid, lol2.promo1Nid)
        XCTAssertEqual(lol.unitDisc, lol2.unitDisc)
        XCTAssertEqual(lol.qtyLayerRoundingAdjustment, lol2.qtyLayerRoundingAdjustment)
        XCTAssertEqual(lol.crvContainerTypeNid, lol2.crvContainerTypeNid)
        XCTAssertEqual(lol.qtyDeliveryDriverAdjustment, lol2.qtyDeliveryDriverAdjustment)
        XCTAssertEqual(lol.itemNameOverride, lol2.itemNameOverride)
        XCTAssertEqual(lol.unitPrice, lol2.unitPrice)
        XCTAssertEqual(lol.isManualPrice, lol2.isManualPrice)
        XCTAssertEqual(lol.unitSplitCaseCharge, lol2.unitSplitCaseCharge)
        XCTAssertEqual(lol.unitDeposit, lol2.unitDeposit)
        XCTAssertEqual(lol.isManualDiscount, lol2.isManualDiscount)
        XCTAssertEqual(lol.carrierDeposit, lol2.carrierDeposit)
        XCTAssertEqual(lol.bagCredit, lol2.bagCredit)
        XCTAssertEqual(lol.statePickupCredit, lol2.statePickupCredit)
        XCTAssertEqual(lol.unitFreight, lol2.unitFreight)
        XCTAssertEqual(lol.unitDeliveryCharge, lol2.unitDeliveryCharge)
        XCTAssertEqual(lol.qtyBackordered, lol2.qtyBackordered)
        XCTAssertEqual(lol.isCloseDatedInMarket, lol2.isCloseDatedInMarket)
        XCTAssertEqual(lol.isManualDeposit, lol2.isManualDeposit)
        XCTAssertEqual(lol.basePricesAndPromosOnQtyOrdered, lol2.basePricesAndPromosOnQtyOrdered)
        XCTAssertEqual(lol.wasAutoCut, lol2.wasAutoCut)
        XCTAssertEqual(lol.mergeSequenceTag, lol2.mergeSequenceTag)
        XCTAssertEqual(lol.autoFreeGoodsLine, lol2.autoFreeGoodsLine)
        XCTAssertEqual(lol.isPreferredFreeGoodLine, lol2.isPreferredFreeGoodLine)
        XCTAssertEqual(lol.uniqueifier, lol2.uniqueifier)
        XCTAssertEqual(lol.wasDownloaded, lol2.wasDownloaded)
        XCTAssertEqual(lol.pickAndShipDateCodes, lol2.pickAndShipDateCodes)
        XCTAssertEqual(lol.dateCode, lol2.dateCode)
        XCTAssertEqual(lol.CMAOnNid, lol2.CMAOnNid)
        XCTAssertEqual(lol.CTMOnNid, lol2.CTMOnNid)
        XCTAssertEqual(lol.CCFOnNid, lol2.CCFOnNid)
        XCTAssertEqual(lol.CMAOffNid, lol2.CMAOffNid)
        XCTAssertEqual(lol.CTMOffNid, lol2.CTMOffNid)
        XCTAssertEqual(lol.CCFOffNid, lol2.CCFOffNid)
        XCTAssertEqual(lol.CMAOnAmt, lol2.CMAOnAmt)
        XCTAssertEqual(lol.CTMOnAmt, lol2.CTMOnAmt)
        XCTAssertEqual(lol.CCFOnAmt, lol2.CCFOnAmt)
        XCTAssertEqual(lol.CMAOffAmt, lol2.CMAOffAmt)
        XCTAssertEqual(lol.CTMOffAmt, lol2.CTMOffAmt)
        XCTAssertEqual(lol.CCFOffAmt, lol2.CCFOffAmt)
        XCTAssertEqual(lol.commOverrideSlsEmpNid, lol2.commOverrideSlsEmpNid)
        XCTAssertEqual(lol.commOverrideDrvEmpNid, lol2.commOverrideDrvEmpNid)
        XCTAssertEqual(lol.qtyCloseDateRequested, lol2.qtyCloseDateRequested)
        XCTAssertEqual(lol.qtyCloseDateShipped, lol2.qtyCloseDateShipped)
        XCTAssertEqual(lol.preservePricing, lol2.preservePricing)
        XCTAssertEqual(lol.noteLink, lol2.noteLink)
        XCTAssertEqual(lol.unitCRV, lol2.unitCRV)
        XCTAssertEqual(lol.seq, lol2.seq)

    }

}

struct SeedValues {
    let bool: Bool
    let int: Int
    let nullableInt: Int?
    let money: MoneyWithoutCurrency
    let nullableString: String?
    let nullableDate: Date?
    let nullableMoney: MoneyWithoutCurrency?
    let date: Date
}

fileprivate extension LegacyOrderLine {
    func seed(_ v: SeedValues) {
        itemNid = v.nullableInt
        itemWriteoffNid = v.nullableInt
        qtyShippedWhenVoided = v.nullableInt
        qtyShipped = v.int
        qtyOrdered = v.int
        qtyDiscounted = v.int
        promo1Nid = v.nullableInt
        unitDisc = v.money
        qtyLayerRoundingAdjustment = v.nullableInt
        crvContainerTypeNid = v.nullableInt
        qtyDeliveryDriverAdjustment = v.nullableInt
        itemNameOverride = v.nullableString
        unitPrice = v.money
        isManualPrice = v.bool
        unitSplitCaseCharge = v.money
        unitDeposit = v.money
        isManualDiscount = v.bool
        carrierDeposit = v.money
        bagCredit = v.money
        statePickupCredit = v.money
        unitFreight = v.money
        unitDeliveryCharge = v.money
        qtyBackordered = v.nullableInt
        isCloseDatedInMarket = v.bool
        isManualDeposit = v.bool
        basePricesAndPromosOnQtyOrdered = v.bool
        wasAutoCut = v.bool
        mergeSequenceTag = v.nullableInt
        autoFreeGoodsLine = v.bool
        isPreferredFreeGoodLine = v.bool
        uniqueifier = v.nullableInt
        wasDownloaded = v.bool
        pickAndShipDateCodes = v.nullableString
        dateCode = v.nullableDate
        CMAOnNid = v.nullableInt
        CTMOnNid = v.nullableInt
        CCFOnNid = v.nullableInt
        CMAOffNid = v.nullableInt
        CTMOffNid = v.nullableInt
        CCFOffNid = v.nullableInt
        CMAOnAmt = v.money
        CTMOnAmt = v.money
        CCFOnAmt = v.money
        CMAOffAmt = v.money
        CTMOffAmt = v.money
        CCFOffAmt = v.money
        commOverrideSlsEmpNid = v.nullableInt
        commOverrideDrvEmpNid = v.nullableInt
        qtyCloseDateRequested = v.nullableInt
        qtyCloseDateShipped = v.nullableInt
        preservePricing = v.bool
        noteLink = v.nullableInt
        unitCRV = v.money
        seq = v.int

    }
}
