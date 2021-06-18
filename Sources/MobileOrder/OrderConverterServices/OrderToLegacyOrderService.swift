//  Created by Michael Rutherford on 2/17/21.

import Foundation

import Foundation
import MobileLegacyOrder
import MobileDownload
import MoneyAndExchangeRates

public struct OrderToLegacyOrderService {
    public static func getLegacyOrder(_ order: Order) -> LegacyOrder {
        
        let legacyOrder = LegacyOrder()
        
        legacyOrder.convertFromOrder(order: order)
        
        return legacyOrder
    }
}

fileprivate extension LegacyOrder {
    
    func convertFromOrder(order: Order) {
        
        //hack: these should be in the new Order object
        entryTime = Date()
        enteredDate = entryTime
        enteredByNid = order.slsEmpNid
        

        orderNumber = order.orderNumber
        transactionCurrencyNid = order.transactionCurrency.currencyNid
        whseNid = order.shipFromWhseNid
        toCusNid = order.cusNid
        promoDate = order.promoOverrideDate
        shippedDate = order.deliveryDate
        invoiceNote = order.deliveryNote
        
        companyNid = order.companyNid
        trkNid = order.trkNid
        drvEmpNid = order.drvEmpNid
        slsEmpNid = order.slsEmpNid
        orderTypeNid = order.orderTypeNid
        orderType = order.orderType
        
        orderedDate = order.orderedDate

        lines = order.lines.flatMap { line in OrderLineToLegacyOrderLineService.getLegacyOrderLines(line) }
        
        applyLogEntriesToLegacyOrder(logEntries: order.logEntries)
        
        if let voidingEntry = order.voidingEntry {
            isVoided = voidingEntry.isVoided // mpr: we're treating this as a "force-void" even if the other things are nil
            voidedDate = voidingEntry.voidedDate
            voidedByNid = voidingEntry.voidedByNid
            voidReason = voidingEntry.voidReason
            voidReasonNid = voidingEntry.voidReasonNid
        }
        
        shipAdr1 = order.deliveryInfo.shipAdr1
        shipAdr2 = order.deliveryInfo.shipAdr2
        shipCity = order.deliveryInfo.shipCity
        shipState = order.deliveryInfo.shipState
        shipZip = order.deliveryInfo.shipZip
        
        loadNumber = order.deliveryRouteInfo.loadNumber
        deliverySequence = order.deliveryRouteInfo.deliverySequence
        isBulkOrder = order.deliveryRouteInfo.isBulkOrder
        isOffScheduleDelivery = order.deliveryRouteInfo.isOffScheduleDelivery
        
        paymentTermsNid = order.paymentTermsInfo.paymentTermsNid
        isCharge = order.paymentTermsInfo.isCharge
        isEft = order.paymentTermsInfo.isEFT
        termDiscountPct = order.paymentTermsInfo.termDiscountPct
        termDiscountDays = order.paymentTermsInfo.termDiscountDays

        isFromDistributor = false
        isToDistributor = false
        deliveryChargeNid = nil
        isAutoDeliveryCharge = true
        isEarlyPay = false
        earlyPayDiscountAmt = nil
        heldStatus = false
        deliveredStatus = false
        isHotShot = false
        numberSummarized = nil
        summaryOrderNumber = nil
        coopTicketNumber = nil

        doNotChargeUnitFreight = false
        doNotChargeUnitDeliveryCharge = false
        ignoreDeliveryTruckRestrictions = false
        signatureVectors = nil
        driverSignatureVectors = nil
        isSpecialPaymentTerms = false

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
        orderDEXStatus = nil
        isForPlanogramReset = false
        manualHold = false
        pushOffDate = nil
        isBillAndHold = false
        isTaxable = false
        usedCombinedForm = false
        poNumber = nil
        takenFrom = nil
        packNote = nil
        serializedItems = nil
        receivedBy = nil
        pushOffReason = nil
        skipReason = nil
        offInvoiceDiscPct = nil
        discountAmt = nil
        totalFreight = nil
        isExistingOrder = false
        printedReviewInvoice = false
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
