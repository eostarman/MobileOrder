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
        
        let order = Order(shipFromWhseNid: legacyOrder.whseNid, cusNid: legacyOrder.toCusNid, deliveryDate: deliveryDate, lines: [])
        
        order.convertFromLegacyOrder(legacyOrder: legacyOrder)
        
        return order
    }
}

fileprivate extension Order {

    func convertFromLegacyOrder(legacyOrder: LegacyOrder) {
        
        func error(_ message: String) {
            print("ERROR: Cannot convert from legacyOrder #\(legacyOrder.orderNumber): \(message)")
        }
        
        lines = legacyOrder.lines.compactMap { line in LegacyOrderLineToOrderLineService.getOrderLine(orderNumber: legacyOrder.orderNumber, legacyOrderLine: line) }
        
        transactionCurrency = .init(currencyNid: legacyOrder.transactionCurrencyNid) ?? .USD
        orderedDate = legacyOrder.orderedDate
        
        if legacyOrder.companyNid != 1 { error("companyNid = '\(legacyOrder.companyNid)'") }
        if legacyOrder.trkNid != nil { error("trkNid = '\(legacyOrder.trkNid!)'") }
        if legacyOrder.isFromDistributor != false { error("isFromDistributor = '\(legacyOrder.isFromDistributor)'") }
        if legacyOrder.isToDistributor != false { error("isToDistributor = '\(legacyOrder.isToDistributor)'") }
        if legacyOrder.deliveryChargeNid != nil { error("deliveryChargeNid = '\(legacyOrder.deliveryChargeNid!)'") }
        if legacyOrder.isAutoDeliveryCharge != false { error("isAutoDeliveryCharge = '\(legacyOrder.isAutoDeliveryCharge)'") }
        if legacyOrder.isEarlyPay != false { error("isEarlyPay = '\(legacyOrder.isEarlyPay)'") }
        if legacyOrder.earlyPayDiscountAmt != nil { error("earlyPayDiscountAmt = '\(legacyOrder.earlyPayDiscountAmt!)'") }
        if legacyOrder.termDiscountDays != nil { error("termDiscountDays = '\(legacyOrder.termDiscountDays!)'") }
        if legacyOrder.termDiscountPct != nil { error("termDiscountPct = '\(legacyOrder.termDiscountPct!)'") }
        if legacyOrder.heldStatus != false { error("heldStatus = '\(legacyOrder.heldStatus)'") }
        if legacyOrder.isVoided != false { error("isVoided = '\(legacyOrder.isVoided)'") }
        if legacyOrder.deliveredStatus != false { error("deliveredStatus = '\(legacyOrder.deliveredStatus)'") }
        if legacyOrder.orderType != nil { error("orderType = '\(legacyOrder.orderType!)'") }
        if legacyOrder.isHotShot != false { error("isHotShot = '\(legacyOrder.isHotShot)'") }
        if legacyOrder.numberSummarized != nil { error("numberSummarized = '\(legacyOrder.numberSummarized!)'") }
        if legacyOrder.summaryOrderNumber != nil { error("summaryOrderNumber = '\(legacyOrder.summaryOrderNumber!)'") }
        if legacyOrder.coopTicketNumber != nil { error("coopTicketNumber = '\(legacyOrder.coopTicketNumber!)'") }
        if legacyOrder.shipAdr1 != nil { error("shipAdr1 = '\(legacyOrder.shipAdr1!)'") }
        if legacyOrder.shipAdr2 != nil { error("shipAdr2 = '\(legacyOrder.shipAdr2!)'") }
        if legacyOrder.shipCity != nil { error("shipCity = '\(legacyOrder.shipCity!)'") }
        if legacyOrder.shipState != nil { error("shipState = '\(legacyOrder.shipState!)'") }
        if legacyOrder.shipZip != nil { error("shipZip = '\(legacyOrder.shipZip!)'") }
        if legacyOrder.doNotChargeUnitFreight != false { error("doNotChargeUnitFreight = '\(legacyOrder.doNotChargeUnitFreight)'") }
        if legacyOrder.doNotChargeUnitDeliveryCharge != false { error("doNotChargeUnitDeliveryCharge = '\(legacyOrder.doNotChargeUnitDeliveryCharge)'") }
        if legacyOrder.ignoreDeliveryTruckRestrictions != false { error("ignoreDeliveryTruckRestrictions = '\(legacyOrder.ignoreDeliveryTruckRestrictions)'") }
        if legacyOrder.signatureVectors != nil { error("signatureVectors = '\(legacyOrder.signatureVectors!)'") }
        if legacyOrder.driverSignatureVectors != nil { error("driverSignatureVectors = '\(legacyOrder.driverSignatureVectors!)'") }
        if legacyOrder.isOffScheduleDelivery != false { error("isOffScheduleDelivery = '\(legacyOrder.isOffScheduleDelivery)'") }
        if legacyOrder.isSpecialPaymentTerms != false { error("isSpecialPaymentTerms = '\(legacyOrder.isSpecialPaymentTerms)'") }
        if legacyOrder.promoDate != nil { error("promoDate = '\(legacyOrder.promoDate!)'") }
        if legacyOrder.authenticatedByNid != nil { error("authenticatedByNid = '\(legacyOrder.authenticatedByNid!)'") }
        if legacyOrder.authenticatedDate != nil { error("authenticatedDate = '\(legacyOrder.authenticatedDate!)'") }
        if legacyOrder.deliveredDate != nil { error("deliveredDate = '\(legacyOrder.deliveredDate!)'") }
        if legacyOrder.deliveredByNid != nil { error("deliveredByNid = '\(legacyOrder.deliveredByNid!)'") }
        if legacyOrder.deliveryDocumentDate != nil { error("deliveryDocumentDate = '\(legacyOrder.deliveryDocumentDate!)'") }
        if legacyOrder.deliveryDocumentByNid != nil { error("deliveryDocumentByNid = '\(legacyOrder.deliveryDocumentByNid!)'") }
        if legacyOrder.dispatchedDate != nil { error("dispatchedDate = '\(legacyOrder.dispatchedDate!)'") }
        if legacyOrder.dispatchedByNid != nil { error("dispatchedByNid = '\(legacyOrder.dispatchedByNid!)'") }
        if legacyOrder.ediInvoiceDate != nil { error("ediInvoiceDate = '\(legacyOrder.ediInvoiceDate!)'") }
        if legacyOrder.ediInvoiceByNid != nil { error("ediInvoiceByNid = '\(legacyOrder.ediInvoiceByNid!)'") }
        if legacyOrder.ediPaymentDate != nil { error("ediPaymentDate = '\(legacyOrder.ediPaymentDate!)'") }
        if legacyOrder.ediPaymentByNid != nil { error("ediPaymentByNid = '\(legacyOrder.ediPaymentByNid!)'") }
        if legacyOrder.ediShipNoticeDate != nil { error("ediShipNoticeDate = '\(legacyOrder.ediShipNoticeDate!)'") }
        if legacyOrder.ediShipNoticeByNid != nil { error("ediShipNoticeByNid = '\(legacyOrder.ediShipNoticeByNid!)'") }
        if legacyOrder.enteredDate != nil { error("enteredDate = '\(legacyOrder.enteredDate!)'") }
        if legacyOrder.enteredByNid != nil { error("enteredByNid = '\(legacyOrder.enteredByNid!)'") }
        if legacyOrder.followupInvoiceDate != nil { error("followupInvoiceDate = '\(legacyOrder.followupInvoiceDate!)'") }
        if legacyOrder.followupInvoiceByNid != nil { error("followupInvoiceByNid = '\(legacyOrder.followupInvoiceByNid!)'") }
        if legacyOrder.loadedDate != nil { error("loadedDate = '\(legacyOrder.loadedDate!)'") }
        if legacyOrder.loadedByNid != nil { error("loadedByNid = '\(legacyOrder.loadedByNid!)'") }
        if legacyOrder.orderedByNid != nil { error("orderedByNid = '\(legacyOrder.orderedByNid!)'") }
        if legacyOrder.palletizedDate != nil { error("palletizedDate = '\(legacyOrder.palletizedDate!)'") }
        if legacyOrder.palletizedByNid != nil { error("palletizedByNid = '\(legacyOrder.palletizedByNid!)'") }
        if legacyOrder.pickListDate != nil { error("pickListDate = '\(legacyOrder.pickListDate!)'") }
        if legacyOrder.pickListByNid != nil { error("pickListByNid = '\(legacyOrder.pickListByNid!)'") }
        if legacyOrder.shippedDate != nil { error("shippedDate = '\(legacyOrder.shippedDate!)'") }
        if legacyOrder.shippedByNid != nil { error("shippedByNid = '\(legacyOrder.shippedByNid!)'") }
        if legacyOrder.stagedDate != nil { error("stagedDate = '\(legacyOrder.stagedDate!)'") }
        if legacyOrder.stagedByNid != nil { error("stagedByNid = '\(legacyOrder.stagedByNid!)'") }
        if legacyOrder.verifiedDate != nil { error("verifiedDate = '\(legacyOrder.verifiedDate!)'") }
        if legacyOrder.verifiedByNid != nil { error("verifiedByNid = '\(legacyOrder.verifiedByNid!)'") }
        if legacyOrder.voidedDate != nil { error("voidedDate = '\(legacyOrder.voidedDate!)'") }
        if legacyOrder.voidedByNid != nil { error("voidedByNid = '\(legacyOrder.voidedByNid!)'") }
        if legacyOrder.loadNumber != nil { error("loadNumber = '\(legacyOrder.loadNumber!)'") }
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
        if legacyOrder.deliverySequence != nil { error("deliverySequence = '\(legacyOrder.deliverySequence!)'") }
        if legacyOrder.orderDEXStatus != nil && legacyOrder.orderDEXStatus != .NotApplicable { error("orderDEXStatus = '\(legacyOrder.orderDEXStatus!)'") }
        if legacyOrder.isForPlanogramReset != false { error("isForPlanogramReset = '\(legacyOrder.isForPlanogramReset)'") }
        if legacyOrder.manualHold != false { error("manualHold = '\(legacyOrder.manualHold)'") }
        if legacyOrder.pushOffDate != nil { error("pushOffDate = '\(legacyOrder.pushOffDate!)'") }
        if legacyOrder.drvEmpNid != nil { error("drvEmpNid = '\(legacyOrder.drvEmpNid!)'") }
        if legacyOrder.slsEmpNid != nil { error("slsEmpNid = '\(legacyOrder.slsEmpNid!)'") }
        if legacyOrder.orderTypeNid != nil { error("orderTypeNid = '\(legacyOrder.orderTypeNid!)'") }
        if legacyOrder.isBillAndHold != false { error("isBillAndHold = '\(legacyOrder.isBillAndHold)'") }
        if legacyOrder.paymentTermsNid != nil { error("paymentTermsNid = '\(legacyOrder.paymentTermsNid!)'") }
        if legacyOrder.isBulkOrder != false { error("isBulkOrder = '\(legacyOrder.isBulkOrder)'") }
        if legacyOrder.isCharge != false { error("isCharge = '\(legacyOrder.isCharge)'") }
        if legacyOrder.isTaxable != false { error("isTaxable = '\(legacyOrder.isTaxable)'") }
        if legacyOrder.usedCombinedForm != false { error("usedCombinedForm = '\(legacyOrder.usedCombinedForm)'") }
        if legacyOrder.isEft != false { error("isEft = '\(legacyOrder.isEft)'") }
        if legacyOrder.poNumber != nil { error("poNumber = '\(legacyOrder.poNumber!)'") }
        if legacyOrder.takenFrom != nil { error("takenFrom = '\(legacyOrder.takenFrom!)'") }
        if legacyOrder.invoiceNote != nil { error("invoiceNote = '\(legacyOrder.invoiceNote!)'") }
        if legacyOrder.packNote != nil { error("packNote = '\(legacyOrder.packNote!)'") }
        if legacyOrder.serializedItems != nil { error("serializedItems = '\(legacyOrder.serializedItems!)'") }
        if legacyOrder.receivedBy != nil { error("receivedBy = '\(legacyOrder.receivedBy!)'") }
        if legacyOrder.pushOffReason != nil { error("pushOffReason = '\(legacyOrder.pushOffReason!)'") }
        if legacyOrder.skipReason != nil { error("skipReason = '\(legacyOrder.skipReason!)'") }
        if legacyOrder.voidReason != nil { error("voidReason = '\(legacyOrder.voidReason!)'") }
        if legacyOrder.offInvoiceDiscPct != nil { error("offInvoiceDiscPct = '\(legacyOrder.offInvoiceDiscPct!)'") }
        if legacyOrder.discountAmt != nil { error("discountAmt = '\(legacyOrder.discountAmt!)'") }
        if legacyOrder.totalFreight != nil { error("totalFreight = '\(legacyOrder.totalFreight!)'") }
        if legacyOrder.isExistingOrder != false { error("isExistingOrder = '\(legacyOrder.isExistingOrder)'") }
        if legacyOrder.printedReviewInvoice != false { error("printedReviewInvoice = '\(legacyOrder.printedReviewInvoice)'") }
        if legacyOrder.voidReasonNid != nil { error("voidReasonNid = '\(legacyOrder.voidReasonNid!)'") }
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

        
        
        // promoDate = legacyOrder.promoDate
        // invoiceNote = legacyOrder.deliveryNote
        // companyNid = legacyOrder.companyNid
        // orderNumber = legacyOrder.orderNumber
        // trkNid = legacyOrder.trkNid
        // isFromDistributor = legacyOrder.isFromDistributor
        // isToDistributor = legacyOrder.isToDistributor
        // deliveryChargeNid = legacyOrder.deliveryChargeNid
        // isAutoDeliveryCharge = legacyOrder.isAutoDeliveryCharge
        // isEarlyPay = legacyOrder.isEarlyPay
        // earlyPayDiscountAmt = legacyOrder.earlyPayDiscountAmt
        // termDiscountDays = legacyOrder.termDiscountDays
        // termDiscountPct = legacyOrder.termDiscountPct
        // heldStatus = legacyOrder.heldStatus
        // isVoided = legacyOrder.isVoided
        // deliveredStatus = legacyOrder.deliveredStatus
        // orderType = legacyOrder.orderType
        // isHotShot = legacyOrder.isHotShot
        // numberSummarized = legacyOrder.numberSummarized
        // summaryOrderNumber = legacyOrder.summaryOrderNumber
        // coopTicketNumber = legacyOrder.coopTicketNumber
        // shipAdr1 = legacyOrder.shipAdr1
        // shipAdr2 = legacyOrder.shipAdr2
        // shipCity = legacyOrder.shipCity
        // shipState = legacyOrder.shipState
        // shipZip = legacyOrder.shipZip
        // doNotChargeUnitFreight = legacyOrder.doNotChargeUnitFreight
        // doNotChargeUnitDeliveryCharge = legacyOrder.doNotChargeUnitDeliveryCharge
        // ignoreDeliveryTruckRestrictions = legacyOrder.ignoreDeliveryTruckRestrictions
        // signatureVectors = legacyOrder.signatureVectors
        // driverSignatureVectors = legacyOrder.driverSignatureVectors
        // isOffScheduleDelivery = legacyOrder.isOffScheduleDelivery
        // isSpecialPaymentTerms = legacyOrder.isSpecialPaymentTerms
        // promoDate = legacyOrder.promoDate
        // authenticatedByNid = legacyOrder.authenticatedByNid
        // authenticatedDate = legacyOrder.authenticatedDate
        // deliveredDate = legacyOrder.deliveredDate
        // deliveredByNid = legacyOrder.deliveredByNid
        // deliveryDocumentDate = legacyOrder.deliveryDocumentDate
        // deliveryDocumentByNid = legacyOrder.deliveryDocumentByNid
        // dispatchedDate = legacyOrder.dispatchedDate
        // dispatchedByNid = legacyOrder.dispatchedByNid
        // ediInvoiceDate = legacyOrder.ediInvoiceDate
        // ediInvoiceByNid = legacyOrder.ediInvoiceByNid
        // ediPaymentDate = legacyOrder.ediPaymentDate
        // ediPaymentByNid = legacyOrder.ediPaymentByNid
        // ediShipNoticeDate = legacyOrder.ediShipNoticeDate
        // ediShipNoticeByNid = legacyOrder.ediShipNoticeByNid
        // enteredDate = legacyOrder.enteredDate
        // enteredByNid = legacyOrder.enteredByNid
        // followupInvoiceDate = legacyOrder.followupInvoiceDate
        // followupInvoiceByNid = legacyOrder.followupInvoiceByNid
        // loadedDate = legacyOrder.loadedDate
        // loadedByNid = legacyOrder.loadedByNid
        // orderedByNid = legacyOrder.orderedByNid
        // palletizedDate = legacyOrder.palletizedDate
        // palletizedByNid = legacyOrder.palletizedByNid
        // pickListDate = legacyOrder.pickListDate
        // pickListByNid = legacyOrder.pickListByNid
        // shippedDate = legacyOrder.shippedDate
        // shippedByNid = legacyOrder.shippedByNid
        // stagedDate = legacyOrder.stagedDate
        // stagedByNid = legacyOrder.stagedByNid
        // verifiedDate = legacyOrder.verifiedDate
        // verifiedByNid = legacyOrder.verifiedByNid
        // voidedDate = legacyOrder.voidedDate
        // voidedByNid = legacyOrder.voidedByNid
        // loadNumber = legacyOrder.loadNumber
        // toEquipNid = legacyOrder.toEquipNid
        // isVendingReplenishment = legacyOrder.isVendingReplenishment
        // replenishmentVendTicketNumber = legacyOrder.replenishmentVendTicketNumber
        // isCoopDeliveryPoint = legacyOrder.isCoopDeliveryPoint
        // coopCusNid = legacyOrder.coopCusNid
        // doNotOptimizePalletsWithLayerRounding = legacyOrder.doNotOptimizePalletsWithLayerRounding
        // returnsValidated = legacyOrder.returnsValidated
        // POAAmount = legacyOrder.POAAmount
        // POAExpected = legacyOrder.POAExpected
        // includeChargeOrderInTotalDue = legacyOrder.includeChargeOrderInTotalDue
        // deliverySequence = legacyOrder.deliverySequence
        // orderDEXStatus = legacyOrder.orderDEXStatus
        // isForPlanogramReset = legacyOrder.isForPlanogramReset
        // manualHold = legacyOrder.manualHold
        // pushOffDate = legacyOrder.pushOffDate
        // drvEmpNid = legacyOrder.drvEmpNid
        // slsEmpNid = legacyOrder.slsEmpNid
        // orderTypeNid = legacyOrder.orderTypeNid
        // isBillAndHold = legacyOrder.isBillAndHold
        // paymentTermsNid = legacyOrder.paymentTermsNid
        // isBulkOrder = legacyOrder.isBulkOrder
        // isCharge = legacyOrder.isCharge
        // isTaxable = legacyOrder.isTaxable
        // usedCombinedForm = legacyOrder.usedCombinedForm
        // isEft = legacyOrder.isEft
        // poNumber = legacyOrder.poNumber
        // takenFrom = legacyOrder.takenFrom
        // invoiceNote = legacyOrder.invoiceNote
        // packNote = legacyOrder.packNote
        // serializedItems = legacyOrder.serializedItems
        // receivedBy = legacyOrder.receivedBy
        // pushOffReason = legacyOrder.pushOffReason
        // skipReason = legacyOrder.skipReason
        // voidReason = legacyOrder.voidReason
        // offInvoiceDiscPct = legacyOrder.offInvoiceDiscPct
        // discountAmt = legacyOrder.discountAmt
        // totalFreight = legacyOrder.totalFreight
        // isExistingOrder = legacyOrder.isExistingOrder
        // printedReviewInvoice = legacyOrder.printedReviewInvoice
        // voidReasonNid = legacyOrder.voidReasonNid
        // entryTime = legacyOrder.entryTime
        // deliveredByHandheld = legacyOrder.deliveredByHandheld
        // isOffTruck = legacyOrder.isOffTruck
        // isFromBlobbing = legacyOrder.isFromBlobbing
        // salesTax = legacyOrder.salesTax
        // salesTaxState = legacyOrder.salesTaxState
        // salesTaxStateB = legacyOrder.salesTaxStateB
        // salesTaxStateC = legacyOrder.salesTaxStateC
        // salesTaxCounty = legacyOrder.salesTaxCounty
        // salesTaxCity = legacyOrder.salesTaxCity
        // salesTaxLocal = legacyOrder.salesTaxLocal
        // salesTaxWholesale = legacyOrder.salesTaxWholesale
        // VAT = legacyOrder.VAT
        // levy = legacyOrder.levy


    }
}
    
