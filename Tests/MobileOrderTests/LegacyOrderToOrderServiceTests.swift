//
//  LegacyOrderToOrderServiceTests.swift
//  MobileOrderTests
//
//  Created by Michael Rutherford on 4/16/21.
//

import XCTest
@testable import MobileOrder
import MobileLegacyOrder
import MoneyAndExchangeRates

class LegacyOrderToOrderServiceTests: XCTestCase {

    func testIncompleteConversionFromLegacyOrder() throws {
        let lol = LegacyOrder()
        
        let seedDate = Date.fromDownloadedDateTime("20200529:200545")! // don't use Date() since it'll have millisecs and we don't encode/decode millisecs
        let seedValues = SeedValues(bool: true, int: 123, money: 1.0, date: seedDate, string: "xx", nullableInt: 22, nullableMoney: 1.99, nullableDate: Date(), nullableString: "x")
        lol.seed(seedValues)
        
        // this is what we're testing
        guard let order = LegacyOrderToOrderService.getOrder(legacyOrder: lol) else {
            XCTFail("Conversion failed")
            return
        }
      
        let lol2 = OrderToLegacyOrderService.getLegacyOrder(order)

        XCTAssertEqual(lol.transactionCurrencyNid, lol2.transactionCurrencyNid)
        XCTAssertEqual(lol.companyNid, lol2.companyNid)
        XCTAssertEqual(lol.orderNumber, lol2.orderNumber)
        XCTAssertEqual(lol.whseNid, lol2.whseNid)
        XCTAssertEqual(lol.trkNid, lol2.trkNid)
        XCTAssertEqual(lol.toCusNid, lol2.toCusNid)
        XCTAssertEqual(lol.isFromDistributor, lol2.isFromDistributor)
        XCTAssertEqual(lol.isToDistributor, lol2.isToDistributor)
        XCTAssertEqual(lol.deliveryChargeNid, lol2.deliveryChargeNid)
        XCTAssertEqual(lol.isAutoDeliveryCharge, lol2.isAutoDeliveryCharge)
        XCTAssertEqual(lol.isEarlyPay, lol2.isEarlyPay)
        XCTAssertEqual(lol.earlyPayDiscountAmt, lol2.earlyPayDiscountAmt)
        XCTAssertEqual(lol.termDiscountDays, lol2.termDiscountDays)
        XCTAssertEqual(lol.termDiscountPct, lol2.termDiscountPct)
        XCTAssertEqual(lol.heldStatus, lol2.heldStatus)
        XCTAssertEqual(lol.isVoided, lol2.isVoided)
        XCTAssertEqual(lol.deliveredStatus, lol2.deliveredStatus)
        XCTAssertEqual(lol.orderType, lol2.orderType)
        XCTAssertEqual(lol.isHotShot, lol2.isHotShot)
        XCTAssertEqual(lol.numberSummarized, lol2.numberSummarized)
        XCTAssertEqual(lol.summaryOrderNumber, lol2.summaryOrderNumber)
        XCTAssertEqual(lol.coopTicketNumber, lol2.coopTicketNumber)
        XCTAssertEqual(lol.shipAdr1, lol2.shipAdr1)
        XCTAssertEqual(lol.shipAdr2, lol2.shipAdr2)
        XCTAssertEqual(lol.shipCity, lol2.shipCity)
        XCTAssertEqual(lol.shipState, lol2.shipState)
        XCTAssertEqual(lol.shipZip, lol2.shipZip)
        XCTAssertEqual(lol.doNotChargeUnitFreight, lol2.doNotChargeUnitFreight)
        XCTAssertEqual(lol.doNotChargeUnitDeliveryCharge, lol2.doNotChargeUnitDeliveryCharge)
        XCTAssertEqual(lol.ignoreDeliveryTruckRestrictions, lol2.ignoreDeliveryTruckRestrictions)
        XCTAssertEqual(lol.signatureVectors, lol2.signatureVectors)
        XCTAssertEqual(lol.driverSignatureVectors, lol2.driverSignatureVectors)
        XCTAssertEqual(lol.isOffScheduleDelivery, lol2.isOffScheduleDelivery)
        XCTAssertEqual(lol.isSpecialPaymentTerms, lol2.isSpecialPaymentTerms)
        XCTAssertEqual(lol.promoDate, lol2.promoDate)
        XCTAssertEqual(lol.authenticatedByNid, lol2.authenticatedByNid)
        XCTAssertEqual(lol.authenticatedDate, lol2.authenticatedDate)
        XCTAssertEqual(lol.deliveredDate, lol2.deliveredDate)
        XCTAssertEqual(lol.deliveredByNid, lol2.deliveredByNid)
        XCTAssertEqual(lol.deliveryDocumentDate, lol2.deliveryDocumentDate)
        XCTAssertEqual(lol.deliveryDocumentByNid, lol2.deliveryDocumentByNid)
        XCTAssertEqual(lol.dispatchedDate, lol2.dispatchedDate)
        XCTAssertEqual(lol.dispatchedByNid, lol2.dispatchedByNid)
        XCTAssertEqual(lol.ediInvoiceDate, lol2.ediInvoiceDate)
        XCTAssertEqual(lol.ediInvoiceByNid, lol2.ediInvoiceByNid)
        XCTAssertEqual(lol.ediPaymentDate, lol2.ediPaymentDate)
        XCTAssertEqual(lol.ediPaymentByNid, lol2.ediPaymentByNid)
        XCTAssertEqual(lol.ediShipNoticeDate, lol2.ediShipNoticeDate)
        XCTAssertEqual(lol.ediShipNoticeByNid, lol2.ediShipNoticeByNid)
        XCTAssertEqual(lol.enteredDate, lol2.enteredDate)
        XCTAssertEqual(lol.enteredByNid, lol2.enteredByNid)
        XCTAssertEqual(lol.followupInvoiceDate, lol2.followupInvoiceDate)
        XCTAssertEqual(lol.followupInvoiceByNid, lol2.followupInvoiceByNid)
        XCTAssertEqual(lol.loadedDate, lol2.loadedDate)
        XCTAssertEqual(lol.loadedByNid, lol2.loadedByNid)
        XCTAssertEqual(lol.orderedDate, lol2.orderedDate)
        XCTAssertEqual(lol.orderedByNid, lol2.orderedByNid)
        XCTAssertEqual(lol.palletizedDate, lol2.palletizedDate)
        XCTAssertEqual(lol.palletizedByNid, lol2.palletizedByNid)
        XCTAssertEqual(lol.pickListDate, lol2.pickListDate)
        XCTAssertEqual(lol.pickListByNid, lol2.pickListByNid)
        XCTAssertEqual(lol.shippedDate, lol2.shippedDate)
        XCTAssertEqual(lol.shippedByNid, lol2.shippedByNid)
        XCTAssertEqual(lol.stagedDate, lol2.stagedDate)
        XCTAssertEqual(lol.stagedByNid, lol2.stagedByNid)
        XCTAssertEqual(lol.verifiedDate, lol2.verifiedDate)
        XCTAssertEqual(lol.verifiedByNid, lol2.verifiedByNid)
        XCTAssertEqual(lol.voidedDate, lol2.voidedDate)
        XCTAssertEqual(lol.voidedByNid, lol2.voidedByNid)
        XCTAssertEqual(lol.loadNumber, lol2.loadNumber)
        XCTAssertEqual(lol.toEquipNid, lol2.toEquipNid)
        XCTAssertEqual(lol.isVendingReplenishment, lol2.isVendingReplenishment)
        XCTAssertEqual(lol.replenishmentVendTicketNumber, lol2.replenishmentVendTicketNumber)
        XCTAssertEqual(lol.isCoopDeliveryPoint, lol2.isCoopDeliveryPoint)
        XCTAssertEqual(lol.coopCusNid, lol2.coopCusNid)
        XCTAssertEqual(lol.doNotOptimizePalletsWithLayerRounding, lol2.doNotOptimizePalletsWithLayerRounding)
        XCTAssertEqual(lol.returnsValidated, lol2.returnsValidated)
        XCTAssertEqual(lol.POAAmount, lol2.POAAmount)
        XCTAssertEqual(lol.POAExpected, lol2.POAExpected)
        XCTAssertEqual(lol.includeChargeOrderInTotalDue, lol2.includeChargeOrderInTotalDue)
        XCTAssertEqual(lol.deliverySequence, lol2.deliverySequence)
        XCTAssertEqual(lol.orderDEXStatus, lol2.orderDEXStatus)
        XCTAssertEqual(lol.isForPlanogramReset, lol2.isForPlanogramReset)
        XCTAssertEqual(lol.manualHold, lol2.manualHold)
        XCTAssertEqual(lol.pushOffDate, lol2.pushOffDate)
        XCTAssertEqual(lol.drvEmpNid, lol2.drvEmpNid)
        XCTAssertEqual(lol.slsEmpNid, lol2.slsEmpNid)
        XCTAssertEqual(lol.orderTypeNid, lol2.orderTypeNid)
        XCTAssertEqual(lol.isBillAndHold, lol2.isBillAndHold)
        XCTAssertEqual(lol.paymentTermsNid, lol2.paymentTermsNid)
        XCTAssertEqual(lol.isBulkOrder, lol2.isBulkOrder)
        XCTAssertEqual(lol.isCharge, lol2.isCharge)
        XCTAssertEqual(lol.isTaxable, lol2.isTaxable)
        XCTAssertEqual(lol.usedCombinedForm, lol2.usedCombinedForm)
        XCTAssertEqual(lol.isEft, lol2.isEft)
        XCTAssertEqual(lol.poNumber, lol2.poNumber)
        XCTAssertEqual(lol.takenFrom, lol2.takenFrom)
        XCTAssertEqual(lol.invoiceNote, lol2.invoiceNote)
        XCTAssertEqual(lol.packNote, lol2.packNote)
        XCTAssertEqual(lol.serializedItems, lol2.serializedItems)
        XCTAssertEqual(lol.receivedBy, lol2.receivedBy)
        XCTAssertEqual(lol.pushOffReason, lol2.pushOffReason)
        XCTAssertEqual(lol.skipReason, lol2.skipReason)
        XCTAssertEqual(lol.voidReason, lol2.voidReason)
        XCTAssertEqual(lol.offInvoiceDiscPct, lol2.offInvoiceDiscPct)
        XCTAssertEqual(lol.discountAmt, lol2.discountAmt)
        XCTAssertEqual(lol.totalFreight, lol2.totalFreight)
        XCTAssertEqual(lol.isExistingOrder, lol2.isExistingOrder)
        XCTAssertEqual(lol.printedReviewInvoice, lol2.printedReviewInvoice)
        XCTAssertEqual(lol.voidReasonNid, lol2.voidReasonNid)
        XCTAssertEqual(lol.entryTime, lol2.entryTime)
        XCTAssertEqual(lol.deliveredByHandheld, lol2.deliveredByHandheld)
        XCTAssertEqual(lol.isOffTruck, lol2.isOffTruck)
        XCTAssertEqual(lol.isFromBlobbing, lol2.isFromBlobbing)
        XCTAssertEqual(lol.salesTax, lol2.salesTax)
        XCTAssertEqual(lol.salesTaxState, lol2.salesTaxState)
        XCTAssertEqual(lol.salesTaxStateB, lol2.salesTaxStateB)
        XCTAssertEqual(lol.salesTaxStateC, lol2.salesTaxStateC)
        XCTAssertEqual(lol.salesTaxCounty, lol2.salesTaxCounty)
        XCTAssertEqual(lol.salesTaxCity, lol2.salesTaxCity)
        XCTAssertEqual(lol.salesTaxLocal, lol2.salesTaxLocal)
        XCTAssertEqual(lol.salesTaxWholesale, lol2.salesTaxWholesale)
        XCTAssertEqual(lol.VAT, lol2.VAT)
        XCTAssertEqual(lol.levy, lol2.levy)

    }

}

