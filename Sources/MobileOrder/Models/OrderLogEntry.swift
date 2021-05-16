//
//  File.swift
//  
//
//  Created by Michael Rutherford on 5/15/21.
//

import Foundation
import MobileLegacyOrder

public struct OrderLogEntry: Codable {
    var logEntryType: OrderLogEntryType
    var time: Date
    var empNid: Int
}

public enum OrderLogEntryType: Int, Codable {
    //case Ordered - every order *must* have an orderedDate - for other log entries, the date is optional
    case Authenticated
    case Delivered
    case DeliveryDocument
    case Dispatched
    case EdiInvoice
    case EdiPayment
    case EdiShipNotice
    case Entered
    case FollowupInvoice
    case Loaded
    case OTLCommit
    case Palletized
    case PickList
    case Shipped
    case Staged
    case Verified
    //case Voided - when an order is voided, there must be a reason it's voided (also, we track qtyShippedWhenVoided)
}

var old1970 = Date(timeIntervalSince1970: 0) // we use DateTime.MinValue in c#

extension LegacyOrder {
    
    func getLogEntriesFromLegacyOrder() -> [OrderLogEntry] {
        
        var entries: [OrderLogEntry] = []
        
        func add(_ logEntryType: OrderLogEntryType, time: Date?, empNid: Int?) {
            if let empNid = empNid, empNid > 0, let time = time, time >= old1970 {
                entries.append(OrderLogEntry(logEntryType: logEntryType, time: time, empNid: empNid))
            }
        }
        
        //add(.Ordered, time: orderedDate, empNid: orderedByNid)
        
        add(.Authenticated, time: authenticatedDate, empNid: authenticatedByNid)
        add(.Delivered, time: deliveredDate, empNid: drvEmpNid)
        add(.DeliveryDocument, time: deliveredDate, empNid: deliveryDocumentByNid)
        add(.Dispatched, time: dispatchedDate, empNid: dispatchedByNid)
        add(.EdiInvoice, time: ediInvoiceDate, empNid: ediInvoiceByNid)
        add(.EdiPayment, time: ediPaymentDate, empNid: ediPaymentByNid)
        add(.EdiShipNotice, time: ediShipNoticeDate, empNid: ediShipNoticeByNid)
        add(.Entered, time: enteredDate, empNid: enteredByNid)
        add(.FollowupInvoice, time: followupInvoiceDate, empNid: followupInvoiceByNid)
        add(.Loaded, time: loadedDate, empNid: loadedByNid)
        add(.Palletized, time: palletizedDate, empNid: palletizedByNid)
        add(.PickList, time: pickListDate, empNid: pickListByNid)
        add(.Shipped, time: shippedDate, empNid: shippedByNid)
        add(.Staged, time: stagedDate, empNid: stagedByNid)
        add(.Verified, time: verifiedDate, empNid: verifiedByNid)
        
        //add(.Voided, time: voidedDate, empNid: voidedByNid)
        
        //addLogEntry(.OTLCommit, time: otlCommitDate, empNid: otlCommitByNid)
        // mpr: voided needs the voidReasonNid
        
        return entries
    }
    
    func applyLogEntriesToLegacyOrder(logEntries: [OrderLogEntry]) {

        for entry in logEntries {
            let time = entry.time
            let empNid = entry.empNid
            
            switch entry.logEntryType {
            case .Authenticated:
                authenticatedDate = time
                authenticatedByNid = empNid
            case .Delivered:
                deliveredDate = time
                deliveredByNid = empNid
            case .DeliveryDocument:
                deliveryDocumentDate = time
                deliveryDocumentByNid = empNid
            case .Dispatched:
                dispatchedDate = time
                dispatchedByNid = empNid
            case .EdiInvoice:
                ediInvoiceDate = time
                ediInvoiceByNid = empNid
            case .EdiPayment:
                ediPaymentDate = time
                ediPaymentByNid = empNid
            case .EdiShipNotice:
                ediShipNoticeDate = time
                ediShipNoticeByNid = empNid
            case .Entered:
                enteredDate = time
                enteredByNid = empNid
            case .FollowupInvoice:
                followupInvoiceDate = time
                followupInvoiceByNid = empNid
            case .Loaded:
                loadedDate = time
                loadedByNid = empNid
            case .OTLCommit:
                break//TODO
            case .Palletized:
                palletizedDate = time
                palletizedByNid = empNid
            case .PickList:
                pickListDate = time
                pickListByNid = empNid
            case .Shipped:
                shippedDate = time
                shippedByNid = empNid
            case .Staged:
                stagedDate = time
                stagedByNid = empNid
            case .Verified:
                verifiedDate = time
                verifiedByNid = empNid
            }
        }
    }
    
}
