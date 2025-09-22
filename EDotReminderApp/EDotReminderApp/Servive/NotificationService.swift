//
//  NotificationService.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import Foundation
import UserNotifications
import UIKit

protocol NotificationService {
    func requestAuthorization() async throws -> Bool
    func scheduleDailyReminder(id: String, title: String, date: Date) async throws
    func cancelReminder(id: String) async
}

final class UNNotificationService: NotificationService {
    private let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleDailyReminder(id: String, title: String, date: Date) async throws {
        let fireDate = Calendar.current.date(byAdding: .minute, value: -10, to: date) ?? date
        let comps = Calendar.current.dateComponents([.hour, .minute], from: fireDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "It's time to do \(title)"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let err = error {
                    cont.resume(throwing: err)
                } else {
                    cont.resume(returning: ())
                }
            }
        }
    }
    
    func cancelReminder(id: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
}