fileprivate extension LegacyOrder {
    func seed(_ v: SeedValues) {
        
        transactionCurrencyNid = Currency.ZAR.currencyNid
        companyNid = v.int
        orderNumber = v.nullableInt
        whseNid = v.int
        trkNid = v.nullableInt
        toCusNid = v.int
        isFromDistributor = v.bool
        isToDistributor = v.bool
        deliveryChargeNid = v.nullableInt
        isAutoDeliveryCharge = v.bool
        isEarlyPay = v.bool
        earlyPayDiscountAmt = v.nullableMoney
        termDiscountDays = v.nullableInt
        termDiscountPct = v.nullableInt
        heldStatus = v.bool
        isVoided = v.bool
        deliveredStatus = v.bool
        orderType = .DeliveryOfDownloadedOrder
        isHotShot = v.bool
        numberSummarized = v.nullableInt
        summaryOrderNumber = v.nullableInt
        coopTicketNumber = v.nullableInt
        shipAdr1 = v.nullableString
        shipAdr2 = v.nullableString
        shipCity = v.nullableString
        shipState = v.nullableString
        shipZip = v.nullableString
        doNotChargeUnitFreight = v.bool
        doNotChargeUnitDeliveryCharge = v.bool
        ignoreDeliveryTruckRestrictions = v.bool
        signatureVectors = v.nullableString
        driverSignatureVectors = v.nullableString
        isOffScheduleDelivery = v.bool
        isSpecialPaymentTerms = v.bool
        promoDate = v.nullableDate
        authenticatedByNid = v.nullableInt
        authenticatedDate = v.nullableDate
        deliveredDate = v.nullableDate
        deliveredByNid = v.nullableInt
        deliveryDocumentDate = v.nullableDate
        deliveryDocumentByNid = v.nullableInt
        dispatchedDate = v.nullableDate
        dispatchedByNid = v.nullableInt
        ediInvoiceDate = v.nullableDate
        ediInvoiceByNid = v.nullableInt
        ediPaymentDate = v.nullableDate
        ediPaymentByNid = v.nullableInt
        ediShipNoticeDate = v.nullableDate
        ediShipNoticeByNid = v.nullableInt
        enteredDate = v.nullableDate
        enteredByNid = v.nullableInt
        followupInvoiceDate = v.nullableDate
        followupInvoiceByNid = v.nullableInt
        loadedDate = v.nullableDate
        loadedByNid = v.nullableInt
        orderedDate = v.date
        orderedByNid = v.nullableInt
        palletizedDate = v.nullableDate
        palletizedByNid = v.nullableInt
        pickListDate = v.nullableDate
        pickListByNid = v.nullableInt
        shippedDate = v.date
        shippedByNid = v.nullableInt
        stagedDate = v.nullableDate
        stagedByNid = v.nullableInt
        verifiedDate = v.nullableDate
        verifiedByNid = v.nullableInt
        voidedDate = v.nullableDate
        voidedByNid = v.nullableInt
        loadNumber = v.nullableInt
        toEquipNid = v.nullableInt
        isVendingReplenishment = v.bool
        replenishmentVendTicketNumber = v.nullableInt
        isCoopDeliveryPoint = v.bool
        coopCusNid = v.nullableInt
        doNotOptimizePalletsWithLayerRounding = v.bool
        returnsValidated = v.bool
        POAAmount = v.nullableMoney
        POAExpected = v.nullableMoney
        includeChargeOrderInTotalDue = v.bool
        deliverySequence = v.nullableInt
        orderDEXStatus = .NotApplicable
        isForPlanogramReset = v.bool
        manualHold = v.bool
        pushOffDate = v.nullableDate
        drvEmpNid = v.nullableInt
        slsEmpNid = v.nullableInt
        orderTypeNid = v.nullableInt
        isBillAndHold = v.bool
        paymentTermsNid = v.nullableInt
        isBulkOrder = v.bool
        isCharge = v.bool
        isTaxable = v.bool
        usedCombinedForm = v.bool
        isEft = v.bool
        poNumber = v.nullableString
        takenFrom = v.nullableString
        invoiceNote = v.nullableString ?? ""
        packNote = v.nullableString
        serializedItems = v.nullableString
        receivedBy = v.nullableString
        pushOffReason = v.nullableString
        skipReason = v.nullableString
        voidReason = v.nullableString
        offInvoiceDiscPct = v.nullableInt
        discountAmt = v.nullableMoney
        totalFreight = v.nullableMoney
        isExistingOrder = v.bool
        printedReviewInvoice = v.bool
        voidReasonNid = v.nullableInt
        entryTime = v.nullableDate
        deliveredByHandheld = v.bool
        isOffTruck = v.bool
        isFromBlobbing = v.bool
        salesTax = v.nullableMoney
        salesTaxState = v.nullableMoney
        salesTaxStateB = v.nullableMoney
        salesTaxStateC = v.nullableMoney
        salesTaxCounty = v.nullableMoney
        salesTaxCity = v.nullableMoney
        salesTaxLocal = v.nullableMoney
        salesTaxWholesale = v.nullableMoney
        VAT = v.nullableMoney
        levy = v.nullableMoney

        
        orderNumbersForPartitioner = []
        deliveryInfos = []
        lines = []
    }
}
