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

final class UNNotificationService: NSObject, NotificationService {
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleDailyReminder(id: String, title: String, date: Date) async throws {
        let fireDate = Calendar.current.date(byAdding: .minute, value: -10, to: date) ?? date
        let comps = Calendar.current.dateComponents([.day ,.hour, .minute, .second], from: fireDate)
        
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

extension UNNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}


