//
//  EDotReminderAppApp.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import SwiftUI

@main
struct EDotReminderAppApp: App {
    init() {
        // Register services
        ServiceLocator.shared.register(HabitRepository.self, service: CoreDataHabitRepository())
        ServiceLocator.shared.register(NotificationService.self, service: UNNotificationService())
    }
    
    var body: some Scene {
        WindowGroup {
            HabitListView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }
}
