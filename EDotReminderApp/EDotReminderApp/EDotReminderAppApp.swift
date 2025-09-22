//
//  EDotReminderAppApp.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import SwiftUI

@main
struct EDotReminderAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
