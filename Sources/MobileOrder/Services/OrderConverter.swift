//  Created by Michael Rutherford on 2/17/21.

import Foundation

import Foundation
import MobileLegacyOrder
import MobileDownload
import MoneyAndExchangeRates

struct OrderConverter {
    static func getLegacyOrder(_ order: Order) -> LegacyOrder {
        
        let mobileOrder = LegacyOrder()
        
        mobileOrder.convertFromPresellOrder(order: order)
        
        return mobileOrder
    }
}

fileprivate extension LegacyOrder {
    
    func convertFromPresellOrder(order: Order) {

        transactionCurrencyNid = order.transactionCurrency.currencyNid
        whseNid = order.shipFromWhseNid
        toCusNid = order.cusNid
        promoDate = order.promoDate
        shippedDate = order.deliveryDate
        invoiceNote = order.deliveryNote
        lines = order.lines.flatMap { line in OrderLineConverter.getLegacyOrderLines(line) }
        
        companyNid = 1
        orderType = .FreshPresellOrder
        
        orderNumber = 0
        trkNid = nil
        isFromDistributor = false
        isToDistributor = false
        deliveryChargeNid = nil
        isAutoDeliveryCharge = true
        isEarlyPay = false
        earlyPayDiscountAmt = nil
        termDiscountDays = nil
        termDiscountPct = nil
        heldStatus = false
        isVoided = false
        deliveredStatus = false
        isHotShot = false
        numberSummarized = nil
        summaryOrderNumber = nil
        coopTicketNumber = nil
        shipAdr1 = nil
        shipAdr2 = nil
        shipCity = nil
        shipState = nil
        shipZip = nil
        doNotChargeUnitFreight = false
        doNotChargeUnitDeliveryCharge = false
        ignoreDeliveryTruckRestrictions = false
        signatureVectors = nil
        driverSignatureVectors = nil
        isOffScheduleDelivery = false
        isSpecialPaymentTerms = false
        authenticatedByNid = nil
        authenticatedDate = nil
        deliveredDate = nil
        deliveredByNid = nil
        deliveryDocumentDate = nil
        deliveryDocumentByNid = nil
        dispatchedDate = nil
        dispatchedByNid = nil
        ediInvoiceDate = nil
        ediInvoiceByNid = nil
        ediPaymentDate = nil
        ediPaymentByNid = nil
        ediShipNoticeDate = nil
        ediShipNoticeByNid = nil
        enteredDate = nil
        enteredByNid = nil
        followupInvoiceDate = nil
        followupInvoiceByNid = nil
        loadedDate = nil
        loadedByNid = nil
        orderedDate = nil
        orderedByNid = nil
        palletizedDate = nil
        palletizedByNid = nil
        pickListDate = nil
        pickListByNid = nil
        shippedByNid = nil
        stagedDate = nil
        stagedByNid = nil
        verifiedDate = nil
        verifiedByNid = nil
        voidedDate = nil
        voidedByNid = nil
        loadNumber = nil
        toEquipNid = nil
        isVendingReplenishment = false
        replenishmentVendTicketNumber = nil
        isCoopDeliveryPoint = false
        coopCusNid = nil
        doNotOptimizePalletsWithLayerRounding = false
        returnsValidated = false
        POAAmount = nil
        POAExpected = nil
        includeChargeOrderInTotalDue = false
        deliverySequence = nil
        orderDEXStatus = nil
        isForPlanogramReset = false
        manualHold = false
        pushOffDate = nil
        drvEmpNid = nil
        slsEmpNid = nil
        orderTypeNid = nil
        isBillAndHold = false
        paymentTermsNid = nil
        isBulkOrder = false
        isCharge = false
        isTaxable = false
        usedCombinedForm = false
        isEft = false
        poNumber = nil
        takenFrom = nil
        packNote = nil
        serializedItems = nil
        receivedBy = nil
        pushOffReason = nil
        skipReason = nil
        voidReason = nil
        offInvoiceDiscPct = nil
        discountAmt = nil
        totalFreight = nil
        isExistingOrder = false
        printedReviewInvoice = false
        voidReasonNid = nil
        entryTime = nil
        deliveredByHandheld = false
        isOffTruck = false
        isFromBlobbing = false
        salesTax = nil
        salesTaxState = nil
        salesTaxStateB = nil
        salesTaxStateC = nil
        salesTaxCounty = nil
        salesTaxCity = nil
        salesTaxLocal = nil
        salesTaxWholesale = nil
        VAT = nil
        levy = nil
        
        orderNumbersForPartitioner = []
        deliveryInfos = []
    }
}
