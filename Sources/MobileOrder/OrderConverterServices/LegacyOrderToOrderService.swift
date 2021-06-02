//
//  File.swift
//  
//
//  Created by Michael Rutherford on 4/16/21.
//

import Foundation
import MobileLegacyOrder
import MobileDownload
import MoneyAndExchangeRates


public struct LegacyOrderToOrderService {
    public static func getOrder(legacyOrder: LegacyOrder) -> Order? {
        
        let deliveryDate = legacyOrder.deliveredDate ?? legacyOrder.orderedDate
        
        let order = Order(orderNumber: legacyOrder.orderNumber, shipFromWhseNid: legacyOrder.whseNid, cusNid: legacyOrder.toCusNid, deliveryDate: deliveryDate, lines: [])
        
        order.convertFromLegacyOrder(legacyOrder: legacyOrder)
        
        return order
    }
}

fileprivate extension Order {

    func convertFromLegacyOrder(legacyOrder: LegacyOrder) {
        
        func error(_ message: String) {
            conversionErrors.append(message)
            print("ERROR: Cannot convert from legacyOrder #\(legacyOrder.orderNumber ?? 0): \(message)")
        }
        
        orderNumber = legacyOrder.orderNumber
        transactionCurrency = Currency(currencyNid: legacyOrder.transactionCurrencyNid) ?? .USD
        shipFromWhseNid = legacyOrder.whseNid
        cusNid = legacyOrder.toCusNid
        promoOverrideDate = legacyOrder.promoDate
        deliveryDate = legacyOrder.shippedDate
        deliveryNote = legacyOrder.invoiceNote
        
        companyNid = legacyOrder.companyNid
        trkNid = legacyOrder.trkNid
        drvEmpNid = legacyOrder.drvEmpNid
        slsEmpNid = legacyOrder.slsEmpNid
        orderTypeNid = legacyOrder.orderTypeNid
        orderType = legacyOrder.orderType
        orderedDate = legacyOrder.orderedDate

        lines = legacyOrder.lines.compactMap { line in LegacyOrderLineToOrderLineService.getOrderLine(orderNumber: legacyOrder.orderNumber ?? 0, legacyOrderLine: line) }
        
        transactionCurrency = .init(currencyNid: legacyOrder.transactionCurrencyNid) ?? .USD
        orderedDate = legacyOrder.orderedDate
        
        logEntries = legacyOrder.getLogEntriesFromLegacyOrder()
        
        if legacyOrder.isVoided || legacyOrder.voidedDate != nil || legacyOrder.voidedByNid != nil || legacyOrder.voidReason != nil || legacyOrder.voidReasonNid != nil {
            voidingEntry = OrderVoidingEntry(isVoided: legacyOrder.isVoided, voidedDate: legacyOrder.voidedDate, voidedByNid: legacyOrder.voidedByNid, voidReason: legacyOrder.voidReason, voidReasonNid: legacyOrder.voidReasonNid)
        }
        
        deliveryInfo = OrderDeliveryInfo(shipAdr1: legacyOrder.shipAdr1, shipAdr2: legacyOrder.shipAdr2, shipCity: legacyOrder.shipCity, shipState: legacyOrder.shipState, shipZip: legacyOrder.shipZip)
        
        deliveryRouteInfo = .init(loadNumber: legacyOrder.loadNumber, deliverySequence: legacyOrder.deliverySequence, isBulkOrder: legacyOrder.isBulkOrder, isOffScheduleDelivery: legacyOrder.isOffScheduleDelivery)
        
        paymentTermsInfo = .init(paymentTermsNid: legacyOrder.paymentTermsNid, isCharge: legacyOrder.isCharge, isEFT: legacyOrder.isEft, termDiscountDays: legacyOrder.termDiscountDays, termDiscountPct: legacyOrder.termDiscountPct)
        

        if legacyOrder.isFromDistributor != false { error("isFromDistributor = '\(legacyOrder.isFromDistributor)'") }
        if legacyOrder.isToDistributor != false { error("isToDistributor = '\(legacyOrder.isToDistributor)'") }
        if legacyOrder.deliveryChargeNid != nil { error("deliveryChargeNid = '\(legacyOrder.deliveryChargeNid!)'") }
        if legacyOrder.isAutoDeliveryCharge != false { error("isAutoDeliveryCharge = '\(legacyOrder.isAutoDeliveryCharge)'") }
        if legacyOrder.isEarlyPay != false { error("isEarlyPay = '\(legacyOrder.isEarlyPay)'") }
        if legacyOrder.earlyPayDiscountAmt != nil { error("earlyPayDiscountAmt = '\(legacyOrder.earlyPayDiscountAmt!)'") }
        if legacyOrder.heldStatus != false { error("heldStatus = '\(legacyOrder.heldStatus)'") }
        if legacyOrder.deliveredStatus != false { error("deliveredStatus = '\(legacyOrder.deliveredStatus)'") }
        if legacyOrder.isHotShot != false { error("isHotShot = '\(legacyOrder.isHotShot)'") }
        if legacyOrder.numberSummarized != nil { error("numberSummarized = '\(legacyOrder.numberSummarized!)'") }
        if legacyOrder.summaryOrderNumber != nil { error("summaryOrderNumber = '\(legacyOrder.summaryOrderNumber!)'") }
        if legacyOrder.coopTicketNumber != nil { error("coopTicketNumber = '\(legacyOrder.coopTicketNumber!)'") }
        if legacyOrder.doNotChargeUnitFreight != false { error("doNotChargeUnitFreight = '\(legacyOrder.doNotChargeUnitFreight)'") }
        if legacyOrder.doNotChargeUnitDeliveryCharge != false { error("doNotChargeUnitDeliveryCharge = '\(legacyOrder.doNotChargeUnitDeliveryCharge)'") }
        if legacyOrder.ignoreDeliveryTruckRestrictions != false { error("ignoreDeliveryTruckRestrictions = '\(legacyOrder.ignoreDeliveryTruckRestrictions)'") }
        if legacyOrder.signatureVectors != nil { error("signatureVectors = '\(legacyOrder.signatureVectors!)'") }
        if legacyOrder.driverSignatureVectors != nil { error("driverSignatureVectors = '\(legacyOrder.driverSignatureVectors!)'") }
        if legacyOrder.isSpecialPaymentTerms != false { error("isSpecialPaymentTerms = '\(legacyOrder.isSpecialPaymentTerms)'") }
        if legacyOrder.promoDate != nil { error("promoDate = '\(legacyOrder.promoDate!)'") }
        if legacyOrder.toEquipNid != nil { error("toEquipNid = '\(legacyOrder.toEquipNid!)'") }
        if legacyOrder.isVendingReplenishment != false { error("isVendingReplenishment = '\(legacyOrder.isVendingReplenishment)'") }
        if legacyOrder.replenishmentVendTicketNumber != nil { error("replenishmentVendTicketNumber = '\(legacyOrder.replenishmentVendTicketNumber!)'") }
        if legacyOrder.isCoopDeliveryPoint != false { error("isCoopDeliveryPoint = '\(legacyOrder.isCoopDeliveryPoint)'") }
        if legacyOrder.coopCusNid != nil { error("coopCusNid = '\(legacyOrder.coopCusNid!)'") }
        if legacyOrder.doNotOptimizePalletsWithLayerRounding != false { error("doNotOptimizePalletsWithLayerRounding = '\(legacyOrder.doNotOptimizePalletsWithLayerRounding)'") }
        if legacyOrder.returnsValidated != false { error("returnsValidated = '\(legacyOrder.returnsValidated)'") }
        if legacyOrder.POAAmount != nil { error("POAAmount = '\(legacyOrder.POAAmount!)'") }
        if legacyOrder.POAExpected != nil { error("POAExpected = '\(legacyOrder.POAExpected!)'") }
        if legacyOrder.includeChargeOrderInTotalDue != false { error("includeChargeOrderInTotalDue = '\(legacyOrder.includeChargeOrderInTotalDue)'") }
        if legacyOrder.orderDEXStatus != nil && legacyOrder.orderDEXStatus != .NotApplicable { error("orderDEXStatus = '\(legacyOrder.orderDEXStatus!)'") }
        if legacyOrder.isForPlanogramReset != false { error("isForPlanogramReset = '\(legacyOrder.isForPlanogramReset)'") }
        if legacyOrder.manualHold != false { error("manualHold = '\(legacyOrder.manualHold)'") }
        if legacyOrder.pushOffDate != nil { error("pushOffDate = '\(legacyOrder.pushOffDate!)'") }
        if legacyOrder.isBillAndHold != false { error("isBillAndHold = '\(legacyOrder.isBillAndHold)'") }
        if legacyOrder.isTaxable != false { error("isTaxable = '\(legacyOrder.isTaxable)'") }
        if legacyOrder.usedCombinedForm != false { error("usedCombinedForm = '\(legacyOrder.usedCombinedForm)'") }
        if legacyOrder.poNumber != nil { error("poNumber = '\(legacyOrder.poNumber!)'") }
        if legacyOrder.takenFrom != nil { error("takenFrom = '\(legacyOrder.takenFrom!)'") }
        if legacyOrder.packNote != nil { error("packNote = '\(legacyOrder.packNote!)'") }
        if legacyOrder.serializedItems != nil { error("serializedItems = '\(legacyOrder.serializedItems!)'") }
        if legacyOrder.receivedBy != nil { error("receivedBy = '\(legacyOrder.receivedBy!)'") }
        if legacyOrder.pushOffReason != nil { error("pushOffReason = '\(legacyOrder.pushOffReason!)'") }
        if legacyOrder.skipReason != nil { error("skipReason = '\(legacyOrder.skipReason!)'") }
        if legacyOrder.offInvoiceDiscPct != nil { error("offInvoiceDiscPct = '\(legacyOrder.offInvoiceDiscPct!)'") }
        if legacyOrder.discountAmt != nil { error("discountAmt = '\(legacyOrder.discountAmt!)'") }
        if legacyOrder.totalFreight != nil { error("totalFreight = '\(legacyOrder.totalFreight!)'") }
        if legacyOrder.isExistingOrder != false { error("isExistingOrder = '\(legacyOrder.isExistingOrder)'") }
        if legacyOrder.printedReviewInvoice != false { error("printedReviewInvoice = '\(legacyOrder.printedReviewInvoice)'") }
        if legacyOrder.entryTime != nil { error("entryTime = '\(legacyOrder.entryTime!)'") }
        if legacyOrder.deliveredByHandheld != false { error("deliveredByHandheld = '\(legacyOrder.deliveredByHandheld)'") }
        if legacyOrder.isOffTruck != false { error("isOffTruck = '\(legacyOrder.isOffTruck)'") }
        if legacyOrder.isFromBlobbing != false { error("isFromBlobbing = '\(legacyOrder.isFromBlobbing)'") }
        if legacyOrder.salesTax != nil { error("salesTax = '\(legacyOrder.salesTax!)'") }
        if legacyOrder.salesTaxState != nil { error("salesTaxState = '\(legacyOrder.salesTaxState!)'") }
        if legacyOrder.salesTaxStateB != nil && legacyOrder.salesTaxStateB != .zero { error("salesTaxStateB = '\(legacyOrder.salesTaxStateB!)'") }
        if legacyOrder.salesTaxStateC != nil && legacyOrder.salesTaxStateC != .zero { error("salesTaxStateC = '\(legacyOrder.salesTaxStateC!)'") }
        if legacyOrder.salesTaxCounty != nil { error("salesTaxCounty = '\(legacyOrder.salesTaxCounty!)'") }
        if legacyOrder.salesTaxCity != nil { error("salesTaxCity = '\(legacyOrder.salesTaxCity!)'") }
        if legacyOrder.salesTaxLocal != nil { error("salesTaxLocal = '\(legacyOrder.salesTaxLocal!)'") }
        if legacyOrder.salesTaxWholesale != nil { error("salesTaxWholesale = '\(legacyOrder.salesTaxWholesale!)'") }
        if legacyOrder.VAT != nil { error("VAT = '\(legacyOrder.VAT!)'") }
        if legacyOrder.levy != nil { error("levy = '\(legacyOrder.levy!)'") }

    }
}
    
