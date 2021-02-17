//
//  PresellOrderService.swift
//  MobileBench (iOS)
//
//  Created by Michael Rutherford on 10/3/20.
//

import Foundation

public struct PresellOrderService {
    public static func getSoonestDeliveryDate() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: 1), to: Date()) ?? Date()
    }
}
